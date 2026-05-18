"""
KeepUp Gemma 4 Moderation Service

Privacy boundary: student message content is moderated and translated ON-DEVICE by Gemma 4 E4B
in the mobile app. These endpoints handle coach/AD/admin-authored content only — no student
message content is ever sent server-side.
"""

import os
import io
import re
import json
import base64
import logging
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Optional

import torch
from fastapi import FastAPI, HTTPException
from PIL import Image
from pydantic import BaseModel, Field
from transformers import AutoProcessor, AutoModelForImageTextToText

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

from auto_flags import GROOMING_ANY as _GROOMING_ANY, GROOMING_ADULT_TO_MINOR as _GROOMING_ADULT_TO_MINOR
from better_profanity import profanity as _profanity

_profanity.load_censor_words()

_LEET = str.maketrans({
    '4': 'a', '@': 'a', '^': 'a',
    '3': 'e',
    '1': 'i', '!': 'i', '|': 'i',
    '0': 'o',
    '5': 's', '$': 's',
    '6': 'g', '9': 'g',
    '7': 't', '+': 't',
    '8': 'b',
    '2': 'z',
})


def _norm_token(token: str) -> str:
    return re.sub(r'[^a-z]', '', token.lower().translate(_LEET))


def _slur_prefilter(content: str) -> "ModerateResponse | None":
    tokens = re.split(r'\s+', content.strip())
    norms  = [_norm_token(t) for t in tokens if t]

    if _profanity.contains_profanity(' '.join(norms)) or _profanity.contains_profanity(content):
        return _slur_hit()

    for window in range(2, 11):
        for i in range(len(norms) - window + 1):
            chunk = norms[i:i + window]
            if all(len(c) == 1 for c in chunk) and _profanity.contains_profanity(''.join(chunk)):
                return _slur_hit()

    return None


def _slur_hit() -> "ModerateResponse":
    return ModerateResponse(
        flagged=True,
        score=1.0,
        tier="severe",
        categories=["hate_speech"],
        reason="Message contains a slur or a variation of one.",
    )


MODEL_ID = os.getenv("GEMMA_MODEL_ID", "google/gemma-4-E4B-it")

# MPS requires attn_implementation="eager" — the fused SDPA kernel crashes on certain Gemma 4 tensor shapes.
if os.getenv("GEMMA_DEVICE"):
    DEVICE = os.getenv("GEMMA_DEVICE")
elif torch.cuda.is_available():
    DEVICE = "cuda"
elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
    DEVICE = "mps"
else:
    DEVICE = "cpu"

_DTYPE = torch.bfloat16 if DEVICE in ("cuda", "mps") else torch.float32

_processor = None
_model     = None

_theme_cache: dict[str, dict] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _processor, _model

    logger.info(f"Loading Gemma 4 from {MODEL_ID} on {DEVICE} ({_DTYPE})")

    _processor = AutoProcessor.from_pretrained(MODEL_ID)

    if DEVICE == "cuda":
        _model = AutoModelForImageTextToText.from_pretrained(
            MODEL_ID,
            device_map="auto",
            torch_dtype=_DTYPE,
        )
    elif DEVICE == "mps":
        _model = AutoModelForImageTextToText.from_pretrained(
            MODEL_ID,
            torch_dtype=_DTYPE,
            attn_implementation="eager",
            low_cpu_mem_usage=True,
        ).to(DEVICE)
    else:
        _model = AutoModelForImageTextToText.from_pretrained(
            MODEL_ID,
            torch_dtype=_DTYPE,
            low_cpu_mem_usage=True,
        ).to(DEVICE)

    logger.info("Gemma 4 loaded and ready")
    yield

    del _processor, _model


app = FastAPI(
    title="KeepUp Gemma 4 Moderation Service",
    version="1.0.0",
    lifespan=lifespan,
)


def _generate_text(
    messages: list[dict],
    max_new_tokens: int = 256,
    do_sample: bool = False,
    temperature: float | None = None,
    top_p: float | None = None,
) -> str:
    inputs = _processor.apply_chat_template(
        messages,
        add_generation_prompt=True,
        tokenize=True,
        return_dict=True,
        return_tensors="pt",
    ).to(DEVICE)
    gen_kwargs: dict = {"max_new_tokens": max_new_tokens, "do_sample": do_sample}
    if temperature is not None:
        gen_kwargs["temperature"] = temperature
    if top_p is not None:
        gen_kwargs["top_p"] = top_p
    with torch.inference_mode():
        output_ids = _model.generate(**inputs, **gen_kwargs)
    input_len = inputs["input_ids"].shape[-1]
    return _processor.decode(output_ids[0][input_len:], skip_special_tokens=True)


class ModerateRequest(BaseModel):
    content: str = Field(..., description="Message text to evaluate")
    sender_role: str = Field(..., description="Role of sender: student, coach, parent, admin")
    conversation_context: Optional[str] = Field(
        None, description="Serialized recent messages for context (non-student paths only)"
    )


class ModerateResponse(BaseModel):
    flagged: bool
    score: float = Field(..., ge=0.0, le=1.0)
    tier: str = Field(..., description="clear | questionable | severe")
    categories: list[str]
    reason: Optional[str]


class AccessLogEntry(BaseModel):
    accessor_id: int
    accessor_role: str
    accessed_user_id: int
    resource_type: Optional[str]
    resource_id: Optional[int]
    sport_id: Optional[int]
    accessed_at: str


class AnalyzeAccessRequest(BaseModel):
    current_log: AccessLogEntry
    recent_logs: list[AccessLogEntry] = Field(
        ..., description="Last 50 access log entries by this accessor, newest first"
    )


class AnalyzeAccessResponse(BaseModel):
    anomaly_flagged: bool
    anomaly_score: float = Field(..., ge=0.0, le=1.0)
    anomaly_reason: Optional[str]
    patterns_detected: list[str]


class ModerateEmojiRequest(BaseModel):
    image_url: Optional[str] = Field(None, description="Public URL of the submitted image")
    image_base64: Optional[str] = Field(None, description="Base64-encoded image (fallback)")
    emoji_name: str
    sport_id: int
    requested_by_role: str


class ModerateEmojiResponse(BaseModel):
    approved_for_queue: bool
    score: float = Field(..., ge=0.0, le=1.0)
    reason: Optional[str]
    categories: list[str]


class TranslateRequest(BaseModel):
    text: str = Field(..., description="Coach/AD-authored text to translate")
    target_language: str = Field(
        ...,
        description="Target language name (e.g. 'French', 'Arabic', 'Japanese')"
    )
    source_language: str = Field("en", description="Source language code (default: en)")
    context: str = Field(
        "message",
        description="Content register hint: announcement | message. Affects tone."
    )


class TranslateResponse(BaseModel):
    translated_text: str
    source_language: str
    target_language: str
    language_name: str


class MeetHighlight(BaseModel):
    athlete: str
    event: str
    time: Optional[str] = None
    pr: bool = False


class SummarizeMeetRequest(BaseModel):
    sport: str
    home_school: str
    away_school: str
    home_score: int
    away_score: int
    venue: Optional[str] = None
    date: Optional[str] = None
    highlights: list[MeetHighlight] = []


class SummarizeMeetResponse(BaseModel):
    summary: str
    focus_athlete: Optional[str] = None
    focus_event: Optional[str] = None


class GenerateThemeRequest(BaseModel):
    school_colors: str = Field(..., description="Plain-language description of school colors, e.g. 'purple and white'")
    school_name: Optional[str] = Field(None, description="School name for context")

class ThemePalette(BaseModel):
    color_background:      str
    color_surface:         str
    color_surface_variant: str
    color_border:          str
    color_primary:         str
    color_accent:          str
    color_text_primary:    str
    color_text_secondary:  str
    color_text_on_primary: str
    color_text_on_accent:  str

class GenerateThemeResponse(BaseModel):
    dark:  ThemePalette
    light: ThemePalette


def _build_grooming_examples() -> str:
    lines = ["Concerning regardless of sender role:"]
    for category, phrases in _GROOMING_ANY.items():
        label = category.replace("_", " ")
        examples = "; ".join(f'"{p}"' for p in phrases[:4])
        lines.append(f"  - {label}: {examples}")

    lines.append("Concerning only when sender is a coach, admin, or adult (normal between peers):")
    for category, phrases in _GROOMING_ADULT_TO_MINOR.items():
        label = category.replace("_", " ")
        examples = "; ".join(f'"{p}"' for p in phrases[:4])
        lines.append(f"  - {label}: {examples}")

    return "\n".join(lines)


MODERATION_SYSTEM_PROMPT = f"""You are a content safety classifier for KeepUp, a sports communication
platform used by high school students aged 14–18. Your job is to evaluate messages for safety.

Respond with a JSON object only — no prose, no markdown, no explanation outside the JSON.

JSON schema:
{{
  "score": <float 0.0–1.0, where 0 = completely safe, 1 = extremely harmful>,
  "categories": <array of strings from: ["violence", "harassment", "grooming", "explicit", "bullying", "self_harm", "hate_speech", "none"]>,
  "reason": <one sentence explanation if score > 0, else null>
}}

Scoring guide:
- 0.00–0.39: Safe or clearly benign (even if edgy humor between peers)
- 0.40–0.74: Potentially harmful — context-dependent, could be a joke or could be a problem
- 0.75–1.00: Clearly harmful — threats, explicit grooming language, graphic violence, explicit content
- Slurs, hate speech, or derogatory language targeting race, gender, sexuality, or disability: 0.90–1.00 regardless of context. This includes leet-speak and character-substitution variants — treat them identically to the plain form.
- Grooming patterns from a coach or adult to a student: 0.85–1.00

Grooming patterns to watch for (score higher when sender is coach/admin, still flag when student-to-student):
{_build_grooming_examples()}

Err on the side of caution for any adult-to-student content involving power dynamics.
A coach using pressure tactics or boundary-crossing language scores higher than the same words between peers."""

ACCESS_ANALYSIS_SYSTEM_PROMPT = """You are a behavioral anomaly detector for KeepUp, a school sports
platform. You analyze access log patterns to detect suspicious admin behavior.

Suspicious patterns include:
- Repeated access to the same student's DMs with no documented reason
- Accessing one student's history multiple times in a short window
- Access at unusual hours (before 6am or after 11pm in any US timezone)
- Consistent targeting of one specific student across many sessions
- A coach reviewing DMs of students not on their team

Respond with a JSON object only.

JSON schema:
{
  "anomaly_score": <float 0.0–1.0, where 0 = normal, 1 = highly suspicious>,
  "patterns_detected": <array of short pattern description strings, empty if none>,
  "reason": <one sentence summary if anomaly_score > 0.3, else null>
}"""

TRANSLATION_SYSTEM_PROMPT = """You are a translator for KeepUp, a high school sports communication
platform. You translate messages from coaches and athletic staff so that families who speak other
languages can read them.

Rules:
- Output ONLY the translated text. No preamble, no explanation, no quotes around the output.
- Preserve the original tone and formatting (line breaks, punctuation, capitalization).
- Use clear, plain language — parents reading this may not be fluent.
- For announcements, use slightly formal phrasing. For messages, use conversational phrasing.
- Never add information that was not in the original.
- If the input contains a proper noun (school name, coach name, sport name), keep it as-is."""

EMOJI_MODERATION_SYSTEM_PROMPT = """You are an image content classifier for KeepUp, a sports
communication platform used by high school students aged 14–18.

A student has submitted a custom sport emoji image. Your job is to determine whether the image
is appropriate for a school-facing platform.

Reject images containing: nudity, graphic violence, drug/alcohol references, hate symbols,
offensive gestures, or any content inappropriate for a school environment.

Approve images that are: sport-related, team symbols, mascots, celebratory, or generally
appropriate for a school sports app.

Respond with a JSON object only.

JSON schema:
{
  "score": <float 0.0–1.0, where 0 = clearly appropriate, 1 = clearly inappropriate>,
  "categories": <array of strings from: ["nudity", "violence", "drugs", "hate_symbol", "offensive_gesture", "inappropriate", "none"]>,
  "reason": <one sentence if score > 0.3, else null>
}"""

THEME_GENERATION_SYSTEM_PROMPT = """You are a UI theme designer for KeepUp, a high school sports communication platform. Given a school's colors described in plain language, generate a complete and accessible color theme.

Produce both a dark variant and a light variant. Both must prominently use the school's colors while maintaining excellent readability.

Color slot definitions:
- color_background: Main page background
- color_surface: Card and panel backgrounds (slightly different from background)
- color_surface_variant: Secondary surfaces, muted sections
- color_border: Border and divider color
- color_primary: Primary brand color for buttons and active states — strongly reflect school colors
- color_accent: Complementary accent/highlight color
- color_text_primary: Main text — must have 4.5:1+ contrast on color_surface
- color_text_secondary: Muted text — must have 3:1+ contrast on color_surface
- color_text_on_primary: Text drawn on top of color_primary
- color_text_on_accent: Text drawn on top of color_accent

Requirements:
- All values must be valid 6-digit hex colors (#RRGGBB format)
- Dark variant: very dark backgrounds (lightness < 20%), vibrant primary/accent
- Light variant: light backgrounds (lightness > 92%), rich primary color
- WCAG AA contrast for all text/background pairs
- School colors must be clearly visible in primary and accent slots
- Respond with JSON only — no prose, no markdown outside the JSON

JSON schema:
{
  "dark": {
    "color_background": "#hex", "color_surface": "#hex", "color_surface_variant": "#hex",
    "color_border": "#hex", "color_primary": "#hex", "color_accent": "#hex",
    "color_text_primary": "#hex", "color_text_secondary": "#hex",
    "color_text_on_primary": "#hex", "color_text_on_accent": "#hex"
  },
  "light": {
    "color_background": "#hex", "color_surface": "#hex", "color_surface_variant": "#hex",
    "color_border": "#hex", "color_primary": "#hex", "color_accent": "#hex",
    "color_text_primary": "#hex", "color_text_secondary": "#hex",
    "color_text_on_primary": "#hex", "color_text_on_accent": "#hex"
  }
}"""

def to_palette(d: dict) -> ThemePalette:
    return ThemePalette(
        color_background=d.get("color_background", "#111827"),
        color_surface=d.get("color_surface", "#1f2937"),
        color_surface_variant=d.get("color_surface_variant", "#374151"),
        color_border=d.get("color_border", "#4b5563"),
        color_primary=d.get("color_primary", "#6366f1"),
        color_accent=d.get("color_accent", "#8b5cf6"),
        color_text_primary=d.get("color_text_primary", "#f9fafb"),
        color_text_secondary=d.get("color_text_secondary", "#9ca3af"),
        color_text_on_primary=d.get("color_text_on_primary", "#ffffff"),
        color_text_on_accent=d.get("color_text_on_accent", "#ffffff"),
    )


MEET_SUMMARY_SYSTEM_PROMPT = """You are a high school sports journalist writing brief meet summaries
for KeepUp, a sports communication platform. Given structured meet data, write a 2–4 sentence
summary in an energetic but factual sports-journalism tone.

Rules:
- Lead with the result (winner, score, and whether it was home or away).
- Call out the margin — note if it was dominant, comfortable, or close.
- If highlights are provided, name the standout athlete and their performance.
- End with a brief forward-looking line (season record, upcoming fixture, or positioning).
- Never invent facts not present in the data. If no highlights are provided, skip that sentence.
- Write in past tense. No bullet points. Plain prose only.

Respond with a JSON object only — no prose outside the JSON.

JSON schema:
{
  "summary": <2–4 sentence narrative string>,
  "focus_athlete": <name of the single most notable athlete mentioned, or null>,
  "focus_event": <the event they performed in, or null>
}"""


def _parse_json_response(raw: str) -> dict:
    raw = raw.strip()
    start = raw.find("{")
    end = raw.rfind("}") + 1
    if start == -1 or end == 0:
        raise ValueError(f"No JSON object found in model output: {raw[:200]}")
    return json.loads(raw[start:end])


def _score_to_tier(score: float) -> str:
    if score >= 0.75:
        return "severe"
    if score >= 0.40:
        return "questionable"
    return "clear"


def _load_image(request: ModerateEmojiRequest) -> Image.Image:
    if request.image_base64:
        data = base64.b64decode(request.image_base64)
        return Image.open(io.BytesIO(data)).convert("RGB")
    if request.image_url:
        import httpx
        response = httpx.get(request.image_url, timeout=10)
        response.raise_for_status()
        return Image.open(io.BytesIO(response.content)).convert("RGB")
    raise ValueError("Either image_url or image_base64 must be provided")


@app.post("/moderate", response_model=ModerateResponse)
async def moderate_content(request: ModerateRequest) -> ModerateResponse:
    hit = _slur_prefilter(request.content)
    if hit:
        logger.info(f"/moderate slur prefilter triggered for sender_role={request.sender_role}")
        return hit

    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    prompt = (
        f"Sender role: {request.sender_role}\n"
        f"Message: {request.content}"
    )
    if request.conversation_context:
        prompt = f"Recent context:\n{request.conversation_context}\n\n{prompt}"

    messages = [
        {"role": "system", "content": MODERATION_SYSTEM_PROMPT},
        {"role": "user", "content": prompt},
    ]

    raw = _generate_text(messages, max_new_tokens=256)

    try:
        parsed = _parse_json_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        logger.error(f"/moderate parse error: {e} | raw: {raw[:300]}")
        raise HTTPException(status_code=500, detail="Failed to parse model response")

    score = float(parsed.get("score", 0.0))
    score = max(0.0, min(1.0, score))
    tier = _score_to_tier(score)

    return ModerateResponse(
        flagged=score >= 0.40,
        score=score,
        tier=tier,
        categories=parsed.get("categories", ["none"]),
        reason=parsed.get("reason"),
    )


@app.post("/analyze_access", response_model=AnalyzeAccessResponse)
async def analyze_access(request: AnalyzeAccessRequest) -> AnalyzeAccessResponse:
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    log_summary = _format_access_logs(request.current_log, request.recent_logs)

    messages = [
        {"role": "system", "content": ACCESS_ANALYSIS_SYSTEM_PROMPT},
        {"role": "user", "content": f"Analyze this access pattern:\n\n{log_summary}"},
    ]

    raw = _generate_text(messages, max_new_tokens=256)

    try:
        parsed = _parse_json_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        logger.error(f"/analyze_access parse error: {e} | raw: {raw[:300]}")
        raise HTTPException(status_code=500, detail="Failed to parse model response")

    score = float(parsed.get("anomaly_score", 0.0))
    score = max(0.0, min(1.0, score))

    return AnalyzeAccessResponse(
        anomaly_flagged=score >= 0.40,
        anomaly_score=score,
        anomaly_reason=parsed.get("reason"),
        patterns_detected=parsed.get("patterns_detected", []),
    )


@app.post("/moderate_emoji", response_model=ModerateEmojiResponse)
async def moderate_emoji(request: ModerateEmojiRequest) -> ModerateEmojiResponse:
    if _model is None or _processor is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    try:
        image = _load_image(request)
    except Exception as e:
        logger.error(f"/moderate_emoji image load error: {e}")
        raise HTTPException(status_code=422, detail=f"Could not load image: {e}")

    prompt_text = (
        f"A student submitted this image as a custom sport emoji named '{request.emoji_name}' "
        f"for a high school sports app. Evaluate whether it is appropriate for a school environment."
    )

    messages = [
        {
            "role": "user",
            "content": [
                {"type": "image", "image": image},
                {"type": "text", "text": f"{EMOJI_MODERATION_SYSTEM_PROMPT}\n\n{prompt_text}"},
            ],
        }
    ]

    inputs = _processor.apply_chat_template(
        messages,
        add_generation_prompt=True,
        tokenize=True,
        return_dict=True,
        return_tensors="pt",
    ).to(_model.device)

    with torch.inference_mode():
        output_ids = _model.generate(
            **inputs,
            max_new_tokens=256,
            do_sample=False,
        )

    input_len = inputs["input_ids"].shape[-1]
    raw = _processor.decode(output_ids[0][input_len:], skip_special_tokens=True)

    try:
        parsed = _parse_json_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        logger.error(f"/moderate_emoji parse error: {e} | raw: {raw[:300]}")
        raise HTTPException(status_code=500, detail="Failed to parse model response")

    score = float(parsed.get("score", 0.0))
    score = max(0.0, min(1.0, score))

    return ModerateEmojiResponse(
        approved_for_queue=score < 0.40,
        score=score,
        reason=parsed.get("reason"),
        categories=parsed.get("categories", ["none"]),
    )


@app.post("/translate", response_model=TranslateResponse)
async def translate_content(request: TranslateRequest) -> TranslateResponse:
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    language_name = request.target_language
    register      = "formal" if request.context == "announcement" else "conversational"

    user_prompt = (
        f"Translate the following {register} English text into {language_name}.\n\n"
        f"{request.text}"
    )

    messages = [
        {"role": "system", "content": TRANSLATION_SYSTEM_PROMPT},
        {"role": "user",   "content": user_prompt},
    ]

    translated = _generate_text(messages, max_new_tokens=1024).strip()

    if not translated:
        logger.error(f"/translate empty output for target={request.target_language}")
        raise HTTPException(status_code=500, detail="Model returned empty translation")

    return TranslateResponse(
        translated_text=translated,
        source_language=request.source_language,
        target_language=request.target_language,
        language_name=language_name,
    )


@app.post("/summarize_meet", response_model=SummarizeMeetResponse)
async def summarize_meet(request: SummarizeMeetRequest) -> SummarizeMeetResponse:
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    home_wins  = request.home_score >= request.away_score
    winner     = request.home_school if home_wins else request.away_school
    loser      = request.away_school if home_wins else request.home_school
    location   = "home" if home_wins else "road"
    margin     = abs(request.home_score - request.away_score)

    hl_lines = []
    for h in request.highlights:
        line = f"{h.athlete} — {h.event}"
        if h.time:
            line += f": {h.time}"
        if h.pr:
            line += " (PR)"
        hl_lines.append(line)

    user_prompt = (
        f"Sport: {request.sport}\n"
        f"Result: {winner} defeated {loser} {max(request.home_score, request.away_score)}–"
        f"{min(request.home_score, request.away_score)} ({location} meet, margin: {margin} points)\n"
    )
    if request.venue:
        user_prompt += f"Venue: {request.venue}\n"
    if request.date:
        user_prompt += f"Date: {request.date}\n"
    if hl_lines:
        user_prompt += "Standout performances:\n" + "\n".join(f"  - {l}" for l in hl_lines) + "\n"

    messages = [
        {"role": "system", "content": MEET_SUMMARY_SYSTEM_PROMPT},
        {"role": "user",   "content": user_prompt},
    ]

    raw = _generate_text(messages, max_new_tokens=512)

    try:
        parsed = _parse_json_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        logger.error(f"/summarize_meet parse error: {e} | raw: {raw[:300]}")
        raise HTTPException(status_code=500, detail="Failed to parse model response")

    return SummarizeMeetResponse(
        summary=parsed.get("summary", "").strip(),
        focus_athlete=parsed.get("focus_athlete"),
        focus_event=parsed.get("focus_event"),
    )


@app.post("/generate_theme", response_model=GenerateThemeResponse)
async def generate_theme(request: GenerateThemeRequest) -> GenerateThemeResponse:
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    cache_key = f"{(request.school_name or '').lower()}|{request.school_colors.lower().strip()}"
    if cache_key in _theme_cache:
        logger.info(f"/generate_theme cache hit: {cache_key!r}")
        cached = _theme_cache[cache_key]
        return GenerateThemeResponse(dark=to_palette(cached.get("dark", {})), light=to_palette(cached.get("light", {})))

    context = f"School: {request.school_name}\n" if request.school_name else ""
    user_prompt = f"{context}School colors: {request.school_colors}"

    messages = [
        {"role": "system", "content": THEME_GENERATION_SYSTEM_PROMPT},
        {"role": "user",   "content": user_prompt},
    ]

    raw = _generate_text(messages, max_new_tokens=350)

    try:
        parsed = _parse_json_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        logger.error(f"/generate_theme parse error: {e} | raw: {raw[:300]}")
        raise HTTPException(status_code=500, detail="Failed to parse model response")

    _theme_cache[cache_key] = parsed

    return GenerateThemeResponse(
        dark=to_palette(parsed.get("dark", {})),
        light=to_palette(parsed.get("light", {})),
    )


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "model": MODEL_ID,
        "device": DEVICE,
        "dtype": str(_DTYPE),
        "model_loaded": _model is not None,
    }


def _format_access_logs(current: AccessLogEntry, recent: list[AccessLogEntry]) -> str:
    lines = [
        "=== Current access event ===",
        f"Accessor ID: {current.accessor_id} | Role: {current.accessor_role}",
        f"Accessed user ID: {current.accessed_user_id}",
        f"Resource: {current.resource_type} #{current.resource_id}",
        f"Sport ID: {current.sport_id}",
        f"Time: {current.accessed_at}",
        "",
        f"=== Recent access history (last {len(recent)} events by same accessor) ===",
    ]
    for log in recent[:50]:
        lines.append(
            f"  [{log.accessed_at}] accessed_user={log.accessed_user_id} "
            f"resource={log.resource_type}#{log.resource_id} sport={log.sport_id}"
        )
    return "\n".join(lines)

"""
KeepUp Gemma 4 Moderation Service

Exposes four endpoints called by the Rails backend:
  POST /moderate        - Reference implementation of on-device text moderation (Role 1)
  POST /analyze_access  - Behavioral anomaly detection on access log patterns (Role 2)
  POST /moderate_emoji  - Multimodal image moderation for sport emoji submissions (Role 3)
  POST /translate       - Coach/AD content translation for multilingual families (Role 4)

IMPORTANT — Role 1 & 4 privacy boundary:
  Student message content is moderated and translated ON-DEVICE by Gemma 4 E4B running in
  the mobile app. These endpoints are used only for coach/AD/admin-authored content where
  server-side processing is COPPA-safe (no student message content ever sent server-side).
"""

import os
import io
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
from transformers import AutoProcessor, AutoModelForImageTextToText, pipeline

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MODEL_ID = os.getenv("GEMMA_MODEL_ID", "google/gemma-3-4b-it")
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

_text_pipeline = None

_vision_processor = None
_vision_model = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _text_pipeline, _vision_processor, _vision_model

    logger.info(f"Loading Gemma 4 from {MODEL_ID} on {DEVICE}")

    _text_pipeline = pipeline(
        "text-generation",
        model=MODEL_ID,
        device_map="auto",
        torch_dtype=torch.bfloat16,
    )

    _vision_processor = AutoProcessor.from_pretrained(MODEL_ID)
    _vision_model = AutoModelForImageTextToText.from_pretrained(
        MODEL_ID,
        device_map="auto",
        torch_dtype=torch.bfloat16,
    )

    logger.info("Gemma 4 loaded and ready")
    yield

    del _text_pipeline, _vision_processor, _vision_model


app = FastAPI(
    title="KeepUp Gemma 4 Moderation Service",
    version="1.0.0",
    lifespan=lifespan,
)


# ---------------------------------------------------------------------------
# Request / response schemas
# ---------------------------------------------------------------------------

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


SUPPORTED_LANGUAGES: dict[str, str] = {
    "es":    "Spanish",
    "zh-CN": "Mandarin Chinese (Simplified)",
}


class TranslateRequest(BaseModel):
    text: str = Field(..., description="Coach/AD-authored text to translate")
    target_language: str = Field(
        ...,
        description=f"BCP-47 target language code. Supported: {', '.join(SUPPORTED_LANGUAGES)}"
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


# ---------------------------------------------------------------------------
# Prompt builders
# ---------------------------------------------------------------------------

MODERATION_SYSTEM_PROMPT = """You are a content safety classifier for KeepUp, a sports communication
platform used by high school students aged 14–18. Your job is to evaluate messages for safety.

Respond with a JSON object only — no prose, no markdown, no explanation outside the JSON.

JSON schema:
{
  "score": <float 0.0–1.0, where 0 = completely safe, 1 = extremely harmful>,
  "categories": <array of strings from: ["violence", "harassment", "grooming", "explicit", "bullying", "self_harm", "none"]>,
  "reason": <one sentence explanation if score > 0, else null>
}

Scoring guide:
- 0.00–0.39: Safe or clearly benign (even if edgy humor between peers)
- 0.40–0.74: Potentially harmful — context-dependent, could be a joke or could be a problem
- 0.75–1.00: Clearly harmful — threats, explicit grooming language, graphic violence, explicit content

Err on the side of caution for any adult-to-student or student-to-student content involving
power dynamics. A coach using pressure tactics scores higher than the same words between peers."""

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


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _parse_json_response(raw: str) -> dict:
    """Extract JSON from a model response that may contain surrounding text."""
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


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.post("/moderate", response_model=ModerateResponse)
async def moderate_content(request: ModerateRequest) -> ModerateResponse:
    """
    Role 1 — Text content moderation.

    Reference implementation of the on-device Gemma 4 E4B logic that runs in the mobile app.
    For student message paths, this is called on-device only — never server-side with student content.
    """
    if _text_pipeline is None:
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

    output = _text_pipeline(
        messages,
        max_new_tokens=256,
        do_sample=False,
        temperature=None,
        top_p=None,
    )
    raw = output[0]["generated_text"][-1]["content"]

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
    """
    Role 2 — Behavioral anomaly detection on access log patterns.
    Called server-side by Rails after every access log write (via background job).
    Analyzes metadata only — no message content is processed here.
    """
    if _text_pipeline is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    log_summary = _format_access_logs(request.current_log, request.recent_logs)

    messages = [
        {"role": "system", "content": ACCESS_ANALYSIS_SYSTEM_PROMPT},
        {"role": "user", "content": f"Analyze this access pattern:\n\n{log_summary}"},
    ]

    output = _text_pipeline(
        messages,
        max_new_tokens=256,
        do_sample=False,
        temperature=None,
        top_p=None,
    )
    raw = output[0]["generated_text"][-1]["content"]

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
    """
    Role 3 — Multimodal image moderation for sport emoji submissions.
    Called server-side by Rails when a student submits a custom sport emoji.
    Gemma pre-filters the image before it enters the human approval queue.
    """
    if _vision_model is None or _vision_processor is None:
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

    inputs = _vision_processor.apply_chat_template(
        messages,
        add_generation_prompt=True,
        tokenize=True,
        return_dict=True,
        return_tensors="pt",
    ).to(_vision_model.device)

    with torch.inference_mode():
        output_ids = _vision_model.generate(
            **inputs,
            max_new_tokens=256,
            do_sample=False,
        )

    input_len = inputs["input_ids"].shape[-1]
    raw = _vision_processor.decode(output_ids[0][input_len:], skip_special_tokens=True)

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
    """
    Role 4 — Coach/AD content translation for multilingual families.

    COPPA boundary: only coach, AD, and school-admin-authored content is sent here.
    Student message translation runs on-device in the mobile app — never server-side.

    Supported target languages: es (Spanish), zh-CN (Mandarin Chinese Simplified).
    """
    if _text_pipeline is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    if request.target_language not in SUPPORTED_LANGUAGES:
        raise HTTPException(
            status_code=422,
            detail=f"Unsupported language '{request.target_language}'. "
                   f"Supported: {', '.join(SUPPORTED_LANGUAGES)}"
        )

    language_name = SUPPORTED_LANGUAGES[request.target_language]
    source_name   = SUPPORTED_LANGUAGES.get(request.source_language, "English")
    register      = "formal" if request.context == "announcement" else "conversational"

    user_prompt = (
        f"Translate the following {register} {source_name} text into {language_name}.\n\n"
        f"{request.text}"
    )

    messages = [
        {"role": "system", "content": TRANSLATION_SYSTEM_PROMPT},
        {"role": "user",   "content": user_prompt},
    ]

    output = _text_pipeline(
        messages,
        max_new_tokens=1024,
        do_sample=False,
        temperature=None,
        top_p=None,
    )
    translated = output[0]["generated_text"][-1]["content"].strip()

    if not translated:
        logger.error(f"/translate empty output for target={request.target_language}")
        raise HTTPException(status_code=500, detail="Model returned empty translation")

    return TranslateResponse(
        translated_text=translated,
        source_language=request.source_language,
        target_language=request.target_language,
        language_name=language_name,
    )


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

@app.get("/health")
async def health():
    return {
        "status": "ok",
        "model": MODEL_ID,
        "device": DEVICE,
        "model_loaded": _text_pipeline is not None,
    }


# ---------------------------------------------------------------------------
# Helpers (continued)
# ---------------------------------------------------------------------------

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

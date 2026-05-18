FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download model weights at build time so the container starts instantly.
# Pass your HuggingFace token: docker build --build-arg HF_TOKEN=hf_...
ARG HF_TOKEN
ARG GEMMA_MODEL_ID=google/gemma-4-E4B-it
ENV HF_HOME=/app/hf_cache
RUN python -c "\
from huggingface_hub import snapshot_download; \
snapshot_download('${GEMMA_MODEL_ID}', token='${HF_TOKEN}')"

COPY main.py auto_flags.py ./

ENV GEMMA_MODEL_ID=google/gemma-4-E4B-it
ENV PORT=8000
# Never download from HuggingFace at runtime — use the baked-in weights
ENV TRANSFORMERS_OFFLINE=1
ENV HF_HUB_OFFLINE=1

EXPOSE $PORT

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]

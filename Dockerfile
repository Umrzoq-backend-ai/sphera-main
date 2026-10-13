# ============================================================
#  Sphera Radio AI — Render.com uchun Multi-stage Dockerfile
#  Stage 1: Frontend build (Node.js + Vite)
#  Stage 2: Backend + Icecast (Python 3.12)
# ============================================================

# ── Stage 1: Frontend ────────────────────────────────────────
FROM node:20-slim AS frontend-builder

WORKDIR /frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci --prefer-offline

# Same-origin deploy: VITE_API_URL bosh = window.location.origin ishlatiladi
RUN printf "VITE_API_URL=\nVITE_WS_URL=\nVITE_RADIO_URL=\nVITE_DEFAULT_CITY=global\n" > .env

COPY frontend/ ./
RUN npm run build


# ── Stage 2: Backend ─────────────────────────────────────────
FROM python:3.12-slim

WORKDIR /app

# ffmpeg, icecast2, curl, build-essential
RUN echo "icecast2 icecast2/icecast-setup boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ffmpeg build-essential icecast2 \
    && rm -rf /var/lib/apt/lists/*

# Python paketlari
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Backend kodi
COPY backend/app ./app

# Frontend build -> /app/static (backend bu yerdan serve qiladi)
COPY --from=frontend-builder /frontend/dist ./static

# Icecast config + entrypoint
COPY backend/icecast.xml /etc/icecast2/icecast.xml
COPY backend/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Foydalanuvchi (root sifatida ishlamaydi)
RUN useradd -m -r appuser && \
    chown -R appuser:appuser /app && \
    mkdir -p /tmp/sphera_audio /tmp/sphera_uploads /var/log/icecast2 && \
    chown -R appuser:appuser /tmp/sphera_audio /tmp/sphera_uploads /var/log/icecast2 /etc/icecast2

USER appuser

ENV MINIAPP_DIR=/app/static
ENV AUDIO_DIR=/tmp/sphera_audio
ENV UPLOAD_DIR=/tmp/sphera_uploads

EXPOSE 8001

CMD ["docker-entrypoint.sh"]

FROM python:3.12-slim

WORKDIR /app

# Bot uchun kerakli paketlar
RUN pip install --no-cache-dir \
    python-telegram-bot==22.7 \
    httpx==0.28.1

COPY . .

CMD ["python", "bot.py"]

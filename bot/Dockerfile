FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    python-telegram-bot==22.7 \
    httpx==0.28.1

COPY . .

# Render free plan: web service kerak, shuning uchun bot + minimal HTTP health server
CMD ["python", "bot.py"]

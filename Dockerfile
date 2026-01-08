FROM python:3.12-slim

WORKDIR /app

# Security & hygiene
RUN adduser --disabled-password --gecos "" appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8000

USER appuser
CMD ["python", "app/main.py"]

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY app.py /app/

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential gcc libpq-dev \
  && python -m pip install --upgrade pip setuptools wheel \
  && pip install flask gunicorn \
  && apt-get purge -y --auto-remove build-essential gcc \
  && rm -rf /var/lib/apt/lists/*

USER root

EXPOSE 8080

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8080", "app:app"]

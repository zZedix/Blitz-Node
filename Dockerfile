ARG PYTHON_IMAGE=python:3.12-slim

FROM ${PYTHON_IMAGE} AS python-base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser && \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY auth.py traffic.py ./

USER appuser

FROM python-base AS auth
EXPOSE 28262
ENTRYPOINT ["python"]
CMD ["auth.py"]

FROM alpine:3.20 AS hysteria
ARG HYSTERIA_VERSION=v2.4.1
RUN apk add --no-cache ca-certificates curl && \
    curl -fsSL -o /usr/local/bin/hysteria "https://github.com/apernet/hysteria/releases/download/${HYSTERIA_VERSION}/hysteria-linux-amd64" && \
    chmod +x /usr/local/bin/hysteria

WORKDIR /etc/hysteria

ENTRYPOINT ["hysteria"]
CMD ["server", "-c", "/etc/hysteria/config.json"]

FROM auth AS app

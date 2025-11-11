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
ARG HYSTERIA_VERSION=latest
ARG TARGETARCH
RUN apk add --no-cache ca-certificates curl && \
    case "${TARGETARCH}" in \
        amd64) H_ARCH="amd64" ;; \
        arm64) H_ARCH="arm64" ;; \
        arm/v7|armv7) H_ARCH="armv7" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    if [ "${HYSTERIA_VERSION}" = "latest" ]; then \
        DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-${H_ARCH}"; \
    else \
        DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/download/${HYSTERIA_VERSION}/hysteria-linux-${H_ARCH}"; \
    fi && \
    curl -fsSL -o /usr/local/bin/hysteria "${DOWNLOAD_URL}" && \
    chmod +x /usr/local/bin/hysteria

WORKDIR /etc/hysteria

ENTRYPOINT ["hysteria"]
CMD ["server", "-c", "/etc/hysteria/config.json"]

FROM auth AS app

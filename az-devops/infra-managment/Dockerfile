# ── Stage 1: builder ──────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies separately so this layer is cached until they change
COPY requirements.txt .
RUN mkdir -p /install \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: final ────────────────────────────────────────────────────────────
FROM python:3.12-slim AS final

# Upgrade OS packages and remove unused packages with known CVEs
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get remove -y --allow-remove-essential perl-base \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Keeps Python from buffering stdout/stderr and from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.12/site-packages"

WORKDIR /app

# Copy only installed packages from builder — no pip, no build tools in final image
COPY --from=builder /install /install

# Create non-root user before copying app code
RUN groupadd --system appgroup && useradd --system --gid appgroup appuser

# Copy application source
COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 8585

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8585/health')"

# Use exec form so the process receives OS signals (SIGTERM for graceful shutdown)
CMD ["python", "-m", "gunicorn", "app:app", "--bind", "0.0.0.0:8585", "--workers", "2"]

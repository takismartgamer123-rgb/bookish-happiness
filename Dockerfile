FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Algiers

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    fonts-dejavu-core \
    fonts-noto-color-emoji \
    curl \
    jq \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY start.sh /app/start.sh
COPY video.mp4 /app/video.mp4
COPY logo.png /app/logo.png

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]

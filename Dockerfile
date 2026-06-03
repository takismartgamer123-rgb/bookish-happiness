FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Algiers
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    python3 \
    python3-pip \
    ffmpeg \
    fonts-dejavu-core \
    fonts-noto-core \
    fonts-noto-color-emoji \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

RUN fc-cache -f -v

WORKDIR /app

COPY requirements.txt .
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

COPY start.sh /app/start.sh
COPY video.mp4* /app/
COPY logo.png* /app/

RUN chmod +x /app/start.sh

CMD ["/bin/bash", "/app/start.sh"]

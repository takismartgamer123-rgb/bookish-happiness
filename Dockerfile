FROM alpine:3.19

RUN apk add --no-cache \
    ffmpeg \
    bash \
    curl \
    jq \
    tzdata \
    ttf-dejavu \
    font-noto-emoji \
    python3

WORKDIR /app

# السطر هذا كان غالط عندك - ناقصة مسافة
COPY start.sh video.mp4 logo.png ./

RUN chmod +x start.sh

CMD ["./start.sh"]

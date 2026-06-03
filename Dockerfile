FROM alpine:3.19
RUN apk add --no-cache \
    ffmpeg \
    bash \
    curl \
    tzdata \
    jq \
    font-dejavu \
    font-noto-emoji
ENV TZ=Africa/Algiers
WORKDIR /app
COPY start.sh video.mp4 logo.png.
RUN chmod +x start.sh
CMD ["./start.sh"]
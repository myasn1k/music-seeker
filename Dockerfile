FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg flac git gcc g++ curl xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG RSGAIN_VERSION=3.8
RUN curl -fsSL \
      "https://github.com/complexlogic/rsgain/releases/download/v${RSGAIN_VERSION}/rsgain-${RSGAIN_VERSION}-Linux.tar.xz" \
      -o /tmp/rsgain.tar.xz \
    && tar -xJf /tmp/rsgain.tar.xz -C /tmp \
    && install -m 0755 \
      "/tmp/rsgain-${RSGAIN_VERSION}-Linux/rsgain" \
      /usr/local/bin/rsgain \
    && /usr/local/bin/rsgain --version \
    && rm -rf /tmp/rsgain*

COPY requirements.txt .
RUN pip install cython && pip install -r requirements.txt --quiet

# yt-dlp: install the NIGHTLY channel — YouTube frequently breaks the stable build
# between releases, and nightly patches it faster. entrypoint.sh also self-updates
# yt-dlp on every container start so a long-running container stays current.
RUN pip install -U --pre "yt-dlp[default]"

WORKDIR /app
COPY . .

ENTRYPOINT ["/app/entrypoint.sh"]

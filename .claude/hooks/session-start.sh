#!/bin/bash
# Installs video-use skill dependencies (ffmpeg + Python libs) in Claude Code on the web.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends ffmpeg >/dev/null
fi

python3 -m pip install -q --root-user-action=ignore requests librosa matplotlib pillow numpy

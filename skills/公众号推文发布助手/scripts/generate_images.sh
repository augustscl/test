#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <article-dir>"
  exit 1
fi

BASE="$1"
PROMPTS="$BASE/prompts"
IMGS="$BASE/imgs"
BUN="$(command -v bun || true)"
if [ -z "$BUN" ]; then
  BUN="npx -y bun"
fi

if [ ! -d "$PROMPTS" ]; then
  echo "Missing prompts dir: $PROMPTS"
  exit 2
fi
mkdir -p "$IMGS"

MAIN="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen/scripts/main.ts"
MODEL="gemini-3-pro-image-preview"
PROVIDER="google"
AR="16:9"
QUALITY="2k"
IMAGE_SIZE="4K"

count=0
for pf in "$PROMPTS"/*.md; do
  [ -e "$pf" ] || continue
  name="$(basename "$pf" .md)"
  out="$IMGS/$name.png"
  if [ -s "$out" ] && [ "$out" -nt "$pf" ]; then
    echo "[image-gen] Skip existing (up-to-date): $out"
    if [ "$name" = "01-cover" ] && [ ! -s "$IMGS/cover.png" ]; then
      cp "$out" "$IMGS/cover.png"
    fi
    continue
  fi
  echo "[image-gen] Using $PROVIDER / $MODEL / imageSize=$IMAGE_SIZE -> $out"
  if command -v bun >/dev/null 2>&1; then
    bun "$MAIN" --promptfiles "$pf" --image "$out" --provider "$PROVIDER" --model "$MODEL" --ar "$AR" --quality "$QUALITY" --imageSize "$IMAGE_SIZE"
  else
    npx -y bun "$MAIN" --promptfiles "$pf" --image "$out" --provider "$PROVIDER" --model "$MODEL" --ar "$AR" --quality "$QUALITY" --imageSize "$IMAGE_SIZE"
  fi
  if [ "$name" = "01-cover" ]; then
    cp "$out" "$IMGS/cover.png"
  fi
  count=$((count+1))
  sleep 1
 done

echo "GENERATE_IMAGES_OK new_count=$count dir=$IMGS"

#!/bin/bash
set -e
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
OUTPUT_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/xiawang-diary-20260311-handdrawn-from-doc"
PROMPTS_DIR="$OUTPUT_DIR/prompts"
BUN="/Users/suchuanlei/.bun/bin/bun"
cd "$OUTPUT_DIR"
for file in "$PROMPTS_DIR"/*.md; do
  base=$(basename "$file" .md)
  out="$OUTPUT_DIR/${base}.png"
  echo "Generating $base with Google direct ..."
  "$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$file" --image "$out" --ar 16:9 --provider google --quality 2k --model gemini-3-pro-image-preview
  sleep 3
done

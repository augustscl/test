#!/bin/bash
set -e
SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
OUTPUT_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/xiawang-diary-20260310"
PROMPTS_DIR="$OUTPUT_DIR/prompts"
BUN="/Users/suchuanlei/.bun/bin/bun"
cd "$OUTPUT_DIR"
for file in "$PROMPTS_DIR"/*.md; do
  base=$(basename "$file" .md)
  out="$OUTPUT_DIR/${base}.png"
  echo "Generating $base ..."
  "$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$file" --image "$out" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
  sleep 3
done
echo "All images generated."
#!/bin/bash
set -e
SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
OUTPUT_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/从会聊到会干活-google-20260311"
PROMPTS_DIR="$OUTPUT_DIR/prompts"
BUN="/Users/suchuanlei/.bun/bin/bun"
cd "$OUTPUT_DIR"
for file in "$PROMPTS_DIR"/*.md; do
  base=$(basename "$file" .md)
  out="$OUTPUT_DIR/${base}.png"
  echo "Generating $base with Google ..."
  "$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$file" --image "$out" --ar 16:9 --provider google --quality 2k --model gemini-3-pro-image-preview
  sleep 3
done
echo "All Google images generated."
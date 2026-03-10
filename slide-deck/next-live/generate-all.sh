
#!/bin/bash
# 生成剩余所有PPT

cd /Users/suchuanlei/.openclaw/workspace

PROMPTS_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/next-live/prompts"
IMAGES_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/next-live/images"

# 剩余的PPT提示词列表
PROMPTS=(
  "04-slide-getnote-1.md"
  "05-slide-getnote-2.md"
  "06-slide-getnote-3.md"
  "07-slide-voice-1.md"
  "08-slide-voice-2.md"
  "09-slide-voice-3.md"
  "10-slide-wechat-1.md"
  "11-slide-wechat-2.md"
  "12-slide-wechat-3.md"
  "13-slide-summary.md"
  "14-slide-methodology.md"
  "15-slide-ending.md"
  "16-slide-thanks.md"
)

for prompt in "${PROMPTS[@]}"; do
  echo "Generating: $prompt"
  output_image="${IMAGES_DIR}/$(basename "$prompt" .md).png"
  ~/.bun/bin/bun ~/.openclaw/workspace/skills/baoyu-image-gen/scripts/main.ts \
    --promptfiles "$PROMPTS_DIR/$prompt" \
    --image "$output_image" \
    --ar 16:9 \
    --quality 2k \
    --provider dashscope
  echo "Done: $output_image"
done

echo "All slides generated!"

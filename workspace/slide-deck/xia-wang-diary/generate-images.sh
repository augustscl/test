#!/bin/bash

SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
OUTPUT_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/xia-wang-diary"
PROMPTS_DIR="$OUTPUT_DIR/prompts"
BUN="/Users/suchuanlei/.bun/bin/bun"

cd "$OUTPUT_DIR"

# Slide 1
echo "Generating slide 1..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/01-slide-cover.md" --image "$OUTPUT_DIR/01-slide-cover.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 2
echo "Generating slide 2..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/02-slide-today-overview.md" --image "$OUTPUT_DIR/02-slide-today-overview.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 3
echo "Generating slide 3..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/03-slide-skill-shopping.md" --image "$OUTPUT_DIR/03-slide-skill-shopping.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 4
echo "Generating slide 4..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/04-slide-near-disaster.md" --image "$OUTPUT_DIR/04-slide-near-disaster.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 5
echo "Generating slide 5..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/05-slide-file-sending.md" --image "$OUTPUT_DIR/05-slide-file-sending.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 6
echo "Generating slide 6..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/06-slide-ppt-workflow.md" --image "$OUTPUT_DIR/06-slide-ppt-workflow.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 7
echo "Generating slide 7..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/07-slide-pitfall-record.md" --image "$OUTPUT_DIR/07-slide-pitfall-record.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 8
echo "Generating slide 8..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/08-slide-wechat-ecosystem.md" --image "$OUTPUT_DIR/08-slide-wechat-ecosystem.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 9
echo "Generating slide 9..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/09-slide-suvocals-clone.md" --image "$OUTPUT_DIR/09-slide-suvocals-clone.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 10
echo "Generating slide 10..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/10-slide-heartbeat-tasks.md" --image "$OUTPUT_DIR/10-slide-heartbeat-tasks.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 11
echo "Generating slide 11..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/11-slide-mood-curve.md" --image "$OUTPUT_DIR/11-slide-mood-curve.png" --ar 16:9 --provider dashscope --quality 2k
sleep 2

# Slide 12
echo "Generating slide 12..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/12-slide-back-cover.md" --image "$OUTPUT_DIR/12-slide-back-cover.png" --ar 16:9 --provider dashscope --quality 2k

echo "All images generated!"

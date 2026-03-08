#!/bin/bash

set -e

SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
OUTPUT_DIR="/Users/suchuanlei/.openclaw/workspace/slide-deck/xia-wang-diary"
PROMPTS_DIR="$OUTPUT_DIR/prompts"
BUN="/Users/suchuanlei/.bun/bin/bun"

export DASHSCOPE_API_KEY="sk-0358d99ac398475eb6e7b06bd8d34e5b"
export DASHSCOPE_IMAGE_MODEL="qwen-image-2.0-pro"

cd "$OUTPUT_DIR"

echo "🦐 虾王殿下开始批量生成幻灯片..."

# Slide 2
echo -e "\n🎨 生成第2张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/02-slide-today-overview.md" --image "$OUTPUT_DIR/02-slide-today-overview.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 3
echo -e "\n🎨 生成第3张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/03-slide-skill-shopping.md" --image "$OUTPUT_DIR/03-slide-skill-shopping.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 4
echo -e "\n🎨 生成第4张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/04-slide-near-disaster.md" --image "$OUTPUT_DIR/04-slide-near-disaster.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 5
echo -e "\n🎨 生成第5张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/05-slide-file-sending.md" --image "$OUTPUT_DIR/05-slide-file-sending.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 6
echo -e "\n🎨 生成第6张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/06-slide-ppt-workflow.md" --image "$OUTPUT_DIR/06-slide-ppt-workflow.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 7
echo -e "\n🎨 生成第7张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/07-slide-pitfall-record.md" --image "$OUTPUT_DIR/07-slide-pitfall-record.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 8
echo -e "\n🎨 生成第8张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/08-slide-wechat-ecosystem.md" --image "$OUTPUT_DIR/08-slide-wechat-ecosystem.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 9
echo -e "\n🎨 生成第9张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/09-slide-suvocals-clone.md" --image "$OUTPUT_DIR/09-slide-suvocals-clone.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 10
echo -e "\n🎨 生成第10张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/10-slide-heartbeat-tasks.md" --image "$OUTPUT_DIR/10-slide-heartbeat-tasks.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 11
echo -e "\n🎨 生成第11张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/11-slide-mood-curve.md" --image "$OUTPUT_DIR/11-slide-mood-curve.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro
sleep 3

# Slide 12
echo -e "\n🎨 生成第12张..."
"$BUN" "$SKILL_DIR/scripts/main.ts" --promptfiles "$PROMPTS_DIR/12-slide-back-cover.md" --image "$OUTPUT_DIR/12-slide-back-cover.png" --ar 16:9 --provider dashscope --quality 2k --model qwen-image-2.0-pro

echo -e "\n🎉 所有幻灯片生成完成！"

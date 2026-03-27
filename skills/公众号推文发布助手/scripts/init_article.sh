#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <YYYY-MM-DD> <slug>"
  exit 1
fi

DATE="$1"
SLUG="$2"
BASE="/Users/suchuanlei/.openclaw/workspace/post-to-wechat/$DATE/$SLUG"
PROMPTS="$BASE/prompts"
IMGS="$BASE/imgs"

mkdir -p "$PROMPTS" "$IMGS"

ARTICLE="$BASE/$SLUG.md"
OUTLINE="$BASE/outline.md"

if [ ! -f "$ARTICLE" ]; then
  cat > "$ARTICLE" <<EOF
---
title: 
summary: 
author: AI观察员
coverImage: imgs/cover.png
---

# 

EOF
fi

if [ ! -f "$OUTLINE" ]; then
  cat > "$OUTLINE" <<'EOF'
# PPT 大纲

## Page 1｜封面
- 核心信息：
- 画面情绪：

## Page 2｜冲突/问题
- 核心信息：
- 画面情绪：

## Page 3｜拆解 1
- 核心信息：
- 画面情绪：

## Page 4｜拆解 2
- 核心信息：
- 画面情绪：

## Page 5｜转折
- 核心信息：
- 画面情绪：

## Page 6｜总结
- 核心信息：
- 画面情绪：
EOF
fi

for name in \
  '01-cover' \
  '02-conflict' \
  '03-breakdown-1' \
  '04-breakdown-2' \
  '05-turning-point' \
  '06-summary'; do
  FILE="$PROMPTS/$name.md"
  if [ ! -f "$FILE" ]; then
    cat > "$FILE" <<EOF
# ${name}

主题：

画面目标：
- 

主体元素：
- 

视觉风格：
- cinematic
- modern editorial
- high contrast

构图要求：
- 16:9
- suitable for article illustration
- clear focal point

清晰度要求：
- 4K
- high quality

禁用项：
- watermark
- blurry details
- cluttered composition
EOF
  fi
done

echo "Initialized: $BASE"
echo "Article: $ARTICLE"
echo "Outline: $OUTLINE"
echo "Prompts: $PROMPTS"

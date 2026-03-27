#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <YYYY-MM-DD> <slug> [--diary] [--publish]"
  exit 1
fi

DATE="$1"
SLUG="$2"
shift 2
ARGS="$*"
DIARY_FLAG=""
PUBLISH=0

for a in $ARGS; do
  if [ "$a" = "--diary" ]; then
    DIARY_FLAG="--diary"
  fi
  if [ "$a" = "--publish" ]; then
    PUBLISH=1
  fi
done

SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手"
BASE="/Users/suchuanlei/.openclaw/workspace/post-to-wechat/$DATE/$SLUG"
ARTICLE="$BASE/$SLUG.md"

"$SKILL_DIR/scripts/init_article.sh" "$DATE" "$SLUG"
python3 "$SKILL_DIR/scripts/generate_outline.py" "$ARTICLE"
python3 "$SKILL_DIR/scripts/generate_prompts.py" "$BASE"
"$SKILL_DIR/scripts/generate_images.sh" "$BASE"
python3 "$SKILL_DIR/scripts/insert_images.py" "$ARTICLE" "$BASE/imgs"
python3 "$SKILL_DIR/scripts/preflight_check.py" "$BASE" $DIARY_FLAG

if [ $PUBLISH -eq 1 ]; then
  THEME="modern"
  COLOR="blue"
  AUTHOR="AI观察员"
  COVER="$BASE/imgs/cover.png"
  bun /Users/suchuanlei/.openclaw/workspace/skills/baoyu-post-to-wechat/scripts/wechat-api.ts "$ARTICLE" --theme "$THEME" --color "$COLOR" --author "$AUTHOR" --cover "$COVER"
else
  echo "AUTO_PUBLISH_READY"
  echo "base=$BASE"
  echo "article=$ARTICLE"
  echo "cover=$BASE/imgs/cover.png"
  echo "tip=append --publish to send to wechat draft"
fi

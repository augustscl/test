#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <YYYY-MM-DD> <slug> [--diary]"
  exit 1
fi

DATE="$1"
SLUG="$2"
shift 2
DIARY_FLAG="${*:-}"

SKILL_DIR="/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手"
BASE="/Users/suchuanlei/.openclaw/workspace/post-to-wechat/$DATE/$SLUG"
ARTICLE="$BASE/$SLUG.md"

"$SKILL_DIR/scripts/init_article.sh" "$DATE" "$SLUG"
python3 "$SKILL_DIR/scripts/generate_outline.py" "$ARTICLE"
python3 "$SKILL_DIR/scripts/generate_prompts.py" "$BASE"
python3 "$SKILL_DIR/scripts/preflight_check.py" "$BASE" $DIARY_FLAG

echo "PIPELINE_OK"
echo "base=$BASE"
echo "article=$ARTICLE"
echo "outline=$BASE/outline.md"
echo "prompts=$BASE/prompts"

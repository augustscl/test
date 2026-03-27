#!/bin/bash
set -euo pipefail

WORKDIR="/Users/suchuanlei/.openclaw/workspace"
cd "$WORKDIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not a git repo: $WORKDIR" >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "NO_CHANGES"
  exit 0
fi

git commit -m "🦐 每日自动备份"
git push

echo "BACKUP_OK"

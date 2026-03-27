#!/usr/bin/env bash
set -euo pipefail

# Send an existing .opus file as a real Feishu audio message (bot identity).
# Usage:
#   send-feishu-voice.sh /path/to/file.opus --open-id ou_xxx
#   send-feishu-voice.sh /path/to/file.opus --chat-id oc_xxx
#
# If a sibling .duration file exists, it will be used (seconds -> ms).
# Otherwise duration defaults to 0.

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 AUDIO.opus (--open-id ou_xxx | --chat-id oc_xxx)" >&2
  exit 1
fi

AUDIO="$1"
shift
[[ -f "$AUDIO" ]] || { echo "Audio not found: $AUDIO" >&2; exit 1; }

TARGET_TYPE=""
TARGET_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --open-id) TARGET_TYPE="open_id"; TARGET_ID="$2"; shift 2 ;;
    --chat-id) TARGET_TYPE="chat_id"; TARGET_ID="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$TARGET_TYPE" && -n "$TARGET_ID" ]] || { echo "Missing target" >&2; exit 1; }

CFG="/Users/suchuanlei/.openclaw/openclaw.json"
APP_ID="$(python3 - <<'PY' "$CFG"
import json,sys
cfg=json.load(open(sys.argv[1]))
print(cfg['channels']['feishu']['appId'])
PY
)"
APP_SECRET="$(python3 - <<'PY' "$CFG"
import json,sys
cfg=json.load(open(sys.argv[1]))
print(cfg['channels']['feishu']['appSecret'])
PY
)"
BASE='https://open.feishu.cn/open-apis'

DURATION_FILE="${AUDIO%.*}.duration"
DURATION_MS="0"
if [[ -f "$DURATION_FILE" ]]; then
  DURATION_MS="$(python3 - <<'PY' "$DURATION_FILE"
from pathlib import Path
import sys
try:
    secs=float(Path(sys.argv[1]).read_text().strip())
    print(max(0, int(secs*1000)))
except Exception:
    print(0)
PY
)"
fi

if [[ "$DURATION_MS" == "0" ]]; then
  if command -v ffprobe >/dev/null 2>&1; then
    DUR_RAW="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$AUDIO" 2>/dev/null || true)"
    DURATION_MS="$(python3 - <<'PY' "$DUR_RAW"
import sys
s=sys.argv[1].strip()
try:
    print(max(0, int(float(s)*1000)))
except Exception:
    print(0)
PY
)"
  elif command -v ffmpeg >/dev/null 2>&1; then
    DUR_RAW="$(ffmpeg -i "$AUDIO" 2>&1 || true)"
    DURATION_MS="$(python3 - <<'PY' "$DUR_RAW"
import re,sys
text=sys.argv[1]
m=re.search(r"Duration: (\d+):(\d+):(\d+(?:\.\d+)?)", text)
if not m:
    print(0)
else:
    h,mn,sec=int(m.group(1)),int(m.group(2)),float(m.group(3))
    print(int((h*3600+mn*60+sec)*1000))
PY
)"
  elif command -v afinfo >/dev/null 2>&1; then
    DUR_RAW="$(afinfo "$AUDIO" 2>/dev/null || true)"
    DURATION_MS="$(python3 - <<'PY' "$DUR_RAW"
import re,sys
text=sys.argv[1]
m=re.search(r'estimated duration: ([0-9.]+)', text)
if not m:
    print(0)
else:
    print(int(float(m.group(1))*1000))
PY
)"
  fi
fi

TOKEN_JSON=$(curl -sS -X POST "$BASE/auth/v3/tenant_access_token/internal" \
  -H 'Content-Type: application/json; charset=utf-8' \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")
TOKEN=$(python3 - <<'PY' "$TOKEN_JSON"
import json,sys
obj=json.loads(sys.argv[1])
assert obj.get('code')==0, obj
print(obj['tenant_access_token'])
PY
)

UPLOAD_JSON=$(curl -sS -X POST \
  "$BASE/im/v1/files?receive_id_type=$TARGET_TYPE&receive_id=$TARGET_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -F 'file_type=opus' \
  -F "file=@${AUDIO};type=audio/ogg" \
  -F "file_name=$(basename "$AUDIO")")
FILE_KEY=$(python3 - <<'PY' "$UPLOAD_JSON"
import json,sys
obj=json.loads(sys.argv[1])
assert obj.get('code')==0, obj
print(obj['data']['file_key'])
PY
)

SEND_JSON=$(python3 - <<'PY' "$TARGET_ID" "$FILE_KEY" "$DURATION_MS"
import json,sys
receive_id,file_key,duration=sys.argv[1],sys.argv[2],int(sys.argv[3])
print(json.dumps({
  "receive_id": receive_id,
  "msg_type": "audio",
  "content": json.dumps({"file_key": file_key, "duration": duration})
}))
PY
)

RESP=$(curl -sS -X POST "$BASE/im/v1/messages?receive_id_type=$TARGET_TYPE" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json; charset=utf-8' \
  -d "$SEND_JSON")
python3 - <<'PY' "$RESP"
import json,sys
obj=json.loads(sys.argv[1])
assert obj.get('code')==0, obj
print(obj['data']['message_id'])
PY

#!/usr/bin/env bash
set -euo pipefail

# Send a file as Feishu file message (bot identity).
# Usage:
#   send-feishu-file.sh /path/to/file --open-id ou_xxx
#   send-feishu-file.sh /path/to/file --chat-id oc_xxx

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 FILE (--open-id ou_xxx | --chat-id oc_xxx)" >&2
  exit 1
fi

FILE="$1"
shift
[[ -f "$FILE" ]] || { echo "File not found: $FILE" >&2; exit 1; }

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

# Guess file type based on extension
EXT="${FILE##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

case "$EXT_LOWER" in
  ppt|pptx|pot|potx|pps|ppsx)
    FEISHU_FILE_TYPE="stream"
    ;;
  *)
    FEISHU_FILE_TYPE="file"
    ;;
esac

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
  -F "file_type=$FEISHU_FILE_TYPE" \
  -F "file=@${FILE};type=application/octet-stream" \
  -F "file_name=$(basename "$FILE")")
FILE_KEY=$(python3 - <<'PY' "$UPLOAD_JSON"
import json,sys
obj=json.loads(sys.argv[1])
assert obj.get('code')==0, obj
print(obj['data']['file_key'])
PY
)

SEND_JSON=$(python3 - <<'PY' "$TARGET_ID" "$FILE_KEY"
import json,sys
receive_id,file_key=sys.argv[1],sys.argv[2]
print(json.dumps({
  "receive_id": receive_id,
  "msg_type": "file",
  "content": json.dumps({"file_key": file_key})
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

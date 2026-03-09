#!/usr/bin/env bash
set -euo pipefail

# Text -> opus -> real Feishu audio message (bot identity)
#
# Usage:
#   speak-and-send-feishu-voice.sh -t "你好苏神" --open-id ou_xxx
#   speak-and-send-feishu-voice.sh -t "群里来一条" --chat-id oc_xxx
#   speak-and-send-feishu-voice.sh -f ./text.txt --open-id ou_xxx
#
# Optional passthrough args for Noiz TTS:
#   --voice / --voice-id / --lang / --speed / --emo / --duration /
#   --backend / --ref-audio / --auto-emotion / --similarity-enh / --save-voice

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TTS_SH="$ROOT/NoizAI-skills/skills/tts/scripts/tts.sh"
SEND_SH="$SCRIPT_DIR/send-feishu-voice.sh"

[[ -x "$SEND_SH" ]] || { echo "Missing executable sender: $SEND_SH" >&2; exit 1; }
[[ -f "$TTS_SH" ]] || { echo "Missing tts script: $TTS_SH" >&2; exit 1; }

TEXT=""
TEXT_FILE=""
TARGET_FLAG=""
TARGET_ID=""
PASSTHRU=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--text)
      TEXT="$2"; shift 2 ;;
    -f|--text-file)
      TEXT_FILE="$2"; shift 2 ;;
    --open-id)
      TARGET_FLAG="--open-id"; TARGET_ID="$2"; shift 2 ;;
    --chat-id)
      TARGET_FLAG="--chat-id"; TARGET_ID="$2"; shift 2 ;;
    --voice|--voice-id|--lang|--speed|--emo|--duration|--backend|--ref-audio)
      PASSTHRU+=("$1" "$2"); shift 2 ;;
    --auto-emotion|--similarity-enh|--save-voice)
      PASSTHRU+=("$1"); shift ;;
    -h|--help)
      cat <<'EOF'
Usage:
  speak-and-send-feishu-voice.sh (-t TEXT | -f TEXT_FILE) (--open-id ou_xxx | --chat-id oc_xxx) [tts options]

Examples:
  speak-and-send-feishu-voice.sh -t "苏神，听好了" --open-id ou_0eb8fd7529b5669c0a2de183a76a760f
  speak-and-send-feishu-voice.sh -t "大家好" --chat-id oc_xxx --voice-id <voice_id>
EOF
      exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$TEXT" && -z "$TEXT_FILE" ]]; then
  echo "Need -t/--text or -f/--text-file" >&2
  exit 1
fi
if [[ -n "$TEXT" && -n "$TEXT_FILE" ]]; then
  echo "Use either --text or --text-file, not both" >&2
  exit 1
fi
if [[ -z "$TARGET_FLAG" || -z "$TARGET_ID" ]]; then
  echo "Need --open-id or --chat-id" >&2
  exit 1
fi

TMP_OPUS="$(mktemp /tmp/feishu-voice-XXXXXX.opus)"
TMP_DUR="${TMP_OPUS%.*}.duration"
cleanup() {
  rm -f "$TMP_OPUS" "$TMP_DUR"
}
trap cleanup EXIT

TTS_ARGS=(speak --output "$TMP_OPUS" --format opus)
if [[ -n "$TEXT" ]]; then
  TTS_ARGS+=(--text "$TEXT")
else
  TTS_ARGS+=(--text-file "$TEXT_FILE")
fi
if [[ ${#PASSTHRU[@]} -gt 0 ]]; then
  TTS_ARGS+=("${PASSTHRU[@]}")
fi

bash "$TTS_SH" "${TTS_ARGS[@]}" >&2
bash "$SEND_SH" "$TMP_OPUS" "$TARGET_FLAG" "$TARGET_ID"

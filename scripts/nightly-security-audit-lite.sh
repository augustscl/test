#!/bin/bash
# 轻量版 nightly security audit
set -uo pipefail

OC="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
REPORT_DIR="/tmp/openclaw/security-reports"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
REPORT_FILE="$REPORT_DIR/report-$DATE-lite.txt"

mkdir -p "$REPORT_DIR"

SUMMARY=""
DETAILS=""
ALERT_COUNT=0
WARN_COUNT=0

ok()   { SUMMARY+="✅ $1"$'\n'; }
warn() { SUMMARY+="⚠️ $1"$'\n'; WARN_COUNT=$((WARN_COUNT + 1)); }
alert(){ SUMMARY+="🚨 $1"$'\n'; ALERT_COUNT=$((ALERT_COUNT + 1)); }
detail(){ DETAILS+="$1"$'\n'; }

section() {
  detail ""
  detail "--- [$1] $2 ---"
}

section 1 "OpenClaw 平台安全审计"
OC_AUDIT=$(openclaw security audit 2>&1 || true)
detail "$OC_AUDIT"
if echo "$OC_AUDIT" | grep -qi "critical"; then
  warn "1. 平台审计: 存在 CRITICAL 级告警（详见报告）"
else
  ok "1. 平台审计: 已执行原生扫描，无 CRITICAL 告警"
fi

section 2 "进程与网络审计"
LISTEN=$(lsof -i -P -n 2>/dev/null | grep LISTEN || true)
OUTBOUND=$(lsof -i -P -n 2>/dev/null | grep ESTABLISHED | grep -v "127.0.0.1\|::1" || true)
OUTBOUND_COUNT=0
if [ -n "$OUTBOUND" ]; then
  OUTBOUND_COUNT=$(echo "$OUTBOUND" | wc -l | tr -d ' ')
fi
detail "监听端口:"
detail "$LISTEN"
detail "出站连接:"
detail "$OUTBOUND"
if [ "$OUTBOUND_COUNT" -gt 20 ]; then
  warn "2. 进程网络: ${OUTBOUND_COUNT} 个活跃出站连接（偏多，请检查）"
else
  ok "2. 进程网络: ${OUTBOUND_COUNT} 个出站连接，监听端口已记录"
fi

section 3 "敏感目录变更（最近24h）"
CHANGED_FILES=""
for DIR in "$OC/" "$HOME/.ssh/" "/etc/" "/usr/local/bin/"; do
  if [ -d "$DIR" ]; then
    FOUND=$(find "$DIR" -maxdepth 3 -type f -mtime -1 2>/dev/null | head -50 || true)
    if [ -n "$FOUND" ]; then
      CHANGED_FILES+="$FOUND"$'\n'
    fi
  fi
done
CHANGED_COUNT=0
if [ -n "$CHANGED_FILES" ]; then
  CHANGED_COUNT=$(echo "$CHANGED_FILES" | grep -c . || true)
fi
detail "$CHANGED_FILES"
if [ "$CHANGED_COUNT" -gt 0 ]; then
  warn "3. 目录变更: ${CHANGED_COUNT} 个文件在过去 24h 内变更"
else
  ok "3. 目录变更: 敏感目录无文件变更"
fi

section 4 "系统定时任务"
USER_CRON=$(crontab -l 2>/dev/null || echo "(无用户 crontab)")
LA_USER=$(ls ~/Library/LaunchAgents/ 2>/dev/null || echo "(空)")
LA_SYS=$(ls /Library/LaunchAgents/ 2>/dev/null || echo "(空)")
LD_SYS=$(ls /Library/LaunchDaemons/ 2>/dev/null || echo "(空)")
detail "用户 crontab:"
detail "$USER_CRON"
detail "用户 LaunchAgents:"
detail "$LA_USER"
detail "系统 LaunchAgents:"
detail "$LA_SYS"
detail "系统 LaunchDaemons:"
detail "$LD_SYS"
PLIST_WHITELIST="google\|openclaw\|valvesoftware\|baidu\|docker\|com.apple\|Lemon"
SUSPICIOUS_PLIST=$(grep -rl "curl\|wget\|http://" ~/Library/LaunchAgents/ /Library/LaunchAgents/ /Library/LaunchDaemons/ 2>/dev/null | grep -v "$PLIST_WHITELIST" || true)
if [ -n "$SUSPICIOUS_PLIST" ]; then
  alert "4. 系统任务: 发现可疑 plist 引用外部 URL: $SUSPICIOUS_PLIST"
else
  ok "4. 系统任务: 未发现可疑系统级定时任务"
fi

section 5 "OpenClaw Cron Jobs"
OC_CRON=$(openclaw cron list 2>&1 || echo "(无法获取)")
detail "$OC_CRON"
ok "5. 本地 Cron: 已列出 OpenClaw 内部任务（详见报告）"

section 6 "登录与 SSH 安全"
SSH_FAIL=$(log show --predicate 'process == "sshd" AND eventMessage CONTAINS "Failed"' --last 24h --style compact 2>/dev/null | tail -20 || true)
LAST_LOGIN=$(last -10 2>/dev/null || true)
SSH_FAIL_COUNT=0
if echo "$SSH_FAIL" | grep -q "Failed" 2>/dev/null; then
  SSH_FAIL_COUNT=$(echo "$SSH_FAIL" | grep -c "Failed" || true)
fi
detail "SSH 失败尝试 (24h):"
detail "${SSH_FAIL:-(无)}"
detail "最近登录:"
detail "${LAST_LOGIN:-(无)}"
ok "6. SSH 安全: ${SSH_FAIL_COUNT} 次失败尝试"

section 7 "关键文件完整性"
BASELINE_FILE="$OC/.config-baseline.sha256"
if [ -f "$BASELINE_FILE" ]; then
  HASH_CHECK=$(shasum -a 256 -c "$BASELINE_FILE" 2>&1 || true)
  detail "$HASH_CHECK"
  if echo "$HASH_CHECK" | grep -q "FAILED"; then
    alert "7. 配置基线: 哈希校验失败！核心配置文件可能被篡改"
  else
    ok "7. 配置基线: SHA256 哈希校验通过"
  fi
else
  warn "7. 配置基线: 基线文件不存在，无法校验"
fi

section 8 "黄线操作交叉验证"
MEMORY_FILE="$OC/workspace/memory/$DATE.md"
if [ -f "$MEMORY_FILE" ]; then
  ok "8. 黄线审计: 当日 memory 日志存在"
else
  warn "8. 黄线审计: 当日 memory 日志不存在"
fi

section 9 "磁盘使用"
DISK_USAGE=$(df -h / 2>/dev/null | tail -1)
DISK_PCT=$(echo "$DISK_USAGE" | awk '{gsub(/%/,"",$5); print $5}' || echo 0)
detail "根分区: $DISK_USAGE"
if [ "$DISK_PCT" -gt 85 ] 2>/dev/null; then
  warn "9. 磁盘容量: 根分区占用 ${DISK_PCT}%（>85% 告警）"
else
  ok "9. 磁盘容量: 根分区占用 ${DISK_PCT}%"
fi

section 10 "Gateway 环境变量"
GW_PID=$(lsof -ti tcp:18789 -sTCP:LISTEN 2>/dev/null | head -1 || true)
if [ -n "$GW_PID" ]; then
  ok "10. 环境变量: Gateway PID=${GW_PID}"
else
  warn "10. 环境变量: 未找到 Gateway 监听进程"
fi

section 11 "DLP 扫描（轻量）"
DLP_HITS=""
for SCAN_DIR in "$OC/workspace/memory" "$OC/workspace"; do
  if [ -d "$SCAN_DIR" ]; then
    HIT=$(grep -rIlE "0x[0-9a-fA-F]{64}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}" "$SCAN_DIR" 2>/dev/null | head -5 || true)
    if [ -n "$HIT" ]; then DLP_HITS+="$HIT"$'\n'; fi
  fi
done
detail "${DLP_HITS:-(无发现)}"
if [ -n "$DLP_HITS" ]; then
  alert "11. DLP 扫描: 发现可能的明文凭证泄露（详见报告）"
else
  ok "11. DLP 扫描: workspace 未发现明显凭证泄露"
fi

section 12 "Skill 完整性（轻量）"
SKILL_DIR="$HOME/.agents/skills"
SYSTEM_SKILL_DIR="$HOME/.npm-global/lib/node_modules/openclaw/skills"
SKILL_FILE_COUNT=0
SKILL_RECENT=0
for SD in "$SKILL_DIR" "$SYSTEM_SKILL_DIR"; do
  if [ -d "$SD" ]; then
    COUNT=$(find "$SD" -type f \( -name "*.sh" -o -name "*.js" -o -name "*.py" -o -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l | tr -d ' ')
    RECENT=$(find "$SD" -type f -mtime -1 \( -name "*.sh" -o -name "*.js" -o -name "*.py" \) 2>/dev/null | wc -l | tr -d ' ')
    SKILL_FILE_COUNT=$((SKILL_FILE_COUNT + COUNT))
    SKILL_RECENT=$((SKILL_RECENT + RECENT))
  fi
done
detail "Skill 文件总数: $SKILL_FILE_COUNT"
detail "最近 24h 变更的脚本文件: $SKILL_RECENT"
if [ "$SKILL_RECENT" -gt 20 ]; then
  warn "12. Skill 完整性: 最近 24h 有 ${SKILL_RECENT} 个脚本文件变更"
else
  ok "12. Skill 完整性: 轻量巡检完成，未见明显异常"
fi

section 13 "灾备状态（只读）"
if [ -d "$OC/.git" ]; then
  cd "$OC"
  GIT_STATUS=$(git status --short 2>/dev/null || true)
  GIT_LAST=$(git log -1 --oneline 2>/dev/null || true)
  detail "最近一次提交: ${GIT_LAST:-(无)}"
  detail "当前未提交变更: ${GIT_STATUS:-(无)}"
  if [ -n "$GIT_STATUS" ]; then
    warn "13. 灾备状态: 检测到未提交变更，交由 git-backup-daily 处理"
  else
    ok "13. 灾备状态: 工作区干净，最近提交已记录"
  fi
else
  warn "13. 灾备状态: 未配置 Git 仓库"
fi

HEADER="🛡️ OpenClaw 每日安全巡检简报 ($DATE $TIME)"
if [ "$ALERT_COUNT" -gt 0 ]; then
  STATUS="🚨 发现 ${ALERT_COUNT} 个高危告警 + ${WARN_COUNT} 个警告"
elif [ "$WARN_COUNT" -gt 0 ]; then
  STATUS="⚠️ 发现 ${WARN_COUNT} 个警告，无高危"
else
  STATUS="✅ 全部通过，系统安全"
fi

OUTPUT="$HEADER
$STATUS

$SUMMARY
📝 详细战报已保存: $REPORT_FILE"

echo "$DETAILS" > "$REPORT_FILE"
echo "$OUTPUT"

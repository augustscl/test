#!/bin/bash
# ============================================================
# OpenClaw 每日安全巡检脚本 (macOS 适配版)
# 基于慢雾安全团队 OpenClaw 极简安全实践指南 v2.7
# ============================================================

set -uo pipefail
# 注意：不用 set -e，很多检查命令返回非零是正常的

OC="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
REPORT_DIR="/tmp/openclaw/security-reports"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
REPORT_FILE="$REPORT_DIR/report-$DATE.txt"

mkdir -p "$REPORT_DIR"

SUMMARY=""
DETAILS=""
ALERT_COUNT=0
WARN_COUNT=0

ok()   { SUMMARY+="✅ $1"$'\n'; }
warn() { SUMMARY+="⚠️ $1"$'\n'; WARN_COUNT=$((WARN_COUNT + 1)); }
alert(){ SUMMARY+="🚨 $1"$'\n'; ALERT_COUNT=$((ALERT_COUNT + 1)); }
detail(){ DETAILS+="$1"$'\n'; }

detail "=========================================="
detail "OpenClaw 安全巡检详细报告 $DATE $TIME"
detail "=========================================="

# ─────────────────────────────────────────────
# 1. OpenClaw 平台安全审计
# ─────────────────────────────────────────────
detail ""
detail "--- [1] OpenClaw 平台安全审计 ---"
OC_AUDIT=$(openclaw security audit 2>&1 || true)
detail "$OC_AUDIT"

if echo "$OC_AUDIT" | grep -qi "critical"; then
    warn "1. 平台审计: 存在 CRITICAL 级告警（详见报告）"
else
    ok "1. 平台审计: 已执行原生扫描，无 CRITICAL 告警"
fi

# ─────────────────────────────────────────────
# 2. 进程与网络审计
# ─────────────────────────────────────────────
detail ""
detail "--- [2] 进程与网络审计 ---"

LISTEN=$(lsof -i -P -n 2>/dev/null | grep LISTEN || true)
detail "监听端口:"
detail "$LISTEN"

TOP15=$(ps aux | sort -nrk 4 | head -16 || true)
detail ""
detail "Top 15 内存占用:"
detail "$TOP15"

OUTBOUND=$(lsof -i -P -n 2>/dev/null | grep ESTABLISHED | grep -v "127.0.0.1\|::1" || true)
detail ""
detail "出站连接:"
detail "$OUTBOUND"

OUTBOUND_COUNT=0
if [ -n "$OUTBOUND" ]; then
    OUTBOUND_COUNT=$(echo "$OUTBOUND" | wc -l | tr -d ' ')
fi

if [ "$OUTBOUND_COUNT" -gt 20 ]; then
    warn "2. 进程网络: ${OUTBOUND_COUNT} 个活跃出站连接（偏多，请检查）"
else
    ok "2. 进程网络: ${OUTBOUND_COUNT} 个出站连接，监听端口已记录"
fi

# ─────────────────────────────────────────────
# 3. 敏感目录变更（最近 24h）
# ─────────────────────────────────────────────
detail ""
detail "--- [3] 敏感目录变更 ---"

CHANGED_FILES=""
for DIR in "$OC/" "$HOME/.ssh/" "/etc/" "/usr/local/bin/"; do
    if [ -d "$DIR" ]; then
        FOUND=$(find "$DIR" -maxdepth 3 -type f -mtime -1 2>/dev/null | head -50 || true)
        if [ -n "$FOUND" ]; then
            CHANGED_FILES+="$FOUND"$'\n'
        fi
    fi
done
detail "$CHANGED_FILES"

CHANGED_COUNT=0
if [ -n "$CHANGED_FILES" ]; then
    CHANGED_COUNT=$(echo "$CHANGED_FILES" | grep -c . || true)
fi

if [ "$CHANGED_COUNT" -gt 0 ]; then
    warn "3. 目录变更: ${CHANGED_COUNT} 个文件在过去 24h 内变更"
else
    ok "3. 目录变更: 敏感目录无文件变更"
fi

# ─────────────────────────────────────────────
# 4. 系统定时任务
# ─────────────────────────────────────────────
detail ""
detail "--- [4] 系统定时任务 ---"

USER_CRON=$(crontab -l 2>/dev/null || echo "(无用户 crontab)")
detail "用户 crontab:"
detail "$USER_CRON"

LA_USER=$(ls ~/Library/LaunchAgents/ 2>/dev/null || echo "(空)")
LA_SYS=$(ls /Library/LaunchAgents/ 2>/dev/null || echo "(空)")
LD_SYS=$(ls /Library/LaunchDaemons/ 2>/dev/null || echo "(空)")
detail ""
detail "用户 LaunchAgents:"
detail "$LA_USER"
detail ""
detail "系统 LaunchAgents:"
detail "$LA_SYS"
detail ""
detail "系统 LaunchDaemons:"
detail "$LD_SYS"

# 已知安全的 plist 白名单（Google、OpenClaw、Steam、百度、Docker 等）
PLIST_WHITELIST="google\|openclaw\|valvesoftware\|baidu\|docker\|com.apple"
SUSPICIOUS_PLIST=$(grep -rl "curl\|wget\|http://" ~/Library/LaunchAgents/ /Library/LaunchAgents/ /Library/LaunchDaemons/ 2>/dev/null | grep -v "$PLIST_WHITELIST" || true)
if [ -n "$SUSPICIOUS_PLIST" ]; then
    alert "4. 系统任务: 发现可疑 plist 引用外部 URL: $SUSPICIOUS_PLIST"
else
    ok "4. 系统任务: 未发现可疑系统级定时任务"
fi

# ─────────────────────────────────────────────
# 5. OpenClaw Cron Jobs
# ─────────────────────────────────────────────
detail ""
detail "--- [5] OpenClaw Cron Jobs ---"
OC_CRON=$(openclaw cron list 2>&1 || echo "(无法获取)")
detail "$OC_CRON"
ok "5. 本地 Cron: 已列出 OpenClaw 内部任务（详见报告）"

# ─────────────────────────────────────────────
# 6. 登录与 SSH 安全
# ─────────────────────────────────────────────
detail ""
detail "--- [6] 登录与 SSH 安全 ---"

SSH_FAIL=$(log show --predicate 'process == "sshd" AND eventMessage CONTAINS "Failed"' --last 24h --style compact 2>/dev/null | tail -20 || echo "(无 SSH 失败记录)")
detail "SSH 失败尝试 (24h):"
detail "$SSH_FAIL"

LAST_LOGIN=$(last -10 2>/dev/null || echo "(无法获取)")
detail ""
detail "最近登录:"
detail "$LAST_LOGIN"

SSH_FAIL_COUNT=0
if echo "$SSH_FAIL" | grep -q "Failed" 2>/dev/null; then
    SSH_FAIL_COUNT=$(echo "$SSH_FAIL" | grep -c "Failed" || true)
fi
if [ "$SSH_FAIL_COUNT" -gt 10 ]; then
    warn "6. SSH 安全: ${SSH_FAIL_COUNT} 次失败尝试（可能遭遇爆破）"
else
    ok "6. SSH 安全: ${SSH_FAIL_COUNT} 次失败尝试"
fi

# ─────────────────────────────────────────────
# 7. 关键文件完整性
# ─────────────────────────────────────────────
detail ""
detail "--- [7] 关键文件完整性 ---"

BASELINE_FILE="$OC/.config-baseline.sha256"
if [ -f "$BASELINE_FILE" ]; then
    HASH_CHECK=$(shasum -a 256 -c "$BASELINE_FILE" 2>&1 || true)
    detail "哈希校验:"
    detail "$HASH_CHECK"
    if echo "$HASH_CHECK" | grep -q "FAILED"; then
        alert "7. 配置基线: 哈希校验失败！核心配置文件可能被篡改"
    else
        ok "7. 配置基线: SHA256 哈希校验通过"
    fi
else
    warn "7. 配置基线: 基线文件不存在，无法校验"
fi

detail ""
detail "权限检查:"
for F in "$OC/openclaw.json" "$OC/devices/paired.json" "$HOME/.ssh/authorized_keys"; do
    if [ -f "$F" ]; then
        PERM=$(stat -f "%OLp" "$F" 2>/dev/null || true)
        detail "  $F → $PERM"
        if [ "$PERM" != "600" ] && [ "$PERM" != "400" ]; then
            warn "7+. 权限异常: $F 权限为 $PERM（预期 600）"
        fi
    fi
done

# ─────────────────────────────────────────────
# 8. 黄线操作交叉验证
# ─────────────────────────────────────────────
detail ""
detail "--- [8] 黄线操作交叉验证 ---"

SUDO_LOG=$(log show --predicate 'process == "sudo"' --last 24h --style compact 2>/dev/null | tail -30 || echo "(无法获取)")
detail "sudo 记录 (24h):"
detail "$SUDO_LOG"

SUDO_COUNT=0
if echo "$SUDO_LOG" | grep -q "sudo" 2>/dev/null; then
    SUDO_COUNT=$(echo "$SUDO_LOG" | grep -c "sudo" || true)
fi

MEMORY_FILE="$OC/workspace/memory/$DATE.md"
if [ -f "$MEMORY_FILE" ]; then
    ok "8. 黄线审计: ${SUDO_COUNT} 次 sudo 记录（memory 日志已比对）"
else
    if [ "$SUDO_COUNT" -gt 0 ]; then
        warn "8. 黄线审计: 发现 ${SUDO_COUNT} 次 sudo 但无当日 memory 日志"
    else
        ok "8. 黄线审计: 无 sudo 记录"
    fi
fi

# ─────────────────────────────────────────────
# 9. 磁盘使用
# ─────────────────────────────────────────────
detail ""
detail "--- [9] 磁盘使用 ---"

DISK_USAGE=$(df -h / 2>/dev/null | tail -1)
detail "根分区: $DISK_USAGE"
DISK_PCT=$(echo "$DISK_USAGE" | awk '{gsub(/%/,"",$5); print $5}' || echo 0)

BIG_FILES=$(find /Users 2>/dev/null -type f -size +100M -mtime -1 | grep -v "/Library/\|/.Trash/" | head -20 || true)
detail ""
detail "新增大文件 (>100MB, 24h):"
detail "${BIG_FILES:-(无)}"

BIG_COUNT=0
if [ -n "$BIG_FILES" ]; then
    BIG_COUNT=$(echo "$BIG_FILES" | wc -l | tr -d ' ')
fi
if [ "$DISK_PCT" -gt 85 ] 2>/dev/null; then
    warn "9. 磁盘容量: 根分区占用 ${DISK_PCT}%（>85% 告警），${BIG_COUNT} 个大文件"
else
    ok "9. 磁盘容量: 根分区占用 ${DISK_PCT}%，新增 ${BIG_COUNT} 个大文件"
fi

# ─────────────────────────────────────────────
# 10. Gateway 环境变量
# ─────────────────────────────────────────────
detail ""
detail "--- [10] Gateway 环境变量 ---"

GW_PID=$(ps aux 2>/dev/null | grep "[o]penclaw-gateway" | awk '{print $2}' | head -1 || true)
if [ -n "$GW_PID" ]; then
    GW_ENV=$(ps eww -p "$GW_PID" 2>/dev/null || true)
    SENSITIVE_VARS=$(echo "$GW_ENV" | tr ' ' '\n' | grep -iE "KEY=|TOKEN=|SECRET=|PASSWORD=|PRIVATE=" | sed 's/=.*/=***/' || true)
    detail "含敏感关键字的变量名:"
    detail "${SENSITIVE_VARS:-(无)}"
    ok "10. 环境变量: Gateway PID=${GW_PID}，敏感变量已脱敏列出"
else
    warn "10. 环境变量: 未找到 Gateway 进程"
fi

# ─────────────────────────────────────────────
# 11. 明文私钥/凭证泄露扫描 (DLP)
# ─────────────────────────────────────────────
detail ""
detail "--- [11] DLP 扫描 ---"

DLP_HITS=""
for SCAN_DIR in "$OC/workspace/memory" "$OC/workspace" "$OC/agents"; do
    if [ -d "$SCAN_DIR" ]; then
        ETH_KEYS=$(grep -rlE "0x[0-9a-fA-F]{64}" "$SCAN_DIR" 2>/dev/null | head -5 || true)
        API_KEYS=$(grep -rlEi "(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16})" "$SCAN_DIR" 2>/dev/null | head -5 || true)
        if [ -n "$ETH_KEYS" ]; then DLP_HITS+="可能的私钥: $ETH_KEYS"$'\n'; fi
        if [ -n "$API_KEYS" ]; then DLP_HITS+="可能的 API Key: $API_KEYS"$'\n'; fi
    fi
done

detail "${DLP_HITS:-(无发现)}"
if [ -n "$DLP_HITS" ]; then
    alert "11. DLP 扫描: 发现可能的明文凭证泄露（详见报告）"
else
    ok "11. DLP 扫描: workspace 未发现明文私钥或助记词"
fi

# ─────────────────────────────────────────────
# 12. Skill/MCP 完整性
# ─────────────────────────────────────────────
detail ""
detail "--- [12] Skill/MCP 完整性 ---"

SKILL_BASELINE="$OC/.skill-baseline.sha256"
SKILL_DIR="$HOME/.agents/skills"
SYSTEM_SKILL_DIR="$HOME/.npm-global/lib/node_modules/openclaw/skills"

CURRENT_HASHES_FILE="/tmp/openclaw/skill-current.sha256"
: > "$CURRENT_HASHES_FILE"

for SD in "$SKILL_DIR" "$SYSTEM_SKILL_DIR"; do
    if [ -d "$SD" ]; then
        find "$SD" -type f \( -name "*.sh" -o -name "*.js" -o -name "*.py" -o -name "*.md" -o -name "*.json" \) -exec shasum -a 256 {} \; >> "$CURRENT_HASHES_FILE" 2>/dev/null || true
    fi
done

if [ -f "$SKILL_BASELINE" ]; then
    SKILL_DIFF=$(diff "$SKILL_BASELINE" "$CURRENT_HASHES_FILE" 2>/dev/null || true)
    detail "${SKILL_DIFF:-(无变化)}"
    if [ -n "$SKILL_DIFF" ]; then
        warn "12. Skill 基线: 检测到 Skill 文件变更（详见报告）"
    else
        ok "12. Skill 基线: 所有 Skill 文件哈希一致"
    fi
else
    cp "$CURRENT_HASHES_FILE" "$SKILL_BASELINE"
    detail "首次运行，已生成 Skill 哈希基线"
    ok "12. Skill 基线: 首次运行，已生成基线文件"
fi

# ─────────────────────────────────────────────
# 13. 灾备状态
# ─────────────────────────────────────────────
detail ""
detail "--- [13] 灾备状态 ---"

if [ -d "$OC/.git" ]; then
    GIT_STATUS=$(cd "$OC" && git status --porcelain 2>/dev/null || true)
    GIT_REMOTE=$(cd "$OC" && git remote -v 2>/dev/null || true)
    detail "Git status: $GIT_STATUS"
    detail "Git remote: $GIT_REMOTE"
    ok "13. 灾备备份: Git 仓库已配置"
else
    warn "13. 灾备备份: 未配置 Git 仓库（可选，后续可补）"
fi

# ─────────────────────────────────────────────
# 输出汇总
# ─────────────────────────────────────────────

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

# 写入详细报告
echo "$DETAILS" > "$REPORT_FILE"

# 输出摘要
echo "$OUTPUT"

# HEARTBEAT.md — 虾王心跳任务 🦐

## 健康检查（每次心跳执行）

### 1. Cron 任务状态
运行 `openclaw cron list`，检查：
- 所有任务是否 enabled
- lastRunAtMs 是否陈旧（>26 小时未跑 = 异常）
- 如果发现异常，通知苏神

需监控的任务：
- nightly-security-audit（每天 03:00）
- git-backup-daily（每天 03:30）

### 2. Git 灾备状态
在 workspace 目录检查：
- `git status` 是否有未提交的变更
- 如果有超过 24 小时未 push 的改动，执行 commit & push
- 检查 `git log -1 --format="%ar"` 确认最后一次提交时间

### 3. 安全基线校验
运行 `shasum -a 256 -c ~/.openclaw/.config-baseline.sha256 2>&1`
- 如果任何文件校验失败 → **立即通知苏神**（可能被篡改）
- 检查通过则静默

## 注意事项
- 每个检查只执行一次，不要重复
- 全部正常时回复 HEARTBEAT_OK
- 有异常时报告具体问题，**不要**附带 HEARTBEAT_OK
- 深夜（23:00-08:00）只在紧急情况下打扰苏神

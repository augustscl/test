# darwin-skill 交接文档

> 最后更新：2026-04-13 23:50 | v1
> 下次 agent 读这一个文件就够了

## 🎯 项目目标
将 `alchaincyf/darwin-skill` 适配为可在 OpenClaw / ClaWiser 工作流中复用的本地 skill，保留其核心思想：评估 → 改进 → 实测验证 → 人类确认 → 保留或回滚。

## 📍 当前进展
- 已完成仓库安全审计，未发现安装脚本、可疑外连、敏感信息抓取或系统篡改行为。
- 已决定不按 Claude Code 原路径安装，而是改造为 OpenClaw workspace 内 skill。
- 当前正在生成适配版 `skills/darwin-skill/SKILL.md`。

## ➡️ 下一步
1. 写入 OpenClaw 适配版 SKILL.md
2. 复制 README/展示文件作为参考资料（可选）
3. 后续如需要，再补和 ClaWiser 其他 skill 的联动规范

## 关键经验 & 铁律
- 原仓库偏 Claude Code 生态，不能直接视作 OpenClaw 原生 skill。
- 新 skill 必须挂靠项目，避免成为孤立文件。
- 安装/引入第三方 skill 前，先做安全审计，再做生态适配。

## 架构
- 项目文档：`memory/projects/darwin-skill/HANDOFF.md`
- Skill 目录：`skills/darwin-skill/`
- 软链接：`memory/projects/darwin-skill/skills/darwin-skill`

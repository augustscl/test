# darwin-skill for OpenClaw

这是基于 `alchaincyf/darwin-skill` 思路整理的 OpenClaw 适配版本。

## 当前内容
- `SKILL.md`：OpenClaw / ClaWiser 可用的适配版核心说明
- 原仓库设计思想：评估 → 改进 → 验证 → 人类确认 → 保留或回滚

## 适用场景
- 优化单个 skill
- 批量评估 skills 质量
- 为 skill 建立 baseline 分数
- 在真正修改前，先找清楚 skill 的结构和效果短板

## 说明
这个版本没有直接照搬原作者的 Claude Code 安装路径，而是改成更适合当前 workspace 的写法。
原仓库里的展示页和图片不是核心运行必需，所以当前先不复制，后续要保留展示资产再补。

---
name: 公众号推文发布助手
description: 公众号推文与“日记→PPT配图→插图回文→公众号草稿箱”完整发布工作流。用于处理公众号文章、日记推文、虾王日记、按固有流程发草稿箱、公众号草稿箱发布、将文章配图插回正文后再发布等场景。只要用户提到“公众号”“推文”“草稿箱”“日记发公众号”“按固有流程”“虾王日记”，就应使用此技能，避免漏掉固定步骤。
---

# 公众号推文发布助手

把“写完文章就发”改成“按固定流程交付”。

## 目标

对这类任务，强制走完整链路：

1. 生成正文
2. 回写原始日记/原文到 `memory/YYYY-MM-DD.md`（如果任务属于日记类）
3. 生成 PPT 大纲 `outline.md`
4. 生成逐页提示词 `prompts/*.md`
5. 走固定生图链路出图
6. 把图片插回文章合适位置
7. 发公众号草稿箱
8. 回报产物路径与发布结果

**不允许跳步直发。**

---

## 触发后的第一判断

先判断任务类型：

### A. 日记类
包括但不限于：
- 虾王日记
- 昨天日记 / 今日复盘 / 工作日记
- 根据聊天记录整理成日记

### B. 重要文章类
包括但不限于：
- 公众号推文
- 要发公众号的长文
- 需要做成可传播成品的文章

### C. 单纯修改已完成稿件
只有在用户明确说“只改文案，不重走流程”时，才允许跳过配图与发布步骤。

默认：**只要涉及“公众号发草稿箱”，都按完整流程执行。**

---

## 固定工作流（必须按顺序）

如需目录脚手架，优先使用：

`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/init_article.sh <YYYY-MM-DD> <slug>`

正文完成后，优先使用：

- **自动生成大纲 + 提示词（用 baoyu-slide-deck）**：优先调用 baoyu-slide-deck 一次性生成 outline.md 和 prompts/*.md
- 固定生图执行器：`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/generate_images.sh <article-dir>`（根据 baoyu-slide-deck 生成的提示词生图）
- 自动插图回文：`python3 /Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/insert_images.py <article.md> [imgs-dir]`
- 发布前检查：`python3 /Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/preflight_check.py <article-dir> [--diary]`
- 一键总控：`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/run_pipeline.sh <YYYY-MM-DD> <slug> [--diary]`
- 自动发布版：`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/auto_publish.sh <YYYY-MM-DD> <slug> [--diary] [--publish]`

参考模板位于：

`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/references/workflow-examples.md`

先用脚手架创建文章目录，再往里填正文、大纲、prompts 与配图，避免手工漏文件。

### Step 1：收集原始素材

优先从现有材料生成，不要先问一堆废话：

- 相关 `memory/YYYY-MM-DD.md`
- 相关补充记录（如 `*-ppt-status.md`）
- 当天/前一天对话上下文
- 用户明确补充的信息

如果材料不足，再补问最少问题。

### Step 2：生成正文

输出一版可发布的公众号正文，要求：

- 标题明确
- 开头能抓人
- 正文有结构
- 结尾有观点或总结
- 保留用户/虾王的人设风格

正文文件默认保存到：

`post-to-wechat/YYYY-MM-DD/<slug>/<slug>.md`

其中 `<slug>` 建议使用英文 kebab-case，例如：
- `xiawang-diary-2026-03-17`
- `ai-agent-workflow-review`

### Step 3：如果是日记类，必须回写 memory

**这是硬规则。**

如果任务是“日记”“虾王日记”“根据昨天记录整理日记”，则必须把原始日记正文同步写回：

`memory/YYYY-MM-DD.md`

写回方式：
- 保留原有记录
- 追加 `## 虾王日记原文（用于推文/沉淀）` 区块
- 不要覆盖已有内容

如果没有执行这一步，任务**不算完成**。

### Step 4 & 5：生成 PPT 大纲及逐页提示词（用 baoyu-slide-deck）

**⚠️ 重要：必须用 baoyu-slide-deck 一次性生成大纲 + 提示词！**

在文章目录下生成：
- `outline.md`：PPT 大纲
- `prompts/01-slide-*.md`、`prompts/02-slide-*.md`、`prompts/03-slide-*.md` ...：逐页提示词

执行方式：
- 优先调用 baoyu-slide-deck
- 根据文章内容自动选择风格（技术类选 `blueprint` / `intuition-machine`，教育类选 `sketch-notes`，产品/营销类选 `bold-editorial` 等）
- 生成后的 outline.md 和 prompts 直接用于下一步生图

大纲要求：
- 按文章逻辑拆成 4~8 页
- 每页一句核心结论
- 每页说明要传达的画面氛围/情绪
- 优先服务公众号阅读节奏，而不是做企业汇报腔

推荐结构：
- 封面页
- 冲突/问题页
- 拆解页（2~4 页）
- 总结页

提示词要求：
- 画面描述清晰
- 风格统一（从 baoyu-slide-deck 继承）
- 比例固定 `16:9`
- 清晰度要求固定写明：`4K` 或 `高质量`
- 如果是虾王日记，画面允许更强情绪感和角色感

### Step 6：固定生图链路（硬编码流程，不准乱换）

默认固定：

- 技能：`baoyu-image-gen`
- 模型：`gemini-3-pro-image-preview`
- 比例：`16:9`
- 质量：`4K` 或 `高质量`

除非用户明确改模型，否则不准擅自切换。

执行时优先使用：

`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/generate_images.sh <article-dir>`

该脚本默认：
- 遍历 `prompts/*.md`
- 调用 `baoyu-image-gen/scripts/main.ts`
- 输出到 `imgs/<prompt-name>.png`
- 使用 `google / gemini-3-pro-image-preview / 16:9 / 2k`

说明：当前执行器已经把 provider / model / ratio 固定住；质量参数仍用 `2k` 作为脚本层默认值，后续如用户要求，可继续升级到更强默认质量策略。

如果生图失败：
- 先重试
- 再排查
- 再换最短收口路径
- **不准直接跳过配图发布“纯文字版”**，除非用户明确允许

### Step 7：把图片插回文章

配图生成后，必须把图片插回公众号正文的合适位置。

要求：
- 至少封面图 + 正文关键转折处插图
- 不要把所有图堆在开头
- 插图位置应服务阅读节奏
- 插图后的正文仍然通顺

如果原文是 Markdown，最终发布版本仍然维护为 Markdown 源文件，必要时让发布脚本负责转 HTML。

### Step 8：发布到公众号草稿箱

默认使用：
- `baoyu-post-to-wechat`
- 默认发布方式：`api`
- 主题、颜色、作者等优先读取 EXTEND.md

发布前必须确认：
- 正文文件存在
- `outline.md` 存在
- `prompts/` 存在
- 封面存在
- 图片已插回正文

任何一项缺失，**禁止直接发布。**

如果要走半自动发布，优先使用：

`/Users/suchuanlei/.openclaw/workspace/skills/公众号推文发布助手/scripts/auto_publish.sh <YYYY-MM-DD> <slug> [--diary] [--publish]`

说明：
- 不带 `--publish`：只完成流水线、插图、校验，停在可发布状态
- 带 `--publish`：在校验通过后，直接调用公众号草稿箱发布

### Step 9：结果汇报

最终汇报必须包含：

1. 正文路径
2. `memory` 回写状态（如适用）
3. `outline.md` 路径
4. `prompts/` 路径
5. 配图目录
6. 草稿箱发布结果
7. `media_id`（如果有）

---

## 发布前强制自检清单

发草稿箱前，逐项确认：

- [ ] 这次是不是“公众号文章/日记推文”类任务？
- [ ] 正文是否已完成？
- [ ] 若为日记类，是否已回写 `memory/YYYY-MM-DD.md`？
- [ ] 是否已生成 `outline.md`？
- [ ] 是否已生成 `prompts/*.md`？
- [ ] 是否已按固定链路生图？
- [ ] 是否已把图插回正文？
- [ ] 是否已准备封面？
- [ ] 是否满足发布条件？

**只要有一项是“否”，就不准发布。**

---

## 默认目录规范

文章目录：

`post-to-wechat/YYYY-MM-DD/<slug>/`

建议目录结构：

- `<slug>.md`：正文源稿
- `<slug>.html`：渲染后稿件（如生成）
- `outline.md`：PPT 大纲
- `prompts/`：逐页提示词
- `imgs/`：封面与插图

示例：

- `post-to-wechat/2026-03-18/xiawang-diary-2026-03-17/xiawang-diary-2026-03-17.md`
- `post-to-wechat/2026-03-18/xiawang-diary-2026-03-17/outline.md`
- `post-to-wechat/2026-03-18/xiawang-diary-2026-03-17/prompts/01-cover.md`
- `post-to-wechat/2026-03-18/xiawang-diary-2026-03-17/imgs/cover.png`

---

## 不允许的偷步行为

以下行为一律视为流程违规：

- 只写正文，不生成 PPT 大纲
- 只写正文，不生成 prompts
- 不出图，直接发草稿箱
- 出了图但没插回正文就发
- 日记类任务不写回 memory
- 卡住后只报“还没好”，不推进排查
- 用户说“按固有流程”，却仍然走最短路径

---

## 失败时的处理原则

如果流程卡住：

1. 先定位卡在哪一步
2. 先保住完整流程，不要随便砍步骤
3. 除非用户明确允许，否则不要退化成“纯文字直发”
4. 只有当用户说“先发纯文字版也行”时，才允许降级

---

## 汇报模板

完成后按这个格式汇报：

- 正文：`<path>`
- memory 回写：已完成 / 不适用
- 大纲：`<path>`
- prompts：`<path>`
- 配图：`<path>`
- 草稿箱：成功 / 失败
- media_id：`<id>`
- 备注：如有降级、重试、临时调整，必须说明

---

## 核心原则

这个技能的存在意义只有一个：

**把“我记得有流程”变成“我不按流程就不能交付”。**

以后只要触发这个技能，就默认是**流程优先，记忆靠边**。

## 推荐执行顺序

### 只准备不发布
1. 写正文
2. `run_pipeline.sh`
3. `generate_images.sh`
4. `insert_images.py`
5. `preflight_check.py`

### 直接走半自动发布
1. 写正文
2. 准备图片
3. `auto_publish.sh <date> <slug> [--diary] --publish`

如果 `preflight_check.py` 不通过，禁止强行发布。

# content-automation-workflow

内容创作自动化总控 skill。

## 位置
- Skill 主文件：`skills/content-automation-workflow/SKILL.md`
- 说明文件：`skills/content-automation-workflow/README.md`

## 作用
这是整个内容生产链的总控层，不是某一个具体内容任务的专用 skill。
它负责把内容任务拆成 5 层：
1. Input
2. Processing
3. Production
4. Distribution
5. Deposition

## 适用场景
- 搭内容工厂
- 做内容自动化工作流
- 一份源材料改写成多平台内容
- 设计公众号 / 短帖 / PPT / 配图 / 沉淀的统一链路
- 给具体子 skill 提供上位编排框架

## 当前关系
- `content-automation-workflow`：总控
- `ai-news-briefing`：新闻快讯专用子 skill
- `baoyu-post-to-wechat`：公众号发布
- `content-digest`：内容提炼与改写

## 建议 Git 提交时一起带上
- `skills/content-automation-workflow/`
- `skills/ai-news-briefing/`

这样仓库里就同时有：
- 总控 skill
- 一个已经落地的垂直场景示例 skill

# 公众号推文发布助手参考模板

## 1. 标准目录结构

```text
post-to-wechat/YYYY-MM-DD/<slug>/
├── <slug>.md
├── <slug>.html
├── outline.md
├── prompts/
│   ├── 01-cover.md
│   ├── 02-conflict.md
│   ├── 03-breakdown-1.md
│   ├── 04-breakdown-2.md
│   ├── 05-turning-point.md
│   └── 06-summary.md
└── imgs/
    ├── cover.png
    ├── 02-conflict.png
    ├── 03-breakdown-1.png
    ├── 04-breakdown-2.png
    ├── 05-turning-point.png
    └── 06-summary.png
```

## 2. outline.md 模板

```md
# PPT 大纲

## Page 1｜封面
- 核心信息：文章主题与第一视觉冲击
- 画面情绪：强识别、高情绪、适合封面

## Page 2｜冲突/问题
- 核心信息：昨天/这次到底卡在哪
- 画面情绪：紧张、失衡、对抗感

## Page 3｜拆解 1
- 核心信息：第一个关键原因
- 画面情绪：冷静分析、结构化

## Page 4｜拆解 2
- 核心信息：第二个关键原因
- 画面情绪：继续推进、逻辑压强

## Page 5｜转折
- 核心信息：真正的认知改变或关键动作
- 画面情绪：由压抑转为收束

## Page 6｜总结
- 核心信息：最终观点/行动原则
- 画面情绪：稳、狠、收口
```

## 3. 单页 prompt 模板

每一页建议结构：

```md
# Page 01 Cover

主题：<这一页的核心主题>

画面目标：
- 一句话说明这张图要表达什么

主体元素：
- 主角/物体
- 环境
- 动作/状态

视觉风格：
- cinematic
- high contrast
- modern editorial
- strong composition

构图要求：
- 16:9
- suitable for article illustration
- clear focal point
- layered foreground / midground / background

清晰度要求：
- 4K
- high quality

禁用项：
- 多余文字
- 水印
- 低清晰度
- 画面主体混乱
```

## 4. 日记类文章建议分页

适合“复盘 / 翻车 / 成长”主题：

1. 封面：一句狠标题 + 情绪封面
2. 冲突：翻车现场/崩点
3. 原因一：执行问题
4. 原因二：路径问题
5. 转折：认知变化或修正动作
6. 总结：原则提炼

## 5. 完成汇报模板

```md
- 正文：`<path>`
- memory 回写：已完成 / 不适用
- 大纲：`<path>`
- prompts：`<path>`
- 配图：`<path>`
- 草稿箱：成功 / 失败
- media_id：`<id>`
- 备注：如有重试、替代方案、未完成项，必须说明
```

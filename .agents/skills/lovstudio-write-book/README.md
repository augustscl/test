<p align="center">
  <img src="docs/images/cover.png" alt="write-book Cover" width="100%">
</p>

<h1 align="center">write-book</h1>

<p align="center">
  <strong>AI 逐章写书，压缩摘要策略突破上下文窗口限制</strong><br>
  <sub>Claude Code Skill · Content Creation</sub>
</p>

---

## Features

- **突破上下文窗口限制** — 通过 OUTLINE + BOOK_SUMMARY 压缩摘要策略（约 9KB 开销），支持写作任意长度书籍
- **5 阶段工作流** — Plan → Research → Write → Review → Build，结构化完成从大纲到成书
- **多种写作风格** — O'Reilly 实战派、学术专著、教程系列等，按需切换
- **双格式输出** — mdBook HTML（GitHub Pages 部署）+ Pandoc PDF（CJK 中文排版就绪）
- **GitHub 原生** — 每本书一个 repo，Git 版本控制，Actions 自动构建

## How It Works

每次写新章节时，只加载 4 个文件而非全书：

| 文件 | 作用 | 大小 |
|------|------|------|
| `OUTLINE.md` | 全局大纲，理解全书结构 | ~2KB |
| `BOOK_SUMMARY.md` | 全书压缩摘要，每章 ≤500 字 | ~5KB |
| `chapter-xx/refs.md` | 当前章参考文献 | ~1KB |
| `glossary.md` | 术语表，保持前后一致 | ~1KB |

这样即使写到第 20 章，AI 依然清楚第 1 章说了什么。

## Quick Start

```bash
# 安装依赖
cargo install mdbook        # or: brew install mdbook
brew install pandoc basictex
brew install gh

# 开始写书
# 在 Claude Code 中输入：
/write-book
```

## Workflow

1. **Plan** — 收集书籍信息 → 生成 OUTLINE.md → 创建 repo 骨架 → 初始提交
2. **Research** — WebSearch + context7 → 每章生成 refs.md 参考文献
3. **Write** — 每次一章，加载压缩摘要 + 参考文献 + 术语表
4. **Review** — 一致性检查、术语校对、交叉引用、润色
5. **Build** — mdBook → HTML | Pandoc → PDF

## Book Repo Structure

```
book-repo/
├── book.toml              # mdBook config
├── OUTLINE.md             # 全局大纲
├── BOOK_SUMMARY.md        # 全书压缩摘要
├── glossary.md            # 术语表（中英对照）
├── src/
│   ├── SUMMARY.md         # mdBook 目录
│   ├── chapter-01/
│   │   ├── README.md      # 章节正文
│   │   └── refs.md        # 本章参考文献
│   └── ...
├── assets/images/         # 图片、图表
└── .github/workflows/     # 自动构建
```

## Showcase

> "以前写书最头疼的就是上下文断裂，写到第 8 章忘了第 3 章说过什么。write-book 的压缩摘要策略彻底解决了这个问题。"
> — 张工 · 后端工程师，《AI 编程实战》12 章技术书

> "从大纲到完稿只花了 3 个周末，质量不输市面上的技术书。"
> — 李明 · SRE 团队负责人，O'Reilly 风格 Kubernetes 教程

> "学术写作最需要前后一致的术语和引用，BOOK_SUMMARY 机制让 AI 始终记得全书脉络。"
> — 王薇 · MBA 在读

## License

Commercial · by [lovstudio](https://github.com/lovstudio)

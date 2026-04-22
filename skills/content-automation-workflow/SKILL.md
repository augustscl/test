---
name: content-automation-workflow
description: Build and run a five-layer content creation automation workflow for research-driven publishing and repurposing. Use when the user wants to create a content pipeline, automate content production, turn one source into multiple content formats, build a publishing workflow, or design a content factory across collection, processing, production, distribution, and knowledge deposition.
---

# Content Automation Workflow

Build a five-layer content pipeline that turns raw inputs into reusable multi-channel outputs.

Use this skill when the goal is not just to write one piece, but to design or execute a repeatable workflow:
- collect material from links, audio, video, docs, notes, or prior context
- normalize everything into markdown
- extract insights and structure
- generate multiple content formats from one source
- distribute or prepare drafts for multiple channels
- deposit outputs into memory or knowledge assets for reuse

## Core Principle

Default to this five-layer architecture:

1. **Input Layer**: collect and normalize source material
2. **Processing Layer**: summarize, structure, translate, and evaluate value
3. **Production Layer**: generate long-form, short-form, slides, image, audio, or derivative assets
4. **Distribution Layer**: publish or prepare channel-specific drafts
5. **Deposition Layer**: store assets, decisions, and reusable fragments for future work

Do not jump straight to publishing if upstream structure is unclear.

## Workflow Decision Tree

### A. If the user gives raw source material
Run the full 5-layer workflow.

### B. If the user gives a finished article and wants repurposing
Skip most of Input Layer, lightly run Processing Layer, then go to Production + Distribution.

### C. If the user wants a repeatable pipeline or skill/system design
Analyze all 5 layers explicitly and output a workflow architecture before execution.

### D. If the user wants a fast daily content routine
Design an MVP workflow first, not the most complex version.

## Layer 1: Input Layer

Goal: convert every source into a standard markdown-ready working asset.

### Typical source types and preferred skills

| Source | Preferred skills |
|---|---|
| Web pages / news / articles | `tavily-search`, `openclaw-tavily-search`, `baoyu-url-to-markdown` |
| PDFs / documents | `pdf`, `docx`, `getnote`, `ima-note` |
| Audio / video | `asr`, `youtube-transcript-cn`, `video-chapter-splitter` |
| Existing project context | `load-game`, `retrieval-enhance`, `memory-deposit` |

### Actions

1. Identify the source type.
2. Pull or extract the raw material.
3. Convert it into markdown or a structured text artifact.
4. Save intermediate source files when the workflow is long or reusable.

### Output of Layer 1

A clean working source, usually one of:
- `source.md`
- `transcript.md`
- `notes.md`
- `digest-input.md`

## Layer 2: Processing Layer

Goal: turn source material into usable thinking units.

### Preferred skills

- `summarize`
- `content-digest`
- `explainer`
- `baoyu-format-markdown`
- `deepl`
- `edagent-conversation-design`
- `hdd` when direction is unclear
- `sdd` when audience, scenario, or stakeholder context matters

### Actions

1. Produce a short summary.
2. Extract key points, arguments, claims, and reusable examples.
3. Identify audience, use case, and likely best channels.
4. Decide which output formats matter most.
5. If needed, translate or restructure for tone and readability.

### Minimum required outputs

Produce these before large-scale content generation:
- **3-sentence summary**
- **key points list**
- **target audience**
- **recommended output formats**

### Optional analysis outputs

When valuable, also produce:
- title candidates
- controversy / novelty angle
- course / talk / article angle
- reusable quote or social-post fragments

## Layer 3: Production Layer

Goal: generate one or more publishable content assets from the processed source.

### Long-form article route

Preferred skills:
- `公众号推文发布助手`
- `baoyu-post-to-wechat`
- `baoyu-format-markdown`
- `baoyu-cover-image`
- `baoyu-article-illustrator`
- `baoyu-image-gen`

Use when the user wants:
- a公众号 article
- a research explainer
- a long-form structured post
- an article draft with images

### Slide / PPT route

Preferred skills:
- `baoyu-slide-deck`
- `ppt-afp`
- `pptx-generator`
- `baoyu-image-gen`

Use when the output should become:
- teaching slides
- presentation decks
- one-page visual explainers
- PPT-derived content assets

### Short-form / social route

Preferred skills:
- `baoyu-post-to-weibo`
- `baoyu-post-to-x`
- `baoyu-xhs-images`
- `baoyu-image-gen`
- `xiaohongshu` when available/applicable

Use when the user wants:
- social threads
- short-form opinion posts
- image-card content
- repurposed platform variants

### Audio / spoken-content route

Preferred skills:
- `podcast-script-generator`
- `podcast`
- `tts`
- `mm-voice-maker`

Use when the user wants:
- spoken scripts
- podcast outlines
- audio-first repurposing
- voice delivery assets

### Production rule

Default to **one source, many outputs**:
- one canonical long-form source
- one short summary version
- one slide or visual version
- one short social version

Do not force all routes. Choose only what serves the stated goal.

## Layer 4: Distribution Layer

Goal: adapt output for each channel instead of blindly reposting the same text.

### Preferred destinations

- WeChat article drafts
- Feishu docs / wiki
- Weibo drafts
- X drafts
- social image packages
- internal knowledge docs

### Actions

1. Decide whether to auto-publish or prepare drafts.
2. Format content for the destination.
3. Attach cover, illustrations, or slide assets when needed.
4. Prefer draft or review mode for public channels unless the user explicitly wants full auto-send.

### Distribution policy

- **Internal or draft-first** by default
- **Public publish** only when clearly requested
- Keep track of what was produced for which channel

## Layer 5: Deposition Layer

Goal: turn each content run into reusable assets.

### Preferred skills

- `memory-deposit`
- `save-game`
- `retrieval-enhance`
- Feishu doc/wiki/bitable related tools when storing in knowledge systems

### What to deposit

At minimum, deposit:
- source link or source description
- summary
- key points
- final outputs created
- image or slide asset locations
- channel variants created
- follow-up topic ideas

### Why this layer matters

Without deposition, every content task starts from zero.
With deposition, future content becomes retrieval + remix instead of full recreation.

## Reference Files

Read these only when needed:

- `references/workflow-templates.md`: use when the user wants a concrete workflow template instead of a generic framework
- `references/channel-recipes.md`: use when adapting outputs for specific destinations like WeChat, X, Weibo, Xiaohongshu, PPT, Feishu, or audio
- `references/deposition-schema.md`: use when the workflow must store outputs as reusable knowledge assets
- `references/mvp-routes.md`: use when the user wants the fastest practical version to run first
- `references/output-contracts.md`: use when the user wants stable, product-like output structure for workflow design, execution, channel adaptation, deposition, or MVP recommendations

## Standard Output Format

When designing a workflow, return these sections in order:

### 1. Workflow Goal
One paragraph.

### 2. Five-Layer Architecture
List each layer with:
- purpose
- inputs
- outputs
- preferred skills

### 3. Recommended MVP
Describe the smallest useful version to implement first.

### 4. Scale-Up Path
Describe how to evolve from semi-automatic to fully automated.

### 5. Immediate Next Action
Give the clearest next action, not a vague conclusion.

## Default MVP Blueprint

When the user asks for a practical starting workflow, recommend this default MVP:

1. Search or ingest source material
2. Convert to markdown
3. Summarize and extract key points
4. Produce one long-form draft and one short-form derivative
5. Generate one matching image asset
6. Save draft to destination
7. Deposit summary and artifacts for reuse

## Constraints

- Do not over-engineer the first version.
- Prefer a working pipeline over a perfect architecture diagram.
- Do not auto-publish publicly unless clearly instructed.
- Keep one canonical source of truth for the content.
- Reuse existing skills instead of inventing duplicate workflows.
- When the workflow spans many steps, state assumptions briefly and keep going.

## Recommended Pairings

- News / trend monitoring → `tavily-search` + `baoyu-url-to-markdown` + `summarize`
- Article to WeChat → `公众号推文发布助手` + `baoyu-image-gen` + `baoyu-post-to-wechat`
- Article to slides → `baoyu-slide-deck` + `baoyu-image-gen`
- Long-form to social variants → `baoyu-format-markdown` + platform-specific post skills
- Audio/video to reusable content → `asr` or `youtube-transcript-cn` + `content-digest` + downstream production skills

## If asked to build a new automation skill

Create the skill around the same five-layer architecture.
Keep SKILL.md short.
Push detailed templates or schemas into `references/`.
Only add scripts when deterministic automation is truly needed.

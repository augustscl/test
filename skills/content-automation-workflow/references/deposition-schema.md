# Deposition Schema

Use this file when the workflow must store outputs for future reuse instead of ending at publication.

## Purpose

Deposition turns one-off content work into reusable assets.
Every substantial content run should leave behind a structured record.

## Minimum Deposition Record

Store these fields after each meaningful run:

| Field | Description |
|---|---|
| `topic` | Main topic or working title |
| `source_type` | URL, PDF, note, transcript, article, mixed |
| `source_locator` | Link, file path, or description of origin |
| `summary` | 3-sentence summary |
| `key_points` | Core insights, claims, or takeaways |
| `target_audience` | Intended audience |
| `output_types` | WeChat, slides, thread, audio, etc. |
| `artifacts` | Paths or links to outputs |
| `status` | draft, published, archived, reused |
| `follow_up_ideas` | Next related topics or derivative ideas |
| `reuse_tags` | Retrieval-friendly tags |
| `created_at` | Creation time |
| `updated_at` | Last touched time |

## Recommended Extended Record

Add these when useful:

| Field | Description |
|---|---|
| `canonical_source` | Source-of-truth file for the content |
| `title_candidates` | Alternate titles or hooks |
| `channel_variants` | Channel-specific output list |
| `visual_assets` | Covers, illustrations, slide images |
| `slide_assets` | Outline, prompts, deck files |
| `quoted_lines` | Reusable short quotes or hooks |
| `thesis` | Core thesis in one sentence |
| `series_name` | If part of a series |
| `series_position` | Episode or sequence index |
| `risks_or_cautions` | Facts requiring verification, model-generated claims, etc. |

## Deposition Destinations

Choose one or more depending on the workflow:

### 1. Local project memory
Use when the content is part of ongoing work in the workspace.

Recommended destinations:
- project markdown files
- `memory-deposit`
- `save-game`

### 2. Feishu doc / wiki
Use when the content should become searchable, shareable internal knowledge.

Recommended destinations:
- `feishu_doc`
- `feishu_wiki`

### 3. Structured table / asset index
Use when you need repeated retrieval, filtering, or editorial management.

Recommended fields in a table:
- topic
- content type
- channel
- status
- source link
- doc link
- output link
- tags
- created time
- updated time

## Naming Rules

Prefer stable, reusable naming:

- topic slug for folders and assets
- one canonical source per run
- explicit output suffixes

Examples:
- `gpt-image-2-news/source.md`
- `gpt-image-2-news/wechat-draft.md`
- `gpt-image-2-news/thread-version.md`
- `gpt-image-2-news/cover.png`
- `gpt-image-2-news/deposition.md`

## Minimal Deposition Markdown Template

```markdown
# {topic}

- Source type: {source_type}
- Source locator: {source_locator}
- Target audience: {target_audience}
- Output types: {output_types}
- Status: {status}
- Reuse tags: {reuse_tags}
- Created at: {created_at}
- Updated at: {updated_at}

## Summary
{summary}

## Key Points
- ...
- ...
- ...

## Artifacts
- Canonical source: ...
- WeChat draft: ...
- Slides: ...
- Visual assets: ...

## Follow-up Ideas
- ...
- ...

## Risks or Cautions
- ...
```

## Operating Rule

If the run generated meaningful insight, structured content, or reusable assets, do not stop at publication.
Deposit it.

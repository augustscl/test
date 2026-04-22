# Workflow Templates

Use these templates when the user wants a concrete, repeatable content automation setup instead of a generic architecture answer.

## Template 1: AI News Briefing Workflow

### Best for
- daily AI news
- trend briefings
- fast industry updates
- newsletter-style short analysis

### Flow
1. Search current topics with `tavily-search` or `openclaw-tavily-search`
2. Pull target articles with `baoyu-url-to-markdown`
3. Merge and normalize into one markdown source
4. Run `summarize` or `content-digest`
5. Produce:
   - short summary
   - longer WeChat draft
   - social short post variant
6. Generate one matching image with `baoyu-image-gen`
7. Save draft and deposit reusable notes

### Deliverables
- `news-brief.md`
- `wechat-draft.md`
- `social-posts.md`
- `cover.png`
- deposited summary + key points

### Recommended MVP
Start with one topic, one long-form draft, one short-form post, one image.

---

## Template 2: Long-form Article Repurposing Workflow

### Best for
- one article to many channels
- converting a flagship article into multiple assets
- creator workflows that need leverage from one source

### Flow
1. Load the canonical article
2. Extract:
   - thesis
   - key points
   - quotes
   - examples
3. Produce variants:
   - WeChat long-form
   - social thread
   - Xiaohongshu card copy
   - one-page explainer summary
4. Generate cover or supporting images
5. Save all channel variants
6. Deposit content fragments for future reuse

### Deliverables
- `canonical-article.md`
- `thread-version.md`
- `xhs-version.md`
- `one-page-summary.md`
- image assets

### Recommended MVP
Do not start with all channels. Start with long-form + one social channel + one image.

---

## Template 3: Video or Audio to Article + PPT Workflow

### Best for
- turning talks into articles
- course content reuse
- webinar repurposing
- turning spoken material into slide content

### Flow
1. Extract transcript with `asr` or `youtube-transcript-cn`
2. Split long material with `video-chapter-splitter` if needed
3. Normalize transcript into markdown
4. Run `content-digest` or `summarize`
5. Create two output lines:
   - article line
   - slide line
6. Article line:
   - structure into long-form draft
   - add title and summary
7. Slide line:
   - generate outline
   - generate prompts
   - generate visuals / deck assets
8. Deposit transcript, article, slide structure, and follow-up topics

### Deliverables
- `transcript.md`
- `article-draft.md`
- `outline.md`
- `prompts/`
- slide assets or PPTX

### Recommended MVP
Start with transcript → digest → article draft. Add slides only after the article route is stable.

---

## Template 4: Knowledge Base to Series Content Workflow

### Best for
- existing notes or wiki content
- structured knowledge reuse
- educational series production

### Flow
1. Gather source material from docs, notes, wiki, or prior content
2. Cluster content into themes
3. Select one theme per piece
4. For each theme produce:
   - one teaching article
   - one short summary
   - one visual or slide concept
5. Keep a series index to avoid repeating the same angle
6. Deposit the produced assets and uncovered gaps

### Deliverables
- `series-plan.md`
- `episode-01.md`
- `episode-01-short.md`
- `episode-01-visual.md`
- reusable theme index

### Recommended MVP
First create the series plan and one sample episode.

---

## Template 5: Content Factory Operating Model

### Best for
- building a repeatable team or agent workflow
- high-frequency content operations
- standardizing output and review

### Flow
1. Fix one canonical source format
2. Fix one processing checklist
3. Fix 2 to 4 output channels
4. Define which outputs are auto-generated vs review-required
5. Define deposition schema for all produced assets
6. Run every task through the same five-layer pipeline

### Required controls
- source of truth file
- naming rules
- destination rules
- review checkpoint before public publish
- deposition after each run

### Recommended MVP
Use one content type only, such as daily AI news or weekly article repurposing, before scaling to a full content factory.

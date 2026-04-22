---
name: ai-news-briefing
description: >
  Build a Chinese AI news briefing from the last 24 hours of real AI industry news. Produces a long-form markdown briefing,
  a social short-post version, a cover image prompt or image, and a deposition record. Use when user asks for 今日 AI 新闻快讯,
  AI 新闻摘要, AI news digest, or wants to stress test an AI-news workflow end to end.
---

# AI News Briefing

Generate a high-signal Chinese AI news briefing from the last 24 hours.

## Output Contract

This skill should usually produce all of the following:
1. `ai-news-brief-YYYY-MM-DD.md` - 长文快讯版
2. `ai-news-social-YYYY-MM-DD.md` - 社交短帖版
3. `ai-news-deposition-YYYY-MM-DD.md` - 沉淀记录
4. Cover image prompt or generated image
5. A brief evaluation of the workflow quality

## Core Principle

Do **not** mechanically summarize search results.
The real job is to turn scattered AI news into a **coherent industry signal**.

## Required Workflow

### Step 1: Search the last 24 hours
Use web search to find AI industry news in the last 24 hours.
Prefer queries around:
- major model labs
- major funding and capital moves
- AI infrastructure and chips
- important product launches
- notable policy or security events

### Step 2: Filter sources aggressively
Only keep high-trust or clearly attributable sources.

**Prefer**:
- official company announcements
- Reuters
- CNBC
- Bloomberg
- TechCrunch
- The Information
- company newsroom / blog

**Avoid by default**:
- low-quality aggregators
- SEO farms
- random LinkedIn reposts
- YouTube summary videos
- social repost pages
- pages that only restate another source without new information

**Rule**: if a claim is important, try to keep at least one primary or clearly attributable source.

### Step 3: Select 1 to 3 stories only
Do not flood the digest.
Pick 1 to 3 stories that together create a meaningful pattern.

Selection criteria:
- high signal
- recent enough
- strategically relevant
- can be connected into one main thesis

### Step 4: Extract the real thesis
Before writing, identify the single best synthesis.

Examples:
- competition is moving from model quality to workflow ownership
- AI race is becoming product + compute + capital
- frontier labs are binding themselves to infrastructure providers

**The briefing must be organized around this thesis.**
Not around “story 1 / story 2 / story 3” in isolation.

### Step 5: Produce differentiated outputs

#### A. Long-form briefing
Requirements:
- Chinese
- readable like a real WeChat article draft
- not robotic
- has one clear title
- has intro, body, and conclusion
- explains why each story matters
- ends with one sharp summary line

#### B. Social short-post
Requirements:
- shorter than the long form
- not a copy-paste summary
- should feel punchier and more condensed
- optimized for quick sharing

#### C. Deposition record
Must be a real file.
Should include:
- date
- selected stories
- source list
- thesis
- outputs generated
- workflow observations
- what worked / what failed

### Step 6: Cover image rules
If generating a cover image:
- visual theme must match the thesis, not just one company
- no logo dependency unless user explicitly wants it
- suitable for article cover use
- default style: premium editorial / strategic / tech magazine feel

### Step 7: Evaluation block
After generating outputs, assess the workflow on:
1. input quality
2. source cleanliness
3. processing depth
4. output differentiation
5. deposition reality
6. major failure points

## Hard Rules

- Do not use more than 3 stories unless user explicitly asks.
- Do not treat search ranking as editorial judgment.
- Do not produce long-form and short-form as near duplicates.
- Do not claim deposition unless files are actually written.
- Do not rely on low-quality aggregator claims when a primary source is available.
- If image generation provider deviates from the intended default, explicitly report that deviation.

## Recommended File Naming

Write artifacts into a working directory such as `workspace/tmp/` unless the user asks for another location:
- `ai-news-brief-YYYY-MM-DD.md`
- `ai-news-social-YYYY-MM-DD.md`
- `ai-news-deposition-YYYY-MM-DD.md`
- `ai-news-sources-YYYY-MM-DD.md` (optional)

## Quality Bar

A good result should make the reader feel:
- I now know what happened
- I know why it matters
- I can see the broader pattern
- this is publishable after light editing

A bad result feels like:
- stitched search snippets
- repetitive summary
- too many stories with no thesis
- fancy words with no actual judgment

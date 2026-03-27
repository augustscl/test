---
name: docx
description: Generate and edit Word documents (.docx). Supports professional documents including covers, charts, track-changes editing, and more. Suitable for any .docx creation or modification task.
---

# Part 1: Goals

## ⚠️ When to Unzip vs Read

**To preserve ANY formatting from the source document, MUST unzip and parse XML.**

Read tool returns plain text only — fonts, colors, alignment, borders, styles are lost.

| Need | Method |
|------|--------|
| Text content only (summarize, analyze, translate) | Read tool is fine |
| Formatting info (copy styles, preserve layout, template filling) | Unzip and parse XML |
| Structure + comments/track changes | `pandoc input.docx -t markdown` |

## Core Principles

1. **Preserve formatting** — When editing existing documents, retain original formatting. Clone and modify, never recreate.

2. **Correct feature implementation** — Comments need multi-file sync. Track Changes need revision marks. Use the right structure.

**Never use python-docx/docx-js as fallback.** These libraries produce lower quality output than direct XML manipulation.

## Source Principle

**Template provided = Act as form-filler, not designer.**
- Format is the user's decision
- Task: replace placeholders, not redesign
- Like filling a PDF form—do not redesign

**No template = Act as designer.** Design freely based on scenario.

For .doc (legacy format), first convert with `libreoffice --headless --convert-to docx`.

---

# Part 2: Execution

## File Structure

```
docx/
├── SKILL.md                      ← This file (entry point + reference)
├── references/
│   ├── CreationGuide.md          → C# SDK reference (element order, visual design, page layout, XML)
│   └── EditingGuide.md           → Complete Python editing tutorial (comments, track changes, 5-file sync)
├── scripts/
│   ├── docx                      → Unified entry (the only script to call)
│   ├── validate_all.py           → Unified Python validation/fix pipeline used by `build` and `validate`
│   ├── fix_element_order.py      → Standalone element-order fixer reference
│   ├── validate_docx.py          → Standalone business-rule validator reference
│   ├── generate_backgrounds.py       → Morandi style backgrounds
│   ├── generate_inkwash_backgrounds.py → Ink-wash style backgrounds
│   └── generate_chart.py         → matplotlib (only for heatmaps/3D/radar; simple charts must use native)
├── assets/
│   └── templates/
│       ├── KimiDocx.csproj       → Project file template (for creating new docs)
│       ├── Program.cs            → Program entry template
│       ├── Example.cs            → Complete example (cover+TOC+charts+back cover)
│       ├── CJKExample.cs         → CJK content patterns (quote escaping, fonts)
│       └── xml/                  → XML templates for comments infrastructure
└── validator/                    → OpenXML validator bundle (pre-compiled, platform-specific, used only when compatible)
```

**Creating new documents**: Use C# SDK with `./scripts/docx build` → See `Example.cs` for patterns, `CJKExample.cs` for CJK content
**Editing existing documents**: Use Python + lxml → See `references/EditingGuide.md` for complete tutorial

⚠️ **Do NOT mix these approaches.** C# SDK for creation, Python for editing. Never use python-docx/docx-js.

## Environment Setup

First time, execute in the SKILL directory:

```bash
~/.claude/skills/docx/scripts/docx init
```

**Path Conventions**:

| Path | Purpose |
|------|---------|
| `~/.claude/skills/docx/` | SKILL directory (scripts, templates, validator) |
| `/tmp/docx-work/` | Working directory, edit `Program.cs` here |
| `~/Desktop/` | Default output directory (override with `DOCX_OUTPUT_DIR` env var) |

**Script Commands** (`./scripts/docx <cmd>`):

| Command | Purpose |
|---------|---------|
| `env` | Show environment status (no changes) |
| `init` | Setup required build dependencies + workspace |
| `build [out]` | Restore, compile, run, validate (default: `~/Desktop/output.docx`) |
| `validate FILE` | Run validation on an existing docx |

The script automatically handles:
- Detects `python3` for all flows; detects `dotnet` for `init`/`build` and for OpenXML validation when available
- Searches common macOS `dotnet` locations: `PATH`, `/opt/homebrew/bin/dotnet`, `/usr/local/bin/dotnet`, `~/.dotnet/dotnet`
- Uses `timeout` when present, otherwise `gtimeout`; if neither exists, restore still runs without a time limit
- Initializes working directory and copies template files
- Always runs the Python validation chain; runs the OpenXML validator only when the bundle matches the current platform/runtime target

**Dependency behavior**:
- `dotnet` is auto-installed when missing or too old during `init`/`build`
- On macOS, a broken `dotnet` install is **not** auto-deleted; the script prints repair steps instead
- `pandoc`, `playwright`, and `matplotlib` are optional and only detected, not auto-installed

**macOS Playwright recommendation**:

Use a virtual environment instead of installing into the system Python environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install playwright
python -m playwright install
```

## Build Process

**Must use `./scripts/docx build`**, do not execute `dotnet build && dotnet run` separately (skips validation).

### Program.cs Output Path Convention (Critical)

**Program.cs must get output path from command line arguments**, otherwise build script cannot find the generated file:

```csharp
// Correct - get output path from command line arguments
string outputFile = args.Length > 0 ? args[0] : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "output.docx");

// Wrong - hardcoded path causes build failure
string outputFile = "my_document.docx";  // Script can't find file!
```

| Step | Action | Notes |
|------|--------|-------|
| 1. Restore | `dotnet restore` | Uses `timeout`/`gtimeout` when available; otherwise restores without a time limit |
| 2. Compile | `dotnet build` | Provides fix suggestions on failure |
| 3. Generate | `dotnet run -- <output path>` | Path passed via command line args |
| 4. Unified Python validation | `validate_all.py` | Auto-fixes element order/settings/table widths, then runs business-rule checks |
| 5. OpenXML validation | `validator/` | Runs only when the validator bundle is compatible with the current platform |
| 6. Statistics | Character + word count | Optional (requires pandoc) |

**Validation is mandatory**: the Python validation chain always runs. If the optional platform-specific OpenXML validator is incompatible, the script prints a warning and continues with Python validation only. On validation failure, the file is kept but warnings are shown. Check error messages to fix issues.

### Standalone Validation

```bash
~/.claude/skills/docx/scripts/docx validate ~/Desktop/report.docx
```

This always runs `validate_all.py`. If a compatible `dotnet` runtime and validator bundle are available, it also runs the OpenXML validator; otherwise it prints a clear warning and skips that step.

### Content Verification (Mandatory)

**pandoc is the SOURCE OF TRUTH.** OpenXML validation (when available) checks structure; pandoc shows actual content.

Before delivery, verify with pandoc:
- `pandoc output.docx -t plain` — check text completeness
- For revisions/comments: add `--track-changes=all` to verify marker positions

**⚠️ Critical**: `comments.xml` exists ≠ comments visible. Count mismatch = `doc_tree` not saved. See `references/EditingGuide.md` §5.3.

---

# Part 3: Quality Standards

## Delivery Standard

**Generic styling and mediocre aesthetics = mediocre delivery.**

Deliver studio-quality Word documents with deep thought on content, functionality, and styling. Users often don't explicitly request advanced features (covers, TOC, backgrounds, back covers, footnotes, charts)—deeply understand needs and proactively extend.

## Language Consistency

**Document language = User conversation language** (including filename, body text, headings, headers, TOC hints, chart labels, and all other text).

## Headers and Footers - REQUIRED BY DEFAULT

Most documents **MUST** include headers and footers. The specific style (alignment, format, content) should match the document's overall design.

- **Header**: Typically document title, company name, or chapter name
- **Footer**: Typically page numbers (format flexible: "X / Y", "Page X", "— X —", etc.)
- **Cover/Back cover**: Use `TitlePage` setting to hide header/footer on first page

## Professional Elements (Critical)

Create documents that exceed user expectations, proactively add professional elements, don't wait for users to ask. **Delivery standard: Visual quality of a top designer in 2024.**

**Cover & Visual:**
- Formal documents (proposals, reports, financials, bids, contracts) / creative documents (invitations, greeting cards) must have **cover and back cover**
- Covers must have designer-quality background images
- Body pages can optionally include backgrounds to enhance visual appeal

**Structure:**
- Long documents (3+ sections) add TOC, must add refresh hint after TOC

**Data Presentation:**
- When comparing data or showing trends, use charts instead of plain text lists
- Tables use light gray headers or three-line style, avoid Word default blue

**Links & References:**
- URLs must be clickable hyperlinks
- Multiple figures/tables add numbering and cross-references ("see Figure 1", "as shown in Table 2")
- Academic/legal/data analysis citation scenarios implement correct in-text click-to-jump references with corresponding footnotes/endnotes

### TOC Refresh Hint

Word TOC is field code, page numbers may be inaccurate when generated. **Must add gray hint text after TOC**, informing users to manually refresh:

```
Table of Contents
─────────────────
Chapter 1 Overview .......................... 1
Chapter 2 Methods ........................... 3
...

(Hint: On first open, right-click the TOC and select "Update Field" to show correct page numbers)
```

**Hint text requirements**:
- Visually subtle — gray color, smaller font size, should not compete with actual TOC entries
- Language: **Matches user conversation language**

### Only When User Explicitly Requests

| Feature | Reason |
|---------|--------|
| Watermark | Changes visual state. **SDK limitation**: VML watermark classes don't serialize correctly; must write raw XML to header. |
| Document protection | Restricts editing |
| Mail merge fields | Requires data source |

### Chart Selection Strategy (Critical)

**Default to native Word charts**, editable, small file size, professional.

| Chart Type | Method | Notes |
|------------|--------|-------|
| Pie chart | **Native** | `Example.cs` → `AddPieChart()` |
| Bar chart | **Native** | `Example.cs` → `AddBarChart()` |
| Line chart | **Native** | Reference bar chart structure, use `c:lineChart` |
| Horizontal bar | **Native** | Reference bar chart structure, use `barDir="bar"` |
| Heatmap, 3D, radar | matplotlib | Word native doesn't support |
| Complex statistics (box plot, etc.) | matplotlib | Word native doesn't support |

Native charts are preferred (editable, smaller files), but matplotlib is acceptable for data analysis scenarios.

### Inserting Images/Charts

Any PNG (matplotlib charts, backgrounds, photos) must be inserted using `AddInlineImage()`:

```csharp
AddInlineImage(body, mainPart, "/path/to/image.png", "Description", docPrId++);
```

**Critical**:
- Chart labels/titles must match document language (e.g., Chinese labels for Chinese docs)
- Build output shows `X images` — if 0, images were not inserted

## Content Constraints

### Word/Page Count Requirements

| User Request | Execution Standard |
|--------------|-------------------|
| Specific word count (e.g., "3000 words") | Actual output within ±20% |
| Specific page count (e.g., "5 pages") | Exact match |
| Range (e.g., "2000-3000 words") | Within range |
| Minimum (e.g., "at least 5000 words") | No more than 2x the requirement |

**Forbidden**: Padding word count with excessive bullet point lists. Maintain information density.

### Outline Adherence

- **User provides outline**: Follow strictly, no additions, deletions, or reordering
- **No outline provided**: Use standard structure
  - Academic: Introduction → Literature → Methods → Results → Discussion → Conclusion
  - Business: Executive Summary → Analysis → Recommendations
  - Technical: Overview → Principles → Usage → Examples → FAQ

### Scene Completeness

Think one step ahead of the user, complete elements the scenario needs. **Examples below are not exhaustive — apply this principle to ALL document types:**

- **Exam paper** → Name/class/ID fill areas, point allocation per question (consider total), grading section
- **Contract** → Signature and seal areas for both parties, date, contract number, attachment list
- **Meeting minutes** → Attendees, absentees, action items with owners, next meeting time

## Design Philosophy

### Color Scheme

**Low saturation tones**, avoid Word default blue and matplotlib default high saturation.

**Flexibly choose** color schemes based on document scenario:

| Style | Palette | Suitable Scenarios |
|-------|---------|-------------------|
| Morandi | Soft muted tones | Artistic, editorial |
| Earth tones | Brown, olive, natural | Environmental, organic |
| Nordic | Cool gray, misty blue | Minimalist, tech |
| Japanese Wabi-sabi | Gray, raw wood, zen | Traditional, contemplative |
| French elegance | Off-white, dusty pink | Luxury, feminine |
| Industrial | Charcoal, rust, concrete | Manufacturing, engineering |
| Academic | Navy, burgundy, ivory | Research, education |
| Ocean mist | Misty blue, sand | Marine, wellness |
| Forest moss | Olive, moss green | Nature, sustainability |
| Desert dusk | Ochre, sandy gold | Warm, regional |

**Color scheme must be consistent within the same document.**

### Layout

White space (margins, paragraph spacing), clear hierarchy (H1 > H2 > body), proper padding (text shouldn't touch borders).

### Pagination Control

Word uses flow layout, not fixed pages. Control pagination with these properties:

| Property | XML | Effect |
|----------|-----|--------|
| Keep with next | `<w:keepNext/>` | Heading stays on same page as following paragraph |
| Keep lines together | `<w:keepLines/>` | Paragraph won't break across pages |
| Page break before | `<w:pageBreakBefore/>` | Force new page (for H1) |
| Widow/orphan control | `<w:widowControl/>` | Prevent single lines at top/bottom of page |

```csharp
// Example: H1 always starts on new page, stays with next paragraph
new ParagraphProperties(
    new ParagraphStyleId { Val = "Heading1" },
    new PageBreakBefore(),
    new KeepNext(),
    new KeepLines()
)
```

**Table pagination**:
```csharp
// Allow row to break across pages (avoid large blank areas)
new TableRowProperties(
    new CantSplit { Val = false }  // false = can split
)

// Repeat header row on each page
new TableRowProperties(
    new TableHeader()
)
```

---

# Part 4: Technical Reference

**Choose your path:**

| Task | Stack | Reference |
|------|-------|-----------|
| Create new document | C# + OpenXML SDK | `references/CreationGuide.md` + `Example.cs` |
| Edit existing document | Python + lxml | `references/EditingGuide.md` |

- **Creating new documents**: Read [references/CreationGuide.md](references/CreationGuide.md) for SDK fundamentals, element ordering, visual design, page layout, charts, headers/footers, footnotes, math formulas, CJK handling, and XML reference. Use `Example.cs` (or `CJKExample.cs` for CJK) as working templates.

- **Editing existing documents**: Read [references/EditingGuide.md](references/EditingGuide.md) for comments, track changes, and revision operations via `docx_lib.editing` Python API.

### Quick API Reference (Editing)

```python
from scripts.docx_lib.editing import (
    DocxContext,
    add_comment, reply_comment, resolve_comment, delete_comment,
    insert_paragraph, insert_text, propose_deletion,
    reject_insertion, restore_deletion, enable_track_changes
)

with DocxContext("input.docx", "output.docx") as ctx:
    add_comment(ctx, "M-SVI index", "Please define", highlight="M-SVI")
    insert_text(ctx, "The method", after="method", new_text=" and materials")
```

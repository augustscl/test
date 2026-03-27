# Creation Guide

Complete reference for creating new documents with C# + OpenXML SDK. Read this for any document creation task.

---

## 1. SDK Fundamentals

### Schema Compliance (MEMORIZE THESE)

OpenXML has strict element ordering requirements. **Wrong order = Word cannot open the file.**

#### Required Styles

```csharp
// Normal style must exist - all Heading styles use basedOn="Normal"
styles.Append(new Style(
    new StyleName { Val = "Normal" },
    new StyleParagraphProperties(
        new SpacingBetweenLines { After = "200", Line = "276", LineRule = LineSpacingRuleValues.Auto }
    ),
    new StyleRunProperties(
        new RunFonts { Ascii = "Calibri", HighAnsi = "Calibri" },
        new FontSize { Val = "22" },
        new FontSizeComplexScript { Val = "22" }
    )
) { Type = StyleValues.Paragraph, StyleId = "Normal", Default = true });
```

#### Element Order Rules

Most ordering issues are auto-fixed by `fix_element_order.py`. Key rules to remember:

| Parent | Key Rule |
|--------|----------|
| **`sectPr`** | `headerRef` -> `footerRef` must come before `pgSz` -> `pgMar` |
| **`Table`** | Must have `tblGrid` between `tblPr` and `tr` (see below) |

#### Tables Must Have tblGrid

```csharp
// Correct - table must define grid
var table = new Table();
table.Append(new TableProperties(...));
table.Append(new TableGrid(           // Required!
    new GridColumn { Width = "4680" },
    new GridColumn { Width = "4680" }
));
table.Append(new TableRow(...));

// Wrong - missing tblGrid, Word cannot open
var table = new Table();
table.Append(new TableProperties(...));
table.Append(new TableRow(...));  // Adding rows directly
```

#### Table Column Width Consistency

Main cause of skewed tables: `gridCol` width in `tblGrid` doesn't match cell's `tcW` width.

```csharp
// Correct - gridCol and tcW match exactly
table.Append(new TableGrid(
    new GridColumn { Width = "3600" },  // First column
    new GridColumn { Width = "5400" }   // Second column
));

var row = new TableRow(
    new TableCell(
        new TableCellProperties(
            new TableCellWidth { Width = "3600", Type = TableWidthUnitValues.Dxa }  // Matches gridCol!
        ),
        new Paragraph(new Run(new Text("Content")))
    ),
    new TableCell(
        new TableCellProperties(
            new TableCellWidth { Width = "5400", Type = TableWidthUnitValues.Dxa }  // Matches gridCol!
        ),
        new Paragraph(new Run(new Text("Content")))
    )
);
```

| Rule | Reason |
|------|--------|
| gridCol count = table column count | Otherwise column width calculation fails |
| gridCol.Width = tcW.Width | Mismatch causes skewing (checked during validation) |
| All rows in same column use same tcW | Maintains column width consistency |

#### Value Limits

- `paraId` must be < `0x80000000` (for comment paragraph IDs)

### Creation vs Editing

| Task | Method | Why |
|------|--------|-----|
| Create new document | C# OpenXML SDK | Handles package structure, rels, Content_Types automatically |
| Edit existing document | Python + lxml | Transparent, no black box, full control |

**For creating new documents**: Use `Example.cs` patterns with SDK.

**For editing existing documents**: See `references/EditingGuide.md` for complete Python workflow.

---

### Example.cs

**Read the entire file to understand the overall structure**, not just individual functions. The file demonstrates how sections connect (cover -> TOC -> body -> back cover).

The "Project Proposal", "[Company Name]", etc. in Example are **example content only**, and the color scheme is **for reference only**.

| What to Learn | What NOT to Learn |
|---------------|-------------------|
| Section division (cover -> TOC -> body -> back cover) | Specific color values |
| Floating background insertion code | Business content from the example |
| Chart creation API calls | Copy/wording from the example |
| Style definition structure | Hardcoded data from the example |

**Do NOT copy the Example's color scheme.** Redesign visual style based on YOUR document's scenario, like a top designer.

**Function Index** (read source for implementation details):

| Feature | Function | Line # |
|---------|----------|--------|
| **Document Structure** | | |
| Styles (Normal, Heading1-3) | `AddStyles()` | 85-203 |
| Cover page | `AddCoverSection()` | 369-453 |
| Table of contents | `AddTocSection()` | 458-526 |
| Body section | `AddContentSection()` | 531-729 |
| Back cover | `AddBackcoverSection()` | 734-794 |
| **Visual Elements** | | |
| Floating background | `CreateFloatingBackground()` | 228-279 |
| Proportional inline image | `AddInlineImage()` | 285-364 |
| **Tables** | | |
| Three-line table | `CreateDataTable()` | 853-888 |
| Header row (gray bg) | `CreateSimpleHeaderRow()` | 933-971 |
| Data row | `CreateSimpleDataRow()` | 976-1008 |
| **Charts** | | |
| Pie chart | `AddPieChart()` | 1013-1049 |
| Bar chart | `AddBarChart()` | 1133-1169 |
| **Page Elements** | | |
| Header with background | within `AddContentSection()` | 534-575 |
| Footer with page numbers | within `AddContentSection()` | 578-588 |
| Page number field | `CreatePageNumberField()` | 1345-1354 |
| Total pages field | `CreateTotalPagesField()` | 1356-1365 |
| **Advanced Features** | | |
| Footnote | `AddFootnote()` | 1370-1410 |
| Cross-reference | `CreateCrossReference()` | 1415-1425 |
| Numbering/lists | `CreateBasicNumbering()` | 1327-1340 |

### CJKExample.cs

**CJK documents must read `CJKExample.cs` only** -- reading `Example.cs` instead will cause errors (missing font config, quote escaping). It handles:
- Quote escaping (`""` -> `\u201c` `\u201d`)
- CJK font configuration (SimHei, Microsoft YaHei)
- Paragraph indentation for CJK text

Structure is identical to `Example.cs` -- no need to read both.

## 2. Content Elements

### Field Codes

PAGE/NUMPAGES/DATE/TOC -- structure: `FieldChar(Begin)` -> `FieldCode(" PAGE ")` -> `FieldChar(Separate)` -> `Text` -> `FieldChar(End)`. Results cached; WPS doesn't support `UpdateFieldsOnOpen`.

### Bookmarks and Cross-References

Bookmarks mark positions (`BookmarkStart`/`BookmarkEnd` with matching IDs); cross-references link via REF field (`" REF bookmarkName \\h "`).

**Pitfall**: Deleting bookmarked text deletes bookmark -> "Error! Reference source not found".

## 3. Visual Design

### Background Image Design

Cover/back cover must have background. Background images should have center white space, use low saturation colors. Background images must NOT contain any text; text should be implemented in Word for user editability.

#### Design Flow

1. **Read example**: Read `scripts/generate_backgrounds.py` for HTML/CSS techniques (radial-gradient, transparency, positioning)
2. **Choose direction**: Select a style direction from the table below based on document scenario
3. **Create original**: Write new HTML/CSS from scratch -- the example shows ONE style, yours should be different

**Copying the example = all documents look the same = mediocre delivery.** Each document deserves a unique visual identity matching its content and purpose.

#### Style Reference

| Style | Key Elements | Scenarios |
|-------|--------------|-----------|
| MUJI | Thin borders + white space | Minimalist, Japanese, lifestyle |
| Bauhaus | Scattered geometric shapes | Art, design, creative |
| Swiss Style | Grid lines + accent bars | Professional, corporate |
| Soft Blocks | Soft color rectangles, overlapping transparent | Warm, education, healthcare |
| Rounded Geometry | Rounded rectangles, pill shapes | Tech, internet, youthful |
| Frosted Glass | Blur + transparency + subtle borders | Modern, premium, tech |
| Gradient Ribbons | Soft gradient ellipses + small dots | Feminine, beauty, soft |
| Dot Matrix | Regular dot pattern texture | Technical, data, engineering |
| Double Border | Nested borders + corner decorations | Traditional, formal, legal |
| Waves | Bottom SVG waves + gradient background | Ocean, environmental, flowing |
| Warm Natural | Earth tones + organic shapes | Environmental, agriculture, natural |

**Technical**: Playwright generates 794x1123px (`device_scale_factor=2`), insert as floating Anchor with `BehindDoc=true`. See `Example.cs:CreateFloatingBackground()`.

### Letterhead (Business Documents)

For formal business letters, consider adding a letterhead in the header area. Common patterns:
- **Full letterhead on first page** (logo + company name + contact info), simplified or hidden on subsequent pages
- Use `TitlePage` in `SectionProperties` to enable different first-page header
- Design flexibly based on the specific business context -- no fixed rules

### Two-Column Layout

Use `sectPr` with `Columns`. Affects entire section until next `sectPr`.

## 4. Special Content

### Math Formulas (OMML)

**Core pattern**: `<m:e>` is the universal content container. Almost all elements wrap content in `<m:e>`.

**Text**: Always `<m:r><m:t>text</m:t></m:r>`, never bare text.

**Root**: `<m:oMath>` (inline) or `<m:oMathPara>` (display). Do NOT nest `<m:oMath>` inside another.

**Structure examples**:

| Element | Structure |
|---------|-----------|
| Fraction | `<m:f><m:num><m:e>...</m:e></m:num><m:den><m:e>...</m:e></m:den></m:f>` |
| Subscript | `<m:sSub><m:e>base</m:e><m:sub><m:e>...</m:e></m:sub></m:sSub>` |
| Superscript | `<m:sSup><m:e>base</m:e><m:sup><m:e>...</m:e></m:sup></m:sSup>` |
| Radical | `<m:rad><m:deg><m:e>n</m:e></m:deg><m:e>radicand</m:e></m:rad>` |
| Matrix | `<m:m><m:mr><m:e>cell</m:e><m:e>cell</m:e></m:mr></m:m>` |
| Nary (sum/integral) | `<m:nary><m:sub><m:e>...</m:e></m:sub><m:sup><m:e>...</m:e></m:sup><m:e>body</m:e></m:nary>` |
| Delimiter | `<m:d><m:dPr><m:begChr m:val="("/><m:endChr m:val=")"/></m:dPr><m:e>...</m:e></m:d>` |
| Equation array | `<m:eqArr><m:e>eq1</m:e><m:e>eq2</m:e></m:eqArr>` |

**Trap**: Matrix uses `<m:e>` for cells, NOT `<m:mc>` (which is for column properties).

### Curly Quotes in C# Strings

C# treats curly quotes as string delimiters -> CS1003. **Simplest fix**: Use escaped straight quotes `\"` in string literals. If curly quotes are required, use XML entity encoding: `&#8220;` `&#8221;` (doubles) or `&#8216;` `&#8217;` (singles).

**Chinese quote handling** -- see `CJKExample.cs` for complete patterns:

```csharp
// Wrong - Chinese quotes break compilation
new Text("...\u201c...\u201d...")  // CS1003!

// Correct - use Unicode escapes
new Text("...\u201c...\u201d...")
```

| Character | Unicode | Usage |
|-----------|---------|-------|
| left double quote | `\u201c` | Opening quote |
| right double quote | `\u201d` | Closing quote |
| left single quote | `\u2018` | Opening single |
| right single quote | `\u2019` | Closing single |

**Do NOT use verbatim strings `@""`** -- `\u` escapes don't work in verbatim strings:

```csharp
// WRONG - @"" verbatim string, \u NOT escaped, outputs literal "\u201c"
string text = @"text\u201cquote\u201d";  // Outputs: text\u201cquote\u201d

// CORRECT - regular string, \u IS escaped
string text = "text\u201cquote\u201d";   // Outputs: text"quote"

// For long text, use + concatenation
string para = "first part," +
              "text\u201cquote\u201d," +
              "continues.";
```

### Units

Twips = 1/20 pt (11906 = A4 width). Half-points for font size (24 = 12pt). EMU = 914400/inch.

## 5. Page Layout

### Image Size

`wp:extent` and `a:ext` Cx/Cy must match. For proportional scaling: read PNG header (bytes 16-23) for dimensions, calculate `cy = cx * height / width`.

### Pagination Control

Add `KeepNext` to title/chart paragraphs to prevent orphaned titles or chart-caption separation.

### Section Breaks

`sectPr` inside `pPr` = last paragraph of section. Avoid `PageBreak` + `Continuous` (blank page). Use `NextPage`.

### Table of Contents (TOC)

WPS doesn't support `UpdateFieldsOnOpen` -> must pre-populate TOC entries using **field code structure**: `FieldChar(Begin)` -> `FieldCode(" TOC ...")` -> `FieldChar(Separate)` -> placeholder entries (hyperlinked text + page numbers) -> `FieldChar(End)`. The placeholder entries between Separate and End allow Word to display a TOC immediately; users refresh to get accurate page numbers. **Never use static text paragraphs to simulate a TOC** -- must use field code structure, otherwise it cannot be refreshed. See `Example.cs:AddTocSection()`.

Parameters: `\o "1-3"` (heading levels), `\h` (hyperlinks), `\z` (hide page# in web), `\u` (outline level).

Headings must use built-in `Heading1`/`Heading2` styles (custom styles not recognized).

### Alignment and Typography

CJK body: justify + 2-char indent. English: left. Table numbers: right. Headings: no indent.

## 6. Page Elements

### Headers and Footers

```csharp
// 1. Create header part
var headerPart = mainPart.AddNewPart<HeaderPart>();
var headerId = mainPart.GetIdOfPart(headerPart);

headerPart.Header = new Header(
    new Paragraph(
        new ParagraphProperties(
            new ParagraphStyleId { Val = "Header" },
            new Justification { Val = JustificationValues.Center }
        ),
        new Run(new Text("Document Title"))
    )
);

// 2. Create footer part (with page numbers)
var footerPart = mainPart.AddNewPart<FooterPart>();
var footerId = mainPart.GetIdOfPart(footerPart);

var footerPara = new Paragraph(
    new ParagraphProperties(
        new Justification { Val = JustificationValues.Center }
    )
);
// PAGE field: Begin -> FieldCode -> Separate -> Text -> End
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.Begin }));
footerPara.Append(new Run(new FieldCode(" PAGE ")));
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.Separate }));
footerPara.Append(new Run(new Text("1")));  // Placeholder, updated on open
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.End }));
footerPara.Append(new Run(new Text(" / ") { Space = SpaceProcessingModeValues.Preserve }));
// NUMPAGES field (same structure)
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.Begin }));
footerPara.Append(new Run(new FieldCode(" NUMPAGES ")));
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.Separate }));
footerPara.Append(new Run(new Text("1")));
footerPara.Append(new Run(new FieldChar { FieldCharType = FieldCharValues.End }));
footerPart.Footer = new Footer(footerPara);

// 3. Reference in SectionProperties
new SectionProperties(
    new HeaderReference { Type = HeaderFooterValues.Default, Id = headerId },
    new FooterReference { Type = HeaderFooterValues.Default, Id = footerId },
    new PageSize { Width = 11906, Height = 16838 },
    new PageMargin { Top = 1440, Right = 1440, Bottom = 1440, Left = 1440, Header = 720, Footer = 720 }
)
```

**Header/Footer Types**:

| Type | HeaderFooterValues | Purpose |
|------|-------------------|---------|
| Default | `.Default` | Odd pages (or all pages) |
| Even | `.Even` | Even pages |
| First | `.First` | First page |

**Different first page** (for cover): add `TitlePage()` to sectPr.

**Different odd/even pages**: add `<w:evenAndOddHeaders/>` in settings.xml.

### Footnotes and Endnotes

**Separator trap**: FootnotesPart/EndnotesPart must include Id=-1 (Separator) and Id=0 (ContinuationSeparator) before any user notes. Missing these -> Word fails to render.

```xml
<!-- Required in footnotes.xml / endnotes.xml before user notes -->
<w:footnote w:type="separator" w:id="-1">
  <w:p><w:r><w:separator/></w:r></w:p>
</w:footnote>
<w:footnote w:type="continuationSeparator" w:id="0">
  <w:p><w:r><w:continuationSeparator/></w:r></w:p>
</w:footnote>
<!-- User notes start from id="1" -->
```

### Lists

Requires `NumberingDefinitionsPart` with `AbstractNum` + `NumberingInstance`. Apply via `NumberingProperties` in paragraph.

Multi-level: create `AbstractNum` with multiple `Level`s. Formats: `Decimal`, `UpperLetter`, `LowerRoman`, `Bullet`, `ChineseCounting`.

### Hyperlinks

**Must use `<w:hyperlink>` element, not plain text.** Requires relationship first:

```csharp
var relId = mainPart.AddHyperlinkRelationship(new Uri("https://example.com"), true).Id;
paragraph.Append(new Hyperlink(new Run(
    new RunProperties(new Color { Val = "0563C1" }, new Underline { Val = UnderlineValues.Single }),
    new Text("Click here")
)) { Id = relId })
```

### Charts and Visualization

| Requirement | Preferred | Alternative |
|-------------|-----------|-------------|
| Data charts | Word native | matplotlib PNG |
| Flowcharts | DrawingML Shapes | Table layout |
| Illustrations | Image generation | Image search |

**Word Chart**: Use `NumberLiteral` (no Excel), `DataPoint` for colors. See Example.

**matplotlib**: `dpi=300`, `axes.unicode_minus=False`. Font/labels must match document language.

## 7. XML Quick Reference

### Text Formatting (rPr)

```xml
<w:r>
  <w:rPr>
    <w:rFonts w:ascii="Times New Roman" w:eastAsia="SimSun"/>
    <w:sz w:val="24"/>  <!-- 12pt = 24 half-points -->
    <w:b/><w:i/><w:u w:val="single"/>
    <w:color w:val="FF0000"/>
  </w:rPr>
  <w:t>text</w:t>
</w:r>
```

**Font sizes**: 21=10.5pt, 24=12pt, 28=14pt, 32=16pt, 44=22pt

### Track Changes Structure

```xml
<!-- Insertion: <w:ins> wraps <w:r> -->
<w:ins w:id="1" w:author="..." w:date="...">
  <w:r><w:rPr>...</w:rPr><w:t>text</w:t></w:r>
</w:ins>

<!-- Deletion: <w:del> wraps <w:r> (same pattern as ins!) -->
<w:del w:id="2" w:author="..." w:date="...">
  <w:r><w:rPr>...</w:rPr><w:delText>text</w:delText></w:r>
</w:del>
```

**Key**: Both `<w:ins>` and `<w:del>` **wrap** `<w:r>`, not inside it. Use `<w:delText>` instead of `<w:t>` for deletions.

### Schema Constraints

| Rule | Requirement |
|------|-------------|
| RSID values | 8-digit uppercase hex: `00A1B2C3` |
| Whitespace | `xml:space="preserve"` for leading/trailing spaces |
| Revision structure | `<w:ins>`/`<w:del>` **wrap** `<w:r>`, must have `w:id` attribute |

---

**Complete examples**: See `references/EditingGuide.md` for full working code.

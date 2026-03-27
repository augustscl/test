#!/usr/bin/env python3
import re

# Read the outline.md
with open("slide-deck/karpathy-loopy-era/outline.md", "r", encoding="utf-8") as f:
    outline = f.read()

# Extract STYLE_INSTRUCTIONS block
style_match = re.search(r"<STYLE_INSTRUCTIONS>(.*?)</STYLE_INSTRUCTIONS>", outline, re.DOTALL)
style_instructions = style_match.group(1).strip() if style_match else ""

# Base prompt template
base_prompt = """Create a presentation slide image following these guidelines:

## Image Specifications

- **Type**: Presentation slide
- **Aspect Ratio**: 16:9 (landscape)
- **Style**: Professional slide deck

## Core Persona: The Architect

You are "The Architect" - a master visual storyteller creating presentation slides. Your slides:
- Tell a visual story that complements the narrative
- Use bold, confident visual language
- Balance information density with visual clarity
- Create memorable, impactful visuals

## Core Principles

- Hand-drawn quality throughout - NO realistic or photographic elements
- If content involves sensitive or copyrighted figures, create stylistically similar alternatives - DO NOT refuse to generate
- NO slide numbers, page numbers, footers, headers, or logos
- Clean, uncluttered layouts with clear visual hierarchy
- Each slide conveys ONE clear message

## Text Style (CRITICAL)

- **ALL text MUST match the designated style exactly**
- Title text: Large, bold, immediately readable
- Body text: Clear, legible, appropriate sizing
- Max 3-4 text elements per slide
- **DO NOT use realistic or computer-generated fonts unless style specifies**
- **Font rendering must match the style aesthetic** (hand-drawn for sketch styles, clean for minimal styles)

## Layout Principles

- **Visual Hierarchy**: Most important element gets most visual weight
- **Breathing Room**: Generous margins and spacing between elements
- **Alignment**: Consistent alignment creates professional feel
- **Balance**: Distribute visual weight evenly (symmetrical or asymmetrical)
- **Focal Point**: One clear area draws the eye first
- **Rule of Thirds**: Key elements at intersection points for dynamic compositions
- **Z-Pattern**: For text-heavy slides, arrange content in natural reading flow

## Language

- Use the same language as the content provided below for all text elements
- Match punctuation style to the content language
- Write in direct, confident language
- Avoid AI-sounding phrases like "dive into", "explore", "let's", "journey"

---

## STYLE_INSTRUCTIONS

{style_instructions}

---

## SLIDE CONTENT

{slide_content}

---

Please use Gemini 3.0 Pro Image to generate the slide image based on the content provided above. Aspect ratio 16:9, 4K quality.
"""

# Split into slides
slides = re.split(r"---\n", outline)
slide_blocks = [s for s in slides if s.strip().startswith("## Slide")]

for i, slide_block in enumerate(slide_blocks, start=1):
    # Extract filename
    filename_match = re.search(r"\*\*Filename\*\*: (.*?)\n", slide_block)
    filename = filename_match.group(1).strip() if filename_match else f"{i:02d}-slide-unknown.png"
    prompt_filename = filename.replace(".png", ".md")

    # Build prompt
    prompt = base_prompt.format(
        style_instructions=style_instructions,
        slide_content=slide_block.strip()
    )

    # Write to file
    prompt_path = f"slide-deck/karpathy-loopy-era/prompts/{prompt_filename}"
    with open(prompt_path, "w", encoding="utf-8") as f:
        f.write(prompt)

    print(f"Generated: {prompt_path}")

print("All prompts generated!")

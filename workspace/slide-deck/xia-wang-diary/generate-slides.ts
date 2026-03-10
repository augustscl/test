#!/usr/bin/env bun

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { $ } from 'bun';

const SKILL_DIR = '/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen';
const OUTPUT_DIR = '/Users/suchuanlei/.openclaw/workspace/slide-deck/xia-wang-diary';
const PROMPTS_DIR = join(OUTPUT_DIR, 'prompts');

// Read the outline
const outline = readFileSync(join(OUTPUT_DIR, 'outline.md'), 'utf-8');

// Extract STYLE_INSTRUCTIONS
const styleMatch = outline.match(/<STYLE_INSTRUCTIONS>([\s\S]*?)<\/STYLE_INSTRUCTIONS>/);
if (!styleMatch) {
  console.error('Could not find STYLE_INSTRUCTIONS');
  process.exit(1);
}
const STYLE_INSTRUCTIONS = styleMatch[1];

// Base prompt template
const BASE_PROMPT = `Create a presentation slide image following these guidelines:

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

${STYLE_INSTRUCTIONS}

---

## SLIDE CONTENT

`;

// Split outline into slides
const slideSections = outline.split(/^## Slide \d+ of \d+$/m).filter(s => s.trim());

// Skip the first section (header)
const slides = slideSections.slice(1);

console.log(`Found ${slides.length} slides`);

// Generate prompt files and images
for (let i = 0; i < slides.length; i++) {
  const slideNum = i + 1;
  const slideNumStr = String(slideNum).padStart(2, '0');
  
  // Extract filename
  const filenameMatch = slides[i].match(/\*\*Filename\*\*: (\S+\.png)/);
  if (!filenameMatch) {
    console.error(`Could not find filename for slide ${slideNum}`);
    continue;
  }
  const filename = filenameMatch[1];
  const baseName = filename.replace('.png', '');
  
  console.log(`\nProcessing slide ${slideNum}: ${filename}`);
  
  // Write prompt file
  const promptContent = BASE_PROMPT + slides[i].trim() + '\n\n---\n\nPlease generate the slide image based on the content provided above.';
  const promptPath = join(PROMPTS_DIR, `${baseName}.md`);
  writeFileSync(promptPath, promptContent, 'utf-8');
  console.log(`  ✅ Wrote prompt: ${promptPath}`);
  
  // Generate image
  const imagePath = join(OUTPUT_DIR, filename);
  console.log(`  🎨 Generating image...`);
  
  try {
    await $`${SKILL_DIR}/scripts/main.ts --promptfiles ${promptPath} --image ${imagePath} --ar 16:9 --provider dashscope --quality 2k`;
    console.log(`  ✅ Generated image: ${imagePath}`);
  } catch (error) {
    console.error(`  ❌ Failed to generate image for slide ${slideNum}:`, error);
  }
  
  // Add a small delay to avoid rate limiting
  if (i < slides.length - 1) {
    console.log(`  ⏳ Waiting 2 seconds...`);
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
}

console.log('\n🎉 All done!');

#!/usr/bin/env python3
import re
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print('Usage: preflight_check.py <article-dir> [--diary]')
    sys.exit(1)

base = Path(sys.argv[1])
need_diary = '--diary' in sys.argv[2:]
if not base.exists():
    print(f'Missing dir: {base}')
    sys.exit(2)

article_files = list(base.glob('*.md'))
article_file = next((p for p in article_files if p.name != 'outline.md'), None)
outline = base / 'outline.md'
prompts = base / 'prompts'
imgs = base / 'imgs'
cover = imgs / 'cover.png'

errors = []
if not article_file:
    errors.append('missing article markdown')
if not outline.exists():
    errors.append('missing outline.md')
if not prompts.exists():
    errors.append('missing prompts directory')
else:
    prompt_count = len(list(prompts.glob('*.md')))
    if prompt_count < 4:
        errors.append(f'not enough prompt files: {prompt_count}')
if not imgs.exists():
    errors.append('missing imgs directory')
if not cover.exists():
    errors.append('missing imgs/cover.png')

if article_file and article_file.exists():
    text = article_file.read_text(encoding='utf-8', errors='ignore')
    if '![' not in text and '<img' not in text and 'coverImage:' not in text:
        errors.append('article appears to have no image references inserted')

if need_diary:
    candidates = []
    if article_file and article_file.exists():
        article_text = article_file.read_text(encoding='utf-8', errors='ignore')
        title_match = re.search(r'^title:\s*.*?(20\d{2}-\d{2}-\d{2}).*$', article_text, re.M)
        if title_match:
            candidates.append(title_match.group(1))
        name_matches = re.findall(r'(20\d{2}-\d{2}-\d{2})', article_file.name)
        candidates.extend(name_matches)
        body_matches = re.findall(r'20\d{2}-\d{2}-\d{2}', article_text)
        candidates.extend(body_matches[:3])
    base_matches = re.findall(r'(20\d{2}-\d{2}-\d{2})', base.as_posix())
    candidates.extend(base_matches)

    seen = []
    for c in candidates:
        if c not in seen:
            seen.append(c)

    matched_memory = None
    mem_root = Path('/Users/suchuanlei/.openclaw/workspace/memory')
    for date in seen:
        mem = mem_root / f'{date}.md'
        if mem.exists():
            matched_memory = mem
            break

    if not matched_memory:
        if seen:
            errors.append(f'missing memory file for diary date candidates: {", ".join(d + ".md" for d in seen)}')
        else:
            errors.append('could not infer diary date for memory writeback check')
    else:
        mem_text = matched_memory.read_text(encoding='utf-8', errors='ignore')
        if '虾王日记原文' not in mem_text:
            errors.append(f'memory file missing diary writeback marker: {matched_memory.name}')

if errors:
    print('PREFLIGHT_FAIL')
    for e in errors:
        print('-', e)
    sys.exit(3)

print('PREFLIGHT_OK')
print('article=', article_file)
print('outline=', outline)
print('prompts=', prompts)
print('cover=', cover)

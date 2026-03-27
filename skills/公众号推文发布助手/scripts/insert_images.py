#!/usr/bin/env python3
import re
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print('Usage: insert_images.py <article.md> [imgs-dir]')
    sys.exit(1)

article = Path(sys.argv[1])
imgs = Path(sys.argv[2]) if len(sys.argv) > 2 else article.parent / 'imgs'
if not article.exists():
    print(f'Missing article: {article}')
    sys.exit(2)
if not imgs.exists():
    print(f'Missing imgs dir: {imgs}')
    sys.exit(2)

text = article.read_text(encoding='utf-8', errors='ignore')
body_parts = re.split(r'(^# .*$)', text, maxsplit=1, flags=re.M)
front = ''
rest = text
if text.startswith('---'):
    m = re.match(r'^(---\n[\s\S]*?\n---\n?)', text)
    if m:
        front = m.group(1)
        rest = text[m.end():]

lines = rest.splitlines()
paras = []
buf = []
for line in lines:
    if line.strip() == '':
        if buf:
            paras.append('\n'.join(buf))
            buf = []
        paras.append('')
    else:
        buf.append(line)
if buf:
    paras.append('\n'.join(buf))

image_candidates = [
    ('cover.png', '文章开头主视觉'),
    ('02-conflict.png', '冲突段后插图'),
    ('03-breakdown-1.png', '拆解一后插图'),
    ('04-breakdown-2.png', '拆解二后插图'),
    ('05-turning-point.png', '转折段后插图'),
    ('06-summary.png', '总结段后插图'),
]
existing = [(name, desc) for name, desc in image_candidates if (imgs / name).exists()]
if not existing:
    print('No images to insert')
    sys.exit(3)

insertions = []
non_empty_idx = [i for i,p in enumerate(paras) if p and not p.startswith('![') and '<img' not in p]
if non_empty_idx:
    insertions.append((non_empty_idx[0], existing[0][0]))

for k, (name, _) in enumerate(existing[1:], start=1):
    if len(non_empty_idx) > 2:
        pos = non_empty_idx[min(len(non_empty_idx)-1, max(1, int(k * len(non_empty_idx) / max(2, len(existing)))))]
        insertions.append((pos, name))

added = 0
offset = 0
for idx, name in insertions:
    rel = f'imgs/{name}'
    snippet = f'\n![插图]({rel})\n'
    target = idx + offset + 1
    paras.insert(target, snippet)
    offset += 1
    added += 1

new_rest = '\n\n'.join([p for p in paras]) + '\n'
article.write_text(front + new_rest, encoding='utf-8')
print(f'INSERT_OK {added}')
print(article)

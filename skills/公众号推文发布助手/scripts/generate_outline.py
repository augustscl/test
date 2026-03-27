#!/usr/bin/env python3
import re
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print('Usage: generate_outline.py <article.md>')
    sys.exit(1)

article = Path(sys.argv[1])
if not article.exists():
    print(f'Missing article: {article}')
    sys.exit(1)

text = article.read_text(encoding='utf-8', errors='ignore')
body = re.sub(r'^---[\s\S]*?---\n?', '', text, count=1)
paras = [p.strip().replace('\n', ' ') for p in body.split('\n\n') if p.strip()]
heading = next((line[2:].strip() for line in body.splitlines() if line.startswith('# ')), article.stem)

samples = paras[:6]
while len(samples) < 6:
    samples.append('待补充内容')

def compact(s, n=34):
    s = re.sub(r'\s+', ' ', s).strip()
    return s[:n] + ('…' if len(s) > n else '')

pages = [
    ('Page 1｜封面', f'文章主题：{heading}', '强识别、适合封面、能一眼看懂主旨'),
    ('Page 2｜冲突/问题', compact(samples[0]), '紧张、失衡、冲突感'),
    ('Page 3｜拆解 1', compact(samples[1]), '冷静分析、结构化'),
    ('Page 4｜拆解 2', compact(samples[2]), '继续推进、逻辑压强'),
    ('Page 5｜转折', compact(samples[3]), '开始收束、出现转机'),
    ('Page 6｜总结', compact(samples[4]), '稳、狠、收口'),
]

out = article.parent / 'outline.md'
lines = ['# PPT 大纲', '']
for title, core, mood in pages:
    lines += [f'## {title}', f'- 核心信息：{core}', f'- 画面情绪：{mood}', '']
out.write_text('\n'.join(lines).rstrip() + '\n', encoding='utf-8')
print(out)

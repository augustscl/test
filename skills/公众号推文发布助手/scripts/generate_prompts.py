#!/usr/bin/env python3
import re
import sys
import shutil
from pathlib import Path
from datetime import datetime


def slugify(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r'page\s*\d+[｜|:_\-\s]*', '', text)
    text = re.sub(r'[^a-z0-9\u4e00-\u9fff]+', '-', text)
    text = re.sub(r'-+', '-', text).strip('-')
    return text or 'slide'


def choose_style(content: str) -> str:
    lowered = content.lower()
    if any(k in lowered for k in ['tutorial', 'learn', 'education', 'guide', 'beginner', '教程', '学习', '教育']):
        return 'sketch-notes'
    if any(k in lowered for k in ['product', 'launch', 'marketing', 'keynote', '产品', '发布', '营销']):
        return 'bold-editorial'
    if any(k in lowered for k in ['executive', 'investor', 'business', 'corporate', '高管', '投资人', '商业']):
        return 'corporate'
    if any(k in lowered for k in ['saas', 'dashboard', 'metrics', 'product demo', '仪表板']):
        return 'notion'
    if any(k in lowered for k in ['science', 'biology', 'chemistry', 'medical', '科学', '生物', '化学', '医学']):
        return 'scientific'
    if any(k in lowered for k in ['entertainment', 'gaming', 'music', 'atmospheric', '娱乐', '游戏', '音乐']):
        return 'dark-atmospheric'
    return 'blueprint'


def load_style_snippet(style_name: str) -> str:
    style_file = Path('/Users/suchuanlei/.openclaw/workspace/skills/baoyu-slide-deck/references/styles') / f'{style_name}.md'
    if not style_file.exists():
        return style_name
    text = style_file.read_text(encoding='utf-8', errors='ignore')
    text = re.sub(r'\s+', ' ', text).strip()
    return text[:800]


def parse_outline(outline_path: Path):
    sections = []
    if not outline_path.exists():
        return sections
    lines = outline_path.read_text(encoding='utf-8', errors='ignore').splitlines()
    current = None
    for line in lines:
        if line.startswith('## '):
            if current:
                sections.append(current)
            current = {'title': line[3:].strip(), 'core': '', 'mood': ''}
        elif current and line.startswith('- 核心信息：'):
            current['core'] = line.split('：', 1)[1].strip()
        elif current and line.startswith('- 画面情绪：'):
            current['mood'] = line.split('：', 1)[1].strip()
    if current:
        sections.append(current)
    return sections


def default_sections(content: str, title: str):
    paras = [p.strip().replace('\n', ' ') for p in re.split(r'\n\s*\n', content) if p.strip()]
    return [
        {'title': '封面', 'core': f'文章主题：{title}', 'mood': '强识别、封面感、抓眼、适合作为公众号头图'},
        {'title': '冲突', 'core': paras[0][:100] if paras else title, 'mood': '冲突、压力、信息过载、视觉张力强'},
        {'title': '拆解一', 'core': paras[1][:100] if len(paras) > 1 else title, 'mood': '结构化拆解、理性分析、但仍保留视觉冲击'},
        {'title': '拆解二', 'core': paras[2][:100] if len(paras) > 2 else title, 'mood': '继续推进、逻辑压强、层层收束'},
        {'title': '转折', 'core': paras[3][:100] if len(paras) > 3 else title, 'mood': '观点跃迁、认知扭转、开始收束'},
        {'title': '总结', 'core': paras[4][:100] if len(paras) > 4 else title, 'mood': '有结论感、有余味、稳狠收口'},
    ]


def filename_for(idx: int, raw_title: str) -> str:
    lower_title = raw_title.lower()
    if '封面' in raw_title or 'cover' in lower_title:
        return '01-cover.md'
    if '冲突' in raw_title or 'problem' in lower_title or 'conflict' in lower_title:
        return f'{idx:02d}-conflict.md'
    if '转折' in raw_title or 'turning' in lower_title:
        return f'{idx:02d}-turning-point.md'
    if '总结' in raw_title or 'summary' in lower_title:
        return f'{idx:02d}-summary.md'
    if '拆解' in raw_title or 'breakdown' in lower_title:
        return f'{idx:02d}-breakdown-{max(1, idx-2)}.md'
    return f'{idx:02d}-{slugify(raw_title)}.md'


def reset_prompts_dir(prompts_dir: Path):
    if prompts_dir.exists():
        backup_dir = prompts_dir.parent / f'prompts-backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
        shutil.move(str(prompts_dir), str(backup_dir))
    prompts_dir.mkdir(parents=True, exist_ok=True)


def write_prompts(base: Path, article_path: Path, style: str) -> None:
    content = article_path.read_text(encoding='utf-8', errors='ignore')
    title_match = re.search(r'^#\s+(.+)$', content, re.M)
    title = title_match.group(1).strip() if title_match else article_path.stem
    outline_path = base / 'outline.md'
    prompts_dir = base / 'prompts'
    reset_prompts_dir(prompts_dir)

    sections = parse_outline(outline_path)
    if not sections:
        sections = default_sections(content, title)

    style_snippet = load_style_snippet(style)
    article_context = re.sub(r'^---[\s\S]*?---\n?', '', content, count=1).strip()
    article_context = re.sub(r'\s+', ' ', article_context)[:1500]

    for idx, sec in enumerate(sections, 1):
        raw_title = sec.get('title', f'{idx:02d}-slide')
        core = sec.get('core', title)
        mood = sec.get('mood', '统一风格、适合公众号插图')
        filename = filename_for(idx, raw_title)
        prompt = f'''# {raw_title}\n\n你正在为微信公众号文章《{title}》生成一张高质量插图。\n\n## 本页任务\n- 页面标题：{raw_title}\n- 核心信息：{core}\n- 画面情绪：{mood}\n\n## 全文语境\n{article_context}\n\n## 风格约束\n- 使用 baoyu-slide-deck 风格：{style}\n- 风格参考：{style_snippet}\n- 视觉目标：像高质量公众号头图 / 杂志级 editorial illustration，不要廉价 AI 感\n- 统一中文语境，贴合文章观点，不要空泛素材图\n\n## 构图要求\n- 比例：16:9\n- 清晰度：4K / 高质量\n- 必须有清晰主体、明确前中后景或层次\n- 允许使用抽象隐喻，但必须能一眼服务这一页观点\n- 色彩、光影、版式要有设计感，不能像普通素材站配图\n\n## 禁用项\n- 禁止水印、logo、乱码文字、大段可读文字\n- 禁止 UI 截图感、PPT 模板感、廉价图标拼贴\n- 禁止主体模糊、构图松散、元素堆砌\n- 禁止与文章主题无关的通用“科技蓝光效”敷衍画面\n'''
        (prompts_dir / filename).write_text(prompt, encoding='utf-8')

    print(f'Prompts generated with style={style}: {prompts_dir}')


def main():
    if len(sys.argv) < 2:
        print('Usage: generate_prompts.py <article-dir|article.md>')
        sys.exit(1)

    arg = Path(sys.argv[1])
    base = arg if arg.is_dir() else arg.parent
    article_files = [f for f in base.glob('*.md') if f.name != 'outline.md']
    if not article_files:
        print(f'Error: No article markdown found in {base}')
        sys.exit(1)

    article_path = article_files[0]
    content = article_path.read_text(encoding='utf-8', errors='ignore')
    style = choose_style(content)
    print(f'Using baoyu-slide-deck style fallback builder: {style}')
    write_prompts(base, article_path, style)
    print(f'Prompts generation complete: {base / "prompts"}')


if __name__ == '__main__':
    main()

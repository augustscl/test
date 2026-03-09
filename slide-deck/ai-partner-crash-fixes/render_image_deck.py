from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import textwrap, math

W, H = 1600, 900
BG = '#F7F9FC'
WHITE = '#FFFFFF'
BLUE = '#2563EB'
BLUE2 = '#60A5FA'
CORAL = '#F97316'
EMERALD = '#10B981'
AMBER = '#F59E0B'
TEXT = '#0F172A'
SUB = '#475569'
LINE = '#D9E2F1'
PALE_BLUE = '#E8F0FF'
PALE_ORANGE = '#FFF1E8'
PALE_GREEN = '#E9FBF3'
PALE_AMBER = '#FFF8E1'

OUT = Path('/Users/suchuanlei/.openclaw/workspace/slide-deck/ai-partner-crash-fixes/final-image-deck')
OUT.mkdir(parents=True, exist_ok=True)

font_candidates = [
    '/System/Library/Fonts/PingFang.ttc',
    '/System/Library/Fonts/STHeiti Light.ttc',
    '/System/Library/Fonts/Hiragino Sans GB.ttc',
    '/Library/Fonts/Arial Unicode.ttf',
]
font_path = next((p for p in font_candidates if Path(p).exists()), None)
if not font_path:
    raise SystemExit('No CJK font found')

def F(size, bold=False):
    idx = 1 if bold else 0
    try:
        return ImageFont.truetype(font_path, size=size, index=idx)
    except:
        return ImageFont.truetype(font_path, size=size)

TITLE = F(54, True)
H1 = F(42, True)
H2 = F(28, True)
BODY = F(26, False)
BODY_B = F(26, True)
SMALL = F(20, False)
SMALL_B = F(20, True)
BIG = F(86, True)


def rounded(draw, box, fill, outline=None, width=2, r=24):
    draw.rounded_rectangle(box, radius=r, fill=fill, outline=outline, width=width)

def wrap(draw, text, font, max_width):
    lines = []
    for para in text.split('\n'):
        if not para:
            lines.append('')
            continue
        cur = ''
        for ch in para:
            test = cur + ch
            if draw.textlength(test, font=font) <= max_width:
                cur = test
            else:
                if cur:
                    lines.append(cur)
                cur = ch
        if cur:
            lines.append(cur)
    return lines

def draw_textbox(draw, x, y, text, font, fill, max_width, line_gap=10):
    yy = y
    for line in wrap(draw, text, font, max_width):
        draw.text((x, yy), line, font=font, fill=fill)
        yy += font.size + line_gap
    return yy

def base(slide_no, title=None, subtitle=None):
    img = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(img)
    # top stripe
    d.rectangle((0,0,W,18), fill=BLUE)
    d.rectangle((0,18,W,24), fill=CORAL)
    # side accent
    d.rounded_rectangle((60,70,110,830), radius=25, fill=WHITE, outline=LINE, width=2)
    d.rounded_rectangle((76,92,94,200), radius=8, fill=BLUE)
    d.rounded_rectangle((76,220,94,280), radius=8, fill=CORAL)
    d.rounded_rectangle((76,300,94,360), radius=8, fill=EMERALD)
    d.rounded_rectangle((76,380,94,440), radius=8, fill=AMBER)
    d.text((126, 82), f'{slide_no:02d}', font=H2, fill=SUB)
    if title:
        d.text((150, 82), title, font=TITLE, fill=TEXT)
    if subtitle:
        d.text((152, 150), subtitle, font=H2, fill=SUB)
    return img, d

def bullet_list(draw, items, x, y, w, color=TEXT, bullet_color=BLUE, gap=18, font=BODY):
    yy = y
    for item in items:
        draw.ellipse((x, yy+10, x+12, yy+22), fill=bullet_color)
        yy = draw_textbox(draw, x+28, yy, item, font, color, w-28, line_gap=8) + gap
    return yy

def slide1():
    img,d = Image.new('RGB',(W,H),WHITE), ImageDraw.Draw(Image.new('RGB',(W,H),WHITE))
    img = Image.new('RGB',(W,H), WHITE)
    d = ImageDraw.Draw(img)
    # background blocks
    d.rectangle((0,0,W,H), fill=WHITE)
    for i,c in enumerate([PALE_BLUE, '#EEF4FF', '#F3F7FF']):
        d.rounded_rectangle((860+i*30, 110+i*30, 1500+i*5, 770-i*10), radius=40, fill=c)
    # system windows
    rounded(d, (920,160,1460,350), WHITE, LINE, 2, 28)
    rounded(d, (960,390,1490,700), WHITE, LINE, 2, 28)
    d.rectangle((920,160,1460,205), fill=PALE_BLUE)
    d.rectangle((960,390,1490,435), fill=PALE_ORANGE)
    for x,c in [(948,CORAL),(978,AMBER),(1008,EMERALD)]:
        d.ellipse((x,176,x+16,192), fill=c)
    for x,c in [(988,CORAL),(1018,AMBER),(1048,EMERALD)]:
        d.ellipse((x,406,x+16,422), fill=c)
    # mascot-like icon
    d.ellipse((1040,500,1180,640), fill=CORAL)
    d.ellipse((1110,470,1210,560), fill=CORAL)
    d.ellipse((1020,470,1120,560), fill=CORAL)
    d.ellipse((1158,520,1198,560), fill=WHITE)
    d.ellipse((1072,520,1112,560), fill=WHITE)
    d.ellipse((1170,532,1186,548), fill=TEXT)
    d.ellipse((1084,532,1100,548), fill=TEXT)
    d.arc((1100,570,1180,620), 10, 170, fill=TEXT, width=5)
    # arrows and warning icons
    d.polygon([(1280,250),(1340,250),(1340,220),(1400,275),(1340,330),(1340,300),(1280,300)], fill=BLUE)
    d.regular_polygon((1300,575,48), n_sides=3, rotation=0, fill=PALE_ORANGE, outline=CORAL)
    d.text((1287,548), '!', font=H1, fill=CORAL)
    # text
    d.text((120,140), '苏神和虾王', font=BIG, fill=TEXT)
    d.text((124,258), '那些一起翻过的车，\n最后都怎么修好了', font=TITLE, fill=SUB, spacing=16)
    rounded(d, (120,430,700,560), PALE_BLUE, None, 0, 28)
    d.text((150,468), '真实人机协作  ×  踩坑复盘  ×  方法论输出', font=H2, fill=BLUE)
    bullet_list(d, ['不是炫技展示，而是真实翻车与修复', '从案例拆到机制，再沉淀为方法', '适合直播分享，也适合后续传播'], 128, 610, 620, bullet_color=CORAL)
    d.text((120,820),'AI 协作复盘 · 图片版成品', font=SMALL_B, fill=SUB)
    return img

def slide2():
    img,d = base(2,'这不是一场炫技直播','而是一场真实人机协作复盘')
    # layered blocks
    boxes = [
        ((180,260,760,390), PALE_ORANGE, CORAL, '表层', '那些具体发生过的翻车与修复'),
        ((240,420,820,550), PALE_BLUE, BLUE, '中层', '一个 AI 助手为什么会翻车，它的根因是什么'),
        ((300,580,880,710), PALE_GREEN, EMERALD, '深层', '如果你也想养一个长期搭子，方法是什么'),
    ]
    for box, fill, accent, t1, t2 in boxes:
        rounded(d, box, fill, None, 0, 28)
        d.rectangle((box[0], box[1], box[0]+18, box[3]), fill=accent)
        d.text((box[0]+40, box[1]+24), t1, font=H2, fill=accent)
        draw_textbox(d, box[0]+40, box[1]+64, t2, BODY, TEXT, box[2]-box[0]-60)
    rounded(d, (970,260,1460,710), WHITE, LINE, 2, 30)
    d.text((1010,300),'为什么值得讲？', font=H2, fill=TEXT)
    bullet_list(d, [
        '因为大家都知道 AI 会犯错，但很少有人公开拆“错是怎么修好的”',
        '真正有价值的，不是它从不翻车，而是翻车后有没有形成结构性经验',
        '这场内容既能当案例分享，也能当方法课',
    ], 1010, 360, 410, bullet_color=BLUE)
    return img

def slide3():
    img,d = base(3,'AI 助手为什么会翻车','通常不是一个点坏了，而是五层没打通')
    labels = [
        ('指令层','有没有把事情说清楚', BLUE),
        ('记忆层','有没有把偏好和规则沉淀下来', CORAL),
        ('规则层','有没有边界和白名单', AMBER),
        ('工具层','脑子里知道，手上有没有真正打通', EMERALD),
        ('反馈层','错误有没有进入纠错闭环', BLUE2),
    ]
    x0,y,w,h,gap = 190, 300, 220, 290, 30
    for i,(a,b,c) in enumerate(labels):
        x = x0 + i*(w+gap)
        rounded(d, (x,y,x+w,y+h), WHITE, LINE, 2, 28)
        d.rounded_rectangle((x+28,y+24,x+w-28,y+86), radius=18, fill=c)
        d.text((x+50,y+38), a, font=H2, fill='white')
        d.ellipse((x+80,y+122,x+140,y+182), fill=PALE_BLUE if c!=CORAL else PALE_ORANGE, outline=c, width=3)
        d.line((x+110,y+190,x+110,y+235), fill=c, width=6)
        d.line((x+80,y+205,x+140,y+205), fill=c, width=6)
        draw_textbox(d, x+22, y+210, b, SMALL_B, TEXT, w-44, line_gap=6)
        if i < len(labels)-1:
            d.polygon([(x+w+8, y+145),(x+w+42,y+145),(x+w+42,y+130),(x+w+72,y+160),(x+w+42,y+190),(x+w+42,y+175),(x+w+8,y+175)], fill=LINE)
    rounded(d, (210,650,1400,770), PALE_BLUE, None, 0, 24)
    d.text((250,690),'结论：翻车往往不是“模型笨”，而是表达协议、记忆机制、规则边界、工具链和反馈闭环没有一起打通。', font=BODY_B, fill=BLUE)
    return img

def slide4():
    img,d = base(4,'案例一：发消息身份搞错了','同一句话，谁发出去，性质完全不同')
    rounded(d,(200,280,720,720),WHITE,LINE,2,30)
    rounded(d,(840,280,1360,720),WHITE,LINE,2,30)
    d.text((250,320),'机器人身份', font=H1, fill=BLUE)
    d.text((890,320),'用户身份', font=H1, fill=CORAL)
    rounded(d,(250,390,670,500),PALE_BLUE,None,0,24)
    rounded(d,(890,390,1310,500),PALE_ORANGE,None,0,24)
    d.text((288,430),'代表自动化工具行为', font=H2, fill=BLUE)
    d.text((928,430),'代表你本人公开表态', font=H2, fill=CORAL)
    bullet_list(d,['适合默认发送策略','风险可控','语义边界清晰'],270,545,360,bullet_color=EMERALD)
    bullet_list(d,['容易造成“替你发言”','办公场景语义敏感','默认策略必须谨慎'],910,545,360,bullet_color=CORAL)
    d.polygon([(710,470),(805,470),(805,435),(865,500),(805,565),(805,530),(710,530)], fill=CORAL)
    return img

def slide5():
    img,d = base(5,'案例二：群聊规则没收住','真正高级的助手，不是会说，而是知道什么时候闭嘴')
    rounded(d,(200,260,980,740),WHITE,LINE,2,28)
    d.text((230,290),'群聊响应白名单', font=H1, fill=TEXT)
    # decision tree
    rounded(d,(290,380,520,470),PALE_BLUE,None,0,22); d.text((336,413),'收到群消息', font=H2, fill=BLUE)
    d.line((405,470,405,540), fill=LINE, width=5)
    rounded(d,(170,540,430,640),PALE_GREEN,None,0,22); d.text((206,574),'被艾特？ → 回应', font=H2, fill=EMERALD)
    rounded(d,(480,540,860,640),PALE_ORANGE,None,0,22); d.text((520,574),'出现“虾王”？ → 回应', font=H2, fill=CORAL)
    rounded(d,(300,670,790,740), '#EEF2F7', None, 0, 22); d.text((380,695),'其他情况：一律装死，不插嘴', font=H2, fill=SUB)
    d.line((405,470,300,540), fill=LINE, width=4)
    d.line((405,470,670,540), fill=LINE, width=4)
    rounded(d,(1050,260,1450,740),WHITE,LINE,2,28)
    bullet_list(d,['这不是临时理解，而是群级行为白名单','真正贵的不是会答，而是不在不该说话的时候瞎说','关键修复：写入长期记忆'],1080,340,330,bullet_color=BLUE)
    return img

def slide6():
    img,d = base(6,'案例三：心跳任务只做了半套','AI 最怕的，不是任务难，而是没有完成标准')
    rounded(d,(190,280,1410,720),WHITE,LINE,2,30)
    steps=['健康检查','生成自拍','发出消息','时间窗口合规']
    xs=[260,560,860,1160]
    for i,s in enumerate(steps):
        fill = PALE_ORANGE if i==0 else '#EEF2F7'
        color = CORAL if i==0 else SUB
        rounded(d,(xs[i]-90,390,xs[i]+90,560),fill,None,0,24)
        d.ellipse((xs[i]-32,430,xs[i]+32,494), outline=color, width=5, fill=WHITE)
        if i==0:
            d.line((xs[i]-16,462,xs[i]-2,478), fill=color, width=6)
            d.line((xs[i]-2,478,xs[i]+20,446), fill=color, width=6)
        d.text((xs[i]-60,515), s, font=SMALL_B, fill=color)
        if i<3:
            d.line((xs[i]+92,475,xs[i+1]-92,475), fill=LINE, width=6)
    rounded(d,(250,610,1350,680),PALE_BLUE,None,0,20)
    d.text((300,632),'修复关键：不能只定义“做什么”，还要定义“做到什么程度才算完成”。', font=BODY_B, fill=BLUE)
    return img

def slide7():
    img,d = base(7,'案例四：飞书语音发不出去','脑子知道要发语音，不等于真的会发语音')
    nodes=[('text',BLUE),('生成 opus',CORAL),('上传 opus',AMBER),('发送 audio',EMERALD)]
    x=220
    for i,(name,c) in enumerate(nodes):
        rounded(d,(x,390,x+220,520),WHITE,LINE,2,26)
        rounded(d,(x+20,410,x+200,460),PALE_BLUE if c==BLUE else PALE_ORANGE if c==CORAL else PALE_AMBER if c==AMBER else PALE_GREEN,None,0,18)
        d.text((x+42,422),name, font=H2, fill=c)
        if i < len(nodes)-1:
            d.polygon([(x+230,448),(x+300,448),(x+300,430),(x+340,455),(x+300,480),(x+300,462),(x+230,462)], fill=c)
        x += 300
    rounded(d,(220,590,1380,730),WHITE,LINE,2,24)
    bullet_list(d,['第一次：只是生成了音频，不是真正语音条','问题不在“不会发”，而在“没走对协议”','最终把正确链路固化成脚本，能力才算沉淀'],260,625,1080,bullet_color=EMERALD)
    return img

def slide8():
    img,d = base(8,'案例五：基线校验误报','不是所有红色报错，都等于真实故障')
    rounded(d,(200,280,760,710),WHITE,LINE,2,30)
    d.text((240,320),'表面现象', font=H1, fill=TEXT)
    rounded(d,(240,400,710,520),'#FFF3F0',None,0,24)
    d.text((278,438),'openclaw.json: FAILED', font=H1, fill=CORAL)
    draw_textbox(d, 242, 570, '看起来像安全事故，第一反应会觉得：配置被改了。', BODY, SUB, 430)
    rounded(d,(840,280,1400,710),WHITE,LINE,2,30)
    d.text((880,320),'真实原因', font=H1, fill=TEXT)
    rounded(d,(880,400,1360,520),PALE_BLUE,None,0,24)
    d.text((920,430),'基线文件写的是相对路径', font=H2, fill=BLUE)
    d.text((920,472),'执行目录一变，就会误报', font=H2, fill=SUB)
    d.line((980,590,1280,590), fill=CORAL, width=4)
    d.text((900,620),'修复：改绝对路径 + 改说明 + 重新校验', font=H2, fill=EMERALD)
    return img

def slide9():
    img,d = base(9,'案例六：记忆改了，系统配置没改','最怕的不是没改，而是只改了一半')
    layers=[('口头规则','4 小时一次',BLUE),('记忆文件','4 小时一次',EMERALD),('系统配置','heartbeat.every = 30m',CORAL),('校验结果','前后不一致',AMBER)]
    y=260
    for i,(a,b,c) in enumerate(layers):
        rounded(d,(300,y,1280,y+110),WHITE,LINE,2,24)
        rounded(d,(330,y+20,560,y+90),PALE_BLUE if c==BLUE else PALE_GREEN if c==EMERALD else PALE_ORANGE if c==CORAL else PALE_AMBER,None,0,18)
        d.text((365,y+42),a, font=H2, fill=c)
        d.text((620,y+42),b, font=H2, fill=TEXT)
        if i<3:
            d.line((790,y+110,790,y+138), fill=LINE, width=6)
        y += 140
    rounded(d,(230,800,1370,860),PALE_BLUE,None,0,18)
    d.text((290,820),'真正修好，必须做到四层一致：口头规则、记忆文件、系统配置、校验结果。', font=BODY_B, fill=BLUE)
    return img

def slide10():
    img,d = base(10,'案例七：双插件冲突','很多长期不稳定，不是新东西坏了，而是旧垃圾没清干净')
    rounded(d,(200,300,700,720),WHITE,LINE,2,28)
    rounded(d,(900,300,1400,720),WHITE,LINE,2,28)
    d.text((350,340),'Before', font=H1, fill=CORAL)
    d.text((1060,340),'After', font=H1, fill=EMERALD)
    rounded(d,(280,420,620,520),PALE_ORANGE,None,0,22); d.text((320,456),'旧版 Feishu 插件', font=H2, fill=CORAL)
    rounded(d,(280,560,620,660),PALE_BLUE,None,0,22); d.text((320,596),'新版 Feishu 插件', font=H2, fill=BLUE)
    d.line((620,470,640,540), fill=CORAL, width=5)
    d.line((620,610,640,540), fill=CORAL, width=5)
    d.text((510,525),'⚠', font=H1, fill=CORAL)
    rounded(d,(980,470,1320,570),PALE_GREEN,None,0,22); d.text((1030,506),'保留新版插件', font=H2, fill=EMERALD)
    rounded(d,(980,610,1320,690),'#EEF2F7',None,0,22); d.text((1030,646),'旧版移入备份区', font=H2, fill=SUB)
    d.text((980,390),'duplicate plugin id 消失', font=H2, fill=TEXT)
    return img

def slide11():
    img,d = base(11,'升维总结：四个闭环','一个长期搭子，至少要打通这四层')
    cx,cy,r=830,500,190
    labels=[('指令闭环',-90,BLUE),('记忆闭环',0,CORAL),('执行闭环',90,EMERALD),('纠错闭环',180,AMBER)]
    for name,ang,c in labels:
        a=math.radians(ang)
        x=cx+int(math.cos(a)*250)
        y=cy+int(math.sin(a)*180)
        rounded(d,(x-110,y-45,x+110,y+45),WHITE,LINE,2,22)
        d.text((x-72,y-16),name, font=H2, fill=c)
        d.line((cx,cy,x-120 if x<cx else x+120 if x>cx else x, y), fill=c, width=5)
    d.ellipse((cx-r,cy-r,cx+r,cy+r), fill=PALE_BLUE, outline=BLUE, width=5)
    d.text((705,455),'长期协作型\n智能体', font=H1, fill=TEXT, spacing=14)
    bullet_list(d,['你说的，它真的理解了','它理解的，真的沉淀了','它沉淀的，真的变成行为了','它做错的，真的被修成经验了'],210,330,360,bullet_color=BLUE)
    return img

def slide12():
    img,d = base(12,'AI 搭子真正的成熟','不是从不翻车，而是越来越不重复翻同样的车')
    d.line((260,650,1280,650), fill=LINE, width=8)
    for i in range(5):
        x=320+i*180
        d.line((x,630,x+70,670), fill=EMERALD if i>1 else CORAL, width=12)
    rounded(d,(250,250,1350,540),WHITE,LINE,2,30)
    d.text((320,320),'不是从不翻车', font=BIG, fill=TEXT)
    d.text((320,430),'而是每翻一次车，都比上一次\n更难再翻同样的车', font=TITLE, fill=BLUE, spacing=16)
    d.text((250,800),'苏神 × 虾王  |  真实协作，持续修正，长期进化', font=SMALL_B, fill=SUB)
    return img

slides=[slide1,slide2,slide3,slide4,slide5,slide6,slide7,slide8,slide9,slide10,slide11,slide12]
for i,fn in enumerate(slides,1):
    img=fn()
    img.save(OUT/f'{i:02d}-slide-final.png', quality=95)
    print('saved', i)

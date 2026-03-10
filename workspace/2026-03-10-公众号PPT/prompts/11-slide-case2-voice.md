# Slide 11: 案例二：语音克隆

## Style: corporate (clean + professional + geometric + balanced)

## Layout: text-heavy

## Content

- Title (Chinese): 案例二：语音克隆
- Subtitle (Chinese): 从"能生成"到"能发出去"
- Scenario (Chinese): 跟虾王说"用我的参考音色发语音到飞书"
- Problem (Chinese): 虾王生成了音频，但没有按飞书语音消息协议发成可播放语音条
- Solution Steps (Chinese):
  1. 需求闭环打透：用参考音色，发到飞书，要可播放语音条
  2. 技能闭环打开：找到 speak-and-send-feishu-voice.sh 脚本
  3. 记忆闭环打通：记住参考音频要加 .wav 后缀
  4. 执行闭环跑通：文本→Noiz克隆→生成opus→上传飞书→发audio
  5. 纠错闭环留出来：踩了三个坑，都变成护栏
- Result (Chinese): 语音时长13.33秒，成功发送到飞书

## Visual Guidance

- 背景：白色或浅灰色
- 标题：深蓝色，粗体
- 步骤：使用流程图
- 结果：突出显示"13.33秒语音条"

## Technical Notes

- Aspect ratio: 16:9
- Resolution: 2K (2048x1152)
- Output: PNG

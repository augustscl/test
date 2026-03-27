---
name: codesome-setup
description: 配置 Codesome Claude API 环境。当用户提到"配置 codesome"、"codesome claude api"、"codesome 设置"、"配置 claude api 代理"、"setup codesome"时激活。支持 macOS 和 Windows，包含 Claude Code 安装、环境变量配置和连通性验证。
---

# Codesome Claude API 配置助手

> 帮助用户在 macOS 和 Windows 上配置 Codesome API 代理，以使用 Claude Code。

## When to Use This Skill

- 用户提到"配置 codesome"、"codesome 设置"
- 用户提到"codesome claude api"、"配置 claude api 代理"
- 用户想通过 Codesome 使用 Claude Code
- 用户需要设置 `ANTHROPIC_BASE_URL` 或 `ANTHROPIC_AUTH_TOKEN`
- 用户在 Trae/VS Code 中使用 Claude Code 插件遇到 API 配置问题

## 配置流程

按以下 6 步顺序执行，每步完成后确认再进入下一步。

### Step 1: 检测操作系统

判断用户的操作系统：

- **macOS**: 终端使用 zsh 或 bash，环境变量写入 shell 配置文件
- **Windows**: 使用 PowerShell 或 CMD，环境变量通过 `setx` 或系统设置配置

如果无法自动判断，直接询问用户。

### Step 2: 获取 API 密钥

引导用户获取 Codesome API 密钥：

1. 登录 [Codesome 平台](https://cc.codesome.cn)
2. 进入控制台，找到【使用密钥】
3. 创建新的 API 密钥（或复制已有密钥）
4. 密钥格式为 `sk-` 开头的字符串

**提示用户**：

```
请先在 Codesome 平台 (https://cc.codesome.ai) 上获取您的 API 密钥：
1. 登录后进入控制台
2. 找到【使用密钥】
3. 创建或复制您的 API 密钥（sk-开头）
4. 将密钥提供给我，我来帮您完成配置
```

**校验**：确认用户提供的密钥以 `sk-` 开头，长度合理（通常 64 字符以上）。

### Step 3: 安装 Claude Code

检查并安装 Claude Code CLI 工具。

**前置条件检查**：

**Windows 用户优先检查 Git Bash**：

```cmd
git --version
```

如果提示命令不存在，需要先安装 Git for Windows：
1. 下载：https://git-scm.com/download/win
2. 运行安装程序，**全程使用默认选项**（Next → Next → Install）即可
3. 安装完成后重新打开终端验证 `git --version`

**检查 Node.js 和 npm**：

```bash
# 检查 Node.js 是否已安装
node --version
# 检查 npm 是否可用
npm --version
```

如果未安装 Node.js，引导用户：
- **macOS**: `brew install node` 或从 https://nodejs.org 下载
- **Windows**: 从 https://nodejs.org 下载 LTS 版本安装

**安装 Claude Code**：

```bash
npm install -g @anthropic-ai/claude-code
```

**Windows 特殊处理**：如果遇到 PowerShell 执行策略错误，参考下方「故障排查」章节。快速修复：

```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# 输入 Y 确认，然后重新运行 npm install
```

### Step 4: 配置环境变量

根据操作系统配置以下环境变量：

- `ANTHROPIC_BASE_URL` = `https://cc.codesome.ai`
- `ANTHROPIC_AUTH_TOKEN` = 用户提供的 API 密钥

#### macOS 配置

**临时生效**（当前终端会话）：

```bash
export ANTHROPIC_BASE_URL="https://cc.codesome.ai"
export ANTHROPIC_AUTH_TOKEN="sk-你的密钥"
```

**永久生效**（写入 shell 配置文件）：

检测用户使用的 shell（`echo $SHELL`），然后写入对应配置文件：

- zsh → `~/.zshrc`
- bash → `~/.bashrc` 或 `~/.bash_profile`

```bash
# 写入配置（以 zsh 为例）
echo '' >> ~/.zshrc
echo '# Codesome Claude API Configuration' >> ~/.zshrc
echo 'export ANTHROPIC_BASE_URL="https://cc.codesome.ai"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-你的密钥"' >> ~/.zshrc

# 使配置立即生效
source ~/.zshrc
```

#### Windows 配置

**方式一：setx 永久设置**（推荐）：

```cmd
setx ANTHROPIC_BASE_URL "https://cc.codesome.ai"
setx ANTHROPIC_AUTH_TOKEN "sk-你的密钥"
```

> 注意：`setx` 设置的变量需要**重新打开终端**才能生效。

**方式二：系统环境变量 GUI**：

1. 右键"此电脑" → 属性 → 高级系统设置
2. 点击"环境变量"
3. 在"用户变量"中新建：
   - 变量名：`ANTHROPIC_BASE_URL`，值：`https://cc.codesome.ai`
   - 变量名：`ANTHROPIC_AUTH_TOKEN`，值：`sk-你的密钥`
4. 确定保存，重新打开终端

### Step 5: IDE 插件配置

根据用户使用的 IDE 提供对应指引：

#### Trae / VS Code — Claude Code 插件

1. 在扩展商店搜索并安装 **Claude Code** 插件
2. 环境变量已在 Step 4 中配置，插件会自动读取
3. 重启 IDE 使环境变量生效
4. 在 IDE 中打开 Claude Code 面板即可使用

#### Windows — Claude-Code ChatUI 插件

1. 在 VS Code 扩展商店搜索 **Claude-Code ChatUI for Windows**
2. 安装插件
3. 确保环境变量已配置（Step 4）
4. 重启 VS Code
5. 通过命令面板（Ctrl+Shift+P）搜索 "Claude" 打开

#### 命令行使用

环境变量配置完成后，直接在终端中运行：

```bash
claude
```

### Step 6: 验证配置

执行以下验证步骤确认配置成功：

**1. 检查 Claude Code 安装**：

```bash
claude --version
```

预期输出：显示版本号，如 `claude-code x.x.x`

**2. 检查环境变量**：

```bash
# macOS
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_AUTH_TOKEN

# Windows CMD
echo %ANTHROPIC_BASE_URL%
echo %ANTHROPIC_AUTH_TOKEN%

# Windows PowerShell
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN
```

预期输出：分别显示 `https://cc.codesome.ai` 和用户的 API 密钥。

**3. 测试 API 连通性**：

```bash
claude "你好，请简单回复确认连接正常"
```

预期：Claude 正常回复，说明配置成功。

**如果验证失败**，参考下方「故障排查」章节。

---

## Examples

### Example 1: macOS 用户完整配置

**用户请求**: "帮我配置 codesome claude api"

**执行流程**:
1. 检测到 macOS 系统
2. 引导用户获取 API 密钥 → 用户提供 `sk-abc123...`
3. 运行 `npm install -g @anthropic-ai/claude-code`
4. 将环境变量写入 `~/.zshrc`
5. 提供 IDE 插件安装指引
6. 运行 `claude --version` 和测试命令验证

### Example 2: Windows 用户遇到 PowerShell 问题

**用户请求**: "在 Windows 上配置 codesome"

**执行流程**:
1. 检测到 Windows 系统
2. 引导获取密钥
3. 安装时遇到 PowerShell 执行策略错误 → 引导执行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
4. 重新安装成功
5. 使用 `setx` 配置环境变量
6. 提醒重启终端后验证

### Example 3: 仅更新 API 密钥

**用户请求**: "我需要更换 codesome 的 API 密钥"

**执行流程**:
1. 获取新密钥
2. 更新环境变量中的 `ANTHROPIC_AUTH_TOKEN`
3. 重新加载配置 / 重启终端
4. 验证新密钥可用

---

## 故障排查

### 问题 1: Windows PowerShell 执行策略限制

**症状**：运行 `npm install -g @anthropic-ai/claude-code` 时报错，提示脚本执行被禁止。

**原因**：Windows PowerShell 默认执行策略为 `Restricted`，阻止 `.ps1` 脚本运行。

**解决方案**：

1. 以管理员身份打开 PowerShell（右键 → 以管理员身份运行）
2. 执行：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. 输入 `Y` 确认
4. 重新运行安装命令：
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

### 问题 2: Node.js / npm 未安装

**症状**：`node --version` 或 `npm --version` 提示命令不存在。

**解决方案**：

- **macOS**：
  ```bash
  brew install node
  ```
  或从 https://nodejs.org 下载 LTS 版本

- **Windows**：
  从 https://nodejs.org 下载 LTS 版本安装，安装时勾选"Add to PATH"

  安装完成后检查 Node.js 路径（如 `D:\Program Files\nodejs`）是否在系统 `Path` 环境变量中。

### 问题 3: 环境变量不生效

**症状**：配置了环境变量但 `echo $ANTHROPIC_BASE_URL` 输出为空。

**解决方案**：

- **macOS**：
  - 确认写入了正确的配置文件（`~/.zshrc` 或 `~/.bashrc`）
  - 执行 `source ~/.zshrc`（或对应文件）重新加载
  - 或关闭终端重新打开

- **Windows**：
  - `setx` 设置的变量需要**重新打开终端**才能生效（当前窗口不会更新）
  - 检查是否在"系统环境变量"而非"用户环境变量"中设置（建议用用户变量）
  - 重启 IDE（Trae/VS Code）使其读取新的环境变量

### 问题 4: API 连接失败

**症状**：`claude` 命令报错，无法连接到 API。

**排查步骤**：

1. 确认 `ANTHROPIC_BASE_URL` 值为 `https://cc.codesome.ai`（注意 https）
2. 确认 API 密钥正确且未过期（登录 https://cc.codesome.ai 检查）
3. 测试网络连通性：
   ```bash
   curl https://cc.codesome.ai
   ```
4. 如果使用代理，确认代理设置不会拦截该域名

### 问题 5: npm 全局安装路径问题

**症状**：安装成功但 `claude` 命令找不到。

**解决方案**：

```bash
# 查看 npm 全局安装路径
npm config get prefix

# 确认该路径在系统 PATH 中
# macOS 通常是 /usr/local/bin
# Windows 通常是 %AppData%\npm
```

如果路径不在 PATH 中，手动添加或重新安装 Node.js。

### 问题 6: Windows 未安装 Git Bash

**症状**：Windows 用户在终端中无法运行 `git` 命令，或 Claude Code 运行时提示缺少 bash 环境，或终端只有 CMD/PowerShell 而没有类 Unix shell 环境。

**原因**：Claude Code 依赖 bash 环境运行部分功能，Windows 默认不自带 Git Bash。

**解决方案**：

1. 下载 Git for Windows：https://git-scm.com/download/win
2. 运行安装程序，**全程使用默认选项即可**（Next → Next → Install）
   - 关键默认项会自动勾选：
   - "Git Bash Here" 右键菜单
   - "Use Git from the Windows Command Prompt"（将 git 加入 PATH）
   - "Use bundled OpenSSH"
   - 默认编辑器选 Vim 或 Nano 均可
3. 安装完成后，点击 Finish
4. 验证安装：
   - 在任意文件夹右键，应出现 "Git Bash Here" 选项
   - 打开新的 CMD 或 PowerShell，运行：
     ```cmd
     git --version
     ```
     预期输出：`git version 2.x.x.windows.x`

**安装后注意**：
- 需要**重新打开**所有终端窗口和 IDE，新的 PATH 才会生效
- 如果在 Trae/VS Code 中使用，重启 IDE 后在终端下拉菜单中可以选择 "Git Bash" 作为默认终端
- 建议将 VS Code / Trae 的默认终端设置为 Git Bash：设置中搜索 `terminal.integrated.defaultProfile.windows`，选择 "Git Bash"

---

## Notes

- API 密钥属于敏感信息，不要将其硬编码到代码或公开文件中
- `ANTHROPIC_BASE_URL` 固定为 `https://cc.codesome.ai`，不需要用户修改
- Windows 用户使用 `setx` 后必须重新打开终端窗口
- 如果用户同时使用多个 API 代理，注意环境变量冲突

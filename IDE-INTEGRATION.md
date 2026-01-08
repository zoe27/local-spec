# LocalSpec IDE 集成指南

> 🎯 一键集成 LocalSpec 到 VS Code 和 PyCharm，让 AI 开发更高效

---

## 📋 目录

- [VS Code 集成](#vs-code-集成)
- [PyCharm 集成](#pycharm-集成)
- [快速对比](#快速对比)
- [常见问题](#常见问题)

---

## 🎨 VS Code 集成

### 方案 1：一键自动配置（推荐）⭐⭐⭐⭐⭐

```bash
# 在项目根目录运行
curl -fsSL https://raw.githubusercontent.com/.../install-vscode-integration.sh | bash

# 或使用本地脚本
chmod +x install-vscode-integration.sh
./install-vscode-integration.sh
```

**安装内容：**
- ✅ `.vscode/tasks.json` - 任务配置
- ✅ `.vscode/keybindings.json` - 快捷键
- ✅ `.vscode/settings.json` - 设置
- ✅ `.vscode/localspec.code-snippets` - 代码片段
- ✅ `localspec-vscode.vsix` - 扩展（可选）

---

### 配置后的功能

#### 1. 快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl+Shift+L S` | 创建规范 | 自动使用选中文本 |
| `Ctrl+Shift+L P` | 生成计划 | 自动使用选中文本 |
| `Ctrl+Shift+L T` | 分解任务 | - |
| `Ctrl+Shift+L I` | 执行实现 | 交互式模式 |
| `Ctrl+Shift+L C` | AI 聊天 | 打开聊天终端 |

#### 2. 命令面板

按 `Ctrl+Shift+P` 或 `Cmd+Shift+P` (Mac)，输入：

```
LocalSpec: 创建规范
LocalSpec: 生成计划
LocalSpec: 分解任务
LocalSpec: 执行实现
LocalSpec: AI 聊天
LocalSpec: 查看文档
```

#### 3. 任务快速访问

按 `Ctrl+Shift+B` 打开构建任务菜单：

```
Build Task
  └─ LocalSpec: 创建规范
  └─ LocalSpec: 生成计划
  └─ LocalSpec: 分解任务
  └─ LocalSpec: 执行实现
```

#### 4. 代码片段

在任何文件中输入：

```
lspec<Tab>    → localspec specify "$1"
lplan<Tab>    → localspec plan "$1"
ltasks<Tab>   → localspec tasks
limplement<Tab> → localspec implement --interactive
```

#### 5. 状态栏

左下角显示：🚀 LocalSpec，点击快速访问功能

---

### 手动配置（高级）

如果需要自定义配置，可以手动创建以下文件：

#### `.vscode/tasks.json`

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "LocalSpec: 创建规范",
      "type": "shell",
      "command": "localspec",
      "args": ["specify", "${input:specDescription}"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "showReuseMessage": false
      },
      "group": {
        "kind": "build",
        "isDefault": false
      }
    },
    {
      "label": "LocalSpec: 生成计划",
      "type": "shell",
      "command": "localspec",
      "args": ["plan", "${input:planDescription}"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    },
    {
      "label": "LocalSpec: 分解任务",
      "type": "shell",
      "command": "localspec",
      "args": ["tasks"],
      "problemMatcher": []
    },
    {
      "label": "LocalSpec: 执行实现",
      "type": "shell",
      "command": "localspec",
      "args": ["implement", "--interactive"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "focus": true
      }
    },
    {
      "label": "LocalSpec: AI 聊天",
      "type": "shell",
      "command": "localspec",
      "args": ["chat"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "focus": true
      }
    },
    {
      "label": "LocalSpec: 从选中文本创建规范",
      "type": "shell",
      "command": "localspec",
      "args": ["specify", "${selectedText}"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    }
  ],
  "inputs": [
    {
      "id": "specDescription",
      "type": "promptString",
      "description": "输入功能需求描述",
      "default": ""
    },
    {
      "id": "planDescription",
      "type": "promptString",
      "description": "输入技术栈描述",
      "default": ""
    }
  ]
}
```

#### `.vscode/keybindings.json`

```json
[
  {
    "key": "ctrl+shift+l s",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 从选中文本创建规范",
    "when": "editorTextFocus && editorHasSelection"
  },
  {
    "key": "ctrl+shift+l s",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 创建规范",
    "when": "editorTextFocus && !editorHasSelection"
  },
  {
    "key": "ctrl+shift+l p",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 生成计划"
  },
  {
    "key": "ctrl+shift+l t",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 分解任务"
  },
  {
    "key": "ctrl+shift+l i",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 执行实现"
  },
  {
    "key": "ctrl+shift+l c",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: AI 聊天"
  }
]
```

#### `.vscode/settings.json`

```json
{
  "files.associations": {
    "**/.specify/**/*.md": "markdown",
    "**/specs/**/*.md": "markdown"
  },
  "markdown.preview.breaks": true,
  "markdown.preview.fontSize": 14,
  "files.watcherExclude": {
    "**/.specify/cache/**": true,
    "**/.specify/logs/**": true
  },
  "search.exclude": {
    "**/.specify/cache": true,
    "**/.specify/logs": true
  }
}
```

#### `.vscode/localspec.code-snippets`

```json
{
  "LocalSpec Specify": {
    "prefix": "lspec",
    "body": [
      "localspec specify \"$1\""
    ],
    "description": "创建功能规范"
  },
  "LocalSpec Plan": {
    "prefix": "lplan",
    "body": [
      "localspec plan \"$1\""
    ],
    "description": "生成技术计划"
  },
  "LocalSpec Tasks": {
    "prefix": "ltasks",
    "body": [
      "localspec tasks"
    ],
    "description": "分解任务列表"
  },
  "LocalSpec Implement": {
    "prefix": "limplement",
    "body": [
      "localspec implement --interactive"
    ],
    "description": "交互式实现"
  },
  "LocalSpec Chat": {
    "prefix": "lchat",
    "body": [
      "localspec chat"
    ],
    "description": "启动 AI 聊天"
  }
}
```

---

### 使用示例

#### 场景 1：从需求文档创建规范

1. 打开 `requirements.txt`
2. 选中需求文本
3. 按 `Ctrl+Shift+L S`
4. LocalSpec 自动创建规范

#### 场景 2：快速生成技术方案

1. 按 `Ctrl+Shift+P`
2. 输入 "LocalSpec: 生成计划"
3. 输入技术栈（如 "FastAPI + PostgreSQL"）
4. 查看生成的 `plan.md`

#### 场景 3：逐步实现功能

1. 按 `Ctrl+Shift+L T` 分解任务
2. 查看 `tasks.md` 确认任务列表
3. 按 `Ctrl+Shift+L I` 开始交互式实现
4. 逐个确认每个任务的实现

---

## 🐍 PyCharm 集成

### 方案 1：一键自动配置（推荐）⭐⭐⭐⭐⭐

```bash
# 在项目根目录运行
chmod +x install-pycharm-integration.sh
./install-pycharm-integration.sh
```

**安装内容：**
- ✅ `.idea/externalTools.xml` - 外部工具配置
- ✅ `.idea/runConfigurations/` - 运行配置
- ✅ `.idea/liveTemplates/LocalSpec.xml` - 代码模板
- ✅ `.idea/keymaps/LocalSpec.xml` - 快捷键映射

---

### 配置后的功能

#### 1. 外部工具（Tools 菜单）

```
Tools
  └─ External Tools
      └─ LocalSpec
          ├─ 创建规范
          ├─ 生成计划
          ├─ 分解任务
          ├─ 执行实现
          └─ AI 聊天
```

#### 2. 运行配置（Run 菜单）

右上角运行配置下拉菜单：

```
Run Configurations
  └─ LocalSpec: 创建规范
  └─ LocalSpec: 生成计划
  └─ LocalSpec: 分解任务
  └─ LocalSpec: 执行实现
```

点击绿色运行按钮或 `Shift+F10` 执行

#### 3. 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Alt+L S` | 创建规范 |
| `Ctrl+Alt+L P` | 生成计划 |
| `Ctrl+Alt+L T` | 分解任务 |
| `Ctrl+Alt+L I` | 执行实现 |

#### 4. Live Templates

在编辑器中输入：

```
lspec<Tab>    → localspec specify "$END$"
lplan<Tab>    → localspec plan "$END$"
ltasks<Tab>   → localspec tasks
```

---

### 手动配置（高级）

如果需要自定义，手动创建以下文件：

#### `.idea/externalTools.xml`

```xml
<toolSet name="LocalSpec">
  <tool name="LocalSpec: 创建规范" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="specify &quot;$Prompt$&quot;" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 生成计划" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="plan &quot;$Prompt$&quot;" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 分解任务" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="tasks" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 执行实现" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="implement --interactive" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: AI 聊天" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="chat" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>
</toolSet>
```

#### `.idea/runConfigurations/LocalSpec_Specify.xml`

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="LocalSpec: 创建规范" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="localspec specify &quot;$Prompt$&quot;" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <option name="EXECUTE_SCRIPT_FILE" value="false" />
    <envs />
    <method v="2" />
  </configuration>
</component>
```

#### `.idea/liveTemplates/LocalSpec.xml`

```xml
<templateSet group="LocalSpec">
  <template name="lspec" value="localspec specify &quot;$END$&quot;" description="创建规范" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="lplan" value="localspec plan &quot;$END$&quot;" description="生成计划" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="ltasks" value="localspec tasks" description="分解任务" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="limplement" value="localspec implement --interactive" description="执行实现" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>
</templateSet>
```

---

### 使用示例

#### 场景 1：通过菜单创建规范

1. 打开 PyCharm
2. 菜单：Tools → External Tools → LocalSpec → 创建规范
3. 输入需求描述
4. 查看生成的规范文件

#### 场景 2：使用运行配置

1. 点击右上角运行配置下拉菜单
2. 选择 "LocalSpec: 创建规范"
3. 点击绿色运行按钮
4. 在终端中输入需求

#### 场景 3：使用快捷键

1. 按 `Ctrl+Alt+L S`
2. 输入功能描述
3. 自动创建规范

---

## 📊 快速对比

| 功能 | VS Code | PyCharm | 说明 |
|------|---------|---------|------|
| **一键安装** | ✅ | ✅ | 都提供自动化脚本 |
| **快捷键** | ✅ | ✅ | 都支持自定义快捷键 |
| **任务系统** | ✅ | ✅ | VS Code Tasks / PyCharm Run Configs |
| **代码片段** | ✅ | ✅ | Snippets / Live Templates |
| **选中文本执行** | ✅ | ⚠️ | VS Code 更方便 |
| **终端集成** | ✅ | ✅ | 都支持内置终端 |
| **状态栏显示** | ✅ | ⚠️ | VS Code 原生支持 |
| **扩展/插件** | ✅ | ⚠️ | VS Code 可开发扩展 |

**推荐选择：**
- 🎯 **前端项目**：VS Code（更轻量、扩展丰富）
- 🐍 **Python项目**：PyCharm（专业Python支持）
- 🌐 **全栈项目**：VS Code（通用性更好）

---

## 🔧 高级配置

### 团队配置共享

#### VS Code

```bash
# 提交配置到版本控制
git add .vscode/
git commit -m "feat: add LocalSpec VS Code integration"

# 团队成员克隆后自动生效
git clone https://github.com/team/project
cd project
# 打开 VS Code 即可使用快捷键
```

#### PyCharm

```bash
# PyCharm 配置在 .idea/ 目录
# 默认 .gitignore 会忽略 .idea/
# 需要选择性提交

cat >> .gitignore << 'EOF'
# 保留 LocalSpec 配置
!.idea/externalTools.xml
!.idea/runConfigurations/LocalSpec_*.xml
!.idea/liveTemplates/LocalSpec.xml
EOF

git add .idea/externalTools.xml
git add .idea/runConfigurations/LocalSpec_*.xml
git add .idea/liveTemplates/LocalSpec.xml
git commit -m "feat: add LocalSpec PyCharm integration"
```

---

### 多项目配置

如果你有多个项目需要 LocalSpec 集成：

```bash
# 创建全局配置目录
mkdir -p ~/localspec-ide-configs

# VS Code 全局配置
cp .vscode/tasks.json ~/localspec-ide-configs/vscode-tasks.json
cp .vscode/keybindings.json ~/localspec-ide-configs/vscode-keybindings.json

# 新项目快速应用
cd new-project
mkdir -p .vscode
cp ~/localspec-ide-configs/vscode-*.json .vscode/
```

---

## ❓ 常见问题

### Q1: 快捷键不生效？

**VS Code:**
```bash
# 检查快捷键冲突
Ctrl+Shift+P → Preferences: Open Keyboard Shortcuts
搜索 "ctrl+shift+l"
查看是否有冲突

# 或修改快捷键
编辑 .vscode/keybindings.json
将 "ctrl+shift+l" 改为其他组合
```

**PyCharm:**
```bash
# 检查快捷键映射
Settings → Keymap
搜索 "LocalSpec"
右键 → Add Keyboard Shortcut
```

---

### Q2: 找不到 localspec 命令？

```bash
# 确保已安装 LocalSpec
localspec --version

# 如果未找到命令，重新加载 shell
source ~/.bashrc  # 或 source ~/.zshrc

# 或重启 IDE
```

---

### Q3: 任务执行失败？

**VS Code:**
```bash
# 查看任务输出
Terminal → 查看任务输出

# 手动测试命令
localspec specify "测试"
```

**PyCharm:**
```bash
# 查看运行日志
Run → Show Running List → 查看输出

# 手动测试
Tools → Terminal → 运行命令
```

---

### Q4: 如何卸载集成？

**VS Code:**
```bash
# 删除配置文件
rm -rf .vscode/tasks.json
rm -rf .vscode/keybindings.json
rm -rf .vscode/localspec.code-snippets

# 或重置整个 .vscode 目录
rm -rf .vscode
```

**PyCharm:**
```bash
# 删除外部工具
Settings → Tools → External Tools → 删除 LocalSpec 相关

# 删除配置文件
rm .idea/externalTools.xml
rm .idea/runConfigurations/LocalSpec_*.xml
rm .idea/liveTemplates/LocalSpec.xml
```

---

### Q5: 可以自定义命令吗？

**可以！** 编辑配置文件添加自定义命令：

**VS Code** - `.vscode/tasks.json`:
```json
{
  "label": "LocalSpec: 自定义命令",
  "type": "shell",
  "command": "localspec",
  "args": ["custom-command", "${input:customInput}"]
}
```

**PyCharm** - `.idea/externalTools.xml`:
```xml
<tool name="LocalSpec: 自定义命令">
  <exec>
    <option name="COMMAND" value="localspec" />
    <option name="PARAMETERS" value="custom-command &quot;$Prompt$&quot;" />
  </exec>
</tool>
```

---

## 🚀 快速开始

### 最快 5 分钟集成

#### VS Code

```bash
# 1. 下载并运行集成脚本
curl -O https://raw.githubusercontent.com/.../install-vscode-integration.sh
chmod +x install-vscode-integration.sh
./install-vscode-integration.sh

# 2. 重新加载 VS Code
Ctrl+Shift+P → Developer: Reload Window

# 3. 测试
Ctrl+Shift+L S → 输入 "测试功能" → 查看生成的规范
```

#### PyCharm

```bash
# 1. 下载并运行集成脚本
chmod +x install-pycharm-integration.sh
./install-pycharm-integration.sh

# 2. 重启 PyCharm

# 3. 测试
Tools → External Tools → LocalSpec → 创建规范
```

---

## 📚 更多资源

- 📖 [完整文档](LocalSpec-README.md)
- 🔖 [快速参考](LOCALSPEC-QUICKREF.md)
- 💼 [使用示例](example-xiangmanyuan.sh)
- ⚙️ [配置模板](localspec-config-template.yaml)

---

**开始你的 IDE 集成之旅！** 🎉

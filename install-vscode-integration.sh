#!/usr/bin/env bash

###############################################################################
# LocalSpec VS Code 一键集成脚本
#
# 功能：
# - 自动创建 VS Code 配置文件
# - 配置任务、快捷键、代码片段
# - 设置文件关联和搜索排除
#
# 使用方法：
#   chmod +x install-vscode-integration.sh
#   ./install-vscode-integration.sh
#
###############################################################################

set -e

# ============= 颜色定义 =============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============= 日志函数 =============
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# ============= 显示欢迎信息 =============
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║               LocalSpec VS Code 集成工具                      ║
║                                                                ║
║              一键配置 VS Code 开发环境                         ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# ============= 检查环境 =============
check_environment() {
    log_step "检查环境"

    # 检查是否在项目目录
    if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "pom.xml" ]; then
        log_warning "当前目录似乎不是项目根目录"
        read -p "是否继续在当前目录安装？[y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "安装已取消"
            exit 1
        fi
    fi

    # 检查 VS Code
    if ! command -v code &> /dev/null; then
        log_warning "未检测到 VS Code 命令行工具"
        log_info "安装方法：VS Code → Command Palette → Shell Command: Install 'code' command in PATH"
        read -p "继续安装配置文件吗？[y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "检测到 VS Code"
    fi

    # 检查 LocalSpec
    if ! command -v localspec &> /dev/null; then
        log_warning "未检测到 LocalSpec CLI"
        log_info "请先运行: ./install-localspec.sh"
        read -p "继续安装配置文件吗（稍后安装 LocalSpec）？[y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "检测到 LocalSpec CLI"
    fi
}

# ============= 创建 .vscode 目录 =============
create_vscode_dir() {
    log_step "创建配置目录"

    if [ -d ".vscode" ]; then
        log_warning ".vscode 目录已存在"
        read -p "是否备份现有配置？[Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_DIR=".vscode.backup.$(date +%Y%m%d_%H%M%S)"
            cp -r .vscode "$BACKUP_DIR"
            log_success "已备份到: $BACKUP_DIR"
        fi
    else
        mkdir -p .vscode
        log_success "已创建 .vscode 目录"
    fi
}

# ============= 创建任务配置 =============
create_tasks() {
    log_step "配置任务"

    cat > .vscode/tasks.json << 'EOF'
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
        "showReuseMessage": false,
        "clear": true
      },
      "group": {
        "kind": "build",
        "isDefault": false
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
        "panel": "dedicated",
        "clear": true
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
        "panel": "dedicated",
        "clear": true
      }
    },
    {
      "label": "LocalSpec: 分解任务",
      "type": "shell",
      "command": "localspec",
      "args": ["tasks", "--parallel", "--estimate"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "clear": true
      }
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
        "focus": true,
        "clear": true
      },
      "isBackground": false
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
        "focus": true,
        "clear": true
      }
    },
    {
      "label": "LocalSpec: 澄清规范",
      "type": "shell",
      "command": "localspec",
      "args": ["clarify"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "clear": true
      }
    },
    {
      "label": "LocalSpec: 分析项目",
      "type": "shell",
      "command": "localspec",
      "args": ["analyze", "--all"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "clear": true
      }
    },
    {
      "label": "LocalSpec: 查看状态",
      "type": "shell",
      "command": "localspec",
      "args": ["status"],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "clear": true
      }
    }
  ],
  "inputs": [
    {
      "id": "specDescription",
      "type": "promptString",
      "description": "输入功能需求描述（详细描述功能、用户故事、验收标准）",
      "default": ""
    },
    {
      "id": "planDescription",
      "type": "promptString",
      "description": "输入技术栈描述（框架、数据库、工具等）",
      "default": ""
    }
  ]
}
EOF

    log_success "任务配置已创建"
}

# ============= 创建快捷键配置 =============
create_keybindings() {
    log_step "配置快捷键"

    cat > .vscode/keybindings.json << 'EOF'
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
  },
  {
    "key": "ctrl+shift+l q",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 澄清规范"
  },
  {
    "key": "ctrl+shift+l a",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 分析项目"
  },
  {
    "key": "ctrl+shift+l enter",
    "command": "workbench.action.tasks.runTask",
    "args": "LocalSpec: 查看状态"
  }
]
EOF

    log_success "快捷键配置已创建"
    log_info "快捷键列表："
    echo "  Ctrl+Shift+L S - 创建规范"
    echo "  Ctrl+Shift+L P - 生成计划"
    echo "  Ctrl+Shift+L T - 分解任务"
    echo "  Ctrl+Shift+L I - 执行实现"
    echo "  Ctrl+Shift+L C - AI 聊天"
    echo "  Ctrl+Shift+L Q - 澄清规范"
    echo "  Ctrl+Shift+L A - 分析项目"
    echo "  Ctrl+Shift+L Enter - 查看状态"
}

# ============= 创建设置配置 =============
create_settings() {
    log_step "配置设置"

    cat > .vscode/settings.json << 'EOF'
{
  "files.associations": {
    "**/.specify/**/*.md": "markdown",
    "**/specs/**/*.md": "markdown",
    "**/constitution.md": "markdown"
  },
  "markdown.preview.breaks": true,
  "markdown.preview.fontSize": 14,
  "markdown.preview.lineHeight": 1.6,
  "files.watcherExclude": {
    "**/.specify/cache/**": true,
    "**/.specify/logs/**": true,
    "**/.localspec/cache/**": true
  },
  "search.exclude": {
    "**/.specify/cache": true,
    "**/.specify/logs": true,
    "**/.localspec/cache": true
  },
  "files.exclude": {
    "**/.specify/cache": true,
    "**/.specify/logs": true
  },
  "[markdown]": {
    "editor.wordWrap": "on",
    "editor.quickSuggestions": {
      "comments": "on",
      "strings": "on",
      "other": "on"
    }
  }
}
EOF

    log_success "设置配置已创建"
}

# ============= 创建代码片段 =============
create_snippets() {
    log_step "配置代码片段"

    cat > .vscode/localspec.code-snippets << 'EOF'
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
  },
  "LocalSpec Constitution": {
    "prefix": "lconst",
    "body": [
      "localspec constitution \"$1\""
    ],
    "description": "创建项目宪法"
  },
  "LocalSpec Clarify": {
    "prefix": "lclarify",
    "body": [
      "localspec clarify"
    ],
    "description": "澄清规范"
  },
  "LocalSpec Analyze": {
    "prefix": "lanalyze",
    "body": [
      "localspec analyze --all"
    ],
    "description": "分析项目"
  },
  "LocalSpec Status": {
    "prefix": "lstatus",
    "body": [
      "localspec status"
    ],
    "description": "查看状态"
  }
}
EOF

    log_success "代码片段已创建"
}

# ============= 创建扩展推荐 =============
create_extensions() {
    log_step "配置推荐扩展"

    cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "yzhang.markdown-all-in-one",
    "davidanson.vscode-markdownlint",
    "bierner.markdown-mermaid",
    "ms-python.python",
    "ms-vscode.vscode-typescript-next"
  ]
}
EOF

    log_success "扩展推荐已创建"
}

# ============= 更新 .gitignore =============
update_gitignore() {
    log_step "更新 .gitignore"

    GITIGNORE_CONTENT="
# LocalSpec 缓存和日志
.specify/cache/
.specify/logs/
.localspec/cache/
.localspec/logs/

# VS Code 个人设置（保留团队配置）
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/keybindings.json
!.vscode/extensions.json
!.vscode/*.code-snippets
"

    if [ -f ".gitignore" ]; then
        if ! grep -q ".specify/cache" .gitignore; then
            echo "$GITIGNORE_CONTENT" >> .gitignore
            log_success "已更新 .gitignore"
        else
            log_info ".gitignore 已包含 LocalSpec 配置"
        fi
    else
        echo "$GITIGNORE_CONTENT" > .gitignore
        log_success "已创建 .gitignore"
    fi
}

# ============= 创建使用文档 =============
create_usage_doc() {
    log_step "创建使用文档"

    cat > .vscode/LOCALSPEC_USAGE.md << 'EOF'
# LocalSpec VS Code 使用指南

## 🚀 快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl+Shift+L S` | 创建规范 | 选中文本时使用选中内容，否则弹出输入框 |
| `Ctrl+Shift+L P` | 生成计划 | 输入技术栈描述 |
| `Ctrl+Shift+L T` | 分解任务 | 自动读取计划并生成任务 |
| `Ctrl+Shift+L I` | 执行实现 | 交互式实现模式 |
| `Ctrl+Shift+L C` | AI 聊天 | 打开聊天终端 |
| `Ctrl+Shift+L Q` | 澄清规范 | 澄清模糊需求 |
| `Ctrl+Shift+L A` | 分析项目 | 一致性分析 |
| `Ctrl+Shift+L Enter` | 查看状态 | 显示当前进度 |

## 📝 代码片段

在任何文件中输入以下前缀并按 `Tab`：

- `lspec` → `localspec specify ""`
- `lplan` → `localspec plan ""`
- `ltasks` → `localspec tasks`
- `limplement` → `localspec implement --interactive`
- `lchat` → `localspec chat`

## 🎯 使用场景

### 场景 1：从需求文档创建规范

1. 打开需求文档（如 `requirements.txt`）
2. 选中需求文本
3. 按 `Ctrl+Shift+L S`
4. 查看生成的规范文件

### 场景 2：快速生成技术方案

1. 按 `Ctrl+Shift+L P`
2. 输入技术栈（如 "FastAPI + PostgreSQL + Vue3"）
3. 查看生成的 `plan.md`

### 场景 3：逐步实现功能

1. 按 `Ctrl+Shift+L T` 分解任务
2. 查看 `tasks.md` 确认任务列表
3. 按 `Ctrl+Shift+L I` 开始交互式实现
4. 逐个确认每个任务

## 📚 更多信息

- 完整文档：`../LocalSpec-README.md`
- 快速参考：`../LOCALSPEC-QUICKREF.md`
- IDE 集成：`../IDE-INTEGRATION.md`
EOF

    log_success "使用文档已创建: .vscode/LOCALSPEC_USAGE.md"
}

# ============= 验证安装 =============
verify_installation() {
    log_step "验证安装"

    local errors=0

    # 检查文件
    for file in tasks.json keybindings.json settings.json localspec.code-snippets extensions.json LOCALSPEC_USAGE.md; do
        if [ -f ".vscode/$file" ]; then
            log_success "✓ $file"
        else
            log_error "✗ $file"
            ((errors++))
        fi
    done

    if [ $errors -eq 0 ]; then
        log_success "所有配置文件已创建"
        return 0
    else
        log_error "安装不完整，缺少 $errors 个文件"
        return 1
    fi
}

# ============= 显示完成信息 =============
show_completion() {
    log_step "安装完成"

    echo -e "${GREEN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║                  ✅ VS Code 集成安装成功！                    ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${CYAN}📦 已安装的配置：${NC}"
    echo "  ✅ .vscode/tasks.json           - 任务配置"
    echo "  ✅ .vscode/keybindings.json     - 快捷键"
    echo "  ✅ .vscode/settings.json        - 设置"
    echo "  ✅ .vscode/localspec.code-snippets - 代码片段"
    echo "  ✅ .vscode/extensions.json      - 扩展推荐"
    echo "  ✅ .vscode/LOCALSPEC_USAGE.md   - 使用文档"
    echo ""

    echo -e "${CYAN}🚀 下一步：${NC}"
    echo ""
    echo "  1. 重新加载 VS Code："
    echo "     Ctrl+Shift+P → Developer: Reload Window"
    echo ""
    echo "  2. 测试快捷键："
    echo "     Ctrl+Shift+L S → 创建规范"
    echo ""
    echo "  3. 查看使用文档："
    echo "     打开 .vscode/LOCALSPEC_USAGE.md"
    echo ""

    echo -e "${CYAN}💡 快捷键列表：${NC}"
    echo "  Ctrl+Shift+L S - 创建规范"
    echo "  Ctrl+Shift+L P - 生成计划"
    echo "  Ctrl+Shift+L T - 分解任务"
    echo "  Ctrl+Shift+L I - 执行实现"
    echo "  Ctrl+Shift+L C - AI 聊天"
    echo ""

    echo -e "${YELLOW}⚠️  提示：${NC}"
    echo "  • 需要先安装 LocalSpec: ./install-localspec.sh"
    echo "  • 快捷键可能与现有快捷键冲突，可在 keybindings.json 中修改"
    echo "  • 配置文件已提交到版本控制，团队成员克隆后自动生效"
    echo ""

    log_success "开始使用 LocalSpec + VS Code 开发吧！🎉"
}

# ============= 主函数 =============
main() {
    show_banner
    check_environment
    create_vscode_dir
    create_tasks
    create_keybindings
    create_settings
    create_snippets
    create_extensions
    update_gitignore
    create_usage_doc
    verify_installation
    show_completion
}

# 执行主函数
main "$@"

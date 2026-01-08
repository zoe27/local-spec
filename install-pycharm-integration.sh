#!/usr/bin/env bash

###############################################################################
# LocalSpec PyCharm 一键集成脚本
#
# 功能：
# - 自动创建 PyCharm 配置文件
# - 配置外部工具、运行配置、Live Templates
# - 设置快捷键映射
#
# 使用方法：
#   chmod +x install-pycharm-integration.sh
#   ./install-pycharm-integration.sh
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
║              LocalSpec PyCharm 集成工具                       ║
║                                                                ║
║          一键配置 PyCharm/IntelliJ 开发环境                   ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# ============= 检查环境 =============
check_environment() {
    log_step "检查环境"

    # 检查是否在项目目录
    if [ ! -d ".git" ] && [ ! -f "pyproject.toml" ] && [ ! -f "setup.py" ] && [ ! -f "pom.xml" ]; then
        log_warning "当前目录似乎不是项目根目录"
        read -p "是否继续在当前目录安装？[y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "安装已取消"
            exit 1
        fi
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

# ============= 创建 .idea 目录 =============
create_idea_dir() {
    log_step "创建配置目录"

    if [ -d ".idea" ]; then
        log_info ".idea 目录已存在"
        read -p "是否备份现有配置？[Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_DIR=".idea.backup.$(date +%Y%m%d_%H%M%S)"
            cp -r .idea "$BACKUP_DIR"
            log_success "已备份到: $BACKUP_DIR"
        fi
    else
        mkdir -p .idea
        log_success "已创建 .idea 目录"
    fi

    # 创建必要的子目录
    mkdir -p .idea/runConfigurations
    mkdir -p .idea/inspectionProfiles
}

# ============= 创建外部工具配置 =============
create_external_tools() {
    log_step "配置外部工具"

    cat > .idea/externalTools.xml << 'EOF'
<toolSet name="LocalSpec">
  <tool name="LocalSpec: 创建规范" description="创建功能规范" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="specify &quot;$Prompt$&quot;" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 从选中文本创建规范" description="使用选中文本创建规范" showInMainMenu="true" showInEditor="true" showInProject="false" showInSearchPopup="false" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="specify &quot;$SelectedText$&quot;" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 生成计划" description="生成技术实现计划" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="plan &quot;$Prompt$&quot;" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 分解任务" description="将计划分解为任务列表" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="tasks --parallel --estimate" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 执行实现" description="交互式实现任务" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="implement --interactive" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: AI 聊天" description="启动 AI 聊天会话" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="chat" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 澄清规范" description="澄清模糊需求" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="clarify" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 分析项目" description="一致性分析" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="analyze --all" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>

  <tool name="LocalSpec: 查看状态" description="显示当前进度" showInMainMenu="true" showInEditor="true" showInProject="true" showInSearchPopup="true" disabled="false" useConsole="true" showConsoleOnStdOut="true" showConsoleOnStdErr="true" synchronizeAfterRun="true">
    <exec>
      <option name="COMMAND" value="localspec" />
      <option name="PARAMETERS" value="status" />
      <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
    </exec>
  </tool>
</toolSet>
EOF

    log_success "外部工具配置已创建"
}

# ============= 创建运行配置 =============
create_run_configurations() {
    log_step "配置运行配置"

    # 创建规范
    cat > .idea/runConfigurations/LocalSpec_创建规范.xml << 'EOF'
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
EOF

    # 生成计划
    cat > .idea/runConfigurations/LocalSpec_生成计划.xml << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="LocalSpec: 生成计划" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="localspec plan &quot;$Prompt$&quot;" />
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
EOF

    # 分解任务
    cat > .idea/runConfigurations/LocalSpec_分解任务.xml << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="LocalSpec: 分解任务" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="localspec tasks --parallel --estimate" />
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
EOF

    # 执行实现
    cat > .idea/runConfigurations/LocalSpec_执行实现.xml << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="LocalSpec: 执行实现" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="localspec implement --interactive" />
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
EOF

    log_success "运行配置已创建"
}

# ============= 创建 Live Templates =============
create_live_templates() {
    log_step "配置 Live Templates"

    cat > .idea/LiveTemplates_LocalSpec.xml << 'EOF'
<templateSet group="LocalSpec">
  <template name="lspec" value="localspec specify &quot;$END$&quot;" description="创建功能规范" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="lplan" value="localspec plan &quot;$END$&quot;" description="生成技术计划" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="ltasks" value="localspec tasks" description="分解任务列表" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="limplement" value="localspec implement --interactive" description="执行实现" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="lchat" value="localspec chat" description="启动 AI 聊天" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>

  <template name="lconst" value="localspec constitution &quot;$END$&quot;" description="创建项目宪法" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="SHELL_SCRIPT" value="true" />
      <option name="PYTHON" value="true" />
      <option name="JAVA_SCRIPT" value="true" />
      <option name="TypeScript" value="true" />
      <option name="OTHER" value="true" />
    </context>
  </template>
</templateSet>
EOF

    log_success "Live Templates 已创建"
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

# PyCharm/IntelliJ（保留 LocalSpec 配置）
.idea/*
!.idea/externalTools.xml
!.idea/runConfigurations/
!.idea/LiveTemplates_LocalSpec.xml
.idea/workspace.xml
.idea/tasks.xml
.idea/usage.statistics.xml
.idea/dictionaries
.idea/shelf
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

    cat > .idea/LOCALSPEC_USAGE.md << 'EOF'
# LocalSpec PyCharm 使用指南

## 🚀 访问方式

### 方法 1：Tools 菜单

```
Tools → External Tools → LocalSpec
  ├─ 创建规范
  ├─ 从选中文本创建规范
  ├─ 生成计划
  ├─ 分解任务
  ├─ 执行实现
  ├─ AI 聊天
  └─ 查看状态
```

### 方法 2：运行配置

右上角运行配置下拉菜单：
- LocalSpec: 创建规范
- LocalSpec: 生成计划
- LocalSpec: 分解任务
- LocalSpec: 执行实现

点击绿色运行按钮或 `Shift+F10`

### 方法 3：右键菜单

在编辑器中右键：
```
External Tools → LocalSpec → ...
```

### 方法 4：Live Templates

在编辑器中输入并按 `Tab`：
- `lspec` → `localspec specify ""`
- `lplan` → `localspec plan ""`
- `ltasks` → `localspec tasks`
- `limplement` → `localspec implement --interactive`

## 🎯 使用场景

### 场景 1：从需求文档创建规范

1. 打开 `requirements.txt`
2. 选中需求文本
3. 右键 → External Tools → LocalSpec → 从选中文本创建规范

### 场景 2：快速生成技术方案

1. Tools → External Tools → LocalSpec → 生成计划
2. 输入技术栈描述
3. 查看生成的 `plan.md`

### 场景 3：使用运行配置

1. 右上角选择 "LocalSpec: 创建规范"
2. 点击绿色运行按钮
3. 在终端输入需求

## 💡 配置快捷键

自定义快捷键：

1. Settings → Keymap
2. 搜索 "LocalSpec"
3. 右键工具名称
4. Add Keyboard Shortcut
5. 设置快捷键（如 `Ctrl+Alt+L S`）

## 📚 更多信息

- 完整文档：`../LocalSpec-README.md`
- 快速参考：`../LOCALSPEC-QUICKREF.md`
- IDE 集成：`../IDE-INTEGRATION.md`
EOF

    log_success "使用文档已创建"
}

# ============= 验证安装 =============
verify_installation() {
    log_step "验证安装"

    local errors=0

    # 检查文件
    if [ -f ".idea/externalTools.xml" ]; then
        log_success "✓ externalTools.xml"
    else
        log_error "✗ externalTools.xml"
        ((errors++))
    fi

    if [ -f ".idea/LiveTemplates_LocalSpec.xml" ]; then
        log_success "✓ LiveTemplates_LocalSpec.xml"
    else
        log_error "✗ LiveTemplates_LocalSpec.xml"
        ((errors++))
    fi

    # 检查运行配置
    local run_configs=$(ls .idea/runConfigurations/LocalSpec_*.xml 2>/dev/null | wc -l)
    if [ $run_configs -gt 0 ]; then
        log_success "✓ $run_configs 个运行配置"
    else
        log_error "✗ 运行配置"
        ((errors++))
    fi

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
║                 ✅ PyCharm 集成安装成功！                     ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${CYAN}📦 已安装的配置：${NC}"
    echo "  ✅ .idea/externalTools.xml          - 外部工具"
    echo "  ✅ .idea/runConfigurations/         - 运行配置 (4个)"
    echo "  ✅ .idea/LiveTemplates_LocalSpec.xml - Live Templates"
    echo "  ✅ .idea/LOCALSPEC_USAGE.md         - 使用文档"
    echo ""

    echo -e "${CYAN}🚀 下一步：${NC}"
    echo ""
    echo "  1. 重启 PyCharm"
    echo ""
    echo "  2. 测试功能："
    echo "     Tools → External Tools → LocalSpec → 创建规范"
    echo ""
    echo "  3. 配置快捷键（可选）："
    echo "     Settings → Keymap → 搜索 LocalSpec"
    echo ""
    echo "  4. 查看使用文档："
    echo "     .idea/LOCALSPEC_USAGE.md"
    echo ""

    echo -e "${CYAN}💡 访问方式：${NC}"
    echo "  • Tools 菜单 → External Tools → LocalSpec"
    echo "  • 右上角运行配置 → LocalSpec: ..."
    echo "  • 编辑器右键 → External Tools → LocalSpec"
    echo "  • Live Templates: lspec<Tab>, lplan<Tab>, ..."
    echo ""

    echo -e "${YELLOW}⚠️  提示：${NC}"
    echo "  • 需要先安装 LocalSpec: ./install-localspec.sh"
    echo "  • 运行配置会在 PyCharm 重启后生效"
    echo "  • 可以在 Settings → Keymap 中自定义快捷键"
    echo "  • 配置文件已选择性提交到版本控制"
    echo ""

    log_success "开始使用 LocalSpec + PyCharm 开发吧！🎉"
}

# ============= 主函数 =============
main() {
    show_banner
    check_environment
    create_idea_dir
    create_external_tools
    create_run_configurations
    create_live_templates
    update_gitignore
    create_usage_doc
    verify_installation
    show_completion
}

# 执行主函数
main "$@"

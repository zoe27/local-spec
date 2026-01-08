#!/bin/bash

################################################################################
# LocalSpec 完整安装脚本
# 一键安装 LocalSpec + IDE 集成
# 版本: 1.0.0
# 作者: LocalSpec Team
# 日期: 2025-01-15
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "\n${PURPLE}${BOLD}===> $1${NC}\n"
}

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                    LocalSpec 完整安装                        ║
║                                                              ║
║     本地 AI 驱动的规范化开发工具 + IDE 深度集成              ║
║                                                              ║
║     🚀 零 API 成本 | 🔒 完全离线 | 🎯 生产就绪               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# 检测操作系统
detect_os() {
    log_step "检测操作系统"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_success "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_success "检测到 Linux 系统"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# 检查必要工具
check_prerequisites() {
    log_step "检查必要工具"

    local missing_tools=()

    # 检查 curl
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi

    # 检查 git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    # 检查 Python
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请先安装这些工具，然后重新运行安装脚本"
        exit 1
    fi

    log_success "所有必要工具已安装"
}

# 检查硬件配置
check_hardware() {
    log_step "检查硬件配置"

    # 检测可用内存
    if [[ "$OS" == "macos" ]]; then
        TOTAL_MEM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    else
        TOTAL_MEM_GB=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 ))
    fi

    log_info "可用内存: ${TOTAL_MEM_GB}GB"

    # 根据内存推荐模型
    if [ $TOTAL_MEM_GB -ge 32 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:32b-q5_k_m"
        PERFORMANCE_LEVEL="⭐⭐⭐⭐⭐ 专业级"
    elif [ $TOTAL_MEM_GB -ge 16 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:14b-q5_k_m"
        PERFORMANCE_LEVEL="⭐⭐⭐⭐ 推荐配置"
    elif [ $TOTAL_MEM_GB -ge 8 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:7b-q4_k_m"
        PERFORMANCE_LEVEL="⭐⭐⭐ 基础配置"
    else
        log_error "内存不足（需要至少 8GB），当前: ${TOTAL_MEM_GB}GB"
        exit 1
    fi

    log_success "推荐模型: ${RECOMMENDED_MODEL}"
    log_info "性能等级: ${PERFORMANCE_LEVEL}"
}

# 安装目录选择
select_installation_type() {
    log_step "选择安装类型"

    echo "请选择安装类型:"
    echo "  1) 完整安装 (推荐) - 安装核心工具 + VS Code 集成"
    echo "  2) 完整安装 + PyCharm - 安装核心工具 + VS Code + PyCharm 集成"
    echo "  3) 仅核心工具 - 只安装 LocalSpec CLI"
    echo "  4) 仅 IDE 集成 - 只配置 IDE (需要已安装核心工具)"
    echo ""
    read -p "请输入选项 (1-4) [默认: 1]: " choice
    choice=${choice:-1}

    case $choice in
        1)
            INSTALL_TYPE="full_vscode"
            log_success "选择: 完整安装 (核心 + VS Code)"
            ;;
        2)
            INSTALL_TYPE="full_all"
            log_success "选择: 完整安装 (核心 + VS Code + PyCharm)"
            ;;
        3)
            INSTALL_TYPE="core_only"
            log_success "选择: 仅核心工具"
            ;;
        4)
            INSTALL_TYPE="ide_only"
            log_success "选择: 仅 IDE 集成"
            ;;
        *)
            log_error "无效选项"
            exit 1
            ;;
    esac
}

# 下载安装脚本
download_scripts() {
    log_step "下载安装脚本"

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    log_info "临时目录: $TEMP_DIR"

    # 检查是否在 spec-kit 仓库中
    if [ -f "install-localspec.sh" ] && [ -f "install-vscode-integration.sh" ]; then
        log_info "检测到本地脚本，使用本地版本"
        SCRIPT_DIR="$(pwd)"
    else
        log_info "从 GitHub 下载脚本..."
        # 这里应该是实际的 GitHub URL
        # curl -fsSL https://raw.githubusercontent.com/yourusername/localspec/main/install-localspec.sh -o install-localspec.sh
        # curl -fsSL https://raw.githubusercontent.com/yourusername/localspec/main/install-vscode-integration.sh -o install-vscode-integration.sh
        # curl -fsSL https://raw.githubusercontent.com/yourusername/localspec/main/install-pycharm-integration.sh -o install-pycharm-integration.sh

        log_warning "GitHub 下载功能尚未配置，请确保在正确的目录运行脚本"
        exit 1
    fi

    chmod +x install-localspec.sh install-vscode-integration.sh install-pycharm-integration.sh
    log_success "脚本准备完成"
}

# 安装核心工具
install_core() {
    log_step "安装 LocalSpec 核心工具"

    if [ -f "install-localspec.sh" ]; then
        bash install-localspec.sh --model "$RECOMMENDED_MODEL" --non-interactive
    else
        log_error "找不到 install-localspec.sh"
        exit 1
    fi

    # 验证安装
    if command -v localspec &> /dev/null; then
        log_success "LocalSpec 核心工具安装成功"
        localspec --version
    else
        log_error "LocalSpec 安装失败"
        exit 1
    fi
}

# 安装 VS Code 集成
install_vscode_integration() {
    log_step "配置 VS Code 集成"

    # 检查 VS Code 是否安装
    if command -v code &> /dev/null; then
        log_info "检测到 VS Code"

        if [ -f "install-vscode-integration.sh" ]; then
            bash install-vscode-integration.sh --non-interactive
            log_success "VS Code 集成配置完成"
        else
            log_error "找不到 install-vscode-integration.sh"
            exit 1
        fi
    else
        log_warning "未检测到 VS Code，跳过 VS Code 集成"
        log_info "安装 VS Code 后，可运行: bash install-vscode-integration.sh"
    fi
}

# 安装 PyCharm 集成
install_pycharm_integration() {
    log_step "配置 PyCharm 集成"

    # 检查 PyCharm 是否安装
    if [ -d "/Applications/PyCharm.app" ] || [ -d "/Applications/PyCharm CE.app" ] || [ -d "$HOME/.local/share/JetBrains" ]; then
        log_info "检测到 PyCharm"

        if [ -f "install-pycharm-integration.sh" ]; then
            bash install-pycharm-integration.sh --non-interactive
            log_success "PyCharm 集成配置完成"
        else
            log_error "找不到 install-pycharm-integration.sh"
            exit 1
        fi
    else
        log_warning "未检测到 PyCharm，跳过 PyCharm 集成"
        log_info "安装 PyCharm 后，可运行: bash install-pycharm-integration.sh"
    fi
}

# 创建示例项目
create_example_project() {
    log_step "创建示例项目"

    read -p "是否创建示例项目 (xiangmanyuan)? (y/N): " create_example

    if [[ "$create_example" =~ ^[Yy]$ ]]; then
        cd "$HOME"

        if [ -d "xiangmanyuan" ]; then
            log_warning "示例项目已存在: $HOME/xiangmanyuan"
        else
            log_info "创建示例项目..."
            localspec init xiangmanyuan --git
            cd xiangmanyuan

            # 创建基础配置
            cat > .localspec/config.yaml << 'EOF'
model:
  name: "qwen2.5-coder:14b-q5_k_m"
  temperature: 0.3

project:
  name: "xiangmanyuan"
  type: "web"
  language: "zh-CN"

workflow:
  auto_clarify: true
  tdd_enabled: true

performance:
  cache_enabled: true
  parallel_tasks: 2
EOF

            log_success "示例项目创建成功: $HOME/xiangmanyuan"
            log_info "进入项目: cd ~/xiangmanyuan"
        fi
    fi
}

# 运行诊断
run_diagnostics() {
    log_step "运行系统诊断"

    # 检查 Ollama 服务
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        log_success "Ollama 服务运行正常"
    else
        log_warning "Ollama 服务未响应"
    fi

    # 检查模型
    if ollama list | grep -q "$RECOMMENDED_MODEL"; then
        log_success "推荐模型已安装: $RECOMMENDED_MODEL"
    else
        log_warning "推荐模型未安装: $RECOMMENDED_MODEL"
    fi

    # 检查 LocalSpec
    if command -v localspec &> /dev/null; then
        log_success "LocalSpec CLI 可用"
    else
        log_error "LocalSpec CLI 不可用"
    fi

    # 检查 Spec Kit
    if command -v gh-spec &> /dev/null; then
        log_success "Spec Kit 已安装"
    else
        log_warning "Spec Kit 未安装 (可选)"
    fi
}

# 打印使用指南
print_usage_guide() {
    log_step "安装完成"

    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  🎉 LocalSpec 安装成功！                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "\n${BOLD}快速开始:${NC}\n"

    echo -e "${CYAN}1. 验证安装${NC}"
    echo "   localspec --version"
    echo "   localspec doctor"
    echo ""

    echo -e "${CYAN}2. 创建新项目${NC}"
    echo "   localspec init my-project"
    echo "   cd my-project"
    echo ""

    echo -e "${CYAN}3. 定义项目原则${NC}"
    echo "   localspec constitution \"安全第一，TDD开发，微服务架构\""
    echo ""

    echo -e "${CYAN}4. 创建功能规范${NC}"
    echo "   localspec specify \"构建用户认证系统\""
    echo ""

    echo -e "${CYAN}5. 生成技术方案${NC}"
    echo "   localspec plan \"FastAPI + PostgreSQL + Vue3\""
    echo ""

    echo -e "${CYAN}6. 分解任务并实现${NC}"
    echo "   localspec tasks"
    echo "   localspec implement --interactive"
    echo ""

    if [[ "$INSTALL_TYPE" == "full_vscode" ]] || [[ "$INSTALL_TYPE" == "full_all" ]]; then
        echo -e "${CYAN}7. IDE 快捷键 (VS Code)${NC}"
        echo "   Ctrl+Shift+L S  - 创建规范"
        echo "   Ctrl+Shift+L P  - 生成计划"
        echo "   Ctrl+Shift+L T  - 分解任务"
        echo "   Ctrl+Shift+L I  - 执行实现"
        echo "   Ctrl+Shift+L C  - AI 聊天"
        echo ""
    fi

    echo -e "${BOLD}文档位置:${NC}"
    echo "   快速参考: cat ~/localspec/LOCALSPEC-QUICKREF.md"
    echo "   完整文档: cat ~/localspec/LocalSpec-README.md"
    echo "   IDE 集成: cat ~/localspec/IDE-INTEGRATION.md"
    echo ""

    echo -e "${BOLD}示例项目:${NC}"
    echo "   cd ~/xiangmanyuan  # 如果已创建"
    echo "   localspec status"
    echo ""

    echo -e "${BOLD}获取帮助:${NC}"
    echo "   localspec --help"
    echo "   localspec specify --help"
    echo ""

    echo -e "${BOLD}社区支持:${NC}"
    echo "   GitHub: https://github.com/github/spec-kit"
    echo "   文档: https://localspec.dev"
    echo ""

    echo -e "${GREEN}祝你编码愉快！${NC}\n"
}

# 保存安装日志
save_installation_log() {
    local log_file="$HOME/.localspec/install.log"
    mkdir -p "$HOME/.localspec"

    cat > "$log_file" << EOF
LocalSpec 安装日志
==================
安装时间: $(date)
操作系统: $OS
内存大小: ${TOTAL_MEM_GB}GB
推荐模型: $RECOMMENDED_MODEL
安装类型: $INSTALL_TYPE

组件状态:
- LocalSpec CLI: $(command -v localspec &> /dev/null && echo "✓ 已安装" || echo "✗ 未安装")
- Ollama: $(command -v ollama &> /dev/null && echo "✓ 已安装" || echo "✗ 未安装")
- VS Code: $(command -v code &> /dev/null && echo "✓ 已安装" || echo "✗ 未安装")

配置文件:
- 主配置: $HOME/.localspec/config.yaml
- VS Code: $HOME/.vscode/settings.json
- PyCharm: $HOME/.idea/

日志文件: $log_file
EOF

    log_success "安装日志已保存: $log_file"
}

# 主安装流程
main() {
    print_banner

    # 基础检查
    detect_os
    check_prerequisites
    check_hardware

    # 选择安装类型
    select_installation_type

    # 根据选择执行安装
    case $INSTALL_TYPE in
        full_vscode)
            install_core
            install_vscode_integration
            ;;
        full_all)
            install_core
            install_vscode_integration
            install_pycharm_integration
            ;;
        core_only)
            install_core
            ;;
        ide_only)
            install_vscode_integration
            read -p "是否也配置 PyCharm? (y/N): " also_pycharm
            if [[ "$also_pycharm" =~ ^[Yy]$ ]]; then
                install_pycharm_integration
            fi
            ;;
    esac

    # 可选步骤
    if [[ "$INSTALL_TYPE" != "ide_only" ]]; then
        create_example_project
        run_diagnostics
    fi

    # 保存日志
    save_installation_log

    # 打印使用指南
    print_usage_guide
}

# 错误处理
trap 'log_error "安装过程中发生错误，请查看日志: $HOME/.localspec/install.log"; exit 1' ERR

# 运行主程序
main "$@"

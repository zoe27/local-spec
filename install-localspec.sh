#!/usr/bin/env bash

#############################################################################
# LocalSpec 自动化安装脚本
#
# 功能：
# - 自动检测系统环境和硬件配置
# - 安装 Ollama 和推荐的 AI 模型
# - 安装 Spec Kit 框架
# - 部署 LocalSpec CLI 工具
# - 配置环境变量
# - 运行验证测试
#
# 使用方法：
#   curl -fsSL https://raw.githubusercontent.com/yourusername/localspec/main/install.sh | bash
#   或
#   chmod +x install.sh && ./install.sh
#
#############################################################################

set -e  # 遇到错误立即退出

# ============= 全局变量 =============
USE_UV=false  # 是否使用 uv 包管理器

# ============= 颜色定义 =============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}📦 $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# ============= 显示欢迎信息 =============
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║    _                    _   ____                               ║
║   | |    ___   ___ __ _| | / ___| _ __   ___  ___             ║
║   | |   / _ \ / __/ _` | | \___ \| '_ \ / _ \/ __|            ║
║   | |__| (_) | (_| (_| | |  ___) | |_) |  __/ (__             ║
║   |_____\___/ \___\__,_|_| |____/| .__/ \___|\___|            ║
║                                   |_|                          ║
║                                                                ║
║          本地 AI 驱动的 Spec-Driven Development               ║
║                    v1.0.0 by LocalSpec Team                   ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# ============= 检测操作系统 =============
detect_os() {
    log_step "检测操作系统"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_success "检测到 Linux 系统"

        # 检测发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
            log_info "发行版: $NAME"
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_success "检测到 macOS 系统"
        log_info "版本: $(sw_vers -productVersion)"

    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        log_success "检测到 Windows 系统（通过 Git Bash/Cygwin）"
        log_warning "建议使用 WSL2 以获得更好的性能"

    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# ============= 检测硬件配置 =============
check_hardware() {
    log_step "检测硬件配置"

    # 检测 CPU 核心数
    if [[ "$OS" == "linux" ]]; then
        CPU_CORES=$(nproc)
        TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
    elif [[ "$OS" == "macos" ]]; then
        CPU_CORES=$(sysctl -n hw.ncpu)
        TOTAL_MEM=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    fi

    log_info "CPU 核心数: $CPU_CORES"
    log_info "总内存: ${TOTAL_MEM}GB"

    # 检测 GPU
    if command -v nvidia-smi &> /dev/null; then
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
        GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
        HAS_GPU=true
        log_success "检测到 NVIDIA GPU: $GPU_NAME (${GPU_MEM}MB)"
    else
        HAS_GPU=false
        log_info "未检测到 NVIDIA GPU，将使用 CPU 模式"
    fi

    # 检测可用磁盘空间
    if [[ "$OS" == "linux" ]]; then
        DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    elif [[ "$OS" == "macos" ]]; then
        DISK_SPACE=$(df -g . | awk 'NR==2 {print $4}')
    fi
    log_info "可用磁盘空间: ${DISK_SPACE}GB"

    # 推荐模型（使用正确的 Ollama 标签格式）
    echo ""
    if [ $TOTAL_MEM -ge 64 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:32b-instruct"
        PERFORMANCE_LEVEL="🚀 企业级"
        log_success "$PERFORMANCE_LEVEL - 推荐模型: $RECOMMENDED_MODEL"
    elif [ $TOTAL_MEM -ge 32 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:32b-instruct"
        PERFORMANCE_LEVEL="⭐ 专业级"
        log_success "$PERFORMANCE_LEVEL - 推荐模型: $RECOMMENDED_MODEL"
    elif [ $TOTAL_MEM -ge 16 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:14b-instruct"
        PERFORMANCE_LEVEL="💻 标准级"
        log_success "$PERFORMANCE_LEVEL - 推荐模型: $RECOMMENDED_MODEL"
    elif [ $TOTAL_MEM -ge 8 ]; then
        RECOMMENDED_MODEL="qwen2.5-coder:7b-instruct"
        PERFORMANCE_LEVEL="📱 入门级"
        log_warning "$PERFORMANCE_LEVEL - 推荐模型: $RECOMMENDED_MODEL"
        log_warning "内存较低，建议升级到 16GB 以获得更好体验"
    else
        log_error "内存不足 8GB，无法运行本地模型"
        log_info "建议："
        log_info "  1. 升级内存到至少 16GB"
        log_info "  2. 使用云端 API（如 Groq 免费版）"
        exit 1
    fi

    # 检查磁盘空间
    if [ $DISK_SPACE -lt 30 ]; then
        log_error "磁盘空间不足 30GB，无法继续安装"
        exit 1
    fi
}

# ============= 安装依赖 =============
install_dependencies() {
    log_step "安装系统依赖"

    if [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
            log_info "更新软件包列表..."
            sudo apt-get update -qq

            log_info "安装必要依赖..."
            sudo apt-get install -y -qq \
                curl \
                git \
                python3 \
                python3-pip \
                python3-venv \
                jq \
                wget \
                ca-certificates \
                gnupg \
                lsb-release

        elif [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO" == "rhel" ]]; then
            log_info "安装必要依赖..."
            sudo dnf install -y -q \
                curl \
                git \
                python3 \
                python3-pip \
                jq \
                wget
        fi

    elif [[ "$OS" == "macos" ]]; then
        # 检查 Homebrew
        if ! command -v brew &> /dev/null; then
            log_info "安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        log_info "安装必要依赖..."
        brew install python3 jq wget git
    fi

    log_success "系统依赖安装完成"
}

# ============= 安装 Ollama =============
install_ollama() {
    log_step "安装 Ollama"

    # 先检查 Ollama 服务是否运行
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        log_success "Ollama 服务运行正常"
        return 0
    fi

    if command -v ollama &> /dev/null; then
        OLLAMA_VERSION=$(ollama --version 2>&1 | head -1 || echo "unknown")
        log_info "Ollama 已安装 ($OLLAMA_VERSION)"

        # Ollama 已安装但服务未运行
        log_info "启动 Ollama 服务..."
        if [[ "$OS" == "macos" ]]; then
            open -a Ollama 2>/dev/null || {
                log_warning "无法通过 open 命令启动，尝试后台运行..."
                nohup ollama serve > /tmp/ollama.log 2>&1 &
            }
        elif [[ "$OS" == "linux" ]]; then
            if command -v systemctl &> /dev/null; then
                sudo systemctl start ollama
            else
                nohup ollama serve > /tmp/ollama.log 2>&1 &
            fi
        fi

        # 等待服务启动
        log_info "等待 Ollama 服务启动..."
        for i in {1..30}; do
            if curl -s http://localhost:11434/api/tags &> /dev/null; then
                log_success "Ollama 服务已启动"
                return 0
            fi
            sleep 1
        done

        log_warning "Ollama 服务启动超时，但将继续安装"
        return 0
    fi

    log_info "下载并安装 Ollama..."

    if [[ "$OS" == "linux" ]]; then
        curl -fsSL https://ollama.com/install.sh | sh

        # 启动 Ollama 服务
        log_info "启动 Ollama 服务..."
        if command -v systemctl &> /dev/null; then
            sudo systemctl enable ollama
            sudo systemctl start ollama
        else
            # 如果没有 systemd，后台运行
            nohup ollama serve > /tmp/ollama.log 2>&1 &
        fi

    elif [[ "$OS" == "macos" ]]; then
        # macOS 下载安装
        OLLAMA_PKG="/tmp/Ollama.zip"
        curl -L https://ollama.com/download/Ollama-darwin.zip -o "$OLLAMA_PKG"
        unzip -q "$OLLAMA_PKG" -d /Applications/
        rm "$OLLAMA_PKG"

        # 启动 Ollama
        open -a Ollama
    fi

    # 等待 Ollama 服务启动
    log_info "等待 Ollama 服务启动..."
    for i in {1..30}; do
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            log_success "Ollama 服务已启动"
            break
        fi
        sleep 1

        if [ $i -eq 30 ]; then
            log_error "Ollama 服务启动超时"
            exit 1
        fi
    done
}

# ============= 下载 AI 模型 =============
download_model() {
    log_step "下载 AI 模型"

    log_info "准备下载: $RECOMMENDED_MODEL"

    # 确保 Ollama 服务运行
    if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
        log_error "Ollama 服务未运行，无法下载模型"
        log_info "请先启动 Ollama: open -a Ollama (macOS) 或 systemctl start ollama (Linux)"
        log_info "然后手动下载模型: ollama pull $RECOMMENDED_MODEL"
        return 1
    fi

    # 检查模型是否已存在
    if ollama list 2>/dev/null | grep -q "${RECOMMENDED_MODEL%%:*}"; then
        log_info "检测到 qwen2.5-coder 系列模型已存在"
        log_success "可以使用现有模型"
        return 0
    fi

    log_warning "模型大小约 8-20GB，下载可能需要较长时间..."
    log_info "开始下载..."

    # 下载模型
    if ollama pull "$RECOMMENDED_MODEL"; then
        log_success "模型下载完成"
    else
        log_error "模型下载失败"
        log_info "可能的原因："
        log_info "  1. 网络连接问题"
        log_info "  2. 模型名称不存在: $RECOMMENDED_MODEL"
        log_info "  3. 磁盘空间不足"
        log_info ""
        log_info "您可以稍后手动下载:"
        log_info "  ollama pull qwen2.5-coder:7b-instruct   # 小模型 (~4GB)"
        log_info "  ollama pull qwen2.5-coder:14b-instruct  # 中模型 (~8GB)"
        log_info "  ollama pull qwen2.5-coder:32b-instruct  # 大模型 (~18GB)"
        log_info ""
        log_info "或查看可用模型: https://ollama.com/library/qwen2.5-coder"
        return 1
    fi

    # 预加载模型到内存
    log_info "预加载模型到内存..."
    ollama run "$RECOMMENDED_MODEL" "你好" > /dev/null 2>&1 || true
    log_success "模型已就绪"
}

# ============= 检查 uv (可选的加速工具) =============
check_uv() {
    log_step "检查 uv (可选的 Python 包管理加速器)"

    if command -v uv &> /dev/null; then
        log_success "检测到 uv，将使用 uv 加速安装"
        USE_UV=true
        return
    fi

    # 添加 cargo bin 到 PATH（如果 uv 已安装但不在 PATH）
    export PATH="$HOME/.cargo/bin:$PATH"
    if command -v uv &> /dev/null; then
        log_success "检测到 uv，将使用 uv 加速安装"
        USE_UV=true
        return
    fi

    log_info "未检测到 uv，将使用标准的 pip 安装"
    log_info "提示: 安装 uv 可以显著加速包安装（可选）"
    log_info "      curl -LsSf https://astral.sh/uv/install.sh | sh"
    USE_UV=false
}

# ============= 安装 Spec Kit =============
install_speckit() {
    log_step "安装 Spec Kit（全局 CLI 工具）"

    log_info "从 GitHub 安装 Spec Kit CLI..."

    # 方案 1: 使用 pipx（推荐 - 全局可用）
    if command -v pipx &> /dev/null; then
        log_info "使用 pipx 安装（全局可用）..."
        if pipx install git+https://github.com/github/spec-kit.git 2>/dev/null; then
            log_success "使用 pipx 安装完成（全局可用）✅"
            if command -v specify &> /dev/null; then
                SPECIFY_VERSION=$(specify --version 2>&1 || echo "unknown")
                log_info "版本: $SPECIFY_VERSION"
                log_info "安装位置: $(which specify)"
                return 0
            fi
        else
            log_warning "pipx 安装失败，尝试其他方式..."
        fi
    else
        log_info "未检测到 pipx，将尝试安装..."
        if [[ "$OS" == "macos" ]]; then
            log_info "使用 Homebrew 安装 pipx..."
            if brew install pipx 2>/dev/null; then
                pipx ensurepath
                export PATH="$HOME/.local/bin:$PATH"
                log_success "pipx 安装完成"

                log_info "使用 pipx 安装 Spec Kit..."
                if pipx install git+https://github.com/github/spec-kit.git; then
                    log_success "使用 pipx 安装完成（全局可用）✅"
                    if command -v specify &> /dev/null; then
                        SPECIFY_VERSION=$(specify --version 2>&1 || echo "unknown")
                        log_info "版本: $SPECIFY_VERSION"
                        log_info "安装位置: $(which specify)"
                        return 0
                    fi
                fi
            else
                log_warning "pipx 安装失败，将使用其他方式..."
            fi
        fi
    fi

    # 方案 2: 使用 uv（如果可用）
    if [ "$USE_UV" = true ]; then
        log_info "检测到 uv，尝试使用 uv 安装..."
        if uv tool install git+https://github.com/github/spec-kit.git 2>/dev/null; then
            log_success "使用 uv 安装完成"
            if command -v specify &> /dev/null; then
                SPECIFY_VERSION=$(specify --version 2>&1 || echo "unknown")
                log_info "版本: $SPECIFY_VERSION"
                return 0
            fi
        else
            log_warning "uv 安装失败，尝试 pip..."
        fi
    fi

    # 方案 3: 使用 pip + --break-system-packages（全局可用）
    log_info "使用 pip 安装（全局可用）..."
    if python3 -m pip install --user --break-system-packages git+https://github.com/github/spec-kit.git 2>/dev/null; then
        log_success "使用 pip 安装完成（全局可用）✅"

        # 确保 ~/.local/bin 在 PATH 中
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            log_info "添加 ~/.local/bin 到 PATH..."
            export PATH="$HOME/.local/bin:$PATH"

            # 持久化到 shell 配置
            if [ -f "$HOME/.zshrc" ]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
                log_info "已添加到 ~/.zshrc"
            elif [ -f "$HOME/.bashrc" ]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                log_info "已添加到 ~/.bashrc"
            fi
        fi
    else
        log_warning "Spec Kit 安装失败（这是可选组件）"
        log_info "LocalSpec 可以独立使用，不依赖 Spec Kit"
        log_info "您可以稍后手动安装:"
        log_info "  brew install pipx && pipx install git+https://github.com/github/spec-kit.git"
        return 0
    fi

    # 验证安装
    if command -v specify &> /dev/null; then
        log_success "Spec Kit CLI 已就绪（全局可用）✅"
        SPECIFY_VERSION=$(specify --version 2>&1 || echo "unknown")
        log_info "版本: $SPECIFY_VERSION"
        log_info "安装位置: $(which specify)"
        log_info "提示: specify 命令现在可在任何目录使用"
    else
        log_warning "Spec Kit CLI 不可用（这不影响 LocalSpec 使用）"
        log_info "请重新加载 shell 或重启终端后尝试: source ~/.zshrc"
    fi
}

# ============= 安装 LocalSpec CLI =============
install_localspec_cli() {
    log_step "安装 LocalSpec CLI"

    # 创建安装目录
    INSTALL_DIR="$HOME/.localspec"
    mkdir -p "$INSTALL_DIR"/{bin,lib,templates,cache}

    log_info "创建 LocalSpec CLI 工具..."

    # 创建主程序
    cat > "$INSTALL_DIR/bin/localspec" << 'LOCALSPEC_CLI_EOF'
#!/usr/bin/env python3
"""
LocalSpec CLI - 本地 AI 驱动的 Spec-Driven Development 工具
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Optional, Dict, Any

# 配置
OLLAMA_API = "http://localhost:11434/api/generate"
DEFAULT_MODEL = os.getenv("LOCALSPEC_MODEL", "qwen2.5-coder:14b-q5_k_m")
SPEC_DIR = ".specify"

class LocalSpec:
    def __init__(self, model: str = DEFAULT_MODEL):
        self.model = model
        self.project_root = self._find_project_root()
        self.spec_dir = self.project_root / SPEC_DIR if self.project_root else None

    def _find_project_root(self) -> Optional[Path]:
        """查找项目根目录"""
        current = Path.cwd()
        while current != current.parent:
            if (current / SPEC_DIR).exists():
                return current
            current = current.parent
        return None

    def _load_constitution(self) -> str:
        """加载项目宪法"""
        if not self.spec_dir:
            return ""

        constitution_file = self.spec_dir / "memory" / "constitution.md"
        if constitution_file.exists():
            return constitution_file.read_text()
        return ""

    def _load_latest_spec(self) -> str:
        """加载最新规范"""
        if not self.spec_dir:
            return ""

        specs_dir = self.spec_dir / "specs"
        if not specs_dir.exists():
            return ""

        # 找到最新的规范目录
        spec_dirs = sorted([d for d in specs_dir.iterdir() if d.is_dir()])
        if spec_dirs:
            spec_file = spec_dirs[-1] / "spec.md"
            if spec_file.exists():
                return spec_file.read_text()
        return ""

    def _call_ollama(self, prompt: str, system: str = "") -> str:
        """调用 Ollama API"""
        import requests

        full_prompt = f"{system}\n\n{prompt}" if system else prompt

        try:
            response = requests.post(
                OLLAMA_API,
                json={
                    "model": self.model,
                    "prompt": full_prompt,
                    "stream": False
                },
                timeout=300
            )
            response.raise_for_status()
            return response.json()["response"]
        except Exception as e:
            print(f"错误: 调用 Ollama 失败: {e}", file=sys.stderr)
            sys.exit(1)

    def init(self, project_name: str, **kwargs):
        """初始化项目"""
        print(f"🚀 初始化 LocalSpec 项目: {project_name}")

        # 调用 specify init
        cmd = ["specify", "init", project_name]

        if kwargs.get("git"):
            cmd.append("--git")

        subprocess.run(cmd, check=True)

        # 进入项目目录
        os.chdir(project_name)
        self.project_root = Path.cwd()
        self.spec_dir = self.project_root / SPEC_DIR

        # 创建 LocalSpec 配置
        config_file = self.spec_dir / "localspec.json"
        config = {
            "model": self.model,
            "version": "1.0.0",
            "created": subprocess.check_output(["date", "-u"]).decode().strip()
        }
        config_file.write_text(json.dumps(config, indent=2))

        print(f"✅ 项目初始化完成: {project_name}")
        print(f"📂 项目目录: {self.project_root}")
        print(f"🤖 使用模型: {self.model}")

    def constitution(self, description: str, **kwargs):
        """创建项目宪法"""
        print("📜 生成项目宪法...")

        prompt = f"""你是一个软件架构专家，请基于以下描述生成项目宪法（开发原则）：

{description}

要求：
1. 使用中文
2. 包含以下部分：
   - 核心原则（3-5条）
   - 技术标准（编码规范、测试要求等）
   - 架构约束（设计模式、依赖管理等）
   - 开发流程（版本控制、代码审查等）
3. 每条原则要具体、可执行
4. 使用 Markdown 格式

输出格式：
# 项目宪法

## 第一条：[原则名称]
[详细描述]

## 第二条：[原则名称]
[详细描述]

...
"""

        result = self._call_ollama(prompt)

        # 保存到文件
        constitution_file = self.spec_dir / "memory" / "constitution.md"
        constitution_file.parent.mkdir(parents=True, exist_ok=True)
        constitution_file.write_text(result)

        print(f"✅ 宪法已生成: {constitution_file}")
        print("\n" + "="*60)
        print(result[:500] + "...")
        print("="*60)

    def specify(self, description: str, **kwargs):
        """生成功能规范"""
        print("📝 生成功能规范...")

        constitution = self._load_constitution()

        # 加载规范模板
        template_file = self.spec_dir / "templates" / "spec-template.md"
        if template_file.exists():
            template = template_file.read_text()
        else:
            template = ""

        system_prompt = f"""你是一个专业的需求分析师。

项目宪法：
{constitution}

规范模板参考：
{template[:1000]}
"""

        prompt = f"""请基于以下用户需求生成详细的功能规范：

{description}

要求：
1. 使用中文
2. 包含完整的用户故事
3. 明确功能需求和非功能需求
4. 定义清晰的验收标准
5. 不包含技术实现细节
6. 使用 Markdown 格式

输出格式应包含：
# 功能规范：[功能名称]

## 概述
[简短描述]

## 用户故事
- 作为[角色]，我想要[功能]，以便[价值]

## 功能需求
1. [需求1]
2. [需求2]

## 非功能需求
- 性能：[要求]
- 安全：[要求]

## 验收标准
- [ ] [标准1]
- [ ] [标准2]
"""

        result = self._call_ollama(prompt, system_prompt)

        # 确定规范目录
        specs_dir = self.spec_dir / "specs"
        specs_dir.mkdir(exist_ok=True)

        # 获取下一个编号
        existing = [d for d in specs_dir.iterdir() if d.is_dir() and d.name[:3].isdigit()]
        next_num = len(existing) + 1

        # 创建规范目录
        spec_name = f"{next_num:03d}-feature"
        spec_dir = specs_dir / spec_name
        spec_dir.mkdir(exist_ok=True)

        # 保存规范
        spec_file = spec_dir / "spec.md"
        spec_file.write_text(result)

        print(f"✅ 规范已生成: {spec_file}")
        print("\n" + "="*60)
        print(result[:500] + "...")
        print("="*60)

    def plan(self, tech_stack: str, **kwargs):
        """生成技术计划"""
        print("🎯 生成技术实现计划...")

        constitution = self._load_constitution()
        spec = self._load_latest_spec()

        if not spec:
            print("错误: 未找到功能规范，请先运行 localspec specify", file=sys.stderr)
            sys.exit(1)

        system_prompt = f"""你是一个资深的技术架构师。

项目宪法：
{constitution}

当前功能规范：
{spec[:2000]}
"""

        prompt = f"""请基于以下技术栈生成详细的实现计划：

{tech_stack}

要求：
1. 使用中文
2. 详细的技术架构设计
3. 数据模型定义
4. API 接口设计
5. 实现步骤分解
6. 测试策略
7. 使用 Markdown 格式

输出格式：
# 技术实现计划

## 技术栈
[列出所有技术选型及理由]

## 系统架构
[架构图描述]

## 数据模型
[实体和关系]

## API 设计
[接口列表]

## 实现步骤
### Phase 1: [阶段名称]
- Task 1.1: [任务描述]
- Task 1.2: [任务描述]

## 测试策略
[测试方法和覆盖范围]
"""

        result = self._call_ollama(prompt, system_prompt)

        # 保存计划
        specs_dir = self.spec_dir / "specs"
        latest_spec = sorted([d for d in specs_dir.iterdir() if d.is_dir()])[-1]
        plan_file = latest_spec / "plan.md"
        plan_file.write_text(result)

        print(f"✅ 计划已生成: {plan_file}")
        print("\n" + "="*60)
        print(result[:500] + "...")
        print("="*60)

    def tasks(self, **kwargs):
        """分解任务"""
        print("📋 生成任务列表...")

        # 加载计划
        specs_dir = self.spec_dir / "specs"
        latest_spec = sorted([d for d in specs_dir.iterdir() if d.is_dir()])[-1]
        plan_file = latest_spec / "plan.md"

        if not plan_file.exists():
            print("错误: 未找到实现计划，请先运行 localspec plan", file=sys.stderr)
            sys.exit(1)

        plan = plan_file.read_text()

        prompt = f"""请基于以下实现计划生成详细的任务列表：

{plan}

要求：
1. 使用中文
2. 将计划分解为具体的、可执行的任务
3. 标记任务依赖关系
4. 标记可并行执行的任务 [P]
5. 估算每个任务的时间
6. 使用 Markdown 格式

输出格式：
# 任务分解

## Phase 1: [阶段名称] [预计时间]

### 任务组 1.1: [组名] [并行标记]
- [P] Task 1.1.1: [任务描述] (预计时间) [文件路径]
- [P] Task 1.1.2: [任务描述] (预计时间) [文件路径]
- [→] Task 1.1.3: [任务描述] (预计时间) [依赖 1.1.1]

## Phase 2: [阶段名称] [预计时间]
...
"""

        result = self._call_ollama(prompt)

        # 保存任务列表
        tasks_file = latest_spec / "tasks.md"
        tasks_file.write_text(result)

        print(f"✅ 任务列表已生成: {tasks_file}")
        print("\n" + "="*60)
        print(result[:500] + "...")
        print("="*60)

def main():
    parser = argparse.ArgumentParser(
        description="LocalSpec - 本地 AI 驱动的 Spec-Driven Development",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("--model", default=DEFAULT_MODEL, help="AI 模型名称")
    parser.add_argument("--version", action="version", version="LocalSpec 1.0.0")

    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # init 命令
    init_parser = subparsers.add_parser("init", help="初始化项目")
    init_parser.add_argument("project_name", help="项目名称")
    init_parser.add_argument("--git", action="store_true", help="初始化 Git 仓库")

    # constitution 命令
    const_parser = subparsers.add_parser("constitution", help="创建项目宪法")
    const_parser.add_argument("description", help="宪法描述")

    # specify 命令
    spec_parser = subparsers.add_parser("specify", help="生成功能规范")
    spec_parser.add_argument("description", help="功能描述")

    # plan 命令
    plan_parser = subparsers.add_parser("plan", help="生成技术计划")
    plan_parser.add_argument("tech_stack", help="技术栈描述")

    # tasks 命令
    tasks_parser = subparsers.add_parser("tasks", help="生成任务列表")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # 创建 LocalSpec 实例
    localspec = LocalSpec(model=args.model)

    # 执行命令
    if args.command == "init":
        localspec.init(args.project_name, git=args.git)
    elif args.command == "constitution":
        localspec.constitution(args.description)
    elif args.command == "specify":
        localspec.specify(args.description)
    elif args.command == "plan":
        localspec.plan(args.tech_stack)
    elif args.command == "tasks":
        localspec.tasks()

if __name__ == "__main__":
    main()
LOCALSPEC_CLI_EOF

    chmod +x "$INSTALL_DIR/bin/localspec"

    # 添加到 PATH
    SHELL_RC=""
    if [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    fi

    if [ -n "$SHELL_RC" ]; then
        if ! grep -q "localspec/bin" "$SHELL_RC"; then
            echo "" >> "$SHELL_RC"
            echo "# LocalSpec" >> "$SHELL_RC"
            echo "export PATH=\"\$HOME/.localspec/bin:\$PATH\"" >> "$SHELL_RC"
            log_info "已添加到 $SHELL_RC"
        fi
    fi

    export PATH="$HOME/.localspec/bin:$PATH"

    # 安装 Python 依赖
    log_info "安装 Python 依赖（requests）..."

    # 尝试使用 pip 安装（添加 --break-system-packages）
    if python3 -m pip install --user --break-system-packages --quiet requests 2>/dev/null; then
        log_success "Python 依赖安装完成（使用 pip）"
    elif pip3 install --user --break-system-packages --quiet requests 2>/dev/null; then
        log_success "Python 依赖安装完成（使用 pip3）"
    else
        log_warning "pip 安装失败，尝试使用 pipx..."
        if command -v pipx &> /dev/null || brew install pipx; then
            pipx install requests 2>/dev/null || log_warning "requests 安装失败（可能已安装）"
        else
            log_warning "无法安装 requests 库"
            log_info "LocalSpec CLI 可能需要手动安装: pip3 install --user --break-system-packages requests"
        fi
    fi

    if command -v localspec &> /dev/null; then
        log_success "LocalSpec CLI 安装完成"
        log_info "安装路径: $INSTALL_DIR"
    else
        log_error "LocalSpec CLI 安装失败"
        exit 1
    fi
}

# ============= 运行验证测试 =============
run_verification() {
    log_step "运行验证测试"

    # 测试 Ollama
    log_info "测试 Ollama 服务..."
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        log_success "Ollama 服务正常"
    else
        log_error "Ollama 服务异常"
        return 1
    fi

    # 测试模型
    log_info "测试 AI 模型..."
    if ollama list | grep -q "$RECOMMENDED_MODEL"; then
        log_success "模型可用: $RECOMMENDED_MODEL"
    else
        log_warning "未找到推荐模型"
    fi

    # 测试 Spec Kit
    log_info "测试 Spec Kit..."
    if specify version > /dev/null 2>&1; then
        log_success "Spec Kit 正常"
    else
        log_error "Spec Kit 异常"
        return 1
    fi

    # 测试 LocalSpec
    log_info "测试 LocalSpec CLI..."
    if localspec --version > /dev/null 2>&1; then
        log_success "LocalSpec CLI 正常"
    else
        log_error "LocalSpec CLI 异常"
        return 1
    fi

    log_success "所有验证测试通过！"
}

# ============= 显示安装摘要 =============
show_summary() {
    log_step "安装完成"

    echo -e "${GREEN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║                  ✅ LocalSpec 安装成功！                      ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${CYAN}📦 已安装组件：${NC}"
    echo "  ✅ Ollama $(ollama --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo '')"
    echo "  ✅ AI 模型: $RECOMMENDED_MODEL"
    echo "  ✅ Spec Kit $(specify --version 2>&1 || echo '')"
    echo "  ✅ LocalSpec CLI v1.0.0"
    echo ""

    echo -e "${CYAN}🚀 快速开始：${NC}"
    echo ""
    echo "  # 1. 创建新项目"
    echo "  localspec init my-project"
    echo ""
    echo "  # 2. 进入项目目录"
    echo "  cd my-project"
    echo ""
    echo "  # 3. 创建项目宪法"
    echo "  localspec constitution \"项目采用微服务架构，TDD开发\""
    echo ""
    echo "  # 4. 创建功能规范"
    echo "  localspec specify \"构建用户认证系统\""
    echo ""
    echo "  # 5. 生成技术计划"
    echo "  localspec plan \"FastAPI + PostgreSQL + Vue3\""
    echo ""
    echo "  # 6. 分解任务"
    echo "  localspec tasks"
    echo ""

    echo -e "${CYAN}📚 更多信息：${NC}"
    echo "  • 完整文档: cat ~/.localspec/README.md"
    echo "  • 命令帮助: localspec --help"
    echo "  • 社区支持: https://github.com/yourname/localspec"
    echo ""

    echo -e "${YELLOW}⚠️  重要提示：${NC}"
    echo "  • 请重新加载终端或运行: source ~/.bashrc (或 ~/.zshrc)"
    echo "  • 首次运行可能需要等待模型加载（10-30秒）"
    echo "  • 建议内存: ${TOTAL_MEM}GB (当前配置)"
    echo ""

    log_success "开始你的 AI 驱动开发之旅吧！🎉"
}

# ============= 主函数 =============
main() {
    show_banner

    # 检测环境
    detect_os
    check_hardware

    # 安装组件
    install_dependencies
    install_ollama
    download_model
    check_uv  # 检查 uv（可选）
    install_speckit
    install_localspec_cli

    # 验证
    run_verification

    # 显示摘要
    show_summary
}

# 执行主函数
main "$@"

#!/bin/bash

################################################################################
# LocalSpec 部署验证脚本
# 用于验证所有文件是否正确部署
################################################################################

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          LocalSpec 解决方案部署验证                         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 文件检查列表
declare -A files=(
    # 核心文档
    ["START-HERE.md"]="快速入门指南"
    ["LocalSpec-README.md"]="完整使用手册"
    ["LOCALSPEC-QUICKREF.md"]="命令快速参考"
    ["DELIVERY-CHECKLIST.md"]="交付清单"
    ["FINAL-DELIVERY.md"]="完整交付说明"

    # 安装脚本
    ["install-localspec-complete.sh"]="完整安装脚本"
    ["install-localspec.sh"]="核心工具安装脚本"
    ["install-vscode-integration.sh"]="VS Code 集成脚本"
    ["install-pycharm-integration.sh"]="PyCharm 集成脚本"

    # 配置和示例
    ["localspec-config-template.yaml"]="配置模板"
    ["example-xiangmanyuan.sh"]="实战示例"

    # IDE 集成文档
    ["IDE-INTEGRATION.md"]="IDE 集成指南"
    ["IDE-INTEGRATION-TEST.md"]="IDE 集成测试"
    ["IDE-INTEGRATION-COMPLETE.md"]="IDE 集成完成说明"
)

# 统计
total=0
passed=0
failed=0

echo "检查文件完整性..."
echo ""

for file in "${!files[@]}"; do
    ((total++))
    description="${files[$file]}"

    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo -e "${GREEN}✓${NC} $file (${size}) - ${description}"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $file - ${description} ${RED}[缺失]${NC}"
        ((failed++))
    fi
done

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# 检查脚本可执行权限
echo "检查脚本可执行权限..."
echo ""

scripts=(
    "install-localspec-complete.sh"
    "install-localspec.sh"
    "install-vscode-integration.sh"
    "install-pycharm-integration.sh"
    "example-xiangmanyuan.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✓${NC} $script 可执行"
        else
            echo -e "${YELLOW}⚠${NC} $script 不可执行，正在修复..."
            chmod +x "$script"
            echo -e "${GREEN}✓${NC} $script 已修复"
        fi
    fi
done

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# 统计报告
echo "部署验证结果:"
echo ""
echo -e "  总文件数: ${BLUE}${total}${NC}"
echo -e "  通过检查: ${GREEN}${passed}${NC}"
echo -e "  检查失败: ${RED}${failed}${NC}"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ 所有文件部署成功！${NC}"
    echo ""
    echo "下一步操作:"
    echo ""
    echo "  1. 阅读快速入门:"
    echo -e "     ${BLUE}cat START-HERE.md${NC}"
    echo ""
    echo "  2. 运行完整安装:"
    echo -e "     ${BLUE}bash install-localspec-complete.sh${NC}"
    echo ""
    echo "  3. 查看完整文档:"
    echo -e "     ${BLUE}cat LocalSpec-README.md${NC}"
    echo ""
    echo "  4. 运行实战示例:"
    echo -e "     ${BLUE}bash example-xiangmanyuan.sh${NC}"
    echo ""
else
    echo -e "${RED}✗ 部署验证失败！${NC}"
    echo ""
    echo "请检查缺失的文件并重新部署。"
    exit 1
fi

# 文件大小统计
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "文件大小统计:"
echo ""

total_size=$(du -sh . 2>/dev/null | cut -f1)
echo -e "  解决方案总大小: ${BLUE}${total_size}${NC}"
echo ""

doc_size=$(du -ch *.md 2>/dev/null | tail -1 | cut -f1)
echo -e "  文档总大小: ${doc_size}"

script_size=$(du -ch *.sh 2>/dev/null | tail -1 | cut -f1)
echo -e "  脚本总大小: ${script_size}"

config_size=$(du -ch *.yaml 2>/dev/null | tail -1 | cut -f1)
echo -e "  配置总大小: ${config_size}"

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# 内容统计
echo "内容统计:"
echo ""

md_lines=$(cat *.md 2>/dev/null | wc -l | xargs)
echo -e "  文档总行数: ${md_lines} 行"

sh_lines=$(cat *.sh 2>/dev/null | wc -l | xargs)
echo -e "  脚本总行数: ${sh_lines} 行"

total_lines=$((md_lines + sh_lines))
echo -e "  总代码行数: ${BLUE}${total_lines}${NC} 行"

echo ""
echo -e "${GREEN}LocalSpec 完整解决方案已准备就绪！${NC}"
echo ""

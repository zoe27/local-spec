# 🚀 LocalSpec 完整解决方案 - 从这里开始

> **本地 AI 驱动的规范化开发工具**
>
> 零 API 成本 | 完全离线 | 生产就绪 | IDE 深度集成

---

## 📦 包含内容

本解决方案提供完整的本地 AI 开发环境,包括:

### 核心组件
- ✅ **LocalSpec CLI** - 命令行工具
- ✅ **Ollama 集成** - 本地 AI 模型运行时
- ✅ **Qwen2.5-Coder** - 中文友好的代码生成模型
- ✅ **Spec Kit 集成** - 规范驱动开发框架

### IDE 集成
- ✅ **VS Code 完整集成** - 任务、快捷键、代码片段
- ✅ **PyCharm 完整集成** - 外部工具、运行配置、模板

### 文档和示例
- ✅ **完整文档** - 使用指南、API 参考、最佳实践
- ✅ **实战示例** - 香满园餐厅管理系统
- ✅ **快速参考卡** - 常用命令速查
- ✅ **配置模板** - 开箱即用的配置

---

## ⚡ 一键安装

### 方式一: 完整自动安装 (推荐)

```bash
# 运行完整安装脚本
bash install-localspec-complete.sh
```

这个脚本会:
1. 检测系统环境和硬件配置
2. 推荐合适的 AI 模型
3. 安装 Ollama + LocalSpec CLI
4. 配置 VS Code 集成 (可选)
5. 配置 PyCharm 集成 (可选)
6. 创建示例项目
7. 运行系统诊断
8. 生成使用指南

### 方式二: 分步安装

```bash
# 1. 安装核心工具
bash install-localspec.sh

# 2. 配置 VS Code (可选)
bash install-vscode-integration.sh

# 3. 配置 PyCharm (可选)
bash install-pycharm-integration.sh
```

---

## 📋 系统要求

### 最低配置
- **内存**: 8GB RAM
- **存储**: 10GB 可用空间
- **系统**: macOS 10.15+ 或 Linux (Ubuntu 20.04+)
- **Python**: 3.8+

### 推荐配置
- **内存**: 16GB RAM
- **存储**: 20GB 可用空间
- **GPU**: 可选,但会显著提升性能

### 模型选择指南

| 内存大小 | 推荐模型 | 性能等级 | 适用场景 |
|---------|---------|----------|---------|
| 8GB     | qwen2.5-coder:7b-q4  | ⭐⭐⭐   | 学习、小型项目 |
| 16GB    | qwen2.5-coder:14b-q5 | ⭐⭐⭐⭐ | 日常开发、中型项目 |
| 32GB    | qwen2.5-coder:32b-q5 | ⭐⭐⭐⭐⭐ | 专业开发、大型项目 |
| 64GB+   | qwen2.5-coder:72b-q8 | ⭐⭐⭐⭐⭐ | 企业级、复杂项目 |

---

## 🎯 快速开始 (5 分钟)

### 1. 验证安装

```bash
# 检查 LocalSpec
localspec --version

# 检查 Ollama
ollama list

# 运行诊断
localspec doctor
```

### 2. 创建第一个项目

```bash
# 初始化项目
localspec init hello-world
cd hello-world

# 定义项目原则
localspec constitution "简单、可维护、有测试"

# 创建功能规范
localspec specify "创建一个简单的问候 API，接受名字参数，返回问候语"

# 生成技术方案
localspec plan "使用 Python FastAPI，简单的 REST API"

# 分解任务
localspec tasks

# 实现代码
localspec implement --interactive
```

### 3. 查看生成的内容

```bash
# 查看规范
cat .specify/specs/001-greeting-api/spec.md

# 查看计划
cat .specify/specs/001-greeting-api/plan.md

# 查看任务
cat .specify/specs/001-greeting-api/tasks.md

# 查看项目状态
localspec status
```

---

## 📚 核心概念

### 规范驱动开发 (SDD)

LocalSpec 采用规范驱动开发方法论:

```
项目宪法 (Constitution)
    ↓
功能规范 (Specification)
    ↓
技术计划 (Plan)
    ↓
任务分解 (Tasks)
    ↓
代码实现 (Implementation)
    ↓
测试验证 (Test)
```

### 核心命令

| 命令 | 用途 | 示例 |
|-----|------|------|
| `init` | 初始化项目 | `localspec init my-app` |
| `constitution` | 定义项目原则 | `localspec constitution "..."` |
| `specify` | 创建功能规范 | `localspec specify "..."` |
| `clarify` | 澄清规范细节 | `localspec clarify` |
| `plan` | 生成技术方案 | `localspec plan "..."` |
| `tasks` | 分解实现任务 | `localspec tasks` |
| `implement` | 执行代码实现 | `localspec implement` |
| `analyze` | 分析项目状态 | `localspec analyze` |
| `chat` | AI 辅助对话 | `localspec chat` |

---

## 💻 IDE 使用

### VS Code 快捷键

| 快捷键 | 功能 |
|-------|------|
| `Ctrl+Shift+L S` | 创建规范 |
| `Ctrl+Shift+L P` | 生成计划 |
| `Ctrl+Shift+L T` | 分解任务 |
| `Ctrl+Shift+L I` | 执行实现 |
| `Ctrl+Shift+L C` | AI 聊天 |
| `Ctrl+Shift+L V` | 查看状态 |
| `Ctrl+Shift+L A` | 项目分析 |

### 代码片段

在任何文件中输入:
- `lspec` + Tab → localspec specify 模板
- `lplan` + Tab → localspec plan 模板
- `ltask` + Tab → localspec tasks 模板
- `limpl` + Tab → localspec implement 模板

### PyCharm 使用

1. **工具菜单**: Tools → LocalSpec → 选择功能
2. **运行配置**: Run → LocalSpec: 创建规范
3. **Live Templates**: 输入 `lspec` + Tab

详细说明请查看: [IDE-INTEGRATION.md](IDE-INTEGRATION.md)

---

## 📖 实战示例: 香满园餐厅管理系统

完整的实战示例展示如何使用 LocalSpec 开发真实项目:

```bash
# 查看示例脚本
cat example-xiangmanyuan.sh

# 运行示例(将实际执行命令)
bash example-xiangmanyuan.sh
```

该示例包含:
- ✅ 完整的项目规范
- ✅ 前后端技术栈选择
- ✅ 数据库设计
- ✅ API 接口定义
- ✅ 测试策略
- ✅ 部署方案

---

## 🔧 配置说明

### 全局配置

配置文件位置: `~/.localspec/config.yaml`

```yaml
# 模型配置
model:
  name: "qwen2.5-coder:14b-q5_k_m"
  temperature: 0.3
  max_tokens: 4096

# 工作流
workflow:
  auto_clarify: true
  tdd_enabled: true

# 性能
performance:
  cache_enabled: true
  parallel_tasks: 2
```

### 项目配置

配置文件位置: `.localspec/config.yaml`

```yaml
project:
  name: "my-project"
  type: "web"
  language: "zh-CN"
  primary_tech: "Python"
```

完整配置模板: [localspec-config-template.yaml](localspec-config-template.yaml)

---

## 🎨 工作流示例

### 场景 1: 全新项目

```bash
# 1. 创建项目
localspec init my-saas
cd my-saas

# 2. 定义原则
localspec constitution "
核心原则:
- 安全第一,所有输入必须验证
- 测试驱动开发,覆盖率 >80%
- 微服务架构,服务间解耦
- RESTful API 设计
- 中文文档
"

# 3. 创建用户认证规范
localspec specify "
实现用户认证系统:
- 邮箱 + 密码登录
- JWT token 认证
- OAuth 第三方登录(微信、GitHub)
- 密码重置功能
- 登录失败限制
"

# 4. 生成技术方案
localspec plan "
后端: Python 3.11 + FastAPI
数据库: PostgreSQL 15 + Redis 7
认证: python-jose (JWT)
部署: Docker + Nginx
测试: pytest + coverage
"

# 5. 实现
localspec tasks && localspec implement
```

### 场景 2: 现有项目添加功能

```bash
# 1. 进入现有项目
cd existing-project

# 2. 初始化 LocalSpec (不覆盖现有代码)
localspec init . --force

# 3. 创建新功能规范
localspec specify "
为现有电商系统添加优惠券功能:
- 创建优惠券(固定金额、百分比折扣)
- 设置使用条件(最低消费、有效期、使用次数)
- 用户领取和使用优惠券
- 优惠券使用统计
"

# 4. 生成增量方案
localspec plan "
复用现有架构:
- 使用现有的 User 和 Order 模型
- 新增 Coupon 和 CouponUsage 模型
- 在结算流程中集成优惠券逻辑
- 新增优惠券管理 API
"

# 5. 实现新功能
localspec tasks && localspec implement
```

### 场景 3: 代码审查和重构

```bash
# 1. 分析现有代码
localspec analyze --all

# 2. 生成重构规范
localspec specify "
重构用户服务模块:
- 提取重复代码为工具函数
- 改进错误处理
- 添加日志
- 优化数据库查询
- 添加缺失的测试
"

# 3. 生成重构计划
localspec plan "保持现有 API 接口不变,内部重构"

# 4. 执行重构
localspec implement --test-first
```

---

## 🐛 故障排查

### 常见问题

#### 1. Ollama 服务未启动

```bash
# macOS
open -a Ollama

# Linux
sudo systemctl start ollama
sudo systemctl status ollama

# 验证
curl http://localhost:11434/api/tags
```

#### 2. 模型未安装

```bash
# 查看已安装模型
ollama list

# 安装推荐模型
ollama pull qwen2.5-coder:14b-q5_k_m

# 预加载模型(提升首次速度)
ollama run qwen2.5-coder:14b-q5_k_m "hello"
```

#### 3. LocalSpec 命令找不到

```bash
# 检查 PATH
echo $PATH | grep localspec

# 如果没有,手动添加
echo 'export PATH="$HOME/.localspec/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 或使用完整路径
~/.localspec/bin/localspec --version
```

#### 4. 生成质量不佳

```bash
# 1. 使用更大的模型
localspec --model qwen2.5-coder:32b specify "..."

# 2. 降低温度(更确定性)
localspec config set model.temperature 0.2

# 3. 提供更详细的描述
localspec specify "
详细需求:
- 功能点 1: xxx
- 功能点 2: xxx
- 技术要求: xxx
- 安全要求: xxx
- 性能要求: xxx
"

# 4. 使用澄清功能
localspec clarify --interactive
```

#### 5. VS Code 快捷键不工作

```bash
# 重新运行集成脚本
bash install-vscode-integration.sh

# 手动检查配置
cat .vscode/keybindings.json

# 重启 VS Code
# Command Palette: Reload Window
```

### 系统诊断

```bash
# 运行完整诊断
localspec doctor --report

# 查看日志
tail -f ~/.localspec/logs/localspec.log

# 清除缓存(如果遇到奇怪问题)
localspec cache clear
```

---

## 📁 文件结构

安装后的完整目录结构:

```
~/.localspec/                    # LocalSpec 主目录
├── bin/                         # 可执行文件
│   └── localspec               # 主命令
├── config.yaml                  # 全局配置
├── cache/                       # 缓存目录
├── logs/                        # 日志目录
│   └── localspec.log
├── history/                     # 对话历史
└── prompts/                     # 自定义提示词

项目目录/.specify/               # 项目规范目录
├── constitution.md              # 项目宪法
├── specs/                       # 规范文件
│   ├── 001-feature-name/
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── 002-another-feature/
├── memory/                      # 项目记忆
└── templates/                   # 项目模板

.vscode/                         # VS Code 配置
├── tasks.json
├── keybindings.json
├── settings.json
├── localspec.code-snippets
└── extensions.json

.idea/                           # PyCharm 配置
├── externalTools.xml
├── runConfigurations/
└── LiveTemplates_LocalSpec.xml
```

---

## 📚 完整文档索引

| 文档 | 用途 | 查看命令 |
|-----|------|---------|
| **START-HERE.md** | 快速入门(本文档) | 你正在看 |
| **LocalSpec-README.md** | 完整使用手册 | `cat LocalSpec-README.md` |
| **LOCALSPEC-QUICKREF.md** | 命令快速参考 | `cat LOCALSPEC-QUICKREF.md` |
| **IDE-INTEGRATION.md** | IDE 集成指南 | `cat IDE-INTEGRATION.md` |
| **localspec-config-template.yaml** | 配置模板 | `cat localspec-config-template.yaml` |
| **example-xiangmanyuan.sh** | 实战示例 | `cat example-xiangmanyuan.sh` |
| **DELIVERY-CHECKLIST.md** | 交付清单 | `cat DELIVERY-CHECKLIST.md` |
| **FINAL-DELIVERY.md** | 完整交付说明 | `cat FINAL-DELIVERY.md` |

---

## 🎓 学习路径

### 第 1 天: 基础入门 (2-3 小时)

1. **安装环境** (30 分钟)
   ```bash
   bash install-localspec-complete.sh
   ```

2. **理解核心概念** (30 分钟)
   - 阅读本文档的"核心概念"部分
   - 理解规范驱动开发流程

3. **创建第一个项目** (1 小时)
   ```bash
   localspec init hello-world
   # 按照"快速开始"部分的步骤操作
   ```

4. **IDE 集成练习** (30 分钟)
   - 熟悉 VS Code 快捷键
   - 尝试代码片段
   - 使用任务菜单

### 第 2 天: 实战练习 (4-6 小时)

1. **运行示例项目** (2 小时)
   ```bash
   bash example-xiangmanyuan.sh
   # 研究生成的代码和文档
   ```

2. **自己的项目** (2-3 小时)
   - 选择一个小型项目想法
   - 完整走一遍 SDD 流程
   - 使用 TDD 方式实现

3. **探索高级功能** (1 小时)
   - 自定义配置
   - 自定义提示词
   - 使用 chat 命令调试

### 第 3 天: 团队协作 (2-4 小时)

1. **配置团队规范** (1 小时)
   - 创建团队配置模板
   - 定义代码风格
   - 设置 Git 工作流

2. **现有项目集成** (2 小时)
   - 为现有项目添加 LocalSpec
   - 生成缺失的文档
   - 规划重构任务

3. **最佳实践总结** (1 小时)
   - 整理工作流
   - 分享团队经验
   - 优化配置

---

## 🤝 贡献和反馈

### 报告问题

```bash
# 生成诊断报告
localspec doctor --report > diagnostic.txt

# 在 GitHub 创建 Issue 并附上报告
# https://github.com/github/spec-kit/issues
```

### 功能建议

欢迎通过 GitHub Discussions 提出:
- 新功能建议
- 使用场景分享
- 最佳实践交流

### 贡献代码

1. Fork 项目
2. 创建功能分支
3. 提交 Pull Request

---

## 📜 许可证

本解决方案基于 MIT 许可证开源。

- **Spec Kit**: MIT License (GitHub)
- **Ollama**: MIT License
- **Qwen2.5-Coder**: Apache 2.0 License

---

## 🔗 相关资源

### 官方文档
- **Spec Kit**: https://github.com/github/spec-kit
- **Ollama**: https://ollama.com
- **Qwen**: https://qwenlm.github.io/

### 社区
- **GitHub Issues**: https://github.com/github/spec-kit/issues
- **Discussions**: https://github.com/github/spec-kit/discussions

### 推荐阅读
- 《规范驱动开发实践》
- 《AI 辅助编程最佳实践》
- 《本地 LLM 应用开发指南》

---

## ❓ 常见疑问

### Q: LocalSpec 和 GitHub Copilot 有什么区别?

**A**:
- **Copilot**: 代码补全,云端 API,按月付费
- **LocalSpec**: 完整的规范驱动开发流程,完全本地,零成本

LocalSpec 更适合:
- 需要离线开发
- 有安全合规要求
- 希望掌控开发流程
- 追求零 API 成本

### Q: 必须使用 Ollama 吗?

**A**: 不是,LocalSpec 设计为模型无关:
- 默认使用 Ollama (最简单)
- 可配置任何 OpenAI 兼容 API
- 可集成其他本地模型服务

### Q: 生成的代码质量如何?

**A**: 取决于:
- **模型大小**: 32B > 14B > 7B
- **规范质量**: 描述越详细越好
- **迭代次数**: 可以多次澄清和改进

建议:
- 16GB 内存用 14B 模型
- 提供详细的需求描述
- 使用 clarify 命令完善规范
- 代码生成后人工审查

### Q: 可以用于生产环境吗?

**A**: 可以,但建议:
- ✅ 使用 LocalSpec 生成规范和骨架代码
- ✅ 人工审查所有生成的代码
- ✅ 完善测试覆盖
- ✅ 遵循安全最佳实践
- ⚠️ 不要盲目信任 AI 生成的代码

### Q: 支持哪些编程语言?

**A**: Qwen2.5-Coder 支持:
- ✅ Python (优秀)
- ✅ JavaScript/TypeScript (优秀)
- ✅ Java (良好)
- ✅ Go (良好)
- ✅ Rust (良好)
- ✅ C/C++ (良好)
- ✅ 其他主流语言(基础)

中文注释和文档支持优秀。

### Q: 团队如何使用?

**A**: 推荐方式:
1. 建立团队配置模板
2. Git 追踪 `.specify/` 目录
3. 统一使用相同模型
4. 定期同步最佳实践
5. Code Review 必不可少

### Q: 性能如何优化?

**A**:
```bash
# 1. 预加载模型
ollama run qwen2.5-coder:14b --keep-alive 60m

# 2. 启用缓存
localspec config set performance.cache_enabled true

# 3. 减少上下文
localspec implement --context-mode minimal

# 4. 使用并行
localspec tasks --parallel 4

# 5. 升级硬件
# 更大内存 → 更大模型 → 更好效果
```

---

## 🎉 开始你的 LocalSpec 之旅

现在你已经准备好开始使用 LocalSpec 了!

### 推荐的第一步:

```bash
# 1. 运行完整安装
bash install-localspec-complete.sh

# 2. 验证安装
localspec doctor

# 3. 创建第一个项目
localspec init my-first-project
cd my-first-project

# 4. 开始开发
localspec constitution "你的项目原则"
localspec specify "你的第一个功能"
localspec plan "你的技术栈"
localspec implement
```

### 需要帮助?

- 📖 查看文档: `cat LocalSpec-README.md`
- 🔍 快速参考: `cat LOCALSPEC-QUICKREF.md`
- 💡 查看示例: `cat example-xiangmanyuan.sh`
- 🔧 运行诊断: `localspec doctor`
- 💬 获取帮助: `localspec --help`

---

**祝你编码愉快！享受 AI 驱动的开发体验！** 🚀

---

*最后更新: 2025-01-15*
*版本: 1.0.0*
*维护者: LocalSpec Team*

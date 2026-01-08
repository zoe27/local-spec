# LocalSpec 快速参考卡

## 🚀 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/localspec/main/install.sh | bash
```

---

## 📋 核心命令

### 项目管理
```bash
# 创建新项目
localspec init <project-name> [--git]

# 在现有目录初始化
localspec init . --force

# 查看项目状态
localspec status

# 显示项目信息
localspec info
```

### 规范驱动工作流
```bash
# 1. 创建项目宪法
localspec constitution "项目原则描述..."

# 2. 生成功能规范
localspec specify "功能需求描述..."

# 3. 澄清规范（可选）
localspec clarify [--focus security]

# 4. 生成技术计划
localspec plan "技术栈描述..."

# 5. 分解任务
localspec tasks [--parallel] [--estimate]

# 6. 执行实现
localspec implement [--interactive] [--test-first]

# 7. 分析项目
localspec analyze [--all]
```

### 辅助命令
```bash
# AI 聊天
localspec chat [--context files] [--mode review]

# 查看文档
localspec show [spec|plan|tasks]

# 清理缓存
localspec cache clear

# 更新工具
localspec update [--check]

# 诊断工具
localspec doctor [--report]
```

---

## 🎯 快速工作流

### 标准流程（从零开始）
```bash
# 1. 初始化
localspec init my-project && cd my-project

# 2. 定义原则
localspec constitution "安全第一，TDD开发，微服务架构"

# 3. 创建规范
localspec specify "构建用户认证系统，支持邮箱和OAuth登录"

# 4. 生成方案
localspec plan "FastAPI + PostgreSQL + Vue3 + JWT"

# 5. 实现代码
localspec tasks && localspec implement --interactive
```

### 快速原型（跳过澄清）
```bash
localspec init prototype
cd prototype
localspec specify "简单的博客系统" --no-clarify
localspec plan "Flask + SQLite" --quick
localspec implement --dry-run
```

### 迭代开发（添加功能）
```bash
cd existing-project
localspec specify "添加评论功能，支持回复和点赞"
localspec plan "复用现有架构，新增Comment模型"
localspec tasks && localspec implement
```

---

## 📊 常用参数

### 模型选择
```bash
# 使用特定模型
localspec --model qwen2.5-coder:32b specify "..."

# 环境变量设置
export LOCALSPEC_MODEL="qwen2.5-coder:14b"
localspec specify "..."
```

### 输出控制
```bash
# 流式输出
localspec specify "..." --stream

# 保存到文件
localspec specify "..." --output custom-spec.md

# 详细日志
localspec specify "..." --verbose

# 调试模式
localspec specify "..." --debug
```

### 交互模式
```bash
# 交互式澄清
localspec clarify --interactive

# 交互式实现（每个任务前确认）
localspec implement --interactive

# 非交互（自动决策）
localspec implement --auto
```

---

## 🔧 配置文件

### 位置
```
.localspec/config.yaml
.specify/localspec.json
```

### 常用配置
```yaml
# 模型配置
model:
  name: "qwen2.5-coder:14b"
  temperature: 0.3

# 工作流
workflow:
  auto_clarify: true
  tdd_enabled: true

# 性能
performance:
  cache_enabled: true
  parallel_tasks: 2
```

---

## 🎨 模板自定义

### 自定义提示词
```bash
# 创建自定义提示词
mkdir -p .localspec/prompts
cat > .localspec/prompts/custom-specify.txt << 'EOF'
你是需求分析专家，请生成详细规范：
{user_input}

要求：
1. 中文输出
2. 包含用户故事
3. 明确验收标准
EOF

# 使用自定义模板
localspec specify --prompt-template custom-specify "..."
```

### 修改配置
```bash
# 编辑配置
vim .localspec/config.yaml

# 验证配置
localspec config validate

# 显示当前配置
localspec config show
```

---

## 📈 性能优化

### 推荐模型配置

| 内存 | 推荐模型 | 性能 |
|------|---------|------|
| 8GB  | qwen2.5-coder:7b-q4 | ⭐⭐⭐ |
| 16GB | qwen2.5-coder:14b-q5 | ⭐⭐⭐⭐ |
| 32GB | qwen2.5-coder:32b-q5 | ⭐⭐⭐⭐⭐ |
| 64GB | qwen2.5-coder:72b-q8 | ⭐⭐⭐⭐⭐ |

### 加速技巧
```bash
# 1. 使用缓存
localspec specify "..." --cache

# 2. 减少上下文
localspec implement --context-mode minimal

# 3. 预加载模型
ollama run qwen2.5-coder:14b --keep-alive 60m

# 4. 并行任务
localspec implement --parallel 4
```

---

## 🐛 故障排查

### 检查服务
```bash
# Ollama 服务
curl http://localhost:11434/api/tags

# 已安装模型
ollama list

# 系统诊断
localspec doctor
```

### 常见问题

#### Ollama 无法启动
```bash
# Linux
sudo systemctl status ollama
sudo systemctl restart ollama

# macOS
ps aux | grep ollama
open -a Ollama
```

#### 模型加载慢
```bash
# 预加载到内存
ollama run qwen2.5-coder:14b "hello"

# 检查内存
free -h  # Linux
vm_stat  # macOS
```

#### 生成质量差
```bash
# 使用更大模型
localspec --model qwen2.5-coder:32b specify "..."

# 调整温度
localspec config set model.temperature 0.2

# 提供更详细描述
localspec specify "详细需求..." --clarify
```

---

## 💡 最佳实践

### 规范编写
```bash
# ✅ 好的需求描述
localspec specify "
实现用户登录功能：
- 支持邮箱+密码登录
- 密码使用bcrypt加密
- 登录失败5次锁定10分钟
- JWT token有效期7天
- 支持记住我功能
安全要求：
- 防止暴力破解
- SQL注入防护
- XSS防护
"

# ❌ 差的需求描述
localspec specify "做一个登录功能"
```

### 技术方案
```bash
# ✅ 详细的技术栈
localspec plan "
后端：Python 3.11 + FastAPI
数据库：PostgreSQL 15
缓存：Redis 7
认证：JWT (python-jose)
部署：Docker + Nginx
"

# ❌ 模糊的技术栈
localspec plan "用Python做后端"
```

### 迭代开发
```bash
# ✅ 小步迭代
localspec specify "用户注册功能"
localspec implement
# 测试通过后
localspec specify "邮箱验证功能"
localspec implement

# ❌ 一次性大需求
localspec specify "完整的用户系统（注册/登录/权限/个人中心/...）"
```

---

## 🔗 相关资源

### 官方文档
- LocalSpec: https://localspec.dev
- Spec Kit: https://github.com/github/spec-kit
- Ollama: https://ollama.com

### 社区
- GitHub Issues: https://github.com/yourname/localspec/issues
- Discussions: https://github.com/yourname/localspec/discussions

### 模型
- Qwen: https://qwenlm.github.io/
- DeepSeek: https://github.com/deepseek-ai/DeepSeek-Coder

---

## 📞 获取帮助

```bash
# 命令帮助
localspec --help
localspec specify --help

# 生成诊断报告
localspec doctor --report

# 查看日志
tail -f ~/.localspec/logs/localspec.log

# 社区支持
https://github.com/yourname/localspec/issues
```

---

## 📝 快捷键（VS Code 扩展）

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Shift+S` | 创建规范 |
| `Ctrl+Shift+P` | 生成计划 |
| `Ctrl+Shift+T` | 分解任务 |
| `Ctrl+Shift+I` | 智能建议 |
| `Ctrl+Shift+C` | AI 聊天 |

---

## 🎯 示例项目

```bash
# 克隆示例项目
git clone https://github.com/yourname/localspec-examples
cd localspec-examples/xiangmanyuan

# 查看规范
cat .specify/specs/001-core-features/spec.md

# 查看实现
tree src/
```

---

**版本**: LocalSpec v1.0.0
**更新**: 2025-01-15
**授权**: MIT License

# AidLux Hermes Agent 安装指南

**语言**: [中文](README_CN.md) | [English](README.md)

**日期**: 2026-04-12
**环境**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)
**版本**: v1.0

---

## 📋 项目概述

本项目提供了在 AidLux 环境下一键安装 Hermes Agent 的解决方案，针对 AidLux/OpenClaw Termux 环境的特殊性进行了优化，解决了虚拟环境创建失败、Python 版本兼容性、环境变量配置等问题。

### 主要特性

- ✅ **一键安装**: 使用 `aidinstall.sh` 脚本自动完成全部安装流程
- ✅ **环境适配**: 针对 AidLux 环境的特殊优化
- ✅ **依赖管理**: 自动处理 Python 和 Node.js 依赖
- ✅ **问题修复**: 内置解决方案，避免常见安装错误
- ✅ **完整配置**: 自动设置环境变量和命令路径

---

## 🚀 快速开始

### 1. 环境要求

- **AidLux** 已安装并运行
- **Termux** 环境（Ubuntu 20.04）
- **网络连接**（下载依赖包）
- **磁盘空间**: 至少 2GB 可用

**可选但推荐**:
- `git`（脚本会自动安装）
- `curl`（用于下载官方脚本）

### 2. 安装步骤

#### 方法 1: 使用 curl（一键安装）

```bash
# 1. 下载并执行脚本
curl -fsSL https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/aidinstall.sh | bash

# 2. 应用环境变量
source ~/.bashrc

# 3. 验证安装
hermes --version

# 4. 初始化配置
hermes setup
```

#### 方法 2: 手动下载

```bash
# 1. 定位到脚本目录
cd /home/aidlux/.openclaw/workspace

# 2. 下载脚本
curl -fsSL -o aidinstall.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/aidinstall.sh

# 3. 赋予执行权限
chmod +x aidinstall.sh

# 4. 执行安装
./aidinstall.sh

# 5. 应用环境变量
source ~/.bashrc

# 6. 验证安装
hermes --version

# 7. 初始化配置
hermes setup
```

**安装时长**: 约 10-20 分钟（取决于网络速度和设备性能）

### 3. 预期输出

```
Hermes Agent v0.8.0 (2026.4.8)
Project: /home/aidlux/.hermes/hermes-agent
Python: 3.11.15
OpenAI SDK: 2.31.0
Up to date
```

---

## 📝 安装流程详解

### 步骤 1: 执行官方 install.sh

- 检测操作系统和依赖
- 安装 uv 包管理器（如未安装）
- 安装 Python 3.11（通过 uv）
- 安装 Git
- 下载 Node.js v22 到 `~/.hermes/node/`
- 克隆 Hermes Agent 仓库到 `~/.hermes/hermes-agent`
- 尝试创建虚拟环境（可能失败）
- 安装 Python 依赖（可能失败）
- 安装 Node.js 依赖
- 配置 hermes 命令软链接
- 复制配置文件模板

### 步骤 2: 修复 Python 依赖（Target 模式）

```bash
rm -rf ~/.hermes/.deps
UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps
```

- 强制使用 copy 模式避免硬链接权限问题
- 将 60+ 个依赖包安装到 `~/.hermes/.deps`

### 步骤 3: 安装 Node.js 依赖

```bash
cd ~/.hermes/hermes-agent
~/.hermes/node/bin/npm install
```

- 安装 366 个 npm 包（约 5-10 分钟）
- 此步骤可选，但如果跳过，浏览器工具将不可用

### 步骤 4: 配置 hermes 命令

```bash
mkdir -p ~/.local/bin
ln -sf ~/.hermes/hermes-agent/hermes ~/.local/bin/hermes
```

### 步骤 5: 修改 shebang

自动将：
```
#!/usr/bin/env python3
```
改为：
```
#!/usr/bin/env python3.11
```

确保使用 Python 3.11 而非系统 Python 3.8。

### 步骤 6: 配置环境变量

添加到 `~/.bashrc`：
```bash
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/.deps:$PYTHONPATH"
```

### 步骤 7: 应用环境变量

当前会话立即应用这些变量，使 `hermes` 立即可用。

---

## ⚠️ 常见问题

### Q1: 安装失败怎么办？

查看日志：
```bash
# 查看安装过程中的输出
# 或重试
cd /home/aidlux/.openclaw/workspace
./aidlinstall.sh
```

### Q2: `hermes: command not found`

确认：
```bash
ls ~/.local/bin/hermes
echo $PATH | grep ~/.local/bin
source ~/.bashrc
```

### Q3: Python 模块导入错误

确认 `PYTHONPATH` 已设置：
```bash
echo $PYTHONPATH
# 应显示: /home/aidlux/.hermes/.deps:...
```

手动设置（临时）：
```bash
export PYTHONPATH="$HOME/.hermes/.deps:$PYTHONPATH"
```

### Q4: Node.js 不可用

确认：
```bash
~/.hermes/node/bin/node --version
```

如果缺失，重新运行第 3 步：
```bash
cd ~/.hermes/hermes-agent
~/.hermes/node/bin/npm install
```

### Q5: 需要卸载重装

```bash
rm -rf ~/.hermes
rm -f ~/.local/bin/hermes
# 从 ~/.bashrc 中删除 Hermes 相关行
./aidlinstall.sh
```

---

## 📁 安装后目录结构

```
~/.hermes/
├── .deps/                    # Python 依赖（target 模式）
├── node/                     # Node.js 22 (官方二进制包)
│   ├── bin/
│   │   ├── node
│   │   ├── npm
│   │   └── npx
├── hermes-agent/             # 源代码（Git 仓库）
│   ├── hermes               # 主启动脚本
│   ├── requirements.txt
│   ├── package.json
│   └── ...
├── config.yaml               # Hermes 配置
├── .env                      # API keys 和敏感信息
├── logs/                     # 日志目录
├── cron/                     # 定时任务
├── sessions/                 # 会话记录
├── skills/                   # 已安装的技能
└── ...
```

---

## 🔄 升级 Hermes

### 方式 1: 使用 hermes 命令

```bash
hermes update
```

### 方式 2: 手动更新

```bash
cd ~/.hermes/hermes-agent
git pull origin main
# 重新安装依赖（如有更新）
cd ~/.hermes/hermes-agent
uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps --upgrade
~/.hermes/node/bin/npm update
```

---

## 🎯 下一步

1. **配置 LLM 提供商**：
   ```bash
   hermes setup
   ```

2. **开始对话**：
   ```bash
   hermes chat
   ```

3. **安装 Gateway 服务**（可选）：
   ```bash
   hermes gateway install
   ```

4. **探索技能**：
   ```bash
   hermes skills list
   hermes skill install <skill-name>
   ```

---

## 📚 技术细节

### 为什么需要 target 模式？

AidLux 的文件系统可能挂载了 `noexec` 或权限限制，导致虚拟环境的硬链接操作失败。使用 `UV_LINK_MODE=copy` 和 `--target` 模式避免了这些问题，依赖直接复制到 `~/.hermes/.deps`，并通过 `PYTHONPATH` 使其可用。

### 为什么修改 shebang？

Hermes 使用了 Python 3.10+ 的语法（如 `Path | None` 联合类型），系统 Python 3.8 无法解析。必须确保 entry point 使用 Python 3.11。

### 为什么跳过虚拟环境？

virtualenv 在受限环境（如某些 Android/Linux 容器）中可能因权限、noexec 挂载选项或内核限制而失败。target 模式更稳健，适合容器化/受限环境。

---

## 📄 Related Documents

| Document | Description | Location |
|----------|-------------|----------|
| `Installation-Guide.md` | Complete installation guide | `docs/` |
| `FAQ.md` | Frequently asked questions and solutions | `docs/` |
| `aidinstall.sh` | One-click installation script | `script/` |

---

## 🔗 Related Links

- [Hermes Agent Official Repository](https://github.com/NousResearch/hermes-agent)
- [OpenClaw-CN Community](https://openclaw.cn)
- [AidLux Documentation](https://docs.aidlux.com)

---

## 🤝 Contribution Guide

We welcome contributions! Please refer to the official contribution guide for development setup, code style, and PR process.

### Quick Start for Contributors (AidLux Environment)

```bash
# 1. Clone the repository
git clone https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

# 2. Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# 3. AidLux special handling: Install dependencies in target mode
export UV_LINK_MODE=copy
mkdir -p ~/.hermes/.deps
uv pip install --python 3.11 -e ".[all,dev]" --target ~/.hermes/.deps

# 4. Configure environment variables
export PYTHONPATH="$HOME/.hermes/.deps:$PYTHONPATH"

# 5. Run tests
python3.11 -m pytest tests/ -q
```

### Key Adjustment Notes

1. **Skip virtual environment creation**: Virtual environments may fail in AidLux due to permissions or filesystem restrictions, so target mode is used instead
2. **Use UV_LINK_MODE=copy**: Avoid hard link permission issues
3. **Specify python3.11**: Ensure the correct Python version is used, avoiding compatibility issues with system Python 3.8
4. **Configure PYTHONPATH**: Ensure Python can find dependencies installed in ~/.hermes/.deps

---

**Maintenance**: byteuser1977
**Last Updated**: 2026-04-12

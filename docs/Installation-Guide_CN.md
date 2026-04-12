# AidLux Hermes Agent 安装教程

**日期**: 2026-04-12
**环境**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)
**版本**: v1.0

---

## 📋 项目概述

本项目提供了在 AidLux 环境下安装 Hermes Agent 的解决方案，针对 AidLux/OpenClaw Termux 环境的特殊性进行了优化，解决了虚拟环境创建失败、Python 版本兼容性、环境变量配置等问题。

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

## 📚 环境信息

| 项目 | 值 |
|------|-----|
| 操作系统 | Ubuntu 20.04.6 LTS (Focal Fossa) |
| 内核 | Linux 5.4.0-aidlite (arm64) |
| Node.js | v22.22.2 (安装在 `~/.hermes/node/`) |
| 系统 Python | Python 3.8.10 (默认) |
| 最终 Python | Python 3.11.15 (uv 管理) |
| 包管理器 | uv 0.11.6, apt, npm |

---

## 🔗 相关链接

- [Hermes Agent 官方仓库](https://github.com/NousResearch/hermes-agent)
- [OpenClaw-CN 社区](https://openclaw.cn)
- [AidLux 文档](https://docs.aidlux.com)

---

**维护**: byteuser1977
**最后更新**: 2026-04-12

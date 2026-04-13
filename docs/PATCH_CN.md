# PATCH 脚本文档

**语言**: [中文](PATCH_CN.md) | [English](PATCH.md)

**日期**: 2026-04-13
**环境**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)

---

## 📋 概述

`patch.sh` 脚本是一个专门设计用于修复在 AidLux 环境中安装 Hermes Agent 时可能出现的常见问题的工具。它提供了一个全面的解决方案，用于解决环境特定的问题并确保安装成功。

### 主要功能

- ✅ **安装后修复**: 解决运行官方 install.sh 后可能出现的问题
- ✅ **AidLux 特定优化**: 专门针对 AidLux 环境约束进行定制
- ✅ **全面的依赖管理**: 确保所有 Python 和 Node.js 依赖正确安装
- ✅ **环境变量配置**: 自动设置必要的环境变量
- ✅ **Shebang 修正**: 修复 Python 解释器路径问题

---

## 🚀 使用方法

### 何时使用

在以下场景中建议使用 PATCH 脚本：

1. **安装失败**: 当初始安装失败或遇到错误时
2. **Python 导入错误**: 当 Hermes Agent 无法导入 Python 模块时
3. **命令未找到**: 当 `hermes` 命令不被识别时
4. **依赖问题**: 当缺少 Node.js 或 Python 依赖时
5. **环境变量问题**: 当环境变量未正确设置时

### 快速开始

```bash
# 下载并执行 PATCH 脚本
curl -fsSL https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh | bash

# 应用环境变量
source ~/.bashrc

# 验证安装
hermes --version
```

### 手动执行

```bash
# 导航到脚本目录
cd /home/aidlux/.openclaw/workspace

# 下载 PATCH 脚本
curl -LsSf -o patch.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh

# 赋予执行权限
chmod +x patch.sh

# 运行脚本
./patch.sh

# 应用环境变量
source ~/.bashrc

# 验证安装
hermes --version
```

---

## 🔧 工作原理

PATCH 脚本按照系统步骤解决安装问题：

### 步骤 1: 执行官方安装程序

脚本首先运行官方的 `install.sh` 脚本建立基础安装：

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### 步骤 2: 修复 Python 依赖

在 AidLux 中，由于文件系统限制，虚拟环境创建经常失败。PATCH 脚本使用目标模式安装来解决这个问题：

```bash
# 清理旧依赖
rm -rf "$HOME/.hermes/.deps"

# 使用复制模式在目标模式下安装依赖
cd "$HOME/.hermes/hermes-agent"
UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target "$HOME/.hermes/.deps"
```

### 步骤 3: 安装 Node.js 依赖

浏览器工具需要 Node.js 依赖，接下来会安装：

```bash
cd "$HOME/.hermes/hermes-agent"
"$HOME/.hermes/node/bin/npm" install
```

### 步骤 4: 配置 Hermes 命令

脚本为 `hermes` 命令创建符号链接并确保它具有正确的权限：

```bash
mkdir -p "$HOME/.local/bin"
rm -f "$HOME/.local/bin/hermes"
ln -s "$HOME/.hermes/hermes-agent/hermes" "$HOME/.local/bin/hermes"
```

### 步骤 5: 修复 Shebang

为确保 Hermes 使用 Python 3.11 而不是系统的 Python 3.8，脚本修改了 shebang：

```bash
# 从:
# #!/usr/bin/env python3
# 改为:
# #!/usr/bin/env python3.11

sed -i '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.11|' "$HERMES_SOURCE"
```

### 步骤 6: 设置环境变量

脚本更新 `~/.bashrc` 以包含必要的环境变量：

```bash
# 添加到 ~/.bashrc:
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"
```

### 步骤 7: 应用环境变量

最后，脚本为当前会话导出环境变量：

```bash
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"
```

---

## 📁 PATCH 后的目录结构

运行 PATCH 脚本后，目录结构应如下所示：

```
~/.hermes/
├── .deps/                    # Python 依赖（目标模式）
├── node/                     # Node.js 22（官方二进制包）
│   ├── bin/
│   │   ├── node
│   │   ├── npm
│   │   └── npx
├── hermes-agent/             # 源代码（Git 仓库）
│   ├── hermes               # 主启动脚本（已修复 shebang）
│   ├── requirements.txt
│   ├── package.json
│   └── ...
├── config.yaml               # Hermes 配置
├── .env                      # 环境变量（API 密钥等）
└── ...
```

---

## ⚠️ 故障排除

### 常见问题和解决方案

#### 问题：PATCH 脚本下载失败

**解决方案**:
```bash
# 检查网络连接
ping github.com

# 尝试替代下载方法
wget -O patch.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh
chmod +x patch.sh
./patch.sh
```

#### 问题：未找到 Python 3.11

**解决方案**:
```bash
# 检查可用的 Python 版本
ls /usr/bin/python*

# 如果缺少，安装 Python 3.11
pkg install python3.11
```

#### 问题：Node.js 安装失败

**解决方案**:
```bash
# 验证 Node.js 安装
~/.hermes/node/bin/node --version

# 重新安装 Node.js
rm -rf ~/.hermes/node
# 再次运行 PATCH 脚本
```

---

## 🎯 最佳实践

1. **以非 root 用户运行**: PATCH 脚本应作为普通用户运行，而不是 root
2. **确保网络连接**: 下载依赖需要稳定的互联网连接
3. **备份现有安装**: 如果你有之前的安装，在运行 PATCH 脚本之前考虑备份
4. **遵循顺序**: 只在尝试官方安装后运行 PATCH 脚本
5. **验证安装**: 运行 PATCH 脚本后始终运行 `hermes --version` 以确认成功

---

## 🔗 相关资源

- [Hermes Agent 官方仓库](https://github.com/NousResearch/hermes-agent)
- [AidLux 文档](https://docs.aidlux.com)
- [OpenClaw-CN 社区](https://openclaw.cn)

---

## 📄 脚本源代码

PATCH 脚本可以在以下位置查看：

[https://github.com/byteuser1977/aidlux-install-hermes/blob/main/script/patch.sh](https://github.com/byteuser1977/aidlux-install-hermes/blob/main/script/patch.sh)

---

**最后更新**: 2026-04-13
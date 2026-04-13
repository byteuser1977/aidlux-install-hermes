#!/bin/bash

# AidLux Hermes Agent 安装脚本
# 专为 AidLux/OpenClaw Termux 环境优化
# 适用于 Ubuntu 20.04 (arm64) + NVM Node.js

set -e  # 遇到错误立即退出
set -u  # 未定义变量报错

echo "=========================================="
echo "Hermes Agent 安装脚本 (AidLux Patch版)"
echo "=========================================="
echo ""

# 1. 执行官方安装脚本
echo "[1/6] 手工执行官方 install.sh..."
ccho "curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"

# 等待安装完成
sleep 2

# 2. 修复 Python 依赖安装（虚拟环境失败时使用 target 模式）
echo "[2/6] 安装 Python 依赖 (target 模式，UV_LINK_MODE=copy)..."

# 清理旧的依赖目录
rm -rf "$HOME/.hermes/.deps"

# 进入源码目录并安装依赖到 target
cd "$HOME/.hermes/hermes-agent"
UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target "$HOME/.hermes/.deps"

echo "✅ Python 依赖安装完成"

# 3. 安装 Node.js 依赖
echo "[3/6] 安装 Node.js 依赖 (可能需要几分钟)..."
cd "$HOME/.hermes/hermes-agent"
"$HOME/.hermes/node/bin/npm" install
echo "✅ Node.js 依赖安装完成"

# 4. 创建 hermes 软链接到 ~/.local/bin
echo "[4/6] 配置 hermes 命令..."
mkdir -p "$HOME/.local/bin"

# 先删除旧链接（处理可能的循环链接）
rm -f "$HOME/.local/bin/hermes"

# 创建新链接
ln -s "$HOME/.hermes/hermes-agent/hermes" "$HOME/.local/bin/hermes"

# 5. 修改 shebang 以使用 Python 3.11（同时修改源码和软链接）
echo "    修改 shebang 为 python3.11..."

HERMES_SOURCE="$HOME/.hermes/hermes-agent/hermes"
HERMES_LINK="$HOME/.local/bin/hermes"

# 修改源码文件
if [ -f "$HERMES_SOURCE" ]; then
    sed -i '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.11|' "$HERMES_SOURCE"
    echo "    ✓ 已修改源码 shebang"
else
    echo "    ⚠️  未找到源码 hermes 文件: $HERMES_SOURCE"
fi

# 修改软链接（如果不同）
if [ -f "$HERMES_LINK" ] && [ "$(readlink -f "$HERMES_LINK")" != "$(readlink -f "$HERMES_SOURCE")" ]; then
    sed -i '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.11|' "$HERMES_LINK"
    echo "    ✓ 已修改软链接 shebang"
fi

# 6. 设置环境变量到 ~/.bashrc
echo "[5/6] 配置环境变量..."

BASHRC="$HOME/.bashrc"

# 检查是否已存在配置
if ! grep -q "# Hermes Agent configuration" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'EOF'

# Hermes Agent configuration
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"
EOF
    echo "✅ 环境变量已添加到 ~/.bashrc"
else
    echo "⚠️  环境变量已存在，跳过"
fi

# 7. 输出当前的配置以应用
echo "[6/6] 应用环境变量..."
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"

# 确保 ~/.local/bin/env 文件有执行权限
if [ -f "$HOME/.local/bin/env" ]; then
    chmod +x "$HOME/.local/bin/env"
    echo "    ✓ 已为 ~/.local/bin/env 添加执行权限"
fi

echo ""
echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "验证安装："
echo "  hermes --version"
echo ""
echo "首次使用："
echo "  hermes setup    # 配置 LLM 和 API keys"
echo "  hermes chat     # 进入交互式对话"
echo ""
echo "如果遇到问题，请确保："
echo "  1. 已执行: source ~/.bashrc"
echo "  2. Python 3.11 可用: python3.11 --version"
echo "  3. Node.js 可用: node --version"
echo ""
# AidLux Hermes Agent 常见问题与解决方案

**日期**: 2026-04-12
**环境**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)

---

## ❓ 常见问题

### Q1: 安装失败怎么办？

**解决方案**:
- 查看安装过程中的输出日志
- 重试安装：
  ```bash
  cd /home/aidlux/
  ./aidlinstall.sh
  ```

### Q2: `hermes: command not found`

**解决方案**:
- 确认 hermes 命令是否存在：
  ```bash
  ls ~/.local/bin/hermes
  ```
- 确认 `~/.local/bin` 是否在 PATH 中：
  ```bash
  echo $PATH | grep ~/.local/bin
  ```
- 重新加载环境变量：
  ```bash
  source ~/.bashrc
  ```

### Q3: Python 模块导入错误（如 `ModuleNotFoundError: No module named 'yaml'`）

**解决方案**:
- 确认 `PYTHONPATH` 已设置：
  ```bash
  echo $PYTHONPATH
  # 应显示: /home/aidlux/.hermes/.deps:...
  ```
- 手动设置（临时）：
  ```bash
  export PYTHONPATH="$HOME/.hermes/.deps:$PYTHONPATH"
  ```
- 检查 `~/.bashrc` 中是否已添加 PYTHONPATH 配置

### Q4: Node.js 不可用

**解决方案**:
- 确认 Node.js 是否安装：
  ```bash
  ~/.hermes/node/bin/node --version
  ```
- 如果缺失，重新安装 Node.js 依赖：
  ```bash
  cd ~/.hermes/hermes-agent
  ~/.hermes/node/bin/npm install
  ```

### Q5: 需要卸载重装

**解决方案**:
```bash
rm -rf ~/.hermes
rm -f ~/.local/bin/hermes
# 从 ~/.bashrc 中删除 Hermes 相关行
./aidlinstall.sh
```

### Q6: 虚拟环境创建失败

**症状**:
```
error: Failed to create virtual environment
  Caused by: Operation not permitted (os error 1)
```

**原因分析**:
- 文件系统/noexec 挂载选项限制
- uv 使用硬链接，但目标位置权限受限

**解决方案**:
- 脚本会自动使用 `UV_LINK_MODE=copy` 和 target 模式安装依赖到 `~/.hermes/.deps`
- 手动安装命令：
  ```bash
  cd ~/.hermes/hermes-agent
  rm -rf ~/.hermes/.deps
  UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps
  ```

### Q7: 系统 Python 版本不兼容

**症状**:
```
TypeError: unsupported operand type(s) for |: 'type' and 'NoneType'
```

**原因**:
- `hermes` 脚本默认使用 `#!/usr/bin/env python3` → 系统 Python 3.8
- Hermes 代码使用了 Python 3.10+ 的联合类型语法 `Path | None`

**解决方案**:
- 脚本会自动修改 shebang 为 `#!/usr/bin/env python3.11`
- 手动修改命令：
  ```bash
  sed -i '1s|^#!.*python3.*$|#!/usr/bin/env python3.11|' ~/.local/bin/hermes
  ```

### Q8: PYTHONPATH 未自动设置

**症状**:
```
ModuleNotFoundError: No module named 'yaml'
```

**原因**:
- PyYAML 已安装到 `~/.hermes/.deps`
- 但 Python 进程的默认搜索路径不包含该目录

**解决方案**:
- 脚本会自动在 `~/.bashrc` 中添加：
  ```bash
  export HERMES_HOME="$HOME/.hermes"
  export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
  export PYTHONPATH="$HERMES_HOME/.deps:$PYTHONPATH"
  ```
- 手动添加后执行：
  ```bash
  source ~/.bashrc
  ```

### Q9: Node.js 依赖安装耗时

**现象**:
- `npm install` 在后台运行时间较长（5-10分钟）
- 安装 366 个包到 `node_modules/`

**处理**:
- 无需干预，等待完成即可
- Hermes 使用 Node.js 22（安装在 `~/.hermes/node/`），自带 npm

---

## 🛠️ 技术细节

### 为什么需要 target 模式？

AidLux 的文件系统可能挂载了 `noexec` 或权限限制，导致虚拟环境的硬链接操作失败。使用 `UV_LINK_MODE=copy` 和 `--target` 模式避免了这些问题，依赖直接复制到 `~/.hermes/.deps`，并通过 `PYTHONPATH` 使其可用。

### 为什么修改 shebang？

Hermes 使用了 Python 3.10+ 的语法（如 `Path | None` 联合类型），系统 Python 3.8 无法解析。必须确保 entry point 使用 Python 3.11。

### 为什么跳过虚拟环境？

virtualenv 在受限环境（如某些 Android/Linux 容器）中可能因权限、noexec 挂载选项或内核限制而失败。target 模式更稳健，适合容器化/受限环境。

---

## 📝 验证安装

```bash
# 1. 检查 hermes 命令可用
which hermes
# → /home/aidlux/.local/bin/hermes

# 2. 查看版本
hermes --version
# Output:
# Hermes Agent v0.8.0 (2026.4.8)
# Project: /home/aidlux/.hermes/hermes-agent
# Python: 3.11.15
# OpenAI SDK: 2.31.0
# Up to date

# 3. 列出子命令
hermes --help
```

---

**维护**: byteuser1977
**最后更新**: 2026-04-12

# AidLux Hermes Agent Frequently Asked Questions

**Date**: 2026-04-12
**Environment**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)

---

## ❓ Common Issues

### Q1: What to do if installation fails?

**Solution**:
- Check the output logs during installation
- Retry installation:
  ```bash
  cd /home/aidlux/.openclaw/workspace
  ./aidlinstall.sh
  ```

### Q2: `hermes: command not found`

**Solution**:
- Confirm if the hermes command exists:
  ```bash
  ls ~/.local/bin/hermes
  ```
- Check if `~/.local/bin` is in PATH:
  ```bash
  echo $PATH | grep ~/.local/bin
  ```
- Reload environment variables:
  ```bash
  source ~/.bashrc
  ```

### Q3: Python module import error (e.g., `ModuleNotFoundError: No module named 'yaml'`)

**Solution**:
- Confirm `PYTHONPATH` is set:
  ```bash
  echo $PYTHONPATH
  # Should show: /home/aidlux/.hermes/.deps:...
  ```
- Set manually (temporary):
  ```bash
  export PYTHONPATH="$HOME/.hermes/.deps:$PYTHONPATH"
  ```
- Check if PYTHONPATH configuration is added to `~/.bashrc`

### Q4: Node.js not available

**Solution**:
- Confirm Node.js is installed:
  ```bash
  ~/.hermes/node/bin/node --version
  ```
- If missing, reinstall Node.js dependencies:
  ```bash
  cd ~/.hermes/hermes-agent
  ~/.hermes/node/bin/npm install
  ```

### Q5: Need to uninstall and reinstall

**Solution**:
```bash
rm -rf ~/.hermes
rm -f ~/.local/bin/hermes
# Remove Hermes-related lines from ~/.bashrc
./aidlinstall.sh
```

### Q6: Virtual environment creation failure

**Symptoms**:
```
error: Failed to create virtual environment
  Caused by: Operation not permitted (os error 1)
```

**Root cause**:
- Filesystem/noexec mount option restriction
- uv uses hard links, but target location has permission restrictions

**Solution**:
- The script will automatically use `UV_LINK_MODE=copy` and target mode to install dependencies to `~/.hermes/.deps`
- Manual installation command:
  ```bash
  cd ~/.hermes/hermes-agent
  rm -rf ~/.hermes/.deps
  UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps
  ```

### Q7: System Python version incompatibility

**Symptoms**:
```
TypeError: unsupported operand type(s) for |: 'type' and 'NoneType'
```

**Root cause**:
- `hermes` script defaults to `#!/usr/bin/env python3` → system Python 3.8
- Hermes code uses Python 3.10+ union type syntax `Path | None`

**Solution**:
- The script will automatically modify shebang to `#!/usr/bin/env python3.11`
- Manual modification command:
  ```bash
  sed -i '1s|^#!.*python3.*$|#!/usr/bin/env python3.11|' ~/.local/bin/hermes
  ```

### Q8: PYTHONPATH not automatically set

**Symptoms**:
```
ModuleNotFoundError: No module named 'yaml'
```

**Root cause**:
- PyYAML is installed to `~/.hermes/.deps`
- But Python process default search path doesn't include this directory

**Solution**:
- The script will automatically add to `~/.bashrc`:
  ```bash
  export HERMES_HOME="$HOME/.hermes"
  export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
  export PYTHONPATH="$HERMES_HOME/.deps:$PYTHONPATH"
  ```
- After manual addition, execute:
  ```bash
  source ~/.bashrc
  ```

### Q9: Node.js dependency installation takes time

**Phenomenon**:
- `npm install` runs in the background for a long time (5-10 minutes)
- Installs 366 packages to `node_modules/`

**Handling**:
- No intervention needed, just wait for completion
- Hermes uses Node.js 22 (installed in `~/.hermes/node/`), which comes with npm

---

## 🛠️ Technical Details

### Why use target mode?

AidLux's filesystem may be mounted with `noexec` or permission restrictions, causing virtual environment hard link operations to fail. Using `UV_LINK_MODE=copy` and `--target` mode avoids these issues, with dependencies directly copied to `~/.hermes/.deps` and made available via `PYTHONPATH`.

### Why modify shebang?

Hermes uses Python 3.10+ syntax (such as `Path | None` union types), which cannot be parsed by system Python 3.8. It's essential to ensure the entry point uses Python 3.11.

### Why skip virtual environment?

virtualenv may fail in restricted environments (like some Android/Linux containers) due to permissions, noexec mount options, or kernel restrictions. Target mode is more robust and suitable for containerized/restricted environments.

---

## 📝 Verify Installation

```bash
# 1. Check if hermes command is available
which hermes
# → /home/aidlux/.local/bin/hermes

# 2. Check version
hermes --version
# Output:
# Hermes Agent v0.8.0 (2026.4.8)
# Project: /home/aidlux/.hermes/hermes-agent
# Python: 3.11.15
# OpenAI SDK: 2.31.0
# Up to date

# 3. List subcommands
hermes --help
```

---

**Maintenance**: byteuser1977
**Last Updated**: 2026-04-12

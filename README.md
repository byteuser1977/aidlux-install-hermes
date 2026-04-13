# AidLux Hermes Agent Installation Guide

**Language**: [English](README.md) | [中文](README_CN.md)

**Date**: 2026-04-12
**Environment**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)
**Version**: v1.0

---

## 📋 Project Overview

This project provides a solution for one-click installation of Hermes Agent in the AidLux environment, optimized for the specific characteristics of AidLux/OpenClaw Termux environment, addressing issues such as virtual environment creation failure, Python version compatibility, and environment variable configuration.

### Key Features

- ✅ **One-click installation**: Use `aidinstall.sh` script to automatically complete the entire installation process
- ✅ **Environment adaptation**: Special optimization for AidLux environment
- ✅ **Dependency management**: Automatically handle Python and Node.js dependencies
- ✅ **Issue fixes**: Built-in solutions to avoid common installation errors
- ✅ **Complete configuration**: Automatically set environment variables and command paths

---

## 🚀 Quick Start

### 1. Prerequisites

- **AidLux** installed and running
- **Termux** environment (Ubuntu 20.04)
- **Network connection** (for downloading dependencies)
- **Disk space**: At least 2GB available

**Optional but recommended**:
- `git` (will be automatically installed by the script)
- `curl` (for downloading the official script)

### 2. Installation Steps

#### Method 1: Using curl (One-click installation)

```bash
# 1. Download and execute the script
curl -fsSL https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/aidinstall.sh | bash

# 2. Apply environment variables
source ~/.bashrc

# 3. Verify installation
hermes --version

# 4. Initialize configuration
hermes setup
```

#### Method 2: Manual download

```bash
# 1. Navigate to the script directory
cd /home/aidlux/.openclaw/workspace

# 2. Download the script
curl -LsSf -o aidinstall.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/aidinstall.sh

# 3. Give execution permission
chmod +x aidinstall.sh

# 4. Execute installation
./aidinstall.sh

# 5. Apply environment variables
source ~/.bashrc

# 6. Verify installation
hermes --version

# 7. Initialize configuration
hermes setup
```

**Installation duration**: Approximately 10-20 minutes (depending on network speed and device performance)

### 3. Expected Output

```
Hermes Agent v0.8.0 (2026.4.8)
Project: /home/aidlux/.hermes/hermes-agent
Python: 3.11.15
OpenAI SDK: 2.31.0
Up to date
```

---

## 📝 Installation Process Details

### Step 1: Execute official install.sh

- Detect operating system and dependencies
- Install uv package manager (if not installed)
- Install Python 3.11 (via uv)
- Install Git
- Download Node.js v22 to `~/.hermes/node/`
- Clone Hermes Agent repository to `~/.hermes/hermes-agent`
- Attempt to create virtual environment (may fail)
- Install Python dependencies (may fail)
- Install Node.js dependencies
- Configure hermes command symlink
- Copy configuration file templates

### Step 2: Fix Python dependencies (Target mode)

```bash
rm -rf ~/.hermes/.deps
UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps
```

- Force copy mode to avoid hard link permission issues
- Install 60+ dependency packages to `~/.hermes/.deps`

### Step 3: Install Node.js dependencies

```bash
cd ~/.hermes/hermes-agent
~/.hermes/node/bin/npm install
```

- Install 366 npm packages (approximately 5-10 minutes)
- This step is optional, but if skipped, browser tools will not be available

### Step 4: Configure hermes command

```bash
mkdir -p ~/.local/bin
ln -sf ~/.hermes/hermes-agent/hermes ~/.local/bin/hermes
```

### Step 5: Modify shebang

Automatically change:
```
#!/usr/bin/env python3
```
to:
```
#!/usr/bin/env python3.11
```

Ensure Python 3.11 is used instead of system Python 3.8.

### Step 6: Configure environment variables

Add to `~/.bashrc`:
```bash
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/.deps:$PYTHONPATH"
```

### Step 7: Apply environment variables

Apply these variables in the current session to make `hermes` immediately available.

---

## ⚠️ Common Issues

### Q1: What to do if installation fails?

Check logs:
```bash
# Check installation output
# Or retry
cd /home/aidlux/.openclaw/workspace
./aidlinstall.sh
```

### Q2: `hermes: command not found`

Verify:
```bash
ls ~/.local/bin/hermes
echo $PATH | grep ~/.local/bin
source ~/.bashrc
```

### Q3: Python module import error

Verify `PYTHONPATH` is set:
```bash
echo $PYTHONPATH
# Should show: /home/aidlux/.hermes/.deps:...
```

Set manually (temporary):
```bash
export PYTHONPATH="$HOME/.hermes/.deps:$PYTHONPATH"
```

### Q4: Node.js not available

Verify:
```bash
~/.hermes/node/bin/node --version
```

If missing, re-run step 3:
```bash
cd ~/.hermes/hermes-agent
~/.hermes/node/bin/npm install
```

### Q5: Need to uninstall and reinstall

```bash
rm -rf ~/.hermes
rm -f ~/.local/bin/hermes
# Remove Hermes-related lines from ~/.bashrc
./aidlinstall.sh
```

## 🛠️ PATCH Script Usage

### What is the PATCH script?

The `patch.sh` script is designed to fix issues that may occur after the official installation. It addresses common problems in the AidLux environment, such as:

- Virtual environment creation failures
- Python dependency installation issues
- Shebang configuration problems
- Environment variable setup

### When to use the PATCH script?

Use the PATCH script if:

1. The initial installation failed
2. You're experiencing Python import errors
3. The `hermes` command is not found
4. You want to ensure all dependencies are correctly installed

### How to use the PATCH script

```bash
# 1. Download the PATCH script
curl -fsSL https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh | bash

# 2. Apply environment variables
source ~/.bashrc

# 3. Verify installation
hermes --version
```

### PATCH script process

1. **Execute official install.sh**: Runs the official installation script
2. **Fix Python dependencies**: Uses target mode with `UV_LINK_MODE=copy`
3. **Install Node.js dependencies**: Installs browser tools dependencies
4. **Configure hermes command**: Creates symlink and fixes shebang
5. **Set environment variables**: Updates `~/.bashrc` with necessary variables
6. **Apply environment variables**: Makes changes available in current session

---

## 📁 Post-installation Directory Structure

```
~/.hermes/
├── .deps/                    # Python dependencies (target mode)
├── node/                     # Node.js 22 (official binary package)
│   ├── bin/
│   │   ├── node
│   │   ├── npm
│   │   └── npx
├── hermes-agent/             # Source code (Git repository)
│   ├── hermes               # Main startup script
│   ├── requirements.txt
│   ├── package.json
│   └── ...
├── config.yaml               # Hermes configuration
├── .env                      # Environment variables (API keys, etc.)
├── logs/                     # Log directory
├── cron/                     # Scheduled tasks
├── sessions/                 # Session records
├── skills/                   # Installed skills
└── ...
```

---

## 🔄 Upgrading Hermes

### Method 1: Using hermes command

```bash
hermes update
```

### Method 2: Manual update

```bash
cd ~/.hermes/hermes-agent
git pull origin main
# Reinstall dependencies (if updated)
cd ~/.hermes/hermes-agent
uv pip install --python 3.11 -r requirements.txt --target ~/.hermes/.deps --upgrade
~/.hermes/node/bin/npm update
```

---

## 🎯 Next Steps

1. **Configure LLM provider**:
   ```bash
   hermes setup
   ```

2. **Start conversation**:
   ```bash
   hermes chat
   ```

3. **Install Gateway service** (optional):
   ```bash
   hermes gateway install
   ```

4. **Explore skills**:
   ```bash
   hermes skills list
   hermes skill install <skill-name>
   ```

---

## 📚 Technical Details

### Why use target mode?

AidLux's filesystem may be mounted with `noexec` or permission restrictions, causing virtual environment hard link operations to fail. Using `UV_LINK_MODE=copy` and `--target` mode avoids these issues, with dependencies directly copied to `~/.hermes/.deps` and made available via `PYTHONPATH`.

### Why modify shebang?

Hermes uses Python 3.10+ syntax (such as `Path | None` union types), which cannot be parsed by system Python 3.8. It's essential to ensure the entry point uses Python 3.11.

### Why skip virtual environment?

virtualenv may fail in restricted environments (like some Android/Linux containers) due to permissions, noexec mount options, or kernel restrictions. Target mode is more robust and suitable for containerized/restricted environments.

---

## 📄 Related Documents

| Document | Description | Location |
|----------|-------------|----------|
| `Installation-Guide.md` | Complete installation guide | `docs/` |
| `FAQ.md` | Frequently asked questions and solutions | `docs/` |
| `aidinstall.sh` | One-click installation script | `script/` |
| `patch.sh` | Post-installation fix script | `script/` |
| `README_CN.md` | Chinese version of this document | `./` |
| `Installation-Guide_CN.md` | Chinese installation guide | `docs/` |
| `FAQ_CN.md` | Chinese FAQ | `docs/` |
| `PATCH.md` | PATCH script documentation | `docs/` |
| `PATCH_CN.md` | Chinese PATCH script documentation | `docs/` |

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

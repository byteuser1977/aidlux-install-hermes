# AidLux Hermes Agent Installation Guide

**Date**: 2026-04-12
**Environment**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)
**Version**: v1.0

---

## 📋 Project Overview

This project provides a solution for installing Hermes Agent in the AidLux environment, optimized for the specific characteristics of AidLux/OpenClaw Termux environment, addressing issues such as virtual environment creation failure, Python version compatibility, and environment variable configuration.

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
curl -fsSL -o aidinstall.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/aidinstall.sh

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

## 📚 Environment Information

| Item | Value |
|------|-------|
| Operating System | Ubuntu 20.04.6 LTS (Focal Fossa) |
| Kernel | Linux 5.4.0-aidlite (arm64) |
| Node.js | v22.22.2 (installed in `~/.hermes/node/`) |
| System Python | Python 3.8.10 (default) |
| Final Python | Python 3.11.15 (managed by uv) |
| Package Managers | uv 0.11.6, apt, npm |

---

## 🔗 Related Links

- [Hermes Agent Official Repository](https://github.com/NousResearch/hermes-agent)
- [OpenClaw-CN Community](https://openclaw.cn)
- [AidLux Documentation](https://docs.aidlux.com)

---

**Maintenance**: byteuser1977
**Last Updated**: 2026-04-12

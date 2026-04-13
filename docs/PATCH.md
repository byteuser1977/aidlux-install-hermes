# PATCH Script Documentation

**Language**: [English](PATCH.md) | [中文](PATCH_CN.md)

**Date**: 2026-04-13
**Environment**: AidLux / OpenClaw Termux (Ubuntu 20.04, arm64)

---

## 📋 Overview

The `patch.sh` script is a specialized utility designed to fix common issues that may occur during or after the installation of Hermes Agent in the AidLux environment. It provides a comprehensive solution to address environment-specific problems and ensure a successful installation.

### Key Features

- ✅ **Post-installation fixes**: Resolves issues that may occur after running the official install.sh
- ✅ **AidLux-specific optimizations**: Tailored to address AidLux environment constraints
- ✅ **Comprehensive dependency management**: Ensures all Python and Node.js dependencies are correctly installed
- ✅ **Environment variable configuration**: Automatically sets up necessary environment variables
- ✅ **Shebang correction**: Fixes Python interpreter path issues

---

## 🚀 Usage

### When to Use

The PATCH script is recommended in the following scenarios:

1. **Installation failure**: When the initial installation fails or encounters errors
2. **Python import errors**: When Hermes Agent fails to import Python modules
3. **Command not found**: When the `hermes` command is not recognized
4. **Dependency issues**: When Node.js or Python dependencies are missing
5. **Environment variable problems**: When environment variables are not properly set

### Quick Start

```bash
# Download and execute the PATCH script
curl -fsSL https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh | bash

# Apply environment variables
source ~/.bashrc

# Verify installation
hermes --version
```

### Manual Execution

```bash
# Navigate to the script directory
cd /home/aidlux/.openclaw/workspace

# Download the PATCH script
curl -LsSf -o patch.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh

# Make it executable
chmod +x patch.sh

# Run the script
./patch.sh

# Apply environment variables
source ~/.bashrc

# Verify installation
hermes --version
```

---

## 🔧 How It Works

The PATCH script follows a systematic approach to fix installation issues:

### Step 1: Execute Official Installer

The script first runs the official `install.sh` script to establish the base installation:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### Step 2: Fix Python Dependencies

In AidLux, virtual environment creation often fails due to filesystem restrictions. The PATCH script uses target mode installation to work around this issue:

```bash
# Clean up old dependencies
rm -rf "$HOME/.hermes/.deps"

# Install dependencies in target mode with copy mode
cd "$HOME/.hermes/hermes-agent"
UV_LINK_MODE=copy uv pip install --python 3.11 -r requirements.txt --target "$HOME/.hermes/.deps"
```

### Step 3: Install Node.js Dependencies

Browser tools require Node.js dependencies, which are installed next:

```bash
cd "$HOME/.hermes/hermes-agent"
"$HOME/.hermes/node/bin/npm" install
```

### Step 4: Configure Hermes Command

The script creates a symlink for the `hermes` command and ensures it has the correct permissions:

```bash
mkdir -p "$HOME/.local/bin"
rm -f "$HOME/.local/bin/hermes"
ln -s "$HOME/.hermes/hermes-agent/hermes" "$HOME/.local/bin/hermes"
```

### Step 5: Fix Shebang

To ensure Hermes uses Python 3.11 instead of the system's Python 3.8, the script modifies the shebang:

```bash
# Change from:
# #!/usr/bin/env python3
# To:
# #!/usr/bin/env python3.11

sed -i '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.11|' "$HERMES_SOURCE"
```

### Step 6: Set Environment Variables

The script updates `~/.bashrc` with the necessary environment variables:

```bash
# Add to ~/.bashrc:
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"
```

### Step 7: Apply Environment Variables

Finally, the script exports the environment variables for the current session:

```bash
export HERMES_HOME="$HOME/.hermes"
export PATH="$HOME/.local/bin:$HERMES_HOME/node/bin:$PATH"
export PYTHONPATH="$HERMES_HOME/hermes-agent:$HERMES_HOME/.deps:$PYTHONPATH"
```

---

## 📁 Directory Structure After PATCH

After running the PATCH script, the directory structure should look like this:

```
~/.hermes/
├── .deps/                    # Python dependencies (target mode)
├── node/                     # Node.js 22 (official binary package)
│   ├── bin/
│   │   ├── node
│   │   ├── npm
│   │   └── npx
├── hermes-agent/             # Source code (Git repository)
│   ├── hermes               # Main startup script (fixed shebang)
│   ├── requirements.txt
│   ├── package.json
│   └── ...
├── config.yaml               # Hermes configuration
├── .env                      # Environment variables (API keys, etc.)
└── ...
```

---

## ⚠️ Troubleshooting

### Common Issues and Solutions

#### Issue: PATCH script fails to download

**Solution**:
```bash
# Check network connection
ping github.com

# Try alternative download method
wget -O patch.sh https://raw.githubusercontent.com/byteuser1977/aidlux-install-hermes/main/script/patch.sh
chmod +x patch.sh
./patch.sh
```

#### Issue: Python 3.11 not found

**Solution**:
```bash
# Check Python versions available
ls /usr/bin/python*

# Install Python 3.11 if missing
pkg install python3.11
```

#### Issue: Node.js installation fails

**Solution**:
```bash
# Verify Node.js installation
~/.hermes/node/bin/node --version

# Reinstall Node.js
rm -rf ~/.hermes/node
# Run the PATCH script again
```

---

## 🎯 Best Practices

1. **Run as non-root user**: The PATCH script should be run as a regular user, not as root
2. **Ensure network connectivity**: A stable internet connection is required for downloading dependencies
3. **Backup existing installation**: If you have a previous installation, consider backing it up before running the PATCH script
4. **Follow the sequence**: Run the PATCH script only after attempting the official installation
5. **Verify installation**: Always run `hermes --version` after running the PATCH script to confirm success

---

## 🔗 Related Resources

- [Hermes Agent Official Repository](https://github.com/NousResearch/hermes-agent)
- [AidLux Documentation](https://docs.aidlux.com)
- [OpenClaw-CN Community](https://openclaw.cn)

---

## 📄 Script Source

The PATCH script can be viewed at:

[https://github.com/byteuser1977/aidlux-install-hermes/blob/main/script/patch.sh](https://github.com/byteuser1977/aidlux-install-hermes/blob/main/script/patch.sh)

---

**Last Updated**: 2026-04-13
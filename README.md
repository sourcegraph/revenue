# Sourcegraph Revenue Team Workstation Setup

Complete macOS workstation setup for Revenue team members. Installs all tools needed for demos and development.

## Quick Start

**Copy and paste this command into Terminal:**

```bash
/bin/bash -c "$(curl -fsSL https://github.com/sourcegraph/revenue-installer/releases/latest/download/install.sh)"
```

**That's it!** The installer will:
- Download this repository to `~/revenue`
- Install all necessary tools (VS Code, Python, Java, etc.)
- Set up demo applications
- Take about 15-30 minutes

## After Installation

Once setup is complete, you can use the `revenue` command:

```bash
revenue demo list        # See available demo apps
revenue demo start python flask  # Start a specific demo
revenue update          # Update tools to latest versions
```

## Demo Applications

Quick commands for managing demo applications:

```bash
# Start any demo
revenue demo start <language> <framework>
revenue demo start python flask
revenue demo start javascript react

# Stop demos
revenue demo stop python flask
revenue demo stop all

# View available demos
revenue demo list
revenue demo running

# View logs and attach to sessions
revenue demo logs python flask
revenue demo attach python flask
```

See [amp_demos/README.md](amp_demos/README.md) for complete demo documentation.

## Troubleshooting

### Common Issues

**"Command not found: revenue"**
- Close and reopen Terminal, or run: `source ~/.zshrc`

**"Cannot clone repository"**
- Ensure you have access to GitHub and the Sourcegraph organization
- Ask in [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75) for repository access

**Installation fails with network errors**
- Check VPN/proxy settings
- Rerun the installer - it's safe to run multiple times

**"Xcode Command Line Tools required"**
- Run: `xcode-select --install`
- Wait for installation to complete, then rerun the installer

### Get Help

If you're stuck:
1. Check the error message for specific guidance
2. Try running the installer again (it's safe to repeat)
3. Ask in [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75) with the error details

## Manual Setup (Alternative)

If you prefer manual setup or the installer doesn't work:

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Clone repository
git clone https://github.com/sourcegraph/revenue.git ~/revenue
cd ~/revenue

# 3. Run setup
./revenue init
```

## What Gets Installed

The setup installs development tools and applications including:
- **Editors**: VS Code (with extensions), JetBrains Toolbox
- **Languages**: Python, Java, Node.js
- **Tools**: Git, Amp CLI, mise, tmux, jq
- **Terminal**: Ghostty terminal emulator

See [DETAILS.md](DETAILS.md) for the complete list and descriptions.

## GitHub CLI Authentication

After installation, authenticate with GitHub for full access:

```bash
gh auth login
# Choose: GitHub.com → HTTPS → Yes → Login with web browser
```

---

**Need repository access?** Ask in [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75)

**For technical details and full application list:** See [DETAILS.md](DETAILS.md)

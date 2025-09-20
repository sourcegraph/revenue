# Sourcegraph Revenue Team Workstation Setup

Complete macOS workstation setup for Revenue team members. Installs all tools
needed for demos and development.

## Quick Start

**Copy and paste this command into Terminal:**

```bash
/bin/bash -c "$(curl -fsSL https://github.com/sourcegraph/revenue/releases/latest/download/install.sh)"
```

**That's it!** The installer will:

- Download this repository to `~/revenue` (customizable with `--install-path`)
- Install all necessary tools (VS Code, Python, Java, etc.)
- Set up demo applications
- Take about 15-30 minutes

## After Installation

Once setup is complete, you can use the `revenue` command:

```bash
revenue demo list                    # See available demo apps
revenue demo running                 # See only running demos
revenue demo start python flask     # Start a specific demo
revenue demo start all               # Start all demos
revenue demo stop python flask      # Stop a specific demo
revenue demo stop all                # Stop all demos
revenue demo restart python flask   # Restart a specific demo
revenue demo restart all             # Restart all running demos
revenue demo logs python flask      # View logs from a running demo
revenue demo connect python flask   # Connect to a running demo session
revenue demo clean --confirm         # Force cleanup all processes and sockets
revenue demo reset --confirm         # Reset to clean git state
revenue update                       # Update tools to latest versions
revenue init --install-path /custom/path  # Reinstall to custom location
```

See [amp_demos/README.md](amp_demos/README.md) for complete demo documentation.

## Troubleshooting

### Common Issues

#### "Command not found: revenue"

- Close and reopen Terminal, or run: `source ~/.zshrc`

#### "Cannot clone repository"

- Ensure you have access to GitHub and the Sourcegraph organization
- Ask in [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75)

#### Installation fails with network errors

- Check VPN/proxy settings
- Rerun the installer - it's safe to run multiple times

#### "Xcode Command Line Tools required"

- Run: `xcode-select --install`
- Wait for installation to complete, then rerun the installer

### Get Help

If you're stuck:

1. Check the error message for specific guidance
2. Try running the installer again (it's safe to repeat)
3. Ask in [#discuss-field-engineering](https://sourcegraph.slack.com/archives/C095PTMTS31)
with the error details

## Manual Setup (Alternative)

If you prefer manual setup or the installer doesn't work:

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Clone repository
git clone https://github.com/sourcegraph/revenue.git ~/revenue
cd ~/revenue

# 3. Run setup (default location)
./install.sh

# OR: Custom installation path
./install.sh --install-path /custom/path
```

### Custom Installation Path

To install the repository to a different location:

```bash
# Download installer directly
curl -fsSL https://raw.githubusercontent.com/sourcegraph/revenue/main/install.sh | bash -s -- --install-path /custom/path

# Or clone first and run locally (recommended for custom paths)
git clone https://github.com/sourcegraph/revenue.git /custom/path
cd /custom/path
./install.sh
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

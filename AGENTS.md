# Agents Configuration

## Build/Test Commands

- `./install.sh` - Initialize workstation with development tools (bootstrap)
- `./install.sh --install-path /custom/path` - Install to custom directory
- `./revenue init` - Initialize workstation (delegates to install.sh)
- `./revenue init --install-path /custom/path` - Initialize with custom installation path
- `./revenue update` - Update existing tools and packages  
- `./revenue help` - Show usage help
- `revenue init|update|demo|help` - Available global commands after setup

## Demo Management Commands

- `revenue demo start <language> <framework>` - Start a demo application
- `revenue demo start all` - Start all demo applications
- `revenue demo stop <language> <framework>` - Stop a specific demo
- `revenue demo stop all` - Stop all running demos
- `revenue demo restart <language> <framework>` - Restart a demo application
- `revenue demo restart all` - Restart all running demo applications
- `revenue demo logs <language> <framework>` - View logs from a running demo
- `revenue demo connect <language> <framework>` - Connect to a running demo session
- `revenue demo list` - List all available demos and their status
- `revenue demo running` - List currently running demos
- `revenue demo clean --confirm` - Force cleanup all processes and sockets
- `revenue demo reset --confirm` - Reset to clean git state
- `revenue demo help` - Show demo usage help
- Direct usage: `cd amp_demos && ./demo <command>`

## Architecture

This is a macOS workstation setup tool for Sourcegraph Revenue team using a simplified, Brewfile-based approach.

Key components:

- `revenue` - Single, self-contained setup script with all logic integrated
- `Brewfile` - Homebrew dependency management (formulae, casks, VS Code extensions)
- `amp_demos/demo` - Demo application manager using Overmind process manager

### Demo System Architecture

The demo system manages multiple language/framework combinations using an Overmind-based approach:

- **Discovery**: Scans `amp_demos/` for directories containing `Procfile` configuration files
- **Process Management**: Uses Overmind with tmux sessions to manage demo processes
- **Tool Management**: Integrates with `mise` for per-demo tool installation and automatic trusting
- **Directory Structure**: `amp_demos/<language>/<framework>/Procfile`

Each demo application must have:

- `Procfile` - Standard Heroku-style process definition file
- `.env` - Environment variables (PORT, LANGUAGE, FRAMEWORK)
- Optional: `.mise.toml` or `.tool-versions` for tool requirements

The system automatically:

- Trusts mise configurations silently
- Installs tools and dependencies before starting demos
- Cleans up socket files when starting/stopping
- Provides URL information based on PORT from .env file

#### Demo Configuration Format

##### Procfile (standard Procfile format)

```Procfile
setup: pnpm install --silent  # Optional: dependency installation command
web: pnpm start               # Required: command to start the web process
```

##### .env (environment variables)

```env
PORT=3000
LANGUAGE=javascript
FRAMEWORK=react
```

Demo processes are managed individually (not as named sessions) with Overmind handling the tmux session management automatically.

## Code Style

- Shell scripts use bash with `set -e` for error handling
- Functions use snake_case naming convention
- Use colored output helpers: `print_success`, `print_info`, `print_warning`, `print_error`
- Check command existence with `command_exists` function
- Input validation: trim whitespace, skip comments/empty lines in CSV
- Error messages prefix with "✗", success with "✓", info with "ℹ", warnings with "⚠"

# Agents Configuration

## Build/Test Commands

- `./setup.sh init` - Initialize workstation with development tools
- `./setup.sh update` - Update existing tools and packages  
- `./setup.sh help` - Show usage help
- `revenue init|update|demo` - Global command after setup

## Demo Management Commands

- `revenue demo start <language> <framework>` - Start a demo application
- `revenue demo stop <language> <framework>` - Stop a specific demo
- `revenue demo stop all` - Stop all running demos
- `revenue demo list` - List all available demos
- `revenue demo running` - List currently running demos
- `revenue demo clean --confirm` - Reset demo directory
- Direct usage: `cd amp_demos && ./demo.sh <command>`

## Architecture

This is a macOS workstation setup tool for Sourcegraph Revenue team using a simplified, Brewfile-based approach.

Key components:

- `setup.sh` - Single, self-contained setup script with all logic integrated
- `Brewfile` - Homebrew dependency management (formulae, casks, VS Code extensions)
- `amp_demos/demo.sh` - Demo application manager using tmux sessions

### Demo System Architecture

The demo system manages multiple language/framework combinations using a config-based approach:

- **Discovery**: Scans `amp_demos/` for directories containing `demo.yaml` configuration files
- **Session Management**: Uses tmux with server name "revenue-demo" to isolate sessions
- **Tool Management**: Integrates with `mise` for per-demo tool installation and YAML parsing
- **Directory Structure**: `amp_demos/<language>/<framework>/demo.yaml`

Each demo application must have:
- `demo.yaml` - Configuration file specifying how to start the application
- Optional: `.mise.toml` or `.tool-versions` for tool requirements

#### Demo Configuration Format

```yaml
language: javascript    # Language identifier
framework: react       # Framework identifier  
port: 3000            # Application port (for URL display)
install: pnpm install --silent  # Optional: dependency installation command
start: pnpm start     # Required: command to start the application
```

Demo sessions are named as `<language>-<framework>` and run in tmux for easy management.

## Code Style

- Shell scripts use bash with `set -e` for error handling
- Functions use snake_case naming convention
- Use colored output helpers: `print_success`, `print_info`, `print_warning`, `print_error`
- Check command existence with `command_exists` function
- Input validation: trim whitespace, skip comments/empty lines in CSV
- Error messages prefix with "✗", success with "✓", info with "ℹ", warnings with "⚠"

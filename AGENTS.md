# Agents Configuration

## Build/Test Commands

- `./setup.sh init` - Initialize workstation with development tools
- `./setup.sh update` - Update existing tools and packages  
- `./setup.sh help` - Show usage help
- `revenue-setup init|update` - Global command after setup

## Architecture

This is a macOS workstation setup tool for Sourcegraph Revenue team

Key components:

- `setup.sh` - Main setup script entry point
- `lib/bootstrap.sh` - Core setup logic and tool processing
- `lib/utils.sh` - Utility functions for colored output and validation
- `lib/installer_registry.sh` - Tool installer management
- `installers/` - Installation methods (brew.sh, curl.sh, system.sh)
- `tools.csv` - Manifest of tools to install (Amp, VS Code, JetBrains, Python, etc.)

## Code Style

- Shell scripts use bash with `set -e` for error handling
- Functions use snake_case naming convention
- Use colored output helpers: `print_success`, `print_info`, `print_warning`, `print_error`
- Check command existence with `command_exists` function
- Input validation: trim whitespace, skip comments/empty lines in CSV
- Error messages prefix with "✗", success with "✓", info with "ℹ", warnings with "⚠"

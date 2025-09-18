#!/bin/bash

# setup.sh - Sourcegraph Revenue team workstation setup

set -e # Exit on any error

# Get the real script directory (resolving symlinks)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Source the bootstrap functionality
source "$SCRIPT_DIR/lib/bootstrap.sh"

# Function to show help menu
show_help() {
  cat <<EOF
setup.sh - Sourcegraph Revenue Team Workstation Setup

DESCRIPTION:
    This utility will setup your environment and ensure you have the necessary tools to both demo and use Amp.

USAGE:
    ./setup.sh [COMMAND]

COMMANDS:
    init        Initialize your workstation
    
    update      Update existing tools and packages
    
    demo        Manage demo applications (delegates to amp_demos/demo.sh)
    
    help        Show this help message

EXAMPLES:
    ./setup.sh init
    ./setup.sh update
    ./setup.sh demo start python flask
    ./setup.sh help

For more information, visit: https://github.com/sourcegraph/revenue
EOF
}

main() {
  local action="${1:-}"

  case "$action" in
  "init")
    bootstrap "init"
    ;;
  "update")
    bootstrap "update"
    ;;
  "demo")
    # Delegate to amp_demos/demo.sh with remaining arguments
    shift # Remove 'demo' from arguments
    cd "$SCRIPT_DIR/amp_demos"
    exec "./demo.sh" "$@"
    ;;
  "help" | "-h" | "--help")
    show_help
    ;;
  "")
    echo -e "\033[0;31m✗ No command specified.\033[0m"
    echo ""
    show_help
    exit 1
    ;;
  *)
    echo -e "\033[0;31m✗ Unknown command: $action\033[0m"
    echo ""
    show_help
    exit 1
    ;;
  esac
}

# Run main function with all arguments
main "$@"

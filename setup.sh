#!/bin/bash

# setup.sh - Sourcegraph Revenue team workstation setup

set -e # Exit on any error

# Get the real script directory (resolving symlinks)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check if running on macOS
check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script currently only supports macOS."
    exit 1
  fi
}

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

# Install prerequisites (Xcode CLT and Homebrew)
install_prerequisites() {
  # Check if Xcode Command Line Tools are installed
  if ! command_exists "git"; then
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and run this script again."
    exit 0
  else
    print_success "Xcode Command Line Tools are already installed"
  fi

  # Install Homebrew if needed
  if ! command_exists "brew"; then
    print_info "Installing Homebrew..."
    if curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; then
      print_success "Homebrew installed successfully"

      # Add Homebrew to PATH for current session
      if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    else
      print_error "Failed to install Homebrew"
      exit 1
    fi
  else
    print_success "Homebrew is already installed"
  fi
}

# Install dependencies via Brewfile
install_brewfile_dependencies() {
  cd "$SCRIPT_DIR"
  if brew bundle install --quiet; then
    print_success "Brewfile dependencies installed successfully"
  else
    print_error "Failed to install Brewfile dependencies"
    exit 1
  fi
}

# Update dependencies via Brewfile
update_brewfile_dependencies() {
  # Update Homebrew first
  brew update

  # Upgrade outdated formulae
  brew upgrade

  # Install/update via Brewfile
  cd "$SCRIPT_DIR"
  if brew bundle install --quiet; then
    print_success "Dependencies updated successfully"
  else
    print_error "Failed to update dependencies"
    exit 1
  fi

  # Cleanup
  brew cleanup
  print_success "Cleanup completed"
}

# Install Amp CLI
install_amp_cli() {
  if ! command_exists "amp"; then
    print_info "Installing Amp CLI..."
    if curl -fsSL https://ampcode.com/install.sh | bash; then
      print_success "Amp CLI: installed successfully"
    else
      print_error "Amp CLI: failed to install"
      exit 1
    fi
  fi
}

update_amp_cli() {
  if ! command_exists "amp"; then
    install_amp_cli
  else
    {
      amp update
    }
  fi
}

# Setup global revenue command
setup_global_command() {
  # Get the absolute path of this script
  local script_path
  script_path="$(realpath "$SCRIPT_DIR/setup.sh")"

  # Create ~/.local/bin if it doesn't exist
  local local_bin_dir="$HOME/.local/bin"
  if [[ ! -d "$local_bin_dir" ]]; then
    mkdir -p "$local_bin_dir"
    print_success "Created $local_bin_dir directory"
  fi

  # Remove old revenue-setup symlink if it exists
  local old_symlink_path="$local_bin_dir/revenue-setup"
  if [[ -L "$old_symlink_path" || -f "$old_symlink_path" ]]; then
    rm "$old_symlink_path"
    print_success "Removed old revenue-setup symlink"
  fi

  # Create symlink
  local symlink_path="$local_bin_dir/revenue"
  if [[ -L "$symlink_path" ]]; then
    rm "$symlink_path"
  elif [[ -f "$symlink_path" ]]; then
    print_warning "File exists at $symlink_path, removing..."
    rm "$symlink_path"
  fi

  ln -s "$script_path" "$symlink_path"
  print_success "Created global command: revenue"

  # Check if ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$local_bin_dir:"* ]]; then
    print_warning "$HOME/.local/bin is not in your PATH"
    print_info "Add this line to your shell profile (~/.zshrc or ~/.bash_profile):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    print_info "Or run: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
  else
    print_success "$HOME/.local/bin is already in your PATH"
  fi
}

# Configure mise shell integration
configure_mise() {
  # Check common bash profile files on macOS
  local bash_profiles=("$HOME/.bashrc" "$HOME/.bash_profile")
  local mise_activation="eval \"\$(mise activate bash)\""
  local profile_updated=false

  for profile in "${bash_profiles[@]}"; do
    if [[ -f "$profile" ]]; then
      if grep -q "mise activate bash" "$profile"; then
        print_success "mise activation already configured in $(basename "$profile")"
        profile_updated=true
        break
      fi
    fi
  done

  if [[ "$profile_updated" == false ]]; then
    # Use .bash_profile on macOS as it's more standard
    local target_profile="$HOME/.bash_profile"

    # Create the file if it doesn't exist
    touch "$target_profile"

    # Add mise activation
    {
      echo ""
      echo "# Initialize mise"
      echo "$mise_activation"
    } >>"$target_profile"

    print_success "Added mise activation to $(basename "$target_profile")"
    print_info "Restart your terminal or run: source $target_profile"
  fi
}

# Update repository from main
update_repository() {
  # Check if we're in a git repository and update from main if applicable
  if [[ -d ".git" ]]; then
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$current_branch" == "main" ]]; then
      git pull origin main
    elif [[ -n "$current_branch" ]]; then
      print_warning "Repository is on branch '$current_branch', not 'main'"
      print_warning "Installed applications may be out of date. Consider switching to main branch."
    fi
  fi
}

# Initialize development environment
init_environment() {
  check_macos
  install_prerequisites
  install_brewfile_dependencies
  install_amp_cli
  setup_global_command
  configure_mise
  print_success "Environment initialization completed!"
}

# Update development environment
update_environment() {
  check_macos
  update_repository
  install_prerequisites # Ensure Homebrew is still available
  update_brewfile_dependencies
  update_amp_cli
  print_success "Environment update completed!"
}

# Main function
main() {
  local action="${1:-}"

  case "$action" in
  "init")
    init_environment
    ;;
  "update")
    update_environment
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

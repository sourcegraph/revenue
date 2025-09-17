#!/bin/bash

# setup.sh - Sourcegraph Revenue team workstation setup

set -e # Exit on any error

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
    
    help        Show this help message

EXAMPLES:
    ./setup.sh init
    ./setup.sh update
    ./setup.sh help

For more information, visit: https://github.com/sourcegraph/revenue
EOF
}

# Function to check if running on macOS
check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script currently only supports macOS only."
    exit 1
  fi
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Essential tools configuration
# Format: "package_name:description:install_method"
essential_tools=(
  "git:Git version control:system"
  "curl:Command line HTTP client:system"
  "ghostty:Cross-platform terminal emulator:brew"
  "jetbrains-toolbox:JetBrains Toolbox:brew"
  "jq:JSON processor:brew"
  "mise:mise-en-place:brew"
  "python:Pyhton Programming Language:brew"
  "temurin:Eclipse Temurin JDK:brew"
  "tree:Directory tree viewer:brew"
  "visual-studio-code:Visual Studio Code:brew"
)

# Function to handle init command
cmd_init() {
  print_info "Initializing development environment..."

  # Check if Xcode Command Line Tools are installed
  if ! command_exists "git"; then
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and run this script again."
    exit 0
  else
    print_success "Xcode Command Line Tools are already installed"
  fi

  # Install Homebrew if not present
  if ! command_exists "brew"; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed successfully"
  else
    print_success "Homebrew is already installed"
  fi

  # Install essential packages
  print_info "Installing essential packages..."

  for tool_info in "${essential_tools[@]}"; do
    IFS=':' read -r package description install_method <<<"$tool_info"

    if [[ "$install_method" == "system" ]]; then
      # Skip system tools like git/curl - they come with Xcode CLI tools
      continue
    fi

    if brew list "$package" &>/dev/null; then
      print_success "$package is already installed"
    else
      print_info "Installing $package..."
      brew install "$package"
      print_success "$package installed successfully"
    fi
  done

  # Create global symlink
  print_info "Setting up global command..."

  # Get the absolute path of this script
  script_path="$(realpath "$0")"

  # Create ~/.local/bin if it doesn't exist
  local_bin_dir="$HOME/.local/bin"
  if [[ ! -d "$local_bin_dir" ]]; then
    mkdir -p "$local_bin_dir"
    print_success "Created $local_bin_dir directory"
  fi

  # Create symlink
  symlink_path="$local_bin_dir/revenue-setup"
  if [[ -L "$symlink_path" ]]; then
    rm "$symlink_path"
  elif [[ -f "$symlink_path" ]]; then
    print_warning "File exists at $symlink_path, removing..."
    rm "$symlink_path"
  fi

  ln -s "$script_path" "$symlink_path"
  print_success "Created global command: revenue-setup"

  # Check if ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$local_bin_dir:"* ]]; then
    print_warning "~/.local/bin is not in your PATH"
    print_info "Add this line to your shell profile (~/.zshrc or ~/.bash_profile):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    print_info "Or run: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
  else
    print_success "~/.local/bin is already in your PATH"
    print_info "You can now run 'revenue-setup' from anywhere"
  fi

  # Configure mise in bash profile
  print_info "Configuring mise activation..."

  # Check common bash profile files on macOS
  bash_profiles=("$HOME/.bashrc" "$HOME/.bash_profile")
  mise_activation='eval "$(mise activate bash)"'
  profile_updated=false

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
    target_profile="$HOME/.bash_profile"

    # Create the file if it doesn't exist
    touch "$target_profile"

    # Add mise activation
    echo "" >>"$target_profile"
    echo "# Initialize mise" >>"$target_profile"
    echo "$mise_activation" >>"$target_profile"

    print_success "Added mise activation to $(basename "$target_profile")"
    print_info "Restart your terminal or run: source $target_profile"
  fi

  print_success "Environment initialization completed!"
}

# Function to handle update command
cmd_update() {
  print_info "Updating environment..."

  # Check if we're in a git repository and update from main if applicable
  if [[ -d ".git" ]]; then
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$current_branch" == "main" ]]; then
      print_info "Updating repository from main..."
      git pull origin main
      print_success "Repository updated from main"
    elif [[ -n "$current_branch" ]]; then
      print_warning "Repository is on branch '$current_branch', not 'main'"
      print_warning "Installed applications may be out of date. Consider switching to main branch."
    fi
  fi

  if command_exists "brew"; then
    print_info "Updating Homebrew..."
    brew update
    print_success "Homebrew updated"

    print_info "Upgrading installed packages..."
    brew upgrade
    print_success "Packages upgraded"

    # Install any missing essential packages
    print_info "Checking for missing packages..."
    missing_packages=()

    for tool_info in "${essential_tools[@]}"; do
      IFS=':' read -r package description install_method <<<"$tool_info"

      if [[ "$install_method" == "system" ]]; then
        # Skip system tools like git/curl
        continue
      fi

      if ! brew list "$package" &>/dev/null; then
        missing_packages+=("$package")
      fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
      print_info "Installing missing packages: ${missing_packages[*]}"
      for package in "${missing_packages[@]}"; do
        print_info "Installing $package..."
        brew install "$package"
        print_success "$package installed successfully"
      done
    else
      print_success "All essential packages are already installed"
    fi

    print_info "Cleaning up..."
    brew cleanup
    print_success "Cleanup completed"
  else
    print_warning "Homebrew not found. Running init first..."
    cmd_init
    return
  fi

  print_success "Environment update completed!"
}

# Main script logic
main() {
  # Check if running on macOS
  check_macos

  # Handle command line arguments
  case "${1:-}" in
  "init")
    cmd_init
    ;;
  "update")
    cmd_update
    ;;
  "help" | "-h" | "--help")
    show_help
    ;;
  "")
    print_error "No command specified."
    echo ""
    show_help
    exit 1
    ;;
  *)
    print_error "Unknown command: $1"
    echo ""
    show_help
    exit 1
    ;;
  esac
}

# Run main function with all arguments
main "$@"

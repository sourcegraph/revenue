#!/bin/bash

# Sourcegraph Revenue Team Workstation Bootstrap Installer
# This script clones/updates the repository and runs the initialization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_header() {
  echo ""
  echo "🚀 Sourcegraph Revenue Team Workstation Setup"
  echo "============================================="
  echo ""
  print_info "This will set up your macOS workstation with all the tools needed for demos and development."
  print_info "Estimated time: 15-30 minutes (depending on internet speed)"
  echo ""
}

# Check if we're on macOS
check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This installer is designed for macOS only."
    print_info "Your system: $OSTYPE"
    exit 1
  fi
  
  print_success "Running on macOS $(sw_vers -productVersion)"
}

# Check if git is available
check_git() {
  if ! command -v git >/dev/null 2>&1; then
    print_error "Git is not installed."
    print_info "Please install Xcode Command Line Tools first:"
    print_info "  xcode-select --install"
    print_info "Then run this installer again."
    exit 1
  fi
  
  print_success "Git is available"
}

# Clone or update the repository
setup_repository() {
  repo_dir="$HOME/revenue"  # Make repo_dir global for use by other functions
  local repo_url="https://github.com/sourcegraph/revenue.git"
  
  if [[ -d "$repo_dir" ]]; then
    print_info "Repository already exists at $repo_dir"
    print_info "Updating to latest version..."
    
    cd "$repo_dir"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      # Save current branch
      local current_branch
      current_branch=$(git branch --show-current 2>/dev/null || echo "")
      
      # Update repository
      git fetch origin >/dev/null 2>&1
      if [[ "$current_branch" == "main" ]]; then
        git pull origin main >/dev/null 2>&1
        print_success "Updated to latest version"
      else
        print_warning "Repository is on branch '$current_branch', not 'main'"
        print_info "Consider switching to main for latest updates"
      fi
    else
      print_error "Directory exists but is not a git repository"
      print_info "Please remove $repo_dir and run this installer again"
      exit 1
    fi
  else
    print_info "Cloning repository to $repo_dir..."
    if git clone "$repo_url" "$repo_dir" >/dev/null 2>&1; then
      print_success "Repository cloned successfully"
      cd "$repo_dir"
    else
      print_error "Failed to clone repository"
      print_info "Please check your internet connection and GitHub access"
      exit 1
    fi
  fi
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect user's current shell
detect_shell() {
  local current_shell
  current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
  
  case "$current_shell" in
    zsh|bash)
      echo "$current_shell"
      ;;
    *)
      # Fallback: check what shell is actually running this script
      if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
      elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
      else
        # Default to zsh since it's macOS default since 10.15
        echo "zsh"
      fi
      ;;
  esac
}

# Get shell profile path based on detected shell
get_shell_profile() {
  local shell_type="$1"
  
  case "$shell_type" in
    zsh)
      echo "$HOME/.zshrc"
      ;;
    bash)
      # Check for existing bash profile files, prefer .bash_profile on macOS
      if [[ -f "$HOME/.bash_profile" ]]; then
        echo "$HOME/.bash_profile"
      elif [[ -f "$HOME/.bashrc" ]]; then
        echo "$HOME/.bashrc"
      else
        echo "$HOME/.bash_profile"  # Create .bash_profile as default on macOS
      fi
      ;;
    *)
      echo "$HOME/.profile"  # Generic fallback
      ;;
  esac
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
    print_info "You may be prompted for your macOS password..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
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
  cd "$repo_dir"
  print_info "Installing development tools and applications..."
  if brew bundle install --quiet; then
    print_success "Development tools installed successfully"
  else
    print_error "Failed to install development tools"
    exit 1
  fi
}

# Install Amp CLI
install_amp_cli() {
  if ! command_exists "amp"; then
    print_info "Installing Amp CLI..."
    if curl -fsSL https://ampcode.com/install.sh | bash; then
      print_success "Amp CLI installed successfully"
    else
      print_error "Failed to install Amp CLI"
      exit 1
    fi
  else
    print_success "Amp CLI is already installed"
  fi
}

# Setup global revenue command
setup_global_command() {
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

  # Create symlink to revenue script
  local symlink_path="$local_bin_dir/revenue"
  local script_path="$repo_dir/revenue"
  
  if [[ -L "$symlink_path" ]]; then
    rm "$symlink_path"
  elif [[ -f "$symlink_path" ]]; then
    print_warning "File exists at $symlink_path, removing..."
    rm "$symlink_path"
  fi

  if ln -s "$script_path" "$symlink_path"; then
    print_success "Created global command: revenue"
  else
    print_error "Failed to create global revenue command"
    exit 1
  fi

  # Check if ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$local_bin_dir:"* ]]; then
    local shell_type
    shell_type=$(detect_shell)
    local profile_path
    profile_path=$(get_shell_profile "$shell_type")
    
    print_warning "$HOME/.local/bin is not in your PATH"
    print_info "Add this line to your shell profile ($(basename "$profile_path")):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    print_info "Or run: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $profile_path"
  else
    print_success "$HOME/.local/bin is already in your PATH"
  fi
}

# Configure mise shell integration
configure_mise() {
  local shell_type
  shell_type=$(detect_shell)
  local profile_path
  profile_path=$(get_shell_profile "$shell_type")
  local mise_activation="eval \"\$(mise activate $shell_type)\""
  local profile_updated=false

  print_info "Detected shell: $shell_type"
  print_info "Using profile: $(basename "$profile_path")"

  # Check if mise activation is already configured
  if [[ -f "$profile_path" ]] && grep -q "mise activate $shell_type" "$profile_path"; then
    print_success "mise activation already configured in $(basename "$profile_path")"
    profile_updated=true
  fi

  # Also check for any existing mise activation (different shell) and warn
  if [[ -f "$profile_path" ]] && grep -q "mise activate" "$profile_path" && ! grep -q "mise activate $shell_type" "$profile_path"; then
    print_warning "Found mise activation for different shell in $(basename "$profile_path")"
    print_info "This will be updated to use $shell_type"
  fi

  if [[ "$profile_updated" == false ]]; then
    # Create the file if it doesn't exist
    touch "$profile_path"

    # Add mise activation
    {
      echo ""
      echo "# Initialize mise"
      echo "$mise_activation"
    } >>"$profile_path"

    print_success "Added mise activation to $(basename "$profile_path")"
    print_info "Restart your terminal or run: source $profile_path"
  fi
}

# Run the main installer
run_installer() {
  print_info "Installing development tools..."
  echo ""
  
  install_prerequisites
  install_brewfile_dependencies
  install_amp_cli
  setup_global_command
  configure_mise
}

# Main installation flow
main() {
  print_header
  check_macos
  check_git
  setup_repository
  run_installer
  
  echo ""
  print_success "🎉 Setup complete!"
  print_info "You can now use the 'revenue' command to manage your workstation and demos."
  print_info "Try: revenue demo list"
  echo ""
}

# Run main function
main "$@"

#!/bin/bash

# bootstrap.sh - Main bootstrap logic for setup script

# Get the script directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."
CONFIG_FILE="$SCRIPT_DIR/tools.csv"

# Source utilities and installer registry
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/installer_registry.sh"

# Load all installer modules
load_installers

bootstrap_prerequisites() {
  print_info "Checking prerequisites..."
  
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
}

process_tools() {
  local action="$1"
  
  print_info "Processing tools with action: $action"
  
  # Update Homebrew if doing updates
  if [[ "$action" == "update" ]] && command_exists "brew"; then
    print_info "Updating Homebrew..."
    brew update
    print_success "Homebrew updated"
  fi
  
  # Process each tool from the CSV file
  while IFS=, read -r name desc method source; do
    # Skip comments and empty lines
    [[ $name == \#* || -z $name ]] && continue
    
    # Trim whitespace
    name=$(echo "$name" | xargs)
    method=$(echo "$method" | xargs)
    source=$(echo "$source" | xargs)
    
    ensure_tool "$name" "$method" "$source" "$action"
  done < "$CONFIG_FILE"
  
  # Cleanup if doing updates
  if [[ "$action" == "update" ]] && command_exists "brew"; then
    print_info "Cleaning up Homebrew..."
    brew cleanup
    print_success "Cleanup completed"
  fi
}

setup_global_command() {
  print_info "Setting up global command..."

  # Get the absolute path of the main script
  local main_script="$SCRIPT_DIR/setup.sh"
  local script_path="$(realpath "$main_script")"

  # Create ~/.local/bin if it doesn't exist
  local local_bin_dir="$HOME/.local/bin"
  if [[ ! -d "$local_bin_dir" ]]; then
    mkdir -p "$local_bin_dir"
    print_success "Created $local_bin_dir directory"
  fi

  # Create symlink
  local symlink_path="$local_bin_dir/revenue-setup"
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
}

configure_mise() {
  print_info "Configuring mise activation..."

  # Check common bash profile files on macOS
  local bash_profiles=("$HOME/.bashrc" "$HOME/.bash_profile")
  local mise_activation='eval "$(mise activate bash)"'
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
    echo "" >>"$target_profile"
    echo "# Initialize mise" >>"$target_profile"
    echo "$mise_activation" >>"$target_profile"

    print_success "Added mise activation to $(basename "$target_profile")"
    print_info "Restart your terminal or run: source $target_profile"
  fi
}

update_repository() {
  # Check if we're in a git repository and update from main if applicable
  if [[ -d ".git" ]]; then
    local current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$current_branch" == "main" ]]; then
      print_info "Updating repository from main..."
      git pull origin main
      print_success "Repository updated from main"
    elif [[ -n "$current_branch" ]]; then
      print_warning "Repository is on branch '$current_branch', not 'main'"
      print_warning "Installed applications may be out of date. Consider switching to main branch."
    fi
  fi
}

# Main bootstrap function
bootstrap() {
  local action="$1"
  
  check_macos
  
  case "$action" in
    "init")
      print_info "Initializing development environment..."
      bootstrap_prerequisites
      process_tools "install"
      setup_global_command
      configure_mise
      print_success "Environment initialization completed!"
      ;;
    "update")
      print_info "Updating environment..."
      update_repository
      bootstrap_prerequisites  # Ensure Homebrew is still available
      process_tools "update"
      print_success "Environment update completed!"
      ;;
    *)
      print_error "Unknown action: $action"
      exit 1
      ;;
  esac
}

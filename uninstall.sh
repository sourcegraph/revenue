#!/bin/bash

# Sourcegraph Revenue Team Workstation Uninstaller
# This script removes the configuration and files created by the installer

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

# Parse command line arguments
FORCE=false
KEEP_REPO=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE=true
      shift
      ;;
    --keep-repo)
      KEEP_REPO=true
      shift
      ;;
    --help | -h)
      print_info "Sourcegraph Revenue Team Workstation Uninstaller"
      echo ""
      print_info "Usage: $0 [OPTIONS]"
      echo ""
      print_info "Options:"
      print_info "  --force                Skip confirmation prompts"
      print_info "  --keep-repo            Do not remove the repository directory"
      print_info "  --help, -h             Show this help message"
      echo ""
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      print_info "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Detect user's current shell (same logic as install.sh)
detect_shell() {
  local current_shell
  current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")

  case "$current_shell" in
    zsh | bash)
      echo "$current_shell"
      ;;
    *)
      if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
      elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
      else
        echo "zsh" # Default
      fi
      ;;
  esac
}

# Get shell profile path (same logic as install.sh)
get_shell_profile() {
  local shell_type="$1"

  case "$shell_type" in
    zsh)
      echo "$HOME/.zshrc"
      ;;
    bash)
      if [[ -f "$HOME/.bash_profile" ]]; then
        echo "$HOME/.bash_profile"
      elif [[ -f "$HOME/.bashrc" ]]; then
        echo "$HOME/.bashrc"
      else
        echo "$HOME/.bash_profile"
      fi
      ;;
    *)
      echo "$HOME/.profile"
      ;;
  esac
}

# Confirmation prompt
confirm() {
  if [[ "$FORCE" == true ]]; then
    return 0
  fi
  
  read -p "$1 [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    return 1
  fi
  return 0
}

print_info "This will remove the Sourcegraph Revenue Team Workstation configuration."
if ! confirm "Are you sure you want to continue?"; then
  print_info "Uninstall cancelled."
  exit 0
fi

# Remove global command
remove_global_command() {
  local symlink_path="$HOME/.local/bin/revenue"
  
  if [[ -L "$symlink_path" || -f "$symlink_path" ]]; then
    print_info "Removing global revenue command..."
    rm "$symlink_path"
    print_success "Removed $symlink_path"
  else
    print_info "Global revenue command not found at $symlink_path"
  fi
}

# Remove configuration from shell profile
clean_shell_profile() {
  local shell_type
  shell_type=$(detect_shell)
  local profile_path
  profile_path=$(get_shell_profile "$shell_type")
  local profile_backup
  profile_backup="${profile_path}.bak.$(date +%s)"

  if [[ -f "$profile_path" ]]; then
    print_info "Checking shell profile: $(basename "$profile_path")"
    
    # Check if we need to modify the file
    if grep -q "export PATH.*\.local/bin" "$profile_path" || grep -q "mise activate" "$profile_path"; then
      
      print_info "Backing up profile to $(basename "$profile_backup")..."
      cp "$profile_path" "$profile_backup"

      # Remove PATH addition
      # We use a temporary file to handle the sed differences and multi-line removals cleanly
      local temp_file
      temp_file=$(mktemp)

      # Filter out the lines we added
      # Note: detailed matching to avoid removing user's own configs if they manually added similar lines
      # We look for the comments we added in install.sh
      
      awk '
        BEGIN { skip = 0 }
        /# Add .*\/revenue\/.local\/bin to PATH/ { skip = 1; next }
        /# Add .*\/.local\/bin to PATH/ { skip = 1; next }
        /export PATH=".*\.local\/bin:\$PATH"/ { 
            if (skip) { skip = 0; next }
        }
        /# Initialize mise/ { skip = 1; next }
        /eval "\$\(mise activate.*\)"/ { 
            if (skip) { skip = 0; next }
        }
        { print }
      ' "$profile_path" > "$temp_file"

      # Check if changes were made
      if ! cmp -s "$profile_path" "$temp_file"; then
        mv "$temp_file" "$profile_path"
        print_success "Removed configuration from $(basename "$profile_path")"
        print_info "You may need to restart your shell for changes to take effect."
      else
        rm "$temp_file"
        print_info "No automated changes made to $(basename "$profile_path") (patterns did not match exactly)"
        print_info "You may want to manually check for leftover configuration."
      fi
    else
      print_success "No revenue configuration found in $(basename "$profile_path")"
    fi
  fi
}

# Remove repository
remove_repository() {
  # Get directory of this script to find repo root
  # Assuming script is in repo root
  local script_dir
  script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  
  if [[ "$KEEP_REPO" == true ]]; then
    print_info "Skipping repository removal (--keep-repo specified)"
    print_info "Repository remains at: $script_dir"
    return
  fi

  # Basic safety check - ensure we are removing the revenue repo
  if [[ -d "$script_dir/.git" ]] && grep -q "sourcegraph/revenue" "$script_dir/.git/config"; then
    if confirm "Do you want to remove the repository at $script_dir?"; then
      print_info "Removing repository..."
      # We can't remove the directory we are running the script from while running it easily
      # So we schedule it for removal or move to tmp?
      # Better approach: warn user that the script file itself will be gone.
      
      # We will remove everything inside EXCEPT this script first, then finish?
      # Actually, simple rm -rf usually works on executed scripts in bash (it stays in memory), 
      # but let's be safe and tell user to delete the dir manually if it fails.
      
      rm -rf "$script_dir" || {
        print_warning "Could not remove directory while script is running."
        print_info "Please manually remove: $script_dir"
      }
      print_success "Repository removed"
    fi
  else
    print_warning "Current directory does not look like the revenue repository. Skipping removal."
    print_info "Path: $script_dir"
  fi
}

# Main
remove_global_command
clean_shell_profile
remove_repository

echo ""
print_success "Uninstall complete!"
print_info "Note: Homebrew and Amp CLI were NOT uninstalled as they may be used by other tools."
print_info "To uninstall Amp CLI manually, remove ~/.amp (or check amp docs)."
print_info "To uninstall Homebrew manually, see https://brew.sh"

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
  local repo_dir="$HOME/revenue"
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

# Run the main installer
run_installer() {
  print_info "Running workstation setup..."
  echo ""
  
  if [[ -x "./revenue" ]]; then
    ./revenue init
  else
    print_error "Revenue script not found or not executable"
    exit 1
  fi
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

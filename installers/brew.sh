#!/bin/bash

# brew.sh - Homebrew installer

brew_install() {
  local name="$1"
  
  if brew list "$name" &>/dev/null; then
    print_success "$name is already installed"
  else
    print_info "Installing $name via Homebrew..."
    if brew install "$name"; then
      print_success "$name installed successfully"
    else
      print_warning "Installation failed, trying with --adopt to handle existing files..."
      if brew install --adopt "$name"; then
        print_success "$name installed successfully (adopted existing installation)"
      else
        print_error "Failed to install $name even with --adopt"
        exit 1
      fi
    fi
  fi
}

brew_update() {
  local name="$1"
  
  if brew list "$name" &>/dev/null; then
    print_info "Updating $name via Homebrew..."
    if brew upgrade "$name" 2>/dev/null || true; then
      print_success "$name is up to date"
    fi
  else
    # If not installed, install it
    brew_install "$name"
  fi
}

# Handlers are registered via dispatch_installer case statement

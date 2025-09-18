#!/bin/bash

# brew.sh - Homebrew installer

brew_install() {
  local name="$1"
  
  if brew list "$name" &>/dev/null; then
    print_success "$name (brew): already installed"
  else
    print_info "$name (brew): installing via Homebrew..."
    if brew install "$name"; then
      print_success "$name (brew): installed successfully"
    else
      print_warning "$name (brew): installation failed, trying with --adopt to handle existing files..."
      if brew install --adopt "$name"; then
        print_success "$name (brew): installed successfully (adopted existing installation)"
      else
        print_error "$name (brew): failed to install even with --adopt"
        exit 1
      fi
    fi
  fi
}

brew_update() {
  local name="$1"
  
  if brew list "$name" &>/dev/null; then
    print_info "$name (brew): updating via Homebrew..."
    if brew upgrade "$name" 2>/dev/null || true; then
      print_success "$name (brew): is up to date"
    fi
  else
    # If not installed, install it
    brew_install "$name"
  fi
}

# Handlers are registered via dispatch_installer case statement

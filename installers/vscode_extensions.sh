#!/bin/bash

# vscode_extensions.sh - VS Code extensions installer

# Check VS Code prerequisites
check_vscode_prerequisites() {
  local name="$1"
  
  # Check if VS Code is installed via brew
  if ! brew list visual-studio-code &>/dev/null; then
    print_error "VS Code is not installed via Homebrew. Please ensure 'visual-studio-code' is installed first."
    print_info "VS Code extension '$name' requires Visual Studio Code to be installed."
    return 1
  fi
  
  # Check if code command is available
  if ! command_exists code; then
    print_error "VS Code CLI (code command) is not available."
    print_info "Please open VS Code and install the 'code' command via:"
    print_info "  View → Command Palette → 'Shell Command: Install code command in PATH'"
    return 1
  fi
  
  return 0
}

vscode_extensions_install() {
  local name="$1"
  local extension_id="$2"
  
  # Check prerequisites first
  if ! check_vscode_prerequisites "$name"; then
    print_warning "Skipping $name installation due to missing prerequisites"
    return 0
  fi
  
  # Check if extension is already installed
  if code --list-extensions | grep -qi "^$extension_id$"; then
    print_success "$name is already installed"
  else
    print_info "Installing VS Code extension: $name ($extension_id)..."
    if code --install-extension "$extension_id" --force; then
      print_success "$name installed successfully"
    else
      print_error "Failed to install $name"
      return 1
    fi
  fi
}

vscode_extensions_update() {
  local name="$1"
  local extension_id="$2"
  
  # Check prerequisites first
  if ! check_vscode_prerequisites "$name"; then
    print_warning "Skipping $name update due to missing prerequisites"
    return 0
  fi
  
  # VS Code handles extension updates automatically - no manual intervention needed
  if code --list-extensions | grep -qi "^$extension_id$"; then
    print_success "$name is installed (updates handled by VS Code)"
  else
    # If not installed, install it
    print_info "$name not found, installing..."
    vscode_extensions_install "$name" "$extension_id"
  fi
}

# Handlers are registered via dispatch_installer case statement

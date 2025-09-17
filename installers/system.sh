#!/bin/bash

# system.sh - System tool installer (tools that come with Xcode CLI tools)

system_install() {
  local name="$1"
  # System tools are expected to be already installed with Xcode CLI tools
  if command_exists "$name"; then
    print_success "$name is already installed (system)"
  else
    print_warning "$name should be installed with Xcode Command Line Tools"
  fi
}

system_update() {
  local name="$1"
  # System tools are updated via macOS system updates
  print_info "$name (system tool) - updates via macOS system updates"
}

# Handlers are registered via dispatch_installer case statement

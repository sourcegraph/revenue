#!/bin/bash

# curl.sh - Curl-based installer

curl_install() {
  local name="$1"
  local url="$2"
  
  if command_exists "$name"; then
    print_success "$name (curl): already installed"
  else
    print_info "$name (curl): installing via curl from $url..."
    if curl -fsSL "$url" | bash; then
      print_success "$name (curl): installed successfully"
    else
      print_error "$name (curl): failed to install"
      exit 1
    fi
  fi
}

curl_update() {
  local name="$1"
  local url="$2"
  
  if command_exists "$name"; then
    print_info "$name (curl): installed - curl-based tools typically auto-update or require manual updates"
  else
    # If not installed, install it
    curl_install "$name" "$url"
  fi
}

# Handlers are registered via dispatch_installer case statement

#!/bin/bash

# installer_registry.sh - Registry for installation handlers

# Function to dispatch to the correct installer handler
dispatch_installer() {
  local method="$1"
  local action="$2"
  local name="$3"
  local source="$4"

  case "${method}:${action}" in
    "system:install")
      system_install "$name" "$source"
      ;;
    "system:update")
      system_update "$name" "$source"
      ;;
    "brew:install")
      brew_install "$name" "$source"
      ;;
    "brew:update")
      brew_update "$name" "$source"
      ;;
    "curl:install")
      curl_install "$name" "$source"
      ;;
    "curl:update")
      curl_update "$name" "$source"
      ;;
    *)
      print_error "No handler registered for method '$method' with action '$action'"
      exit 1
      ;;
  esac
}

# Function to ensure a tool is installed/updated
ensure_tool() {
  local name="$1"
  local method="$2" 
  local source="$3"
  local action="$4"  # install or update

  dispatch_installer "$method" "$action" "$name" "$source"
}

# Function to load all installer modules
load_installers() {
  local script_dir
  script_dir="$(dirname "${BASH_SOURCE[0]}")"
  local installers_dir="$script_dir/../installers"
  
  for installer_file in "$installers_dir"/*.sh; do
    if [[ -f "$installer_file" ]]; then
      # shellcheck source=/dev/null
      source "$installer_file"
    fi
  done
}

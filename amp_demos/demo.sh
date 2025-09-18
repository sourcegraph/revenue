#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Shared tmux server name
TMUX_SERVER="revenue-demo"

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Check if tmux is available
check_tmux() {
  if ! command -v tmux &>/dev/null; then
    print_error "tmux is required but not installed"
    exit 1
  fi
}

# Get session name for a given language and framework
get_session_name() {
  local language="$1"
  local framework="$2"
  echo "${language}-${framework}"
}

# Discover all available demo applications (only those with demo.yaml)
discover_apps() {
  local apps=()
  for lang_dir in */; do
    lang=$(basename "$lang_dir")
    if [[ "$lang" == "." || "$lang" == ".." ]]; then
      continue
    fi
    if [[ -d "$lang_dir" ]]; then
      for framework_dir in "$lang_dir"*/; do
        if [[ -d "$framework_dir" && -f "$framework_dir/demo.yaml" ]]; then
          framework=$(basename "$framework_dir")
          apps+=("$lang:$framework")
        fi
      done
    fi
  done
  printf '%s\n' "${apps[@]}"
}

# Check if demo directory has required files and prepare environment
prepare_demo_environment() {
  local language="$1"
  local framework="$2"
  local app_dir="$language/$framework"

  if [[ ! -d "$app_dir" ]]; then
    print_error "Directory $app_dir does not exist"
    return 1
  fi

  if [[ ! -f "$app_dir/demo.yaml" ]]; then
    print_error "No demo.yaml found in $app_dir"
    return 1
  fi

  # Run mise install to ensure all tools are available
  print_info "Installing required tools with mise..."
  if ! (cd "$app_dir" && mise install 2>/dev/null); then
    print_warning "mise install failed or no mise configuration found"
  fi

  return 0
}

# Parse demo config and execute commands
execute_demo_config() {
  local app_dir="$1"
  local config_file="$app_dir/demo.yaml"
  
  # Check if yq is available through mise
  if ! mise exec -- command -v yq &>/dev/null; then
    print_error "yq is required but not installed. Run 'mise install' in the root directory."
    return 1
  fi
  
  # Parse config values
  local language=$(mise exec -- yq '.language // "unknown"' "$config_file")
  local framework=$(mise exec -- yq '.framework // "unknown"' "$config_file") 
  local port=$(mise exec -- yq '.port // ""' "$config_file")
  local install_cmd=$(mise exec -- yq '.install // ""' "$config_file")
  local start_cmd=$(mise exec -- yq '.start' "$config_file")
  
  if [[ "$start_cmd" == "null" || -z "$start_cmd" ]]; then
    print_error "No 'start' command found in $config_file"
    return 1
  fi
  
  # Build command sequence
  local full_cmd=""
  
  # Add install command if present
  if [[ -n "$install_cmd" && "$install_cmd" != "null" ]]; then
    print_info "Installing dependencies for $language/$framework..."
    full_cmd="echo 'Installing dependencies...' && $install_cmd && "
  fi
  
  # Add start command with announcement
  if [[ -n "$port" && "$port" != "null" ]]; then
    full_cmd="${full_cmd}echo 'Starting $language/$framework demo...' && echo 'Application will be available at: http://localhost:$port' && echo '' && $start_cmd"
  else
    full_cmd="${full_cmd}echo 'Starting $language/$framework demo...' && echo '' && $start_cmd"
  fi
  
  echo "$full_cmd"
}

# Start a demo application
start_app() {
  local language="$1"
  local framework="$2"

  if [[ -z "$language" || -z "$framework" ]]; then
    print_error "Usage: demo.sh start <language> <framework>"
    return 1
  fi

  local session_name=$(get_session_name "$language" "$framework")
  local app_dir="$language/$framework"

  # Prepare the demo environment
  if ! prepare_demo_environment "$language" "$framework"; then
    return 1
  fi

  # Check if session already exists
  if tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
    local config_file="$app_dir/demo.yaml"
    local port=$(mise exec -- yq '.port // ""' "$config_file")
    print_warning "Demo $language/$framework is already running in session: $session_name"
    if [[ -n "$port" && "$port" != "null" ]]; then
      print_info "Application available at: http://localhost:$port"
    fi
    return 0
  fi

  # Get the port info for display
  local config_file="$app_dir/demo.yaml"
  local port=$(mise exec -- yq '.port // ""' "$config_file")
  
  print_info "Starting $language/$framework demo..."
  
  # Get the command sequence from the YAML config
  local demo_command=$(execute_demo_config "$app_dir")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Start tmux session in the demo directory with mise environment and execute the command
  tmux -L "$TMUX_SERVER" new-session -d -s "$session_name" -c "$(pwd)/$app_dir" "mise exec -- bash -c \"$demo_command\""

  # Wait a moment and check if the session is still running
  sleep 2
  if tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
    print_success "Started $language/$framework demo in tmux session: $session_name"
    if [[ -n "$port" && "$port" != "null" ]]; then
      print_info "Application available at: http://localhost:$port"
    fi
    print_info "View logs: revenue demo logs $language $framework"
    print_info "Attach: revenue demo attach $language $framework"
  else
    print_error "Failed to start $language/$framework demo"
    return 1
  fi
}

# Start all demo applications
start_all() {
  local apps=($(discover_apps))
  
  if [[ ${#apps[@]} -eq 0 ]]; then
    print_warning "No demo applications found"
    return 0
  fi
  
  print_info "Starting all demo applications..."
  local started=0
  local failed=0
  
  for app in "${apps[@]}"; do
    IFS=':' read -r language framework <<< "$app"
    
    if start_app "$language" "$framework"; then
      ((started++))
    else
      ((failed++))
    fi
  done
  
  print_success "Started $started demo applications"
  if [[ $failed -gt 0 ]]; then
    print_warning "$failed demo applications failed to start"
  fi
}

# Stop a demo application
stop_app() {
  local language="$1"
  local framework="$2"

  if [[ -z "$language" || -z "$framework" ]]; then
    print_error "Usage: demo.sh stop <language> <framework>"
    return 1
  fi

  local session_name=$(get_session_name "$language" "$framework")

  if tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
    tmux -L "$TMUX_SERVER" kill-session -t "$session_name"
    print_success "Stopped $language/$framework demo"
  else
    print_warning "$language/$framework demo is not running"
  fi
}

# Stop all demo applications
stop_all() {
  local sessions=$(tmux -L "$TMUX_SERVER" list-sessions -F "#{session_name}" 2>/dev/null || true)

  if [[ -z "$sessions" ]]; then
    print_info "No demo applications are currently running"
    return 0
  fi

  print_info "Stopping all demo applications..."
  while IFS= read -r session; do
    if [[ -n "$session" ]]; then
      tmux -L "$TMUX_SERVER" kill-session -t "$session"
      print_success "Stopped session: $session"
    fi
  done <<<"$sessions"
}

# Clean the demo directory
clean_demos() {
  local confirm_flag="$1"

  if [[ "$confirm_flag" != "--confirm" ]]; then
    print_error "This will reset all changes in the demo directory!"
    print_error "Use: demo.sh clean --confirm"
    return 1
  fi

  print_warning "Cleaning demo directory - this will reset all local changes!"

  # Stop all running demos first
  stop_all

  # Reset git state
  git reset --hard HEAD
  git clean -fd

  print_success "Demo directory cleaned and reset"
}

# List all available demos
list_demos() {
  print_info "Available demo applications:"
  discover_apps | while IFS=':' read -r language framework; do
    local session_name=$(get_session_name "$language" "$framework")
    local status="stopped"
    if tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
      status="running"
    fi
    printf "  %-20s %s\n" "$language/$framework" "($status)"
  done
}

# View logs from a demo application
logs_app() {
  local language="$1"
  local framework="$2"

  if [[ -z "$language" || -z "$framework" ]]; then
    print_error "Usage: demo.sh logs <language> <framework>"
    return 1
  fi

  local session_name=$(get_session_name "$language" "$framework")

  if ! tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
    print_error "$language/$framework demo is not running"
    return 1
  fi

  print_info "Current output from $language/$framework demo:"
  echo ""
  
  # Capture and display the current pane content
  tmux -L "$TMUX_SERVER" capture-pane -t "$session_name" -p
  
  echo ""
  print_info "Use 'revenue demo attach $language $framework' to interact with the session"
}

# Attach to a demo application
attach_app() {
  local language="$1"
  local framework="$2"

  if [[ -z "$language" || -z "$framework" ]]; then
    print_error "Usage: demo.sh attach <language> <framework>"
    return 1
  fi

  local session_name=$(get_session_name "$language" "$framework")

  if ! tmux -L "$TMUX_SERVER" has-session -t "$session_name" 2>/dev/null; then
    print_error "$language/$framework demo is not running"
    return 1
  fi

  print_info "Attaching to $language/$framework demo session..."
  tmux -L "$TMUX_SERVER" attach -t "$session_name"
}

# List running demos
list_running() {
  local sessions=$(tmux -L "$TMUX_SERVER" list-sessions -F "#{session_name}" 2>/dev/null || true)

  if [[ -z "$sessions" ]]; then
    print_info "No demo applications are currently running"
    return 0
  fi

  print_info "Running demo applications:"
  while IFS= read -r session; do
    if [[ -n "$session" ]]; then
      printf "  %-20s %s\n" "$session" "(running)"
    fi
  done <<<"$sessions"
}

# Show usage information
show_usage() {
  echo "Demo Application Manager"
  echo ""
  echo "Usage:"
  echo "  demo.sh start <language> <framework>   Start a demo application"
  echo "  demo.sh start all                      Start all demo applications"
  echo "  demo.sh stop <language> <framework>    Stop a demo application"
  echo "  demo.sh stop all                       Stop all demo applications"
  echo "  demo.sh logs <language> <framework>    View logs from a running demo"
  echo "  demo.sh attach <language> <framework>  Attach to a running demo session"
  echo "  demo.sh list                           List all available demos"
  echo "  demo.sh running                        List running demos"
  echo "  demo.sh clean --confirm                Reset demo directory"
  echo "  demo.sh help                           Show this help"
  echo ""
  echo "Examples:"
  echo "  demo.sh start python flask"
  echo "  demo.sh start all"
  echo "  demo.sh stop javascript react"
  echo "  demo.sh stop all"
  echo "  demo.sh logs python flask"
  echo "  demo.sh attach python flask"
  echo ""
}

# Main script logic
main() {
  check_tmux

  local command="$1"

  case "$command" in
  start)
    if [[ "$2" == "all" ]]; then
      start_all
    else
      start_app "$2" "$3"
    fi
    ;;
  stop)
    if [[ "$2" == "all" ]]; then
      stop_all
    else
      stop_app "$2" "$3"
    fi
    ;;
  logs)
    logs_app "$2" "$3"
    ;;
  attach)
    attach_app "$2" "$3"
    ;;
  list)
    list_demos
    ;;
  running)
    list_running
    ;;
  clean)
    clean_demos "$2"
    ;;
  help | --help | -h)
    show_usage
    ;;
  "")
    show_usage
    exit 1
    ;;
  *)
    print_error "Unknown command: $command"
    show_usage
    exit 1
    ;;
  esac
}

main "$@"

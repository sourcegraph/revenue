# Demo Application Manager

The demo application manager allows running multiple language/framework demos in
isolated tmux sessions with proper tool management.

## Directory Structure

The script expects demo applications to be organized as:

```
amp_demos/
├── demo.sh
├── <language>/
│   └── <framework>/
│       ├── start_demo.sh    # Required entry point
│       ├── .mise.toml       # Optional: tool requirements
│       └── ...              # Your demo files
```

Only directories containing `start_demo.sh` are recognized as valid demos.

## Usage

You can use the demo manager directly or through the main setup script:

### Via setup.sh (recommended)

```bash
# From the repository root
./setup.sh demo start <language> <framework>
./setup.sh demo stop <language> <framework>
./setup.sh demo list
```

### Direct usage

```bash
# From amp_demos directory
cd amp_demos
./demo.sh start <language> <framework>
```

### Start a Demo

```bash
./demo.sh start <language> <framework>
```

### Stop a Demo

```bash
./demo.sh stop <language> <framework>
./demo.sh stop all  # Stop all running demos
```

### List Demos

```bash
./demo.sh list     # Show all available demos and their status
./demo.sh running  # Show only running demos
```

### Clean Environment

```bash
./demo.sh clean --confirm  # Reset git state and stop all demos
```

## How It Works

1. **Discovery**: Scans subdirectories for `start_demo.sh` files
2. **Environment**: Runs `mise install` in each demo directory (if available)
3. **Session Management**: Creates isolated tmux sessions named `<language>-<framework>`
4. **Execution**: Runs `start_demo.sh` within the mise environment

## Examples

```bash
# Start a Python Flask demo
./demo.sh start python flask

# Attach to running demo
tmux -L revenue-demo attach -t python-flask

# Stop all demos
./demo.sh stop all

# List available demos
./demo.sh list
```

## Tmux Session Management

All demos run in a shared tmux server named `revenue-demo`. Sessions are automatically named using the pattern `<language>-<framework>`.

To manually attach to a running demo:

```bash
tmux -L revenue-demo attach -t <session-name>
```

# Demo Application Manager

The demo application manager allows running multiple language/framework demos in
isolated tmux sessions using configuration files.

## Directory Structure

The script expects demo applications to be organized as:

```
amp_demos/
├── demo
├── <language>/
│   └── <framework>/
│       ├── demo.yaml        # Required configuration file
│       ├── .mise.toml       # Optional: tool requirements
│       └── ...              # Your demo files
```

Only directories containing `demo.yaml` are recognized as valid demos.

## Configuration Format

Each demo requires a `demo.yaml` configuration file:

```yaml
language: javascript    # Language identifier
framework: react       # Framework identifier  
port: 3000            # Application port (for URL display)
install: pnpm install --silent  # Optional: dependency installation command
start: pnpm start     # Required: command to start the application
```

The `install` field is optional and runs before the `start` command. The `port` field is used to display the application URL.

## Usage

You can use the demo manager directly or through the main setup script:

### Via revenue command (recommended)

```bash
# From anywhere (after running ./setup.sh init)
revenue demo start <language> <framework>
revenue demo stop <language> <framework>  
revenue demo list
```

### Via revenue script

```bash
# From the repository root
./revenue demo start <language> <framework>
./revenue demo stop <language> <framework>
./revenue demo list
```

### Direct usage

```bash
# From amp_demos directory
cd amp_demos
./demo start <language> <framework>
```

### Start a Demo

```bash
./demo start <language> <framework>   # Start a specific demo
./demo start all                      # Start all available demos
```

### Stop a Demo

```bash
./demo stop <language> <framework>    # Stop a specific demo
./demo stop all                       # Stop all running demos
```

### View and Interact with Demos

```bash
./demo logs <language> <framework>    # View current logs from a running demo
./demo attach <language> <framework>  # Attach to a running demo session
```

### List Demos

```bash
./demo list                           # Show all available demos and their status
./demo running                        # Show only running demos
```

### Clean Environment

```bash
./demo clean --confirm                # Reset git state and stop all demos
```

## How It Works

1. **Discovery**: Scans subdirectories for `demo.yaml` configuration files
2. **Environment**: Runs `mise install` in each demo directory (if available)
3. **Config Parsing**: Reads the demo configuration using `yq`
4. **Session Management**: Creates isolated tmux sessions named `<language>-<framework>`
5. **Execution**: Runs install and start commands within the mise environment

## Examples

```bash
# Start a Python Flask demo
./demo start python flask

# Start all available demos
./demo start all

# View logs from a running demo
./demo logs python flask

# Attach to running demo
./demo attach python flask

# Stop all demos
./demo stop all

# List available demos
./demo list
```

## Tmux Session Management

All demos run in a shared tmux server named `revenue-demo`. Sessions are automatically named using the pattern `<language>-<framework>`.

To manually attach to a running demo:

```bash
tmux -L revenue-demo attach -t <session-name>
```

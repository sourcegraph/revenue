# Demo Application Manager

The demo application manager allows running multiple language/framework demos
using [Overmind](https://github.com/DarthSim/overmind)

## Directory Structure

The script expects demo applications to be organized as:

```text
amp_demos/
├── demo                 # Overmind-based demo manager
├── <language>/
│   └── <framework>/
│       ├── Procfile     # Required: Overmind process definition
│       ├── .env         # Required: Environment variables (PORT, etc.)
│       ├── .mise.toml   # Optional: tool requirements
│       └── ...          # Your demo files
```

Only directories containing `Procfile` are recognized as valid demos.

## Configuration Format

Each demo requires a `Procfile` and `.env` file:

### [Procfile](https://devcenter.heroku.com/articles/procfile) (standard Procfile format)

```Procfile
setup: pnpm install --silent
web: pnpm start
```

#### .env (environment variables)

```env
PORT=3000
LANGUAGE=javascript
FRAMEWORK=react
```

The `setup` process is optional and runs before starting the `web` process. The
`PORT` variable is used to display the application URL.

## Usage

You can use the demo manager directly or through the main setup script:

### Via revenue command (recommended)

```bash
# From anywhere (after running ./install.sh)
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

### Restart a Demo

```bash
./demo restart <language> <framework> # Restart a specific demo
./demo restart all                     # Restart all running demos
```

### View and Interact with Demos

```bash
./demo logs <language> <framework>    # View logs from a running demo (Ctrl+C to exit)
./demo connect <language> <framework> # Connect to a running demo session
```

### List Demos

```bash
./demo list                           # Show all available demos and their status
./demo running                        # Show only running demos
```

### Clean Environment

```bash
./demo clean --confirm                # Force cleanup all processes and sockets
./demo reset --confirm                # Reset to clean git state (clean + git restore)
./demo help                           # Show usage help
```

## How It Works

1. **Discovery**: Scans subdirectories for `Procfile` configuration files
2. **Environment**: Runs `mise install` in each demo directory (if available)
3. **Config Parsing**: Uses standard Procfile format and `.env` files
4. **Process Management**: Uses Overmind to manage processes with tmux sessions
named `<language>-<framework>`
5. **Execution**: Runs setup and web processes as defined in Procfile

## Examples

```bash
# Start a Python Flask demo
./demo start python flask

# Start all available demos
./demo start all

# Restart a specific demo
./demo restart python flask

# Restart all running demos
./demo restart all

# View logs from a running demo
./demo logs python flask

# Connect to running demo
./demo connect python flask

# Stop all demos
./demo stop all

# List available demos
./demo list

# Show only running demos
./demo running

# Force cleanup all processes
./demo clean --confirm

# Reset to clean git state
./demo reset --confirm
```

## Process Management

Overmind manages all demos using tmux sessions named using the pattern
`<language>-<framework>`. Each demo runs its processes as defined in the Procfile.

To manually connect to a running demo process:

```bash
cd <language>/<framework>
overmind connect web -s <language>-<framework>

# Or using tmux directly
tmux attach -t <language>-<framework>


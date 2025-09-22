# AGENTS.md

## Build/Test/Lint Commands

Demo management:

- `./demo start <language> <framework>` - Start a specific demo (e.g., `./demo start python flask`)
- `./demo stop <language> <framework>` - Stop a demo
- `./demo start all` / `./demo stop all` - Start/stop all demos
- `./demo list` - List available demos and status
- `./demo logs <language> <framework>` - View logs from running demo
- `./demo connect <language> <framework>` - Connect to running demo session
- `./demo open <language> <framework>` - Open a running demo in browser
- `./demo open all` - Open all running demos in browser

Framework-specific commands:

- JavaScript/React: `pnpm install` (setup), `pnpm start` (dev server), `pnpm build` (production build)
- Python/Flask: `mise run dev` (runs Flask dev server), pytest tests via dev dependencies
- Java/Spring Boot & Ktor: `./gradlew bootRun` (start), `./gradlew build` (build)

## Architecture

Multi-language demo collection using Overmind process manager:

- `amp_demos/` - Root demo directory containing language-specific subdirectories
- `<language>/<framework>/` - Individual demo applications (react, flask, spring-boot, ktor, svelte)
- Each demo requires: `Procfile` (process definition), `.env` (PORT, LANGUAGE, FRAMEWORK variables)
- Tool management via mise (`.mise.toml` files for Node, Python, Java toolchains)
- Process orchestration: Overmind with tmux sessions named `<language>-<framework>`

## Code Style

- Shell scripts: bash with `set -e`, colored output helpers (`print_success`, `print_error`)
- Function naming: snake_case for bash functions
- Error handling: fail fast with clear error messages, graceful degradation where appropriate
- Configuration: Standard formats (Procfile, .env, package.json, pyproject.toml, build.gradle)

# Sourcegraph Revenue Team

This repository serves as both a workspace setup tool and demo environment for
Revenue team members.

## Getting Started

### Install Xcode Command Line Tools

Open a terminal and run the following command:

`xcode-select --install`

### Login to GitHub

- Go to <https://github.com/sourcegraph/revenue> and authenticate if you haven't
already.
- If you can't access the repository, ensure that you've been added to the
Sourcegraph GitHub organization. You can ask in [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75)

### Clone this repository

Open a terminal if not already opened and run the following commands:

```bash
git clone https://github.com/sourcegraph/revenue.git ~/revenue
```

This will clone the repository to `/Users/<your_username>/revenue`

To access the repository in the future, run `cd ~/revenue`

### Setup your workstation

To set up your workstation, open a terminal or re-use the existing session from
the previous step and run the following commands:

```bash
cd ~/revenue
./revenue init
```

Once `init` has been run once, a global `revenue` command will be added to your system:

```bash
revenue init      # Initialize workstation  
revenue update    # Update existing tools
revenue demo      # Manage demo applications
```

### Authenticate the GitHub CLI

This will configure the gh CLI to use HTTPS authentication and allow the `gh`
CLI tool to access any repository you have access to.

```bash
❯ gh auth login
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: ABCD-1234
Press Enter to open https://github.com/login/device in your browser...
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as trly
```

### Run Demo Applications

This repository includes a demo manager for running language/framework demonstrations:

```bash
# Start a demo application
revenue demo start <language> <framework>

# Start all available demos
revenue demo start all

# Stop a specific demo
revenue demo stop <language> <framework>

# Stop all demos
revenue demo stop all

# List available demos
revenue demo list

# List running demos
revenue demo running

# View logs from a running demo
revenue demo logs <language> <framework>

# Attach to a running demo session
revenue demo attach <language> <framework>

# Clean and reset demo directory
revenue demo clean --confirm
```

See the [Demo Application Manager](/amp_demos/README.md) README for complete
details and examples.

## Revenue Team Application Manifest

This list is everything that will be installed on your workstation when running
`revenue init`. All dependencies are managed via [Brewfile](/Brewfile).

To update existing installed tools, run `revenue update`

### Editors and IDEs

#### Visual Studio Code

VS Code is a free code editor, which runs on the macOS, Linux, and Windows
operating systems.

**Extensions**:
Several VS Code extensions are automatically installed for you when you run
`revenue init`

- Amp
- Java Support
- Python Support

#### JetBrains Toolbox App

The JetBrains Toolbox App allows you to easily install and manage JetBrains
products like:

- IntelliJ IDEA Community
  - If you need a license for IntelliJ IDEA Ultimate, see [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75)
- PyCharm
- Fleet

### Languages and Runtimes

#### Eclipse Temurin - Java Runtime/SDK

OpenJDK Based: Eclipse Temurin offers high-performance, cross-platform,
open source Java™

[Learn more](https://adoptium.net/temurin)

#### Python

Python is a programming language that lets you work quickly
and integrate systems more effectively.

[Learn more](https://www.python.org/doc/)

### Development Tools

#### git

Git is a free and open source distributed version control system

#### Amp CLI

Command-line interface for Amp AI coding assistant

#### mise

mise allows you to easily install additional developer tools as well a manage
multiple versions of tools globally or,specific to individual projects.

```bash
revenue on  main [!?] took 12s
❯ mise list
Tool           Version            Source  Requested
bun            1.2.22
caddy          2.9.1
go             1.20
go             1.25.0
golangci-lint  2.4.0
gotestsum      1.12.3
helm           3.11.0
hugo-extended  0.148.2
java           temurin-11.0.28+6
kustomize      4.5.7
node           20.19.4
node           22.18.0
node           24.6.0
pnpm           10.13.1
pnpm           10.15.0
skaffold       2.13.2
task           3.44.1
terraform      1.5.6
terraform      1.12.2
```

### Misc. Applications and Tools

#### Ghostty

[Ghostty](https://ghostty.org/docs) is a fast, feature-rich, and cross-platform
terminal emulator that uses platform-native UI and GPU acceleration.

#### tree

list contents of directories in a tree-like format.

<https://linux.die.net/man/1>

#### jq

[jq](https://github.com/jqlang/jq) is a lightweight and flexible command-line
JSON processor akin to sed,awk,grep, and friends for JSON data

#### tmux

[tmux](https://github.com/tmux/tmux/wiki) is tmux is a terminal multiplexer. It
lets you switch easily between several programs in one terminal, detach them
(they keep running in the background) and reattach them to a different terminal.

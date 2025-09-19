# Revenue Team Application Manifest

This list is everything that will be installed on your workstation when running
the installer. All dependencies are managed via [Brewfile](/Brewfile).

To update existing installed tools, run `revenue update`

## Editors and IDEs

### Visual Studio Code

VS Code is a free code editor, which runs on the macOS, Linux, and Windows
operating systems.

**Extensions**:
Several VS Code extensions are automatically installed for you when you run
`revenue init`

- Amp
- Java Support
- Python Support

### JetBrains Toolbox App

The JetBrains Toolbox App allows you to easily install and manage JetBrains
products like:

- IntelliJ IDEA Community
  - If you need a license for IntelliJ IDEA Ultimate, see [#ask-tech-ops](https://sourcegraph.slack.com/archives/C01CSS3TC75)
- PyCharm
- Fleet

## Languages and Runtimes

### Eclipse Temurin - Java Runtime/SDK

OpenJDK Based: Eclipse Temurin offers high-performance, cross-platform,
open source Java™

[Learn more](https://adoptium.net/temurin)

### Python

Python is a programming language that lets you work quickly
and integrate systems more effectively.

[Learn more](https://www.python.org/doc/)

## Development Tools

### git

Git is a free and open source distributed version control system

### Amp CLI

Command-line interface for Amp AI coding assistant

### mise

mise allows you to easily install additional developer tools as well a manage
multiple versions of tools globally or,specific to individual projects.

```bash
revenue on  main [!?] took 12s
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

## Misc. Applications and Tools

### Ghostty

[Ghostty](https://ghostty.org/docs) is a fast, feature-rich, and cross-platform
terminal emulator that uses platform-native UI and GPU acceleration.

### tree

list contents of directories in a tree-like format.

<https://linux.die.net/man/1>

### jq

[jq](https://github.com/jqlang/jq) is a lightweight and flexible command-line
JSON processor akin to sed,awk,grep, and friends for JSON data

### tmux

[tmux](https://github.com/tmux/tmux/wiki) is tmux is a terminal multiplexer. It
lets you switch easily between several programs in one terminal, detach them
(they keep running in the background) and reattach them to a different terminal.

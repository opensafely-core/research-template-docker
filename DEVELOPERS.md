# Notes for developers

## System requirements

### just

```sh
# macOS
brew install just

# Linux
# Install from https://github.com/casey/just/releases

# Add completion for your shell. E.g. for bash:
source <(just --completions bash)

# Show all available commands
just #  shortcut for just --list
```

## Build instructions

Run `just build` to build the Docker image.

## Local vscode testing

Simplest way to test is to clone the research-template, which will have the
latest devcontainer set up.

```
git clone https://github.com/opensafely/research-template
```

You will then need to edit its .devcontainer/devcontainer.json to use just
"research-template", rather than the fully qualified ghcr.io/... name.  This
will now use your locally build image.

You can then run `code .` in that directory, and then Ctrl-Shift-P, type
"rebuild", and select "Rebuild With Cache and Open in Container" This will
ensure your devconatainer will use your local image changes.

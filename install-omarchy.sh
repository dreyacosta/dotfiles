#!/bin/bash

set -euo pipefail

export PATH="./bin:$HOME/.local/bin:$PATH"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BIN_DIR="$SCRIPT_DIR/bin"

# Add bin directory to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  export PATH="$BIN_DIR:$PATH"
fi

main() {
  local -r files=(
    gitconfig
    gitignore
    ideavimrc
    tmux.conf
    cspell.json
    omarchy/bashrc
  )

  local -r config_dirs=(
    alacritty
    nvim
    mise
    tmux-sessionizer
    starship.toml
    hypr
    ghostty
  )

  local -r etc_dirs=(
    keyd
  )

  dotfiles-install "omarchy" --dotfiles "${files[@]}" --config-dirs "${config_dirs[@]}" --etc-dirs "${etc_dirs[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

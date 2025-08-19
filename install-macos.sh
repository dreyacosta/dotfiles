#!/bin/bash

set -euo pipefail

export PATH="./bin:$HOME/.local/bin:$PATH"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$SCRIPT_DIR/lib"

# Add lib directory to PATH if not already there
if [[ ":$PATH:" != *":$LIB_DIR:"* ]]; then
  export PATH="$LIB_DIR:$PATH"
fi

main() {
  local -r files=(
    gitconfig
    gitignore
    ideavimrc
    tmux.conf
    macos/zshrc
  )

  local -r config_dirs=(
    nvim
    tmux-sessionizer
    starship.toml
    karabiner
  )

  local -r etc_dirs=(
    # Add etc directories here when needed
    # Example: dhcp/dhcpd.conf
  )

  dotfiles-install "macOS" --dotfiles "${files[@]}" --config-dirs "${config_dirs[@]}" --etc-dirs "${etc_dirs[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

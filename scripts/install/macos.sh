#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

source "$REPO_DIR/scripts/install/common.sh"

platform_links=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/macos/zshrc|$HOME/.zshrc"
  "config/karabiner/karabiner.json|$CONFIG_HOME/karabiner/karabiner.json"
  "config/mise/macos.toml|$CONFIG_HOME/mise/config.toml"
  "config/ghostty/config|$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$HOME/Library/Application Support/com.mitchellh.ghostty/themes/Tokyonight Night"
  "config/git/macos|$CONFIG_HOME/git/config"
)

etc_links=()
etc_copies=()

main() {
  install_dotfiles "macos" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

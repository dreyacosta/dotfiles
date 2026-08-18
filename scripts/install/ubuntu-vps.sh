#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

source "$REPO_DIR/scripts/install/common.sh"

platform_links=(
  "shell/platform/ubuntu-vps/bashrc|$HOME/.bashrc"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/git/linux|$CONFIG_HOME/git/config"
)

etc_links=()
etc_copies=()

main() {
  install_dotfiles "ubuntu-vps" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

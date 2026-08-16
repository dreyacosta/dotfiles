#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

source "$REPO_DIR/scripts/install/common.sh"

platform_links=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/omarchy/bashrc|$HOME/.bashrc"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/hypr/bindings.lua|$CONFIG_HOME/hypr/bindings.lua"
  "config/hypr/input.lua|$CONFIG_HOME/hypr/input.lua"
  "config/ghostty/config|$CONFIG_HOME/ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$CONFIG_HOME/ghostty/themes/Tokyonight Night"
  "config/git/linux|$CONFIG_HOME/git/config"
)

platform_legacy_links=(
  "$CONFIG_HOME/mise|config/mise"
  "$CONFIG_HOME/hypr|config/hypr"
  "$CONFIG_HOME/ghostty|config/ghostty"
)

etc_links=(
  "etc/keyd/default.conf|/etc/keyd/default.conf"
)

etc_legacy_links=(
  "/etc/keyd|etc/keyd"
)

main() {
  install_dotfiles "omarchy" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

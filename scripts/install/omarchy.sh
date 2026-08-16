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
  "config/herdr/config.toml|$CONFIG_HOME/herdr/config.toml"
  "config/hypr/bindings.lua|$CONFIG_HOME/hypr/bindings.lua"
  "config/hypr/input.lua|$CONFIG_HOME/hypr/input.lua"
  "config/ghostty/config|$CONFIG_HOME/ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$CONFIG_HOME/ghostty/themes/Tokyonight Night"
  "config/git/linux|$CONFIG_HOME/git/config"
)

etc_links=(
  "etc/keyd/default.conf|/etc/keyd/default.conf"
)

main() {
  local dry_run=false
  local arg

  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && dry_run=true
  done

  install_dotfiles "omarchy" "$@"

  if [[ "$dry_run" == false ]]; then
    sudo keyd reload
    dotfiles-log "Reloaded keyd configuration"

    if herdr status server >/dev/null 2>&1; then
      herdr server reload-config
      dotfiles-log "Reloaded Herdr configuration"
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

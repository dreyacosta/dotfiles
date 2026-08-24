#!/bin/bash

source "$DOTFILES_REPO_DIR/dependencies/common.sh"

require_omarchy_baseline() {
  local -r commands=(docker git mise tmux)
  local command_name
  for command_name in "${commands[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || {
      dotfiles_log "Missing Omarchy baseline command: $command_name"
      return 1
    }
  done
}

install_dependencies() {
  require_omarchy_baseline
  omarchy pkg add base-devel curl file git herdr jq keyd procps-ng
  sudo systemctl enable --now keyd
  install_linux_homebrew
  activate_linux_homebrew
  install_mise_tools
  HERDR_EXECUTABLE="${DOTFILES_OMARCHY_HERDR:-/usr/bin/herdr}" install_herdr_plugins
  install_tmux_sessionizer
}

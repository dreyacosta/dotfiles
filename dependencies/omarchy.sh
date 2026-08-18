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
  omarchy pkg add keyd
  sudo systemctl enable --now keyd
  omarchy pkg add base-devel procps-ng curl file git
  install_linux_homebrew
  activate_linux_homebrew
  install_linux_mise_tools
  install_tmux_sessionizer
}

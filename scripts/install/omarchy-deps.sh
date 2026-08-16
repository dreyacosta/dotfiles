#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

require_omarchy_baseline() {
  local -r commands=(docker git mise tmux)
  local command

  for command in "${commands[@]}"; do
    if ! command -v "$command" >/dev/null 2>&1; then
      dotfiles-log "Missing Omarchy baseline command: $command"
      exit 1
    fi
  done
}

install_keyd() {
  omarchy pkg add keyd
  sudo systemctl enable --now keyd
}

install_homebrew() {
  omarchy pkg add base-devel procps-ng curl file git

  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv bash)"
  else
    dotfiles-log "Homebrew installation was not found"
    exit 1
  fi
}

install_mise_tools() {
  MISE_CONFIG_FILE="$REPO_DIR/config/mise/config.toml" mise install
  MISE_CONFIG_FILE="$REPO_DIR/config/mise/config.toml" mise exec -- \
    npm install --global @vlabo/cspell-lsp cspell
}

install_tmux_sessionizer() {
  local -r install_dir="$HOME/.local/bin"
  local -r repo_dir="$install_dir/tmux-sessionizer"

  mkdir -p "$install_dir"

  if [[ -x "$repo_dir/tmux-sessionizer" ]]; then
    dotfiles-log "tmux-sessionizer already installed: $repo_dir"
    return
  fi

  git clone https://github.com/ThePrimeagen/tmux-sessionizer "$repo_dir"
  chmod +x "$repo_dir/tmux-sessionizer"
}

main() {
  require_omarchy_baseline
  install_keyd
  install_homebrew
  install_mise_tools
  install_tmux_sessionizer
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

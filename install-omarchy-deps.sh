#!/bin/bash

set -euo pipefail

export PATH="./bin:$HOME/.local/bin:$PATH"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BIN_DIR="$SCRIPT_DIR/bin"

# Add bin directory to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  export PATH="$BIN_DIR:$PATH"
fi

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_brew_packages() {
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  else
    eval "$(brew shellenv bash)"
  fi

  brew install gcc
}

install_tmux_sessionizer() {
  local -r install_dir="$HOME/.local/bin"
  local -r repo_dir="$install_dir/tmux-sessionizer"

  mkdir -p "$install_dir"

  if [[ -d "$repo_dir" ]]; then
    dotfiles-log "tmux-sessionizer already installed: $repo_dir"
    return
  fi

  git clone https://github.com/ThePrimeagen/tmux-sessionizer "$repo_dir"
  chmod +x "$repo_dir/tmux-sessionizer"
}

main() {
  install_homebrew
  install_brew_packages
  install_tmux_sessionizer
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
readonly NVM_VERSION="v0.40.6"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

require_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    dotfiles-log "Install the Xcode Command Line Tools with: xcode-select --install"
    exit 1
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

activate_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    dotfiles-log "Homebrew installation was not found"
    exit 1
  fi
}

install_brew_packages() {
  local -r packages=(
    bat
    eza
    fd
    fzf
    gh
    gum
    lazygit
    mise
    neovim
    ripgrep
    starship
    tmux
    zoxide
    zsh-autosuggestions
  )
  local -r casks=(
    font-jetbrains-mono-nerd-font
    docker
    ghostty
    karabiner-elements
  )

  brew install "${packages[@]}"
  brew install --cask "${casks[@]}"
}

install_nvm() {
  if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
    export NVM_DIR="$XDG_CONFIG_HOME/nvm"
  else
    export NVM_DIR="$HOME/.nvm"
  fi

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    PROFILE=/dev/null /bin/bash -c "$(curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh")"
  fi

  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  npm install --global @vlabo/cspell-lsp cspell
}

install_mise_tools() {
  MISE_CONFIG_FILE="$REPO_DIR/config/mise/macos.toml" mise install
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
  require_command_line_tools
  install_homebrew
  activate_homebrew
  install_brew_packages
  install_mise_tools
  install_nvm
  install_tmux_sessionizer
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#!/bin/bash

readonly NVM_INSTALLER_VERSION="v0.40.6"
source "$DOTFILES_REPO_DIR/dependencies/common.sh"

require_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    dotfiles_log "Install the Xcode Command Line Tools with: xcode-select --install"
    return 1
  fi
}

install_macos_homebrew() {
  command -v brew >/dev/null 2>&1 && return
  /usr/bin/env -u NONINTERACTIVE /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

activate_macos_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    dotfiles_log "Homebrew installation was not found"
    return 1
  fi
}

install_nvm() {
  export NVM_DIR="${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/nvm}"
  : "${NVM_DIR:=$HOME/.nvm}"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    PROFILE=/dev/null /bin/bash -c \
      "$(curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_INSTALLER_VERSION/install.sh")"
  fi
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
}

install_nvm_npm_packages() {
  # Global npm packages belong to one Node version; rerunning dependencies
  # after an LTS upgrade reinstalls them for the new default.
  npm install -g cspell @vlabo/cspell-lsp
}

install_claude_code() {
  # Exception: the native installer keeps Claude Code self-updating.
  if [[ -x "$HOME/.local/bin/claude" ]]; then
    dotfiles_log "Claude Code already installed: $HOME/.local/bin/claude"
    return
  fi
  /bin/bash -c "$(curl -fsSL https://claude.ai/install.sh)"
}

install_dependencies() {
  require_command_line_tools
  install_macos_homebrew
  activate_macos_homebrew
  install_common_brew_packages
  install_nvm
  install_nvm_npm_packages
  install_claude_code
  brew install gh herdr jq
  brew install zsh-autosuggestions
  install_tmux_sessionizer
  brew install --cask font-jetbrains-mono-nerd-font karabiner-elements
  brew install --cask peteonrails/voxtype/voxtype
}

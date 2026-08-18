#!/bin/bash

install_linux_homebrew() {
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

activate_linux_homebrew() {
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv bash)"
  else
    dotfiles_log "Homebrew installation was not found"
    return 1
  fi
}

install_common_brew_packages() {
  local -r packages=(bat eza fd fzf gh gum lazygit mise neovim ripgrep starship tmux zoxide)
  brew install "${packages[@]}"
}

install_tmux_sessionizer() {
  local -r install_dir="$HOME/.local/bin"
  local -r repo_dir="$install_dir/tmux-sessionizer"

  mkdir -p "$install_dir"
  if [[ -x "$repo_dir/tmux-sessionizer" ]]; then
    dotfiles_log "tmux-sessionizer already installed: $repo_dir"
    return
  fi
  git clone https://github.com/ThePrimeagen/tmux-sessionizer "$repo_dir"
  chmod +x "$repo_dir/tmux-sessionizer"
}

install_linux_mise_tools() {
  MISE_CONFIG_FILE="$DOTFILES_REPO_DIR/config/mise/config.toml" mise install
  MISE_CONFIG_FILE="$DOTFILES_REPO_DIR/config/mise/config.toml" mise exec -- \
    npm install --global @vlabo/cspell-lsp cspell
}

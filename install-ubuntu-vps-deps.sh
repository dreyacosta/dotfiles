#!/bin/bash

set -euo pipefail

export PATH="./bin:$HOME/.local/bin:$PATH"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BIN_DIR="$SCRIPT_DIR/bin"

# Add bin directory to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  export PATH="$BIN_DIR:$PATH"
fi

install_packages() {
  sudo apt update
  sudo apt install -y \
    build-essential \
    git \
    curl \
    bat \
    eza \
    zoxide \
    ripgrep \
    docker.io \
    docker-compose-plugin
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    dotfiles-log "lazygit already installed"
    return
  fi

  local -r lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
    grep -Po '"tag_name":\s*"v\K[^"]*')

  if [[ -z "$lazygit_version" ]]; then
    dotfiles-log "Failed to determine lazygit version"
    exit 1
  fi

  local -r tmp_dir="$(mktemp -d)"
  local -r archive_path="$tmp_dir/lazygit.tar.gz"

  curl -Lo "$archive_path" \
    "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"
  tar xf "$archive_path" -C "$tmp_dir" lazygit
  sudo install "$tmp_dir/lazygit" -D -t /usr/local/bin/
  rm -rf "$tmp_dir"
}

install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    dotfiles-log "neovim already installed"
    return
  fi

  local -r nvim_version=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" |
    grep -Po '"tag_name":\s*"v\K[^"]*')

  if [[ -z "$nvim_version" ]]; then
    dotfiles-log "Failed to determine neovim version"
    exit 1
  fi

  local -r tmp_dir="$(mktemp -d)"
  local -r archive_path="$tmp_dir/nvim.appimage"

  curl -Lo "$archive_path" \
    "https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.appimage"
  sudo install -m 0755 "$archive_path" /usr/local/bin/nvim
  rm -rf "$tmp_dir"
}

install_brew_packages() {
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  else
    eval "$(brew shellenv bash)"
  fi

  brew install gcc
  brew install tmux fzf mise gum
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

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    dotfiles-log "starship already installed"
    return
  fi

  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

enable_docker() {
  if groups "$USER" | grep -q "\bdocker\b"; then
    dotfiles-log "User already in docker group"
    return
  fi

  sudo usermod -aG docker "$USER"
  dotfiles-log "Added $USER to docker group; log out and back in to apply"
}

main() {
  install_packages
  install_homebrew
  install_brew_packages
  install_lazygit
  install_neovim
  install_tmux_sessionizer
  install_starship
  enable_docker
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

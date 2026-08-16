#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

install_apt_packages() {
  if dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -q 'ok installed'; then
    dotfiles-log "Docker CE already installed"
  else
    local -r conflicting_packages=(docker.io docker-compose docker-compose-v2 podman-docker containerd runc)
    sudo apt remove -y "${conflicting_packages[@]}" || true
  fi

  sudo apt update
  sudo apt install -y \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    procps \
    unzip

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  source /etc/os-release
  local -r architecture="$(dpkg --print-architecture)"
  local -r ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  if [[ -z "$ubuntu_codename" ]]; then
    dotfiles-log "Unable to determine the Ubuntu release codename"
    exit 1
  fi
  local -r docker_repo="Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $ubuntu_codename
Components: stable
Architectures: $architecture
Signed-By: /etc/apt/keyrings/docker.asc"
  printf '%s\n' "$docker_repo" | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null

  sudo apt update
  sudo apt install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

activate_homebrew() {
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  else
    eval "$(brew shellenv bash)"
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
  )

  brew install "${packages[@]}"
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

enable_docker() {
  local -r install_user="${SUDO_USER:-${USER:-$(id -un)}}"

  if groups "$install_user" | grep -q "\bdocker\b"; then
    dotfiles-log "User already in docker group"
    return
  fi

  sudo usermod -aG docker "$install_user"
  dotfiles-log "Added $install_user to docker group; log out and back in to apply"
}

main() {
  install_apt_packages
  install_homebrew
  activate_homebrew
  install_brew_packages
  install_mise_tools
  install_tmux_sessionizer
  enable_docker
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

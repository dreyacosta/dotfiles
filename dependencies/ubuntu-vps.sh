#!/bin/bash

source "$DOTFILES_REPO_DIR/dependencies/common.sh"

install_apt_packages() {
  if dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -q 'ok installed'; then
    dotfiles_log "Docker CE already installed"
  else
    local -r conflicting_packages=(docker.io docker-compose docker-compose-v2 podman-docker containerd runc)
    sudo apt remove -y "${conflicting_packages[@]}" || true
  fi

  sudo apt update
  sudo apt install -y build-essential ca-certificates curl file git procps unzip
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  source /etc/os-release
  local -r architecture="$(dpkg --print-architecture)"
  local -r ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  [[ -n "$ubuntu_codename" ]] || { dotfiles_log "Unable to determine the Ubuntu release codename"; return 1; }
  local -r docker_repo="Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $ubuntu_codename
Components: stable
Architectures: $architecture
Signed-By: /etc/apt/keyrings/docker.asc"
  printf '%s\n' "$docker_repo" | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
  sudo apt update
  sudo apt install -y containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin
}

enable_docker() {
  local -r install_user="${SUDO_USER:-${USER:-$(id -un)}}"
  if groups "$install_user" | grep -q "\bdocker\b"; then
    dotfiles_log "User already in docker group"
    return
  fi
  sudo usermod -aG docker "$install_user"
  dotfiles_log "Added $install_user to docker group; log out and back in to apply"
}

install_dependencies() {
  install_apt_packages
  install_linux_homebrew
  activate_linux_homebrew
  install_common_brew_packages
  install_linux_mise_tools
  install_tmux_sessionizer
  enable_docker
}

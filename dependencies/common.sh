#!/bin/bash

install_linux_homebrew() {
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

activate_linux_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv bash)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  else
    dotfiles_log "Homebrew installation was not found"
    return 1
  fi
}

install_common_brew_packages() {
  local -r packages=(bat eza fd fzf gum lazygit mise neovim ripgrep starship tmux zoxide)
  brew install "${packages[@]}"
}

run_herdr() {
  local -r herdr_executable="${HERDR_EXECUTABLE:-herdr}"

  MISE_CONFIG_FILE="$DOTFILES_REPO_DIR/config/mise/config.toml" mise exec -- "$herdr_executable" "$@"
}

herdr_plugin_is_current() {
  local -r plugin_id="$1"
  local -r commit="$2"

  run_herdr plugin list --json | jq -e \
    --arg plugin_id "$plugin_id" \
    --arg commit "$commit" \
    '.result.plugins[] | select(.plugin_id == $plugin_id and .enabled == true and .source.resolved_commit == $commit)' \
    >/dev/null
}

install_herdr_plugin() {
  local -r plugin_id="$1"
  local -r repository="$2"
  local -r commit="$3"

  if herdr_plugin_is_current "$plugin_id" "$commit"; then
    dotfiles_log "Herdr plugin already installed: $plugin_id@$commit"
    return
  fi
  run_herdr plugin install "$repository" --ref "$commit" --yes
}

install_herdr_plugins() {
  install_herdr_plugin \
    "sessionizer" \
    "andrewchng/herdr-sessionizer" \
    "e3cdab0d8886c9dc2c50a6e09da334d6508fae7b"
  install_herdr_plugin \
    "vim-herdr-navigation" \
    "paulbkim-dev/vim-herdr-navigation" \
    "820d48f5d9c9a7dece6a4bebfa3982ec30bbfbb7"
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

install_mise_tools() {
  MISE_CONFIG_FILE="$DOTFILES_REPO_DIR/config/mise/config.toml" mise install
}

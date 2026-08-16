#!/bin/bash

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

common_links=(
  ".|$HOME/.dotfiles"
  "home/cspell.json|$HOME/.cspell.json"
  "home/cspell-custom-words.txt|$HOME/.cspell-custom-words.txt"
  "config/nvim|$CONFIG_HOME/nvim"
  "config/tmux-sessionizer/tmux-sessionizer.conf|$CONFIG_HOME/tmux-sessionizer/tmux-sessionizer.conf"
  "config/starship.toml|$CONFIG_HOME/starship.toml"
  "config/git/common|$CONFIG_HOME/git/common"
  "config/git/ignore|$CONFIG_HOME/git/ignore"
  "config/tmux|$CONFIG_HOME/tmux"
  "config/tmux/tmux.conf|$HOME/.tmux.conf"
)

legacy_paths=(
  "$HOME/.gitconfig"
  "$HOME/.gitignore"
)

common_legacy_links=(
  "$CONFIG_HOME/git|config/git"
  "$CONFIG_HOME/tmux-sessionizer|config/tmux-sessionizer"
)

install_dotfiles() {
  local platform="$1"
  shift
  local -a options=("$@")

  export DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/dotfiles-wayback/$(date +%Y%m%d-%H%M%S)-$$}"

  dotfiles-install "$platform" "${options[@]}" --legacy "${legacy_paths[@]}" \
    --legacy-links "${common_legacy_links[@]}" "${platform_legacy_links[@]}" \
    --links "${common_links[@]}" "${platform_links[@]}"

  if [[ ${#etc_links[@]} -gt 0 ]]; then
    dotfiles-install-etc "${options[@]}" --legacy-links "${etc_legacy_links[@]}" --links "${etc_links[@]}"
  fi
}

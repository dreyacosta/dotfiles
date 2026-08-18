#!/bin/bash

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

common_links=(
  ".|$HOME/.dotfiles"
  "home/cspell.json|$HOME/.cspell.json"
  "home/cspell-custom-words.txt|$HOME/.cspell-custom-words.txt"
  "home/markdownlint.jsonc|$HOME/.markdownlint.jsonc"
  "config/nvim|$CONFIG_HOME/nvim"
  "config/tmux-sessionizer/tmux-sessionizer.conf|$CONFIG_HOME/tmux-sessionizer/tmux-sessionizer.conf"
  "config/starship.toml|$CONFIG_HOME/starship.toml"
  "config/git/common|$CONFIG_HOME/git/common"
  "config/git/ignore|$CONFIG_HOME/git/ignore"
  "config/tmux|$CONFIG_HOME/tmux"
  "config/tmux/tmux.conf|$HOME/.tmux.conf"
)

install_dotfiles() {
  local platform="$1"
  shift

  export DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/dotfiles-wayback/$(date +%Y%m%d-%H%M%S)-$$}"

  dotfiles-install "$platform" "$@" --links "${common_links[@]}" "${platform_links[@]}"

  local etc_args=()
  [[ ${#etc_links[@]} -gt 0 ]] && etc_args+=(--links "${etc_links[@]}")
  [[ ${#etc_copies[@]} -gt 0 ]] && etc_args+=(--copies "${etc_copies[@]}")

  if [[ ${#etc_args[@]} -gt 0 ]]; then
    dotfiles-install-etc "$@" "${etc_args[@]}"
  fi
}

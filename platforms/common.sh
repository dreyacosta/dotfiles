#!/bin/bash

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

links=(
  ".|$HOME/.dotfiles"
  "home/cspell.json|$HOME/.cspell.json"
  "home/cspell-custom-words.txt|$HOME/.cspell-custom-words.txt"
  "home/markdownlint.jsonc|$HOME/.markdownlint.jsonc"
  "config/herdr/config.toml|$CONFIG_HOME/herdr/config.toml"
  "config/herdr/plugins/sessionizer.toml|$CONFIG_HOME/herdr/plugins/config/sessionizer/config.toml"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/nvim|$CONFIG_HOME/nvim"
  "config/tmux-sessionizer/tmux-sessionizer.conf|$CONFIG_HOME/tmux-sessionizer/tmux-sessionizer.conf"
  "config/starship.toml|$CONFIG_HOME/starship.toml"
  "config/git/common|$CONFIG_HOME/git/common"
  "config/git/ignore|$CONFIG_HOME/git/ignore"
  "config/tmux|$CONFIG_HOME/tmux"
  "config/tmux/tmux.conf|$HOME/.tmux.conf"
)
copies=()
required_commands=(bat eza fd fzf git gum herdr jq lazygit mise nvim rg starship tmux zoxide)
required_services=()
required_executables=("$HOME/.local/bin/tmux-sessionizer/tmux-sessionizer")
mise_config="config/mise/config.toml"

platform_prepare() { return 0; }
reload_herdr_config() {
  local -r herdr_executable="${1:-herdr}"

  if "$herdr_executable" status server --json 2>/dev/null | jq -e '.running == true' >/dev/null; then
    "$herdr_executable" server reload-config
    dotfiles_log "Reloaded Herdr configuration"
  fi
}
platform_post_install() { reload_herdr_config; }
platform_verify() { return 0; }

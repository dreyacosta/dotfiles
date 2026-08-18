#!/bin/bash

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

links=(
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
copies=()
required_commands=(bat eza fd fzf git gum lazygit mise nvim rg starship tmux zoxide)
required_services=()
required_executables=("$HOME/.local/bin/tmux-sessionizer/tmux-sessionizer")
mise_tools=()
mise_config=""

platform_prepare() { return 0; }
platform_post_install() { return 0; }
platform_verify() { return 0; }

#!/bin/bash

platform_name="macos"
links+=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/macos/zshrc|$HOME/.zshrc"
  "config/karabiner/karabiner.json|$CONFIG_HOME/karabiner/karabiner.json"
  "config/mise/macos.toml|$CONFIG_HOME/mise/config.toml"
  "config/ghostty/config|$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$HOME/Library/Application Support/com.mitchellh.ghostty/themes/Tokyonight Night"
  "config/git/macos|$CONFIG_HOME/git/config"
)
required_commands+=(brew gh)
mise_config="config/mise/macos.toml"
mise_tools=(go python)

platform_verify() {
  local nvm_dir nvm_command
  [[ "$(uname -s)" == "Darwin" ]] && verify_pass "platform is macOS" || verify_fail "platform is not macOS"
  nvm_dir="${XDG_CONFIG_HOME:-$HOME/.nvm}"
  [[ -n "${XDG_CONFIG_HOME:-}" ]] && nvm_dir="$XDG_CONFIG_HOME/nvm"
  for nvm_command in node npm cspell-lsp; do
    if NVM_DIR="$nvm_dir" bash -c 'source "$NVM_DIR/nvm.sh" && command -v "$1"' _ "$nvm_command" >/dev/null 2>&1; then
      verify_pass "nvm command available: $nvm_command"
    else
      verify_fail "nvm command missing: $nvm_command"
    fi
  done
}

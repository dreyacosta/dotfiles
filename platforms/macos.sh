#!/bin/bash

platform_name="macos"
links+=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/macos/zshrc|$HOME/.zshrc"
  "config/karabiner/karabiner.json|$CONFIG_HOME/karabiner/karabiner.json"
  "config/ghostty/config|$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$HOME/Library/Application Support/com.mitchellh.ghostty/themes/Tokyonight Night"
  "config/git/macos|$CONFIG_HOME/git/config"
)
required_commands+=(brew)

platform_verify() {
  local nvm_dir="$HOME/.nvm"
  local package_name

  [[ "$(uname -s)" == "Darwin" ]] && verify_pass "platform is macOS" || verify_fail "platform is not macOS"
  for package_name in herdr jq; do
    brew list --formula "$package_name" >/dev/null 2>&1 && verify_pass "Homebrew package installed: $package_name" || verify_fail "Homebrew package missing: $package_name"
  done
  [[ -n "${XDG_CONFIG_HOME:-}" ]] && nvm_dir="$XDG_CONFIG_HOME/nvm"
  if NVM_DIR="$nvm_dir" bash -c '
    source "$NVM_DIR/nvm.sh"
    lts_version="$(nvm version --lts)"
    [[ "$lts_version" != "N/A" ]] && nvm use --silent "$lts_version" && command -v node
  ' >/dev/null 2>&1; then
    verify_pass "nvm LTS Node available"
  else
    verify_fail "nvm LTS Node missing"
  fi
}

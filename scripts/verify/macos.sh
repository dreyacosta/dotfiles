#!/bin/bash

set -uo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  pass "platform is macOS"
else
  fail "platform is not macOS"
fi

check_common_commands
check_command brew
check_command gh
check_common_links
check_link "$HOME/.ideavimrc" "$VERIFY_REPO_DIR/home/ideavimrc"
check_link "$HOME/.zshrc" "$VERIFY_REPO_DIR/shell/platform/macos/zshrc"
check_link "$VERIFY_CONFIG_HOME/git/config" "$VERIFY_REPO_DIR/config/git/macos"
check_link "$VERIFY_CONFIG_HOME/karabiner/karabiner.json" "$VERIFY_REPO_DIR/config/karabiner/karabiner.json"
check_link "$VERIFY_CONFIG_HOME/mise/config.toml" "$VERIFY_REPO_DIR/config/mise/macos.toml"
check_link "$HOME/Library/Application Support/com.mitchellh.ghostty/config" \
  "$VERIFY_REPO_DIR/config/ghostty/config"

if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
  readonly verify_nvm_dir="$XDG_CONFIG_HOME/nvm"
else
  readonly verify_nvm_dir="$HOME/.nvm"
fi
check_file "$verify_nvm_dir/nvm.sh"

for nvm_command in node npm cspell-lsp; do
  if NVM_DIR="$verify_nvm_dir" bash -c 'source "$NVM_DIR/nvm.sh" && command -v "$1"' _ "$nvm_command" >/dev/null 2>&1; then
    pass "nvm command available: $nvm_command"
  else
    fail "nvm command missing: $nvm_command"
  fi
done

check_mise_tool "$VERIFY_REPO_DIR/config/mise/macos.toml" go
check_mise_tool "$VERIFY_REPO_DIR/config/mise/macos.toml" python

finish_checks

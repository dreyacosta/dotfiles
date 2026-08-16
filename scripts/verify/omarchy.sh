#!/bin/bash

set -uo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if command -v omarchy >/dev/null 2>&1; then
  pass "platform command available: omarchy"
else
  fail "platform command missing: omarchy"
fi

check_common_commands
check_command brew
check_command docker
check_command herdr
check_command keyd
check_file "/usr/share/omarchy/default/bash/rc"
check_common_links
check_link "$HOME/.bashrc" "$VERIFY_REPO_DIR/shell/platform/omarchy/bashrc"
check_link "$HOME/.ideavimrc" "$VERIFY_REPO_DIR/home/ideavimrc"
check_link "$VERIFY_CONFIG_HOME/git/config" "$VERIFY_REPO_DIR/config/git/linux"
check_link "$VERIFY_CONFIG_HOME/ghostty/config" "$VERIFY_REPO_DIR/config/ghostty/config"
check_link "$VERIFY_CONFIG_HOME/herdr/config.toml" "$VERIFY_REPO_DIR/config/herdr/config.toml"
check_link "$VERIFY_CONFIG_HOME/hypr/bindings.lua" "$VERIFY_REPO_DIR/config/hypr/bindings.lua"
check_link "$VERIFY_CONFIG_HOME/hypr/input.lua" "$VERIFY_REPO_DIR/config/hypr/input.lua"
check_link "$VERIFY_CONFIG_HOME/mise/config.toml" "$VERIFY_REPO_DIR/config/mise/config.toml"
check_link "/etc/keyd/default.conf" "$VERIFY_REPO_DIR/etc/keyd/default.conf"
check_service keyd
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" go
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" node
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" python
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" cspell-lsp

finish_checks

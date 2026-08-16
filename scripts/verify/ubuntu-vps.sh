#!/bin/bash

set -uo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ -r /etc/os-release ]] && . /etc/os-release && [[ "${ID:-}" == "ubuntu" ]]; then
  pass "platform is Ubuntu"
else
  fail "platform is not Ubuntu"
fi

check_common_commands
check_command brew
check_command docker
check_common_links
check_link "$HOME/.bashrc" "$VERIFY_REPO_DIR/shell/platform/ubuntu-vps/bashrc"
check_link "$VERIFY_CONFIG_HOME/git/config" "$VERIFY_REPO_DIR/config/git/linux"
check_link "$VERIFY_CONFIG_HOME/mise/config.toml" "$VERIFY_REPO_DIR/config/mise/config.toml"
check_service docker
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" go
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" node
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" python
check_mise_tool "$VERIFY_REPO_DIR/config/mise/config.toml" cspell-lsp

if id -nG | tr ' ' '\n' | rg -qx docker; then
  pass "current user belongs to the docker group"
else
  fail "current user does not belong to the docker group; log out and back in after installation"
fi

finish_checks

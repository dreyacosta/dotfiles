#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TEST_DIR="$(mktemp -d /tmp/dotfiles-install-test.XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT

export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES_SYSTEM_ROOT="$TEST_DIR/system"
export DOTFILES_BACKUP_DIR="$TEST_DIR/backups/run"
mkdir -p "$HOME" "$XDG_CONFIG_HOME/git" "$DOTFILES_SYSTEM_ROOT"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_link() {
  local -r path="$1"
  local -r expected="$2"
  [[ -L "$path" ]] || fail "$path is not a symlink"
  [[ "$(readlink "$path")" == "$expected" ]] || fail "$path has the wrong target"
}

printf 'existing git config\n' >"$XDG_CONFIG_HOME/git/config"
"$REPO_DIR/bin/dotfiles" install ubuntu-vps >/dev/null

assert_link "$XDG_CONFIG_HOME/git/config" "$REPO_DIR/config/git/linux"
[[ -f "$DOTFILES_BACKUP_DIR/.config/git/config" ]] || fail "existing Git config was not backed up"

first_target="$(readlink "$XDG_CONFIG_HOME/git/config")"
"$REPO_DIR/bin/dotfiles" install ubuntu-vps >/dev/null
[[ "$(readlink "$XDG_CONFIG_HOME/git/config")" == "$first_target" ]] || fail "reinstall changed a correct link"

printf 'Install smoke test passed\n'

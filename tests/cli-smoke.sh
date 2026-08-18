#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TEST_DIR="$(mktemp -d /tmp/dotfiles-cli-test.XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT

export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES_SYSTEM_ROOT="$TEST_DIR/system"
export DOTFILES_BACKUP_DIR="$TEST_DIR/backups/run"
readonly FAKE_BIN="$TEST_DIR/bin"
export DOTFILES_COMMAND_LOG="$TEST_DIR/commands.log"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$DOTFILES_SYSTEM_ROOT/etc" "$FAKE_BIN"

for command_name in brew docker git herdr keyd mise omarchy sudo systemctl tmux; do
  printf '#!/bin/bash\nprintf "%%s\\n" "$(basename "$0") $*" >>"$DOTFILES_COMMAND_LOG"\n' >"$FAKE_BIN/$command_name"
  chmod +x "$FAKE_BIN/$command_name"
done
export PATH="$FAKE_BIN:$PATH"
mkdir -p "$HOME/.local/bin/tmux-sessionizer"
printf '#!/bin/bash\n' >"$HOME/.local/bin/tmux-sessionizer/tmux-sessionizer"
chmod +x "$HOME/.local/bin/tmux-sessionizer/tmux-sessionizer"

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

assert_contains() {
  local -r text="$1"
  local -r expected="$2"

  [[ "$text" == *"$expected"* ]] || fail "output does not contain: $expected"
}

help_output="$($REPO_DIR/bin/dotfiles help)"
assert_contains "$help_output" "dotfiles install <platform> [--dry-run]"

platform_output="$($REPO_DIR/bin/dotfiles platforms)"
assert_contains "$platform_output" "macos"
assert_contains "$platform_output" "omarchy"
assert_contains "$platform_output" "ubuntu-vps"

fixture_platforms="$TEST_DIR/platforms"
mkdir -p "$fixture_platforms"
cat >"$fixture_platforms/broken.sh" <<EOF
platform_name="broken"
links+=(
  "home/cspell.json|$TEST_DIR/validation/.cspell.json"
  "missing/source|$TEST_DIR/validation/missing"
)
EOF
broken_output=""
if broken_output="$(DOTFILES_PLATFORM_DIR="$fixture_platforms" "$REPO_DIR/bin/dotfiles" install broken 2>&1)"; then
  fail "invalid platform manifest was accepted"
fi
assert_contains "$broken_output" "Invalid link mapping"
[[ ! -e "$TEST_DIR/validation/.cspell.json" ]] || fail "validation failure caused a partial install"

dry_home="$TEST_DIR/dry-home"
HOME="$dry_home" XDG_CONFIG_HOME="$dry_home/.config" \
  "$REPO_DIR/bin/dotfiles" install macos --dry-run >/dev/null
[[ ! -e "$dry_home/.dotfiles" ]] || fail "dry run changed the filesystem"

"$REPO_DIR/bin/dotfiles" install ubuntu-vps >/dev/null
assert_link "$HOME/.dotfiles" "$REPO_DIR/."
assert_link "$HOME/.bashrc" "$REPO_DIR/shell/platform/ubuntu-vps/bashrc"
assert_link "$XDG_CONFIG_HOME/git/config" "$REPO_DIR/config/git/linux"

verify_output="$($REPO_DIR/bin/dotfiles verify ubuntu-vps --links-only)"
assert_contains "$verify_output" "Verification complete"
assert_contains "$verify_output" "0 failed"

DOTFILES_TEST_TOUCHBAR=true "$REPO_DIR/bin/dotfiles" install omarchy >/dev/null
assert_link "$DOTFILES_SYSTEM_ROOT/etc/keyd/default.conf" "$REPO_DIR/etc/keyd/default.conf"
cmp -s "$REPO_DIR/etc/modprobe.d/touchbar.conf" \
  "$DOTFILES_SYSTEM_ROOT/etc/modprobe.d/touchbar.conf" || fail "Touch Bar configuration was not copied"
assert_contains "$(<"$DOTFILES_COMMAND_LOG")" "keyd reload"

"$REPO_DIR/bin/dotfiles" dependencies omarchy >/dev/null
command_log="$(<"$DOTFILES_COMMAND_LOG")"
assert_contains "$command_log" "omarchy pkg add keyd"
assert_contains "$command_log" "mise install"

printf 'CLI smoke test passed\n'

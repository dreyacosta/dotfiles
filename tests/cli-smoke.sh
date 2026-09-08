#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TEST_DIR="$(mktemp -d /tmp/dotfiles-cli-test.XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT

export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export DOTFILES_SYSTEM_ROOT="$TEST_DIR/system"
export DOTFILES_BACKUP_DIR="$TEST_DIR/backups/run"
readonly FAKE_BIN="$TEST_DIR/bin"
export DOTFILES_COMMAND_LOG="$TEST_DIR/commands.log"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$DOTFILES_SYSTEM_ROOT/etc" "$FAKE_BIN"
export DOTFILES_OMARCHY_HERDR="$FAKE_BIN/herdr"

for command_name in brew docker git herdr keyd mise omarchy sudo systemctl tmux voxtype wtype; do
  printf '#!/bin/bash\nprintf "%%s\\n" "$(basename "$0") $*" >>"$DOTFILES_COMMAND_LOG"\n' >"$FAKE_BIN/$command_name"
  chmod +x "$FAKE_BIN/$command_name"
done
printf '#!/bin/bash\noutput_path=""\nwhile [[ "$#" -gt 0 ]]; do\n  if [[ "$1" == "-o" ]]; then output_path="$2"; shift 2; else shift; fi\ndone\n: >"$output_path"\nprintf "curl download %s\\n" "$output_path" >>"$DOTFILES_COMMAND_LOG"\n' >"$FAKE_BIN/curl"
chmod +x "$FAKE_BIN/curl"
printf '#!/bin/bash\ncat >/dev/null\nexit 0\n' >"$FAKE_BIN/sha256sum"
chmod +x "$FAKE_BIN/sha256sum"
printf '#!/bin/bash\nprintf "jq %%s\\n" "$*" >>"$DOTFILES_COMMAND_LOG"\nexit 1\n' >"$FAKE_BIN/jq"
chmod +x "$FAKE_BIN/jq"
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

migration_repo="$TEST_DIR/migration-repo"
migration_home="$TEST_DIR/migration-home"
mkdir -p "$migration_repo" "$migration_home/.config"
cp -R "$REPO_DIR/bin" "$REPO_DIR/config" "$REPO_DIR/home" "$REPO_DIR/lib" \
  "$REPO_DIR/platforms" "$REPO_DIR/shell" "$migration_repo/"
ln -s "$migration_repo/config/tmux-sessionizer" "$migration_home/.config/tmux-sessionizer"
HOME="$migration_home" XDG_CONFIG_HOME="$migration_home/.config" \
  DOTFILES_BACKUP_DIR="$TEST_DIR/migration-backup" \
  "$migration_repo/bin/dotfiles" install macos >/dev/null
[[ -d "$migration_home/.config/tmux-sessionizer" && ! -L "$migration_home/.config/tmux-sessionizer" ]] || \
  fail "symlinked parent directory was not migrated"
assert_link "$migration_home/.config/tmux-sessionizer/tmux-sessionizer.conf" \
  "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf"
[[ -f "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf" && \
  ! -L "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf" ]] || \
  fail "symlinked parent migration replaced the repository source"
rm "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf"
ln -s "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf" \
  "$migration_repo/config/tmux-sessionizer/tmux-sessionizer.conf"
dangling_output=""
if dangling_output="$(HOME="$migration_home" XDG_CONFIG_HOME="$migration_home/.config" \
  "$migration_repo/bin/dotfiles" verify macos --links-only 2>&1)"; then
  fail "dangling symlink passed verification"
fi
assert_contains "$dangling_output" \
  "symlink target is missing: $migration_home/.config/tmux-sessionizer/tmux-sessionizer.conf"

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
cmp -s "$REPO_DIR/etc/systemd/system-sleep/touchbar-backlight" \
  "$DOTFILES_SYSTEM_ROOT/etc/systemd/system-sleep/touchbar-backlight" || fail "Touch Bar helper was not copied"
cmp -s "$REPO_DIR/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf" \
  "$DOTFILES_SYSTEM_ROOT/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf" || \
  fail "Touch Bar suspend drop-in was not copied"
assert_contains "$(<"$REPO_DIR/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf")" \
  "ExecStartPre=/etc/systemd/system-sleep/touchbar-backlight pre suspend"
assert_contains "$(<"$REPO_DIR/etc/systemd/system-sleep/touchbar-backlight")" "modprobe -r hid_appletb_kbd"
assert_contains "$(<"$REPO_DIR/etc/systemd/system-sleep/touchbar-backlight")" "modprobe hid_appletb_bl"
assert_contains "$(<"$DOTFILES_COMMAND_LOG")" "sudo systemctl restart keyd.service"
assert_contains "$(<"$DOTFILES_COMMAND_LOG")" "systemctl --user restart voxtype.service"

"$REPO_DIR/bin/dotfiles" dependencies omarchy >/dev/null
command_log="$(<"$DOTFILES_COMMAND_LOG")"
assert_contains "$command_log" "omarchy pkg add base-devel curl file git herdr jq keyd procps-ng voxtype-bin wtype"
assert_contains "$command_log" "systemctl --user enable voxtype.service"
[[ -f "$HOME/.local/share/voxtype/models/ggml-small.bin" ]] || fail "Voxtype small model was not installed"
assert_contains "$command_log" "mise exec -- $FAKE_BIN/herdr plugin install andrewchng/herdr-sessionizer --ref e3cdab0d8886c9dc2c50a6e09da334d6508fae7b --yes"
assert_contains "$command_log" "mise exec -- $FAKE_BIN/herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 820d48f5d9c9a7dece6a4bebfa3982ec30bbfbb7 --yes"
assert_contains "$command_log" "mise install"
assert_contains "$command_log" "brew shellenv bash"
[[ "$command_log" != *"mise install herdr"* ]] || fail "existing Herdr was reinstalled through mise"
[[ "$command_log" != *"brew install"* ]] || fail "Omarchy dependencies installed a package through Homebrew"

printf 'CLI smoke test passed\n'

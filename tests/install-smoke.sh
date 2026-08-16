#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TEST_DIR="$(mktemp -d /tmp/dotfiles-install-test.XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT

export PATH="$REPO_DIR/bin:$PATH"
export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES_BACKUP_DIR="$TEST_DIR/backups/run"
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_link() {
  local path="$1"
  local expected="$2"
  [[ -L "$path" ]] || fail "$path is not a symlink"
  [[ "$(readlink "$path")" == "$expected" ]] || fail "$path has the wrong target"
}

assert_contains() {
  local path="$1"
  local pattern="$2"
  rg -q -- "$pattern" "$path" || fail "$path does not contain: $pattern"
}

printf 'legacy git config\n' >"$HOME/.gitconfig"
ln -s "$REPO_DIR/config/git" "$XDG_CONFIG_HOME/git"

links=(
  ".|$HOME/.dotfiles"
  "config/git/common|$XDG_CONFIG_HOME/git/common"
  "config/git/ignore|$XDG_CONFIG_HOME/git/ignore"
  "config/git/macos|$XDG_CONFIG_HOME/git/config"
)

dotfiles-install test --legacy "$HOME/.gitconfig" --legacy-links "$XDG_CONFIG_HOME/git|config/git" \
  --links "${links[@]}"

assert_link "$HOME/.dotfiles" "$REPO_DIR/."
assert_link "$XDG_CONFIG_HOME/git/common" "$REPO_DIR/config/git/common"
assert_link "$XDG_CONFIG_HOME/git/ignore" "$REPO_DIR/config/git/ignore"
assert_link "$XDG_CONFIG_HOME/git/config" "$REPO_DIR/config/git/macos"
[[ "$(git config --global --get credential.helper)" == "osxkeychain" ]] || fail "platform Git config was not included"
[[ -f "$DOTFILES_BACKUP_DIR/.gitconfig" ]] || fail "legacy Git config was not backed up"
[[ -L "$DOTFILES_BACKUP_DIR/.config/git" ]] || fail "legacy Git directory link was not backed up"
[[ -f "$REPO_DIR/config/git/common" ]] || fail "repository config was changed during migration"

dotfiles-install test --legacy "$HOME/.gitconfig" --legacy-links "$XDG_CONFIG_HOME/git|config/git" \
  --links "${links[@]}"

dry_home="$TEST_DIR/dry-home"
dotfiles-install test --dry-run --links "home/cspell.json|$dry_home/.cspell.json"
[[ ! -e "$dry_home/.cspell.json" ]] || fail "dry run created a link"

invalid_home="$TEST_DIR/invalid-home"
if dotfiles-install test --links \
  "home/cspell.json|$invalid_home/.cspell.json" \
  "missing/source|$invalid_home/missing"; then
  fail "missing source did not fail validation"
fi
[[ ! -e "$invalid_home/.cspell.json" ]] || fail "validation failure caused a partial install"

unmanaged_home="$TEST_DIR/unmanaged-home"
unmanaged_target="$TEST_DIR/unmanaged-target"
mkdir -p "$unmanaged_home/.config" "$unmanaged_target"
ln -s "$unmanaged_target" "$unmanaged_home/.config/git"
if HOME="$unmanaged_home" dotfiles-install test \
  --legacy-links "$unmanaged_home/.config/git|config/git" \
  --links "config/git/common|$unmanaged_home/.config/git/common"; then
  fail "unmanaged directory symlink was accepted"
fi
assert_link "$unmanaged_home/.config/git" "$unmanaged_target"
[[ ! -e "$unmanaged_target/common" ]] || fail "unmanaged symlink target was modified"

preflight_home="$TEST_DIR/preflight-home"
preflight_target="$TEST_DIR/preflight-target"
preflight_backup="$TEST_DIR/preflight-backup"
mkdir -p "$preflight_home/.config" "$preflight_target"
ln -s "$REPO_DIR/config/git" "$preflight_home/.config/git"
ln -s "$preflight_target" "$preflight_home/.config/hypr"
printf 'legacy git config\n' >"$preflight_home/.gitconfig"
if HOME="$preflight_home" DOTFILES_BACKUP_DIR="$preflight_backup" dotfiles-install test \
  --legacy "$preflight_home/.gitconfig" \
  --legacy-links \
  "$preflight_home/.config/git|config/git" \
  "$preflight_home/.config/hypr|config/hypr" \
  --links "config/git/common|$preflight_home/.config/git/common"; then
  fail "multi-link migration conflict was accepted"
fi
assert_link "$preflight_home/.config/git" "$REPO_DIR/config/git"
assert_link "$preflight_home/.config/hypr" "$preflight_target"
[[ -f "$preflight_home/.gitconfig" ]] || fail "preflight moved a legacy file before failing"
[[ ! -e "$preflight_backup" ]] || fail "preflight created backups before failing"

collision_home="$TEST_DIR/collision-home"
collision_backup="$TEST_DIR/collision-backup"
mkdir -p "$collision_home/.config" "$collision_backup/.config/git"
ln -s "$REPO_DIR/config/git" "$collision_home/.config/git"
if HOME="$collision_home" DOTFILES_BACKUP_DIR="$collision_backup" dotfiles-install test \
  --legacy-links "$collision_home/.config/git|config/git" \
  --links "config/git/common|$collision_home/.config/git/common"; then
  fail "legacy backup collision was accepted"
fi
assert_link "$collision_home/.config/git" "$REPO_DIR/config/git"

nvm_home="$TEST_DIR/nvm home"
nvm_xdg="$nvm_home/custom config"
nvm_dir="$(HOME="$nvm_home" XDG_CONFIG_HOME="$nvm_xdg" bash -c \
  'source "$1"; printf "%s" "$NVM_DIR"' _ "$REPO_DIR/shell/platform/macos/nvm")"
[[ "$nvm_dir" == "$nvm_xdg/nvm" ]] || fail "nvm did not append /nvm to XDG_CONFIG_HOME"

platform_home="$TEST_DIR/platform home"
platform_xdg="$platform_home/custom config"
mkdir -p "$platform_home" "$platform_xdg"
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/macos.sh" --dry-run >/dev/null
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/omarchy.sh" --dry-run >/dev/null
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/ubuntu-vps.sh" --dry-run >/dev/null

etc_home="$TEST_DIR/etc-home"
env -u DOTFILES_BACKUP_DIR HOME="$etc_home" dotfiles-install-etc --dry-run --links \
  "etc/keyd/default.conf|/etc/keyd/default.conf" >/dev/null

assert_contains "$REPO_DIR/config/mise/config.toml" 'python = "latest"'
assert_contains "$REPO_DIR/config/mise/macos.toml" 'go = "latest"'
assert_contains "$REPO_DIR/config/mise/macos.toml" 'python = "latest"'
assert_contains "$REPO_DIR/config/nvim/lua/plugins/lsp.lua" '--config'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'omarchy pkg add keyd'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'systemctl enable --now keyd'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'Homebrew/install/HEAD/install.sh'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'omarchy pkg add base-devel procps-ng curl file git'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'keyd reload'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'herdr server reload-config'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'config/herdr/config.toml'
assert_contains "$REPO_DIR/config/herdr/config.toml" 'prefix = "ctrl\+a"'
assert_contains "$REPO_DIR/config/herdr/config.toml" 'resize_pane_left = "ctrl\+shift\+left"'
assert_contains "$REPO_DIR/shell/common/tmux" 'HERDR_PANE_ID'
assert_contains "$REPO_DIR/scripts/verify/common.sh" "mise exec -- bash -c"
assert_contains "$REPO_DIR/shell/platform/omarchy/bashrc" '/usr/share/omarchy/default/bash/env-bootstrap'
if rg -q '\.local/share/omarchy/default/bash/rc' "$REPO_DIR/shell/platform/omarchy/bashrc"; then
  fail "legacy Omarchy bash rc path is still present"
fi
if rg -q 'git-lfs|omarchy install docker' "$REPO_DIR/scripts/install" "$REPO_DIR/config/git/common"; then
  fail "removed Git LFS or Omarchy Docker setup is still present"
fi

for verify_script in macos omarchy ubuntu-vps; do
  [[ -x "$REPO_DIR/scripts/verify/$verify_script.sh" ]] || fail "verification script is not executable: $verify_script"
  bash -n "$REPO_DIR/scripts/verify/$verify_script.sh"
done
bash -n "$REPO_DIR/scripts/verify/common.sh"

printf 'Install smoke test passed\n'

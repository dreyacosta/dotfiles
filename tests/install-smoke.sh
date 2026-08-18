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

mkdir -p "$XDG_CONFIG_HOME/git"
printf 'existing git config\n' >"$XDG_CONFIG_HOME/git/config"

links=(
  ".|$HOME/.dotfiles"
  "config/git/common|$XDG_CONFIG_HOME/git/common"
  "config/git/ignore|$XDG_CONFIG_HOME/git/ignore"
  "config/git/macos|$XDG_CONFIG_HOME/git/config"
)

dotfiles-install test --links "${links[@]}"

assert_link "$HOME/.dotfiles" "$REPO_DIR/."
assert_link "$XDG_CONFIG_HOME/git/common" "$REPO_DIR/config/git/common"
assert_link "$XDG_CONFIG_HOME/git/ignore" "$REPO_DIR/config/git/ignore"
assert_link "$XDG_CONFIG_HOME/git/config" "$REPO_DIR/config/git/macos"
[[ "$(git config --global --get credential.helper)" == "osxkeychain" ]] || fail "platform Git config was not included"
[[ -f "$DOTFILES_BACKUP_DIR/.config/git/config" ]] || fail "existing Git config was not backed up"

dotfiles-install test --links "${links[@]}"

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

nvm_home="$TEST_DIR/nvm home"
nvm_xdg="$nvm_home/custom config"
nvm_dir="$(HOME="$nvm_home" XDG_CONFIG_HOME="$nvm_xdg" bash -c \
  'source "$1"; printf "%s" "$NVM_DIR"' _ "$REPO_DIR/shell/platform/macos/nvm")"
[[ "$nvm_dir" == "$nvm_xdg/nvm" ]] || fail "nvm did not append /nvm to XDG_CONFIG_HOME"

if ! macos_deps_order="$(bash -c '
  source "$1"
  declare -F install_brew_casks >/dev/null
  require_command_line_tools() { printf "%s\n" command-line-tools; }
  install_homebrew() { printf "%s\n" homebrew; }
  activate_homebrew() { printf "%s\n" activate-homebrew; }
  install_brew_packages() { printf "%s\n" brew-packages; }
  install_mise_tools() { printf "%s\n" mise; }
  install_nvm() { printf "%s\n" nvm; }
  install_tmux_sessionizer() { printf "%s\n" tmux-sessionizer; }
  install_brew_casks() { printf "%s\n" brew-casks; }
  main
' _ "$REPO_DIR/scripts/install/macos-deps.sh")"; then
  fail "macOS dependency installer does not have a separate cask phase"
fi
expected_macos_deps_order="$(printf '%s\n' \
  command-line-tools homebrew activate-homebrew brew-packages mise nvm tmux-sessionizer brew-casks)"
[[ "$macos_deps_order" == "$expected_macos_deps_order" ]] || fail "macOS dependencies are installed in the wrong order"

homebrew_installer_mode="$(bash -c '
  source "$1"
  curl() { printf '\''printf "%%s" "${NONINTERACTIVE-unset}"'\''; }
  export NONINTERACTIVE=parent
  PATH=/usr/bin:/bin
  install_homebrew
' _ "$REPO_DIR/scripts/install/macos-deps.sh")"
[[ "$homebrew_installer_mode" == "unset" ]] || fail "Homebrew bootstrap cannot prompt during a clean install"

if ! bash -c '
  source "$1"
  nvm_version_scope() {
    local NVM_VERSION="probe"
    [[ "$NVM_VERSION" == "probe" ]]
  }
  nvm_version_scope
' _ "$REPO_DIR/scripts/install/macos-deps.sh"; then
  fail "macOS dependency installer reserves nvm internal variables"
fi

platform_home="$TEST_DIR/platform home"
platform_xdg="$platform_home/custom config"
mkdir -p "$platform_home" "$platform_xdg"
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/macos.sh" --dry-run >/dev/null
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/omarchy.sh" --dry-run >/dev/null
HOME="$platform_home" XDG_CONFIG_HOME="$platform_xdg" "$REPO_DIR/scripts/install/ubuntu-vps.sh" --dry-run >/dev/null

etc_home="$TEST_DIR/etc-home"
env -u DOTFILES_BACKUP_DIR HOME="$etc_home" dotfiles-install-etc --dry-run --links \
  "etc/keyd/default.conf|/etc/keyd/default.conf" --copies \
  "etc/modprobe.d/touchbar.conf|/etc/modprobe.d/touchbar.conf" >/dev/null

assert_contains "$REPO_DIR/config/mise/config.toml" 'python = "latest"'
assert_contains "$REPO_DIR/config/mise/macos.toml" 'go = "latest"'
assert_contains "$REPO_DIR/config/mise/macos.toml" 'python = "latest"'
assert_contains "$REPO_DIR/config/nvim/lua/plugins/lsp.lua" '--config'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'omarchy pkg add keyd'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'systemctl enable --now keyd'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'Homebrew/install/HEAD/install.sh'
assert_contains "$REPO_DIR/scripts/install/omarchy-deps.sh" 'omarchy pkg add base-devel procps-ng curl file git'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'keyd reload'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'etc/modprobe.d/touchbar.conf'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'systemd-suspend.service.d/touchbar-backlight.conf'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'touchbar-backlight.service'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'systemctl daemon-reload'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'etc/systemd/system-sleep/touchbar-backlight'
assert_contains "$REPO_DIR/scripts/install/omarchy.sh" 'Run: sudo limine-mkinitcpio'
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
bash -n "$REPO_DIR/etc/systemd/system-sleep/touchbar-backlight"
assert_contains "$REPO_DIR/etc/modprobe.d/touchbar.conf" 'options hid_appletb_kbd autodim=0'

printf 'Install smoke test passed\n'

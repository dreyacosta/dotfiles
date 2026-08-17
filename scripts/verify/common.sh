#!/bin/bash

readonly VERIFY_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly VERIFY_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

verify_passed=0
verify_failed=0

pass() {
  printf 'PASS: %s\n' "$1"
  verify_passed=$((verify_passed + 1))
}

fail() {
  printf '\033[1mFAIL: %s\033[0m\n' "$1" >&2
  verify_failed=$((verify_failed + 1))
}

check_command() {
  local -r command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    pass "command available: $command_name"
  else
    fail "command missing: $command_name"
  fi
}

check_file() {
  local -r path="$1"

  if [[ -f "$path" ]]; then
    pass "file exists: $path"
  else
    fail "file missing: $path"
  fi
}

check_executable() {
  local -r path="$1"

  if [[ -x "$path" ]]; then
    pass "executable exists: $path"
  else
    fail "executable missing: $path"
  fi
}

check_link() {
  local -r path="$1"
  local -r expected_source="$2"

  if [[ ! -L "$path" ]]; then
    fail "symlink missing: $path"
  elif [[ "$(readlink "$path")" != "$expected_source" ]]; then
    fail "symlink target is incorrect: $path"
  else
    pass "symlink installed: $path"
  fi
}

check_service() {
  local -r service="$1"

  if systemctl is-enabled --quiet "$service" >/dev/null 2>&1; then
    pass "service enabled: $service"
  else
    fail "service not enabled: $service"
  fi

  if systemctl is-active --quiet "$service" >/dev/null 2>&1; then
    pass "service active: $service"
  else
    fail "service not active: $service"
  fi
}

check_mise_tool() {
  local -r config_file="$1"
  local -r tool="$2"

  if MISE_CONFIG_FILE="$config_file" mise exec -- bash -c 'command -v "$1"' _ "$tool" >/dev/null 2>&1; then
    pass "mise tool available: $tool"
  else
    fail "mise tool missing: $tool"
  fi
}

check_common_commands() {
  local -r commands=(bat eza fd fzf git gum lazygit mise nvim rg starship tmux zoxide)
  local command_name

  for command_name in "${commands[@]}"; do
    check_command "$command_name"
  done
}

check_common_links() {
  check_link "$HOME/.dotfiles" "$VERIFY_REPO_DIR/."
  check_link "$HOME/.cspell.json" "$VERIFY_REPO_DIR/home/cspell.json"
  check_link "$HOME/.cspell-custom-words.txt" "$VERIFY_REPO_DIR/home/cspell-custom-words.txt"
  check_link "$HOME/.markdownlint.jsonc" "$VERIFY_REPO_DIR/home/markdownlint.jsonc"
  check_link "$HOME/.tmux.conf" "$VERIFY_REPO_DIR/config/tmux/tmux.conf"
  check_link "$VERIFY_CONFIG_HOME/git/common" "$VERIFY_REPO_DIR/config/git/common"
  check_link "$VERIFY_CONFIG_HOME/git/ignore" "$VERIFY_REPO_DIR/config/git/ignore"
  check_link "$VERIFY_CONFIG_HOME/nvim" "$VERIFY_REPO_DIR/config/nvim"
  check_link "$VERIFY_CONFIG_HOME/starship.toml" "$VERIFY_REPO_DIR/config/starship.toml"
  check_link "$VERIFY_CONFIG_HOME/tmux" "$VERIFY_REPO_DIR/config/tmux"
  check_link "$VERIFY_CONFIG_HOME/tmux-sessionizer/tmux-sessionizer.conf" \
    "$VERIFY_REPO_DIR/config/tmux-sessionizer/tmux-sessionizer.conf"
  check_executable "$HOME/.local/bin/tmux-sessionizer/tmux-sessionizer"
}

finish_checks() {
  printf '\nVerification complete: %d passed, %d failed\n' "$verify_passed" "$verify_failed"
  [[ "$verify_failed" -eq 0 ]]
}

#!/bin/bash

verify_passed=0
verify_failed=0

verify_pass() {
  printf 'PASS: %s\n' "$1"
  verify_passed=$((verify_passed + 1))
}

verify_fail() {
  printf '\033[1mFAIL: %s\033[0m\n' "$1" >&2
  verify_failed=$((verify_failed + 1))
}

check_command() {
  local -r command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 && verify_pass "command available: $command_name" || verify_fail "command missing: $command_name"
}

check_link_mapping() {
  local -r mapping="$1"
  local source_path="${mapping%%|*}"
  local target_path="${mapping#*|}"
  local actual_target="$target_path"
  [[ "$target_path" == /etc/* ]] && actual_target="$(system_target "$target_path")"

  if [[ ! -L "$actual_target" ]]; then
    verify_fail "symlink missing: $target_path"
  elif [[ "$(readlink "$actual_target")" != "$DOTFILES_REPO_DIR/$source_path" ]]; then
    verify_fail "symlink target is incorrect: $target_path"
  else
    verify_pass "symlink installed: $target_path"
  fi
}

check_copy_mapping() {
  local -r mapping="$1"
  local source_path="${mapping%%|*}"
  local target_path="${mapping#*|}"
  local actual_target source_mode
  actual_target="$(system_target "$target_path")"
  source_mode="$(stat -c '%a' "$DOTFILES_REPO_DIR/$source_path")"

  if [[ -f "$actual_target" && ! -L "$actual_target" ]] &&
    cmp -s "$DOTFILES_REPO_DIR/$source_path" "$actual_target" &&
    [[ "$(stat -c '%a' "$actual_target")" == "$source_mode" ]]; then
    verify_pass "copy installed: $target_path"
  else
    verify_fail "copy missing or outdated: $target_path"
  fi
}

check_executable() {
  local -r path="$1"
  [[ -x "$path" ]] && verify_pass "executable exists: $path" || verify_fail "executable missing: $path"
}

check_service() {
  local -r service="$1"
  systemctl is-enabled --quiet "$service" >/dev/null 2>&1 && verify_pass "service enabled: $service" || verify_fail "service not enabled: $service"
  systemctl is-active --quiet "$service" >/dev/null 2>&1 && verify_pass "service active: $service" || verify_fail "service not active: $service"
}

check_mise_tool() {
  local -r tool="$1"
  if MISE_CONFIG_FILE="$DOTFILES_REPO_DIR/$mise_config" mise exec -- bash -c 'command -v "$1"' _ "$tool" >/dev/null 2>&1; then
    verify_pass "mise tool available: $tool"
  else
    verify_fail "mise tool missing: $tool"
  fi
}

verify_platform() {
  local links_only=false
  local arg mapping item

  for arg in "$@"; do
    case "$arg" in
    --links-only) links_only=true ;;
    *) dotfiles_log "Unknown verify argument: $arg"; return 1 ;;
    esac
  done

  for mapping in "${links[@]}"; do check_link_mapping "$mapping"; done
  for mapping in "${copies[@]}"; do check_copy_mapping "$mapping"; done

  if [[ "$links_only" == false ]]; then
    platform_verify
    for item in "${required_commands[@]}"; do check_command "$item"; done
    for item in "${required_services[@]}"; do check_service "$item"; done
    for item in "${required_executables[@]}"; do check_executable "$item"; done
    for item in "${mise_tools[@]}"; do check_mise_tool "$item"; done
  fi

  printf '\nVerification complete: %d passed, %d failed\n' "$verify_passed" "$verify_failed"
  [[ "$verify_failed" -eq 0 ]]
}

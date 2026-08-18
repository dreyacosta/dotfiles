#!/bin/bash

run_system() {
  if [[ "${DOTFILES_SYSTEM_ROOT:-/}" == "/" ]]; then
    sudo "$@"
  else
    "$@"
  fi
}

validate_mapping() {
  local -r operation="$1"
  local -r mapping="$2"
  local source_path target_path

  if [[ "$mapping" != *"|"* ]]; then
    dotfiles_log "Invalid $operation mapping: $mapping"
    return 1
  fi

  source_path="${mapping%%|*}"
  target_path="${mapping#*|}"
  if [[ -z "$source_path" || -z "$target_path" || "$source_path" == /* || "$target_path" != /* ||
    ! -e "$DOTFILES_REPO_DIR/$source_path" ]]; then
    dotfiles_log "Invalid $operation mapping: $mapping"
    return 1
  fi

  if [[ "$operation" == "copy" && "$target_path" != /etc/* ]]; then
    dotfiles_log "Copy destination must be below /etc: $target_path"
    return 1
  fi
}

backup_name_for() {
  local -r target_path="$1"

  if [[ "$target_path" == "$HOME/"* ]]; then
    printf '%s\n' "${target_path#"$HOME/"}"
  else
    printf '%s\n' "${target_path#/}"
  fi
}

install_link() {
  local -r mapping="$1"
  local -r dry_run="$2"
  local source_path="${mapping%%|*}"
  local target_path="${mapping#*|}"
  local expected_source="$DOTFILES_REPO_DIR/$source_path"
  local actual_target="$target_path"
  local privileged=false

  if [[ "$target_path" == /etc/* ]]; then
    actual_target="$(system_target "$target_path")"
    privileged=true
  fi

  if [[ -L "$actual_target" && "$(readlink "$actual_target")" == "$expected_source" ]]; then
    dotfiles_log "Already installed: $target_path"
    return
  fi

  if [[ "$dry_run" == true ]]; then
    [[ -e "$actual_target" || -L "$actual_target" ]] && dotfiles_log "Would back up: $target_path"
    dotfiles_log "Would link: $target_path -> $expected_source"
    return
  fi

  if [[ -e "$actual_target" || -L "$actual_target" ]]; then
    if [[ "$privileged" == true ]]; then
      backup_system_target "$actual_target" "$(backup_name_for "$target_path")"
    else
      backup_target "$actual_target" "$(backup_name_for "$target_path")"
    fi
  fi

  if [[ "$privileged" == true ]]; then
    run_system mkdir -p "$(dirname "$actual_target")"
    run_system ln -s "$expected_source" "$actual_target"
  else
    mkdir -p "$(dirname "$actual_target")"
    ln -s "$expected_source" "$actual_target"
  fi
  dotfiles_log "Linked: $target_path -> $expected_source"
}

install_copy() {
  local -r mapping="$1"
  local -r dry_run="$2"
  local source_path="${mapping%%|*}"
  local target_path="${mapping#*|}"
  local expected_source="$DOTFILES_REPO_DIR/$source_path"
  local actual_target
  local source_mode

  actual_target="$(system_target "$target_path")"
  source_mode="$(stat -c '%a' "$expected_source")"

  if [[ -f "$actual_target" && ! -L "$actual_target" ]] &&
    cmp -s "$expected_source" "$actual_target" &&
    [[ "$(stat -c '%a' "$actual_target")" == "$source_mode" ]]; then
    dotfiles_log "Already installed: $target_path"
    return
  fi

  if [[ "$dry_run" == true ]]; then
    [[ -e "$actual_target" || -L "$actual_target" ]] && dotfiles_log "Would back up: $target_path"
    dotfiles_log "Would copy: $expected_source -> $target_path"
    return
  fi

  if [[ -e "$actual_target" || -L "$actual_target" ]]; then
    backup_system_target "$actual_target" "$(backup_name_for "$target_path")"
  fi

  run_system install -D -m "$source_mode" "$expected_source" "$actual_target"
  dotfiles_log "Copied: $expected_source -> $target_path"
}

install_platform() {
  local dry_run=false
  local arg mapping

  for arg in "$@"; do
    case "$arg" in
    --dry-run) dry_run=true ;;
    *) dotfiles_log "Unknown install argument: $arg"; return 1 ;;
    esac
  done

  for mapping in "${links[@]}"; do
    validate_mapping link "$mapping"
  done
  for mapping in "${copies[@]}"; do
    validate_mapping copy "$mapping"
  done

  export DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/dotfiles-wayback/$(date +%Y%m%d-%H%M%S)-$$}"
  dotfiles_log "Installing dotfiles for $platform_name"
  [[ "$dry_run" == true ]] && dotfiles_log "Dry run: no changes will be made"

  for mapping in "${links[@]}"; do
    install_link "$mapping" "$dry_run"
  done
  for mapping in "${copies[@]}"; do
    install_copy "$mapping" "$dry_run"
  done

  if [[ "$dry_run" == false ]]; then
    platform_post_install
  fi

  dotfiles_log "Installation complete"
}

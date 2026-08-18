#!/bin/bash

backup_target() {
  local -r target_path="$1"
  local -r backup_name="$2"
  local -r destination="$DOTFILES_BACKUP_DIR/$backup_name"

  if [[ -e "$destination" || -L "$destination" ]]; then
    dotfiles_log "Backup destination already exists: $destination"
    return 1
  fi

  dotfiles_log "Backing up: $target_path -> $destination"
  mkdir -p "$(dirname "$destination")"
  mv "$target_path" "$destination"
}

backup_system_target() {
  local -r target_path="$1"
  local -r backup_name="$2"
  local -r destination="$DOTFILES_BACKUP_DIR/$backup_name"
  local install_user install_group

  if [[ -e "$destination" || -L "$destination" ]]; then
    dotfiles_log "Backup destination already exists: $destination"
    return 1
  fi

  dotfiles_log "Backing up: $target_path -> $destination"
  mkdir -p "$(dirname "$destination")"
  run_system mv "$target_path" "$destination"
  if [[ "${DOTFILES_SYSTEM_ROOT:-/}" == "/" ]]; then
    install_user="${SUDO_USER:-${USER:-$(id -un)}}"
    install_group="$(id -gn "$install_user")"
    sudo chown -R "$install_user:$install_group" "$destination" 2>/dev/null || true
  fi
}

#!/bin/bash

system_target() {
  local -r target_path="$1"
  local -r system_root="${DOTFILES_SYSTEM_ROOT:-/}"

  if [[ "$system_root" == "/" ]]; then
    printf '%s\n' "$target_path"
  else
    printf '%s%s\n' "${system_root%/}" "$target_path"
  fi
}

#!/bin/bash

source "$DOTFILES_REPO_DIR/dependencies/common.sh"

readonly VOXTYPE_SMALL_MODEL_SHA256="1be3a9b2063867b937e64e2ec7483364a79917e157fa98c5d94b5c1fffea987b"
readonly VOXTYPE_SMALL_MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"

require_omarchy_baseline() {
  local -r commands=(docker git mise tmux)
  local command_name
  for command_name in "${commands[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || {
      dotfiles_log "Missing Omarchy baseline command: $command_name"
      return 1
    }
  done
}

install_voxtype_model() {
  local -r models_dir="${XDG_DATA_HOME:-$HOME/.local/share}/voxtype/models"
  local -r model_path="$models_dir/ggml-small.bin"
  local model_download

  if [[ -f "$model_path" ]] && printf '%s  %s\n' "$VOXTYPE_SMALL_MODEL_SHA256" "$model_path" | sha256sum --check --status; then
    dotfiles_log "Voxtype model already installed: $model_path"
    return
  fi

  model_download="$(mktemp)"
  if ! curl -fsSL "$VOXTYPE_SMALL_MODEL_URL" -o "$model_download"; then
    rm -f "$model_download"
    return 1
  fi
  if ! printf '%s  %s\n' "$VOXTYPE_SMALL_MODEL_SHA256" "$model_download" | sha256sum --check --status; then
    rm -f "$model_download"
    dotfiles_log "Voxtype model checksum mismatch"
    return 1
  fi
  mkdir -p "$models_dir"
  install -m 0644 "$model_download" "$model_path"
  rm -f "$model_download"
  dotfiles_log "Installed Voxtype model: $model_path"
}

install_dependencies() {
  require_omarchy_baseline
  omarchy pkg add base-devel curl file git herdr jq keyd procps-ng voxtype-bin wtype
  sudo systemctl enable --now keyd
  install_voxtype_model
  systemctl --user enable voxtype.service
  install_linux_homebrew
  activate_linux_homebrew
  install_mise_tools
  HERDR_EXECUTABLE="${DOTFILES_OMARCHY_HERDR:-/usr/bin/herdr}" install_herdr_plugins
  install_tmux_sessionizer
}

#!/bin/bash

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly BIN_DIR="$REPO_DIR/bin"
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

source "$REPO_DIR/scripts/install/common.sh"

platform_links=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/omarchy/bashrc|$HOME/.bashrc"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/herdr/config.toml|$CONFIG_HOME/herdr/config.toml"
  "config/hypr/bindings.lua|$CONFIG_HOME/hypr/bindings.lua"
  "config/hypr/input.lua|$CONFIG_HOME/hypr/input.lua"
  "config/ghostty/config|$CONFIG_HOME/ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$CONFIG_HOME/ghostty/themes/Tokyonight Night"
  "config/git/linux|$CONFIG_HOME/git/config"
)

etc_links=(
  "etc/keyd/default.conf|/etc/keyd/default.conf"
)

etc_copies=(
  "etc/modprobe.d/touchbar.conf|/etc/modprobe.d/touchbar.conf"
  "etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf|/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf"
  "etc/systemd/system/touchbar-backlight.service|/etc/systemd/system/touchbar-backlight.service"
  "etc/systemd/system-sleep/touchbar-backlight|/etc/systemd/system-sleep/touchbar-backlight"
)

is_touchbar_mac() {
  local system_vendor=""
  local product_name=""
  local usb_device

  [[ -r /sys/class/dmi/id/sys_vendor ]] && read -r system_vendor </sys/class/dmi/id/sys_vendor
  [[ -r /sys/class/dmi/id/product_name ]] && read -r product_name </sys/class/dmi/id/product_name
  [[ "$system_vendor" == "Apple Inc." && "$product_name" == MacBookPro* ]] || return 1

  for usb_device in /sys/bus/usb/devices/*; do
    if [[ -r "$usb_device/idVendor" && -r "$usb_device/idProduct" ]] &&
      [[ "$(<"$usb_device/idVendor")" == "05ac" && "$(<"$usb_device/idProduct")" == "8102" ]]; then
      return 0
    fi
  done

  return 1
}

main() {
  local dry_run=false
  local arg

  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && dry_run=true
  done

  install_dotfiles "omarchy" "$@"

  if [[ "$dry_run" == false ]]; then
    sudo systemctl daemon-reload
    sudo systemctl enable --now touchbar-backlight.service
    dotfiles-log "Enabled Touch Bar backlight service"

    if is_touchbar_mac; then
      dotfiles-log "Touch Bar configuration installed"
      dotfiles-log "Run: sudo limine-mkinitcpio"
      dotfiles-log "Then reboot to apply the Touch Bar module option during early boot"
    fi

    sudo keyd reload
    dotfiles-log "Reloaded keyd configuration"

    if herdr status server >/dev/null 2>&1; then
      herdr server reload-config
      dotfiles-log "Reloaded Herdr configuration"
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

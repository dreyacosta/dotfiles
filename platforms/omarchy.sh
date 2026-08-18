#!/bin/bash

platform_name="omarchy"
touchbar_mac=false
links+=(
  "home/ideavimrc|$HOME/.ideavimrc"
  "shell/platform/omarchy/bashrc|$HOME/.bashrc"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/herdr/config.toml|$CONFIG_HOME/herdr/config.toml"
  "config/hypr/bindings.lua|$CONFIG_HOME/hypr/bindings.lua"
  "config/hypr/input.lua|$CONFIG_HOME/hypr/input.lua"
  "config/ghostty/config|$CONFIG_HOME/ghostty/config"
  "config/ghostty/themes/Tokyonight Night|$CONFIG_HOME/ghostty/themes/Tokyonight Night"
  "config/git/linux|$CONFIG_HOME/git/config"
  "etc/keyd/default.conf|/etc/keyd/default.conf"
)
required_commands+=(brew docker herdr keyd)
required_services=(keyd)
mise_config="config/mise/config.toml"
mise_tools=(go node python cspell-lsp)

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

platform_prepare() {
  if { [[ "${DOTFILES_SYSTEM_ROOT:-/}" != "/" && "${DOTFILES_TEST_TOUCHBAR:-false}" == true ]]; } || is_touchbar_mac; then
    touchbar_mac=true
    copies+=(
      "etc/modprobe.d/touchbar.conf|/etc/modprobe.d/touchbar.conf"
      "etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf|/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf"
      "etc/systemd/system/touchbar-backlight.service|/etc/systemd/system/touchbar-backlight.service"
      "etc/systemd/system-sleep/touchbar-backlight|/etc/systemd/system-sleep/touchbar-backlight"
    )
  fi
}

platform_post_install() {
  if [[ "$touchbar_mac" == true ]]; then
    sudo systemctl daemon-reload
    sudo systemctl enable --now touchbar-backlight.service
    dotfiles_log "Enabled Touch Bar backlight service"
    dotfiles_log "Run: sudo limine-mkinitcpio"
    dotfiles_log "Then reboot to apply the Touch Bar module option during early boot"
  fi
  sudo keyd reload
  dotfiles_log "Reloaded keyd configuration"
  if herdr status server >/dev/null 2>&1; then
    herdr server reload-config
    dotfiles_log "Reloaded Herdr configuration"
  fi
}

platform_verify() {
  command -v omarchy >/dev/null 2>&1 && verify_pass "platform command available: omarchy" || verify_fail "platform command missing: omarchy"
  [[ -f /usr/share/omarchy/default/bash/rc ]] && verify_pass "file exists: /usr/share/omarchy/default/bash/rc" || verify_fail "file missing: /usr/share/omarchy/default/bash/rc"
}

#!/bin/bash

platform_name="ubuntu-vps"
links+=(
  "shell/platform/ubuntu-vps/bashrc|$HOME/.bashrc"
  "config/git/linux|$CONFIG_HOME/git/config"
)
required_commands+=(brew docker)
required_services=(docker)
platform_verify() {
  if [[ -r /etc/os-release ]] && . /etc/os-release && [[ "${ID:-}" == "ubuntu" ]]; then
    verify_pass "platform is Ubuntu"
  else
    verify_fail "platform is not Ubuntu"
  fi

  if id -nG | tr ' ' '\n' | rg -qx docker; then
    verify_pass "current user belongs to the docker group"
  else
    verify_fail "current user does not belong to the docker group; log out and back in after installation"
  fi

  dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -q 'ok installed' && verify_pass "APT package installed: jq" || verify_fail "APT package missing: jq"
  brew list --formula herdr >/dev/null 2>&1 && verify_pass "Homebrew package installed: herdr" || verify_fail "Homebrew package missing: herdr"
}

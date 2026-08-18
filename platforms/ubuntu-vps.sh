#!/bin/bash

platform_name="ubuntu-vps"
links+=(
  "shell/platform/ubuntu-vps/bashrc|$HOME/.bashrc"
  "config/mise/config.toml|$CONFIG_HOME/mise/config.toml"
  "config/git/linux|$CONFIG_HOME/git/config"
)
required_commands+=(brew docker)
required_services=(docker)
mise_config="config/mise/config.toml"
mise_tools=(go node python cspell-lsp)

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
}

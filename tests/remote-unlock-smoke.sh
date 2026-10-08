#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

# Exercise the actual generated override against classic and already configured boots.
awk '/^# Managed by dotfiles/{copy=1} /^EOF_CONFIG$/{copy=0} copy' \
  "$repo_dir/dependencies/omarchy-remote-unlock.sh" |
  sed -e 's/\\\$/\$/g' -e 's/\\"/"/g' -e 's/\$driver/r8169/g' > "$test_dir/override.conf"
for encrypt_hook in encrypt encryptssh; do
  MODULES=(thunderbolt)
  HOOKS=(base udev plymouth keyboard block "$encrypt_hook" filesystems fsck btrfs-overlayfs resume)
  source "$test_dir/override.conf"
  [[ "${MODULES[*]}" == 'thunderbolt r8169' ]]
  [[ "${HOOKS[*]}" == 'base udev keyboard block netconf tailscale encryptssh filesystems fsck btrfs-overlayfs resume' ]]
  [[ "${MODULES[*]}" == 'thunderbolt r8169' ]]
  source "$test_dir/override.conf"
  [[ "${MODULES[*]}" == 'thunderbolt r8169' ]]
  [[ "${HOOKS[*]}" == 'base udev keyboard block netconf tailscale encryptssh filesystems fsck btrfs-overlayfs resume' ]]
done

# Match the script's network-parameter detection against existing DHCP/static settings.
for network_parameter in ip=dhcp ip=:::::eth1:dhcp ip=192.168.1.50::192.168.1.1:255.255.255.0::eth0:none; do
  printf 'KERNEL_CMDLINE[default]+=" %s"\n' "$network_parameter" > "$test_dir/limine"
  rg -q '(^|[[:space:]"\x27])ip=' "$test_dir/limine"
done
printf 'KERNEL_CMDLINE[default]+="cryptdevice=PARTUUID=example:root"\n' > "$test_dir/limine"
if rg -q '(^|[[:space:]"\x27])ip=' "$test_dir/limine"; then
  exit 1
fi
printf 'Remote unlock smoke test passed\n'

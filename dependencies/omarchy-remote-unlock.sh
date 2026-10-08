#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/lib/dotfiles/log.sh"

dry_run=false
interface=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true; shift ;;
    --interface) interface="${2:?Missing interface name}"; shift 2 ;;
    --help|-h)
      printf 'Usage: bash dependencies/omarchy-remote-unlock.sh [--dry-run] [--interface eno1]\n'
      exit 0 ;;
    *) dotfiles_log "Unknown argument: $1"; exit 1 ;;
  esac
done

fail() { dotfiles_log "$*"; exit 1; }
[[ $EUID -ne 0 ]] || fail "Run as your normal user; the script uses sudo when needed."
for command_name in ip pacman yay rg limine-mkinitcpio; do
  command -v "$command_name" >/dev/null || fail "Missing command: $command_name"
done
[[ -f /etc/mkinitcpio.conf && -f /etc/default/limine ]] || fail "Expected Omarchy mkinitcpio and Limine configuration."
[[ -n "$interface" ]] || interface="$(ip -4 route show default | awk '$0 !~ / tailscale0 / {for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')"
[[ "$interface" =~ ^[a-zA-Z0-9_.:-]+$ ]] || fail "Specify a wired interface with --interface."
[[ -e /sys/class/net/$interface/device && ! -d /sys/class/net/$interface/wireless ]] || fail "Interface must be physical Ethernet: $interface"
driver_path="$(readlink -f "/sys/class/net/$interface/device/driver/module")"
driver="${driver_path##*/}"
[[ "$driver" =~ ^[a-zA-Z0-9_]+$ && -d "$driver_path" ]] || fail "Cannot identify Ethernet driver."

# Evaluate the same drop-ins mkinitcpio uses, without changing the machine.
hooks="$(bash -c 'source /etc/mkinitcpio.conf; for f in /etc/mkinitcpio.conf.d/*.conf; do [[ ! -f "$f" ]] || source "$f"; done; printf " %s " "${HOOKS[*]}"')"
[[ "$hooks" != *" systemd "* && "$hooks" != *" sd-encrypt "* ]] || fail "Only classic encrypt/encryptssh initramfs is supported."
[[ "$hooks" == *" encrypt "* || "$hooks" == *" encryptssh "* ]] || fail "No supported encryption hook found."

dotfiles_log "Ethernet: $interface; driver: $driver"
dotfiles_log "Install packages, register/reuse initrd node, remove Plymouth, enable DHCP, rebuild with Limine."
if [[ "$dry_run" == true ]]; then
  dotfiles_log "Dry run: no changes made."
  exit 0
fi

sudo -v
backup_dir="/var/backups/dotfiles-remote-unlock/$(date +%Y%m%d-%H%M%S)-$$"
sudo mkdir -p "$backup_dir"
sudo cp -a /etc/default/limine /etc/mkinitcpio.conf.d "$backup_dir/"
dotfiles_log "Configuration backup: $backup_dir"
sudo pacman -S --needed mkinitcpio-utils
yay -S --needed mkinitcpio-tailscale mkinitcpio-extras
if ! sudo test -s /etc/initcpio/tailscale/tailscaled.state; then
  setup-initcpio-tailscale
fi
sudo test -s /etc/initcpio/tailscale/default.env || fail "Missing Tailscale daemon settings."
sudo test -d /etc/initcpio/tailscale/ssh || fail "Tailscale SSH keys missing; run setup-initcpio-tailscale with SSH enabled."

sudo tee /etc/mkinitcpio.conf.d/zz-remote-unlock.conf >/dev/null <<EOF_CONFIG
# Managed by dotfiles' optional remote unlock setup.
[[ " \${MODULES[*]} " == *" $driver "* ]] || MODULES+=($driver)
_remote_hooks=()
for _remote_hook in "\${HOOKS[@]}"; do
    case "\$_remote_hook" in
        plymouth|netconf|tailscale) ;;
        encrypt|encryptssh) _remote_hooks+=(netconf tailscale encryptssh) ;;
        *) _remote_hooks+=("\$_remote_hook") ;;
    esac
done
HOOKS=("\${_remote_hooks[@]}")
unset _remote_hooks _remote_hook
EOF_CONFIG

# Keep an existing ip= setting rather than duplicating or overriding it.
if ! rg -q '(^|[[:space:]"\x27])ip=' /etc/default/limine /etc/limine-entry-tool.d 2>/dev/null; then
  sudo tee -a /etc/default/limine >/dev/null <<'EOF_CMDLINE'

# Networking for remote disk unlock
KERNEL_CMDLINE[default]+=" ip=dhcp netconf_timeout=30"
EOF_CMDLINE
fi
sudo limine-mkinitcpio
setup-initcpio-tailscale --check
dotfiles_log "Disable initrd node key expiry and permit Tailscale SSH as root in the admin console."
dotfiles_log "Test while physically present: reboot, ssh root@$(hostname -s)-initrd, then reconnect normally."
dotfiles_log "No reboot performed. See docs/remote-disk-unlock.md for verification and recovery."

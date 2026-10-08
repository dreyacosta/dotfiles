# Remote disk unlock on Omarchy

The optional setup supports Ethernet, DHCP, Limine, and the classic BusyBox
`encrypt` / `encryptssh` hooks. It is separate from normal dotfiles installation.
It preserves disk identifiers, hardware modules, resume, and filesystem hooks.

## Setup

Run on the machine whose encrypted disk you want to unlock, as your normal user:

```bash
cd ~/projects/dotfiles
bash dependencies/omarchy-remote-unlock.sh --dry-run
bash dependencies/omarchy-remote-unlock.sh
```

The script detects the Ethernet driver from the default IPv4 route. If that
route uses Wi-Fi or another device, specify the wired interface explicitly:

```bash
bash dependencies/omarchy-remote-unlock.sh --interface eno1
```

It backs up configuration under `/var/backups/dotfiles-remote-unlock/`, installs
`mkinitcpio-utils`, `mkinitcpio-extras`, and `mkinitcpio-tailscale`, and registers
an early-boot Tailscale node if one does not already exist. Complete the printed
browser authentication when registering a new node. Existing node keys are reused.
No passwords or Tailscale credentials are stored in this repository.

It writes `/etc/mkinitcpio.conf.d/zz-remote-unlock.conf`, removes Plymouth,
adds the Ethernet driver and `netconf tailscale encryptssh`, and enables DHCP
in `/etc/default/limine` if no `ip=` configuration exists there or in Limine's
entry-tool drop-ins. Existing network parameters are preserved; review any
custom static configuration yourself. Repeated runs do not duplicate hooks or
the DHCP line. It rebuilds UKIs using `limine-mkinitcpio` and runs the upstream
check. It does not reboot.

In the [Tailscale admin console](https://console.tailscale.com/admin/machines):

- Disable key expiry for the new `<hostname>-initrd` device.
- Permit your client to connect to it using Tailscale SSH as `root`.
- Restrict that node's access to the rest of your tailnet: its node key is in
  the unencrypted boot image.

## Verification

Keep a screen and keyboard available for the first test. Reboot, leave the
local disk-password prompt unanswered, then run from another tailnet device:

```bash
ssh root@homelab-initrd
# Enter the disk-encryption password, then wait for normal boot.
ssh dreyacosta@homelab
```

Replace host and username for other machines. Confirm normal SSH works before
repeating with the screen and keyboard disconnected. Both tests succeeded on
homelab during initial setup.

Plymouth must be absent from the build hooks: its graphical prompt previously
kept boot waiting after a successful remote disk unlock. Text boot logs can
cover the local password prompt. The package's cleanup may print `no process
killed` or `bad signal name '-quiet'` when Plymouth is absent; verify success
by reconnecting to the booted machine. Removing Plymouth avoids depending on that cleanup command. This automation
does not patch package files.

The upstream checker may report `no built image to inspect` with Limine's UKIs.
That is not verification of image contents: check successful build output and
perform the reboot test. Retest after kernel or boot-package updates before
relying on unattended reboots.

## Recovery

If remote unlock hangs, restart and unlock locally without connecting to the
initrd SSH node. Once booted, disable the override and restore the saved Limine
configuration (replace the backup path with the one printed by the script):

```bash
sudo mv /etc/mkinitcpio.conf.d/zz-remote-unlock.conf /etc/zz-remote-unlock.conf.disabled
sudo cp -a /var/backups/dotfiles-remote-unlock/<backup>/limine /etc/default/limine
sudo limine-mkinitcpio
```

A backup from a repeated run may already include remote networking; use the
first backup to recover the pre-setup Limine settings. Keep physical recovery
access available until the rebuilt image has passed a local reboot test.

References: [Tailscale initramfs hook](https://github.com/dangra/mkinitcpio-tailscale)
and [encryptssh utilities](https://github.com/grazzolini/mkinitcpio-utils).

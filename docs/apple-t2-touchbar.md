# Apple T2 Touch Bar workaround

## Purpose

The Omarchy installer includes a workaround for an Apple T2 Touch Bar whose
backlight turns on or flickers after boot, input, or suspend/resume.

The observed behavior has two parts:

- The `hid_appletb_kbd` automatic dimming state machine changes brightness in
  response to Touch Bar activity and timeouts.
- After resume, the backlight device can report brightness zero while the
  physical Touch Bar remains illuminated until its driver is rebound.

## Installed files

Only when the installer detects the supported Apple hardware, it copies these
files to `/etc` as real files so they remain available independently of the
repository and home filesystem:

| Repository source | Installed destination | Purpose |
| --- | --- | --- |
| `etc/modprobe.d/touchbar.conf` | `/etc/modprobe.d/touchbar.conf` | Disables `hid_appletb_kbd` automatic dimming. |
| `etc/systemd/system/touchbar-backlight.service` | `/etc/systemd/system/touchbar-backlight.service` | Turns the backlight off at normal boot. |
| `etc/systemd/system-sleep/touchbar-backlight` | `/etc/systemd/system-sleep/touchbar-backlight` | Applies the boot or post-resume backlight action. |
| `etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf` | `/etc/systemd/system/systemd-suspend.service.d/touchbar-backlight.conf` | Runs the post-resume action after systemd suspend. |

The installer verifies that the system is an Apple MacBook Pro and that the
Apple `05ac:8102` Touch Bar backlight device exists before installing or
enabling any part of the workaround. Non-Apple computers and Macs without this
Touch Bar device receive no Touch Bar files or systemd service. The installed
helper repeats the same checks before changing hardware state as a defensive
safeguard.

## Installation

Run the normal Omarchy installer:

```bash
bin/dotfiles install omarchy
```

On matching hardware, rebuild the Unified Kernel Image (UKI) and reboot:

```bash
sudo limine-mkinitcpio
sudo reboot
```

`limine-mkinitcpio` rebuilds the bootable UKI so the copied modprobe option is
present when the Touch Bar kernel module is first loaded. Re-running only the
installer does not update an existing UKI.

## Verification

After reboot, run:

```bash
cat /sys/module/hid_appletb_kbd/parameters/autodim
cat /sys/class/backlight/appletb_backlight/{brightness,actual_brightness}
systemctl status touchbar-backlight.service
```

The expected values are `N`, followed by `0` and `0`. The service is a one-shot
unit, so `inactive (dead)` after a successful run is normal.

Close and reopen the lid, then check the brightness values again to exercise
the resume path.

## Logs and recovery

Inspect the boot service and resume helper logs with:

```bash
journalctl -b -u touchbar-backlight.service
journalctl -b -t touchbar-backlight
```

If the physical backlight remains on while the reported brightness is zero,
manually reproduce the resume reset with:

```bash
device_id="$(basename "$(readlink -f /sys/class/backlight/appletb_backlight/device)")"
echo "$device_id" | sudo tee /sys/bus/hid/drivers/hid-appletb-bl/unbind
echo "$device_id" | sudo tee /sys/bus/hid/drivers/hid-appletb-bl/bind
echo 0 | sudo tee /sys/class/backlight/appletb_backlight/brightness
```

To turn the backlight on manually, write a supported value from zero through
`max_brightness` to `brightness`. The tested device exposes a maximum of `2`:

```bash
cat /sys/class/backlight/appletb_backlight/max_brightness
echo 2 | sudo tee /sys/class/backlight/appletb_backlight/brightness
```

The boot and resume actions will turn it off again.

# Installation, updates, and verification

## Supported platforms

The repository has install and verification entry points for macOS, Omarchy,
and Ubuntu VPS environments. Run commands from the repository root.

## New machine

Install platform dependencies first, then install the configuration:

```bash
./scripts/install/macos-deps.sh
./scripts/install/macos.sh
```

```bash
./scripts/install/omarchy-deps.sh
./scripts/install/omarchy.sh
```

```bash
./scripts/install/ubuntu-vps-deps.sh
./scripts/install/ubuntu-vps.sh
```

Dependency scripts install or configure tools. Install scripts create the
managed links and `/etc` files. Both roles are intentionally separate so a
configuration can be reinstalled without repeating dependency setup.

Preview an install with `--dry-run`:

```bash
./scripts/install/omarchy.sh --dry-run
```

Existing targets that need replacement are backed up below
`~/dotfiles-wayback` before the new target is installed.

## Platform-specific follow-up

On a supported Apple T2 MacBook Pro running Omarchy, the installer adds the
Touch Bar configuration and prints an additional instruction to rebuild the
Unified Kernel Image and reboot. It skips all Touch Bar files and service
actions on other hardware. Follow the [Apple T2 Touch Bar guide](apple-t2-touchbar.md)
for that workflow.

Some dependency changes, such as group membership, may also require logging
out and back in. Follow any messages printed by the selected installer.

## Verification

Run the matching read-only verification script after installation:

```bash
./scripts/verify/macos.sh
./scripts/verify/omarchy.sh
./scripts/verify/ubuntu-vps.sh
```

Each check reports `PASS` or `FAIL` and finishes with totals. Verification
covers the expected platform, commands, links, mise tools, and relevant system
services; it does not modify the machine.

For installer development, run the isolated smoke test:

```bash
./tests/install-smoke.sh
```

## Updating an installed machine

Pull the repository changes and rerun the platform install script. Correct
links are left in place, while changed `/etc` copies are backed up and
reinstalled.

If an update changes an early-boot configuration on an Omarchy system using a
UKI, rebuild the UKI before rebooting. The Touch Bar installer explicitly logs
this instruction on matching Apple hardware.

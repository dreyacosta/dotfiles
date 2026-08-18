# Installation and recovery

## New machine

The supported platforms are `macos`, `omarchy`, and `ubuntu-vps`. Clone the
repository and inspect the proposed configuration changes before installing:

```bash
git clone https://github.com/dreyacosta/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bin/dotfiles dependencies <platform>
bin/dotfiles install <platform> --dry-run
bin/dotfiles install <platform>
bin/dotfiles verify <platform>
```

Dependency provisioning and configuration installation are separate. Rerunning
an install does not repeat package-manager work.

The dependency command can install packages, enable services, and add the user
to system groups. Read its output for required logout or reboot steps. On macOS,
Node is managed by nvm while Go and Python are managed by mise. Linux platforms
use mise for Go, Node, and Python.

## Backups and recovery

Before replacing a target, the installer moves it into a timestamped directory
below `~/dotfiles-wayback`. The path beneath the home directory or `/etc` is
preserved inside the backup.

To restore a file:

1. Find the applicable timestamped backup directory.
2. Remove the new symlink or copied file.
3. Move the backed-up file to its original destination.
4. Run `bin/dotfiles verify <platform>` to inspect the resulting state.

Restoration is intentionally manual so an old machine-wide configuration is
never applied automatically.

## Updating

Pull repository changes, preview them, install them, and verify the result:

```bash
git pull --ff-only
bin/dotfiles install <platform> --dry-run
bin/dotfiles install <platform>
bin/dotfiles verify <platform>
```

Correct links and copies are left unchanged. Files in application-managed
directories are linked individually, so unrelated application state is
preserved.

Mise configurations currently use `latest` tool versions. A dependency rerun
can therefore upgrade tools without a corresponding repository change.

## Troubleshooting

- A wrong symlink after moving the repository is corrected by rerunning install.
- A Docker group failure usually requires logging out and back in after dependency provisioning.
- Missing mise tools can be repaired by rerunning the platform dependency command.
- A failed service check should be investigated with `systemctl status <service>`.
- An interrupted install may leave earlier mappings applied; inspect the logged backup directory before rerunning.

On a supported Apple T2 MacBook Pro running Omarchy, follow the
[Touch Bar guide](apple-t2-touchbar.md) after installation. The installer only
adds those files when it detects the matching hardware.

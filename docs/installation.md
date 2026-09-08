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
to system groups. Read its output for required logout or reboot steps. Every
platform uses the shared Mise configuration for development tools. macOS also
installs nvm from its official GitHub repository and installs its current LTS
Node. Mise skips its Node declaration on macOS; the cspell command-line tools
remain Mise-managed and run against nvm's Node there.

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

The shared Mise configuration owns Go, Python, Bun, and npm-backed command-line
tools on every platform, plus Node on Linux. Herdr is not Mise-managed: Omarchy
owns it as an Arch package, while macOS and Ubuntu use its
officially supported Homebrew package. See [Tool management](tool-management.md)
for the cross-platform ownership convention.
Mise configurations currently use `latest` tool versions. A dependency rerun
can therefore upgrade tools without a corresponding repository change.

### Voxtype

On Omarchy, dependency provisioning installs Voxtype and its typing backend,
downloads the configured multilingual Whisper model, and enables the user
service. Configuration installation starts the service after linking its
configuration. Omarchy's default F9 push-to-talk and Super+Control+X toggle
bindings remain available. Physical Control+Semicolon provides an additional
push-to-talk binding through keyd without replacing Super+V universal paste.

On macOS, launch Voxtype after installation and complete its setup wizard.
Download the `small` model, grant Microphone and Accessibility access, and
enable launch at login. macOS requires those privacy permissions to be granted
interactively.

## Troubleshooting

- A wrong symlink after moving the repository is corrected by rerunning install.
- A Docker group failure usually requires logging out and back in after dependency provisioning.
- Missing mise tools can be repaired by rerunning the platform dependency command.
- A failed service check should be investigated with `systemctl status <service>`.
- An interrupted install may leave earlier mappings applied; inspect the logged backup directory before rerunning.

On a supported Apple T2 MacBook Pro running Omarchy, follow the
[Touch Bar guide](apple-t2-touchbar.md) after installation. The installer only
adds those files when it detects the matching hardware.

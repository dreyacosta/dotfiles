# dotfiles

Personal configuration for macOS, Omarchy, and Ubuntu VPS environments.

## Install

Clone the repository, then run the commands for the target platform from the
repository root:

```bash
git clone https://github.com/dreyacosta/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bin/dotfiles dependencies macos
bin/dotfiles install macos --dry-run
bin/dotfiles install macos
bin/dotfiles verify macos
```

Replace `macos` with `omarchy` or `ubuntu-vps` as needed. List the supported
platforms with:

```bash
bin/dotfiles platforms
```

The dependency command installs packages and may change system services. The
install command manages configuration links and selected `/etc` files. Existing
targets are moved below `~/dotfiles-wayback` before replacement.

## Documentation

- [Installation, updates, recovery, and troubleshooting](docs/installation.md)
- [Maintainer guide and installer design](docs/maintenance.md)
- [Apple T2 Touch Bar workaround](docs/apple-t2-touchbar.md)

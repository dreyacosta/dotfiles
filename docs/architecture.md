# Repository structure and installer architecture

## Top-level directories

| Path | Purpose |
| --- | --- |
| `bin/` | Reusable installation, backup, and logging commands. |
| `config/` | Application configuration installed under XDG config locations or application-specific paths. |
| `docs/` | Repository architecture, installation, and operational notes. |
| `etc/` | System-level configuration installed under `/etc`, using links or copies according to boot requirements. |
| `home/` | Individual files installed directly in the user's home directory. |
| `scripts/install/` | Platform entry points and dependency installers. |
| `scripts/verify/` | Read-only checks for installed links, commands, tools, and services. |
| `shell/` | Shared shell fragments and platform-specific shell entry points. |
| `tests/` | Installer smoke tests using temporary home and system directories. |

## Configuration ownership

`config/` is grouped by application. Complete configurations, such as Neovim
and tmux, can be linked as directories. Directories also managed by an
application or distribution, such as Hyprland and Ghostty, receive links only
for the files owned by this repository.

`shell/common/` contains fragments shared across shells and platforms.
`shell/bash/` and `shell/zsh/` contain shell-specific initialization, while
`shell/platform/` provides the `.bashrc` or `.zshrc` entry point for macOS,
Omarchy, and Ubuntu VPS installations.

`etc/` mirrors the destination hierarchy below `/etc`. Files needed before the
home filesystem is available must be copied. Other system configuration may be
linked when keeping it connected to the repository is safe.

## Installation flow

Each platform entry point defines three mapping arrays using
`source|destination` values:

- `platform_links` contains user-level links specific to that platform.
- `etc_links` contains system-level links under `/etc`.
- `etc_copies` contains system-level files that must be independent of the
  repository and home filesystem.

The platform script sources `scripts/install/common.sh`, which combines its
platform mappings with the shared mappings and invokes:

- `bin/dotfiles-install` for home and XDG symlinks.
- `bin/dotfiles-install-etc` for privileged `/etc` links and copies.

The `/etc` installer preserves the source mode when copying a file. It skips an
existing copy only when both its contents and mode already match.

## Backups and idempotency

Before replacing an existing target, the installers move it below a timestamped
directory in `~/dotfiles-wayback`. The relative destination path is retained so
files from the home directory and `/etc` remain identifiable.

An already-correct link or copy is left unchanged. `--dry-run` reports the
links, copies, and backups that would be performed without changing the
machine.

## Platform boundaries

Shared mappings live in `scripts/install/common.sh`. Platform mappings should
remain in their corresponding entry point:

- `scripts/install/macos.sh`
- `scripts/install/omarchy.sh`
- `scripts/install/ubuntu-vps.sh`

This keeps platform-specific paths and post-install actions out of otherwise
portable configuration.

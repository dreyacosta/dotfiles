# dotfiles

Personal configuration for macOS, Omarchy, and Ubuntu VPS environments.

## Install

From the repository root, run the matching entry point:

```bash
./scripts/install/macos.sh
./scripts/install/omarchy.sh
./scripts/install/ubuntu-vps.sh
```

Pass `--dry-run` to preview backups and links without changing the system.

After installation, run the matching read-only verification script:

```bash
./scripts/verify/macos.sh
./scripts/verify/omarchy.sh
./scripts/verify/ubuntu-vps.sh
```

Dependency installers are available at `scripts/install/macos-deps.sh`,
`scripts/install/omarchy-deps.sh`, and `scripts/install/ubuntu-vps-deps.sh`.
The macOS bootstrap installs nvm from its official upstream installer rather
than Homebrew.

The Omarchy dependency script targets the current Omarchy baseline and expects
its standard Docker, Git, mise, tmux, Neovim, fzf, ripgrep, fd, Starship,
zoxide, bat, eza, and gum commands to already be available. It installs and
enables keyd for the system keyboard configuration. Mise installs the configured
Go, Node, and Python runtimes on Linux; macOS uses mise for Go and Python while
nvm remains the Node version manager.

Each entry point resolves the repository location from its own path, so calling
it through an absolute path does not depend on the current working directory.

Installers create symlinks from this repository and back up existing targets to
`~/dotfiles-wayback`. Git and tmux use their XDG locations under `~/.config`.
For compatibility, both `~/.tmux.conf` and `~/.config/tmux` point into this
repository.

Complete configurations such as Neovim and tmux are linked as directories.
Mixed or application-managed directories such as Herdr, Hyprland, Ghostty,
Mise, and Karabiner receive links only for the files maintained in this
repository.

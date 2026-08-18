# Maintenance

## Design

`bin/dotfiles` is the public interface. It loads a platform manifest and invokes
the installer, verifier, or dependency workflow behind that interface.

Platform manifests under `platforms/` are the single source of truth for
managed links, copies, commands, services, and mise tools. Both installation
and verification consume the same declarations. Loading a manifest must be
side-effect free; machine changes belong in dependency workflows or explicit
post-install hooks.

The installer modules under `lib/dotfiles/` own validation, backups, dry-run
behavior, idempotency, filesystem changes, and summaries. Dependency scripts
under `dependencies/` own package managers, remote installers, services, and
group membership.

## Invariants

- A mapping is `repository/source|absolute destination`.
- Every mapping is validated before the first filesystem change.
- Existing targets are backed up before replacement.
- A correct link or copy is unchanged on repeated installation.
- Files needed before the home filesystem is mounted are copied into `/etc`.
- Other `/etc` configuration may be linked when it is safe to depend on the repository.
- Whole directories are linked only when this repository owns the complete directory.
- Mixed or application-managed directories receive individual file links.
- Platform manifests declare state; post-install hooks contain unavoidable imperative actions.

## Adding managed configuration

1. Put the source below `config/`, `home/`, `shell/`, or `etc/`.
2. Add one mapping to `platforms/common.sh` or the applicable platform manifest.
3. Add a dependency declaration only when the configuration requires a new tool.
4. Run `bin/dotfiles install <platform> --dry-run`.
5. Run `bin/dotfiles test`.
6. Install and verify on the matching platform when the change affects live system behavior.

The verifier automatically checks declared mappings. Add `platform_verify`
logic only for behavior that cannot be derived from those mappings.

## Adding a platform

1. Add `platforms/<name>.sh` with mappings and verification declarations.
2. Add `dependencies/<name>.sh` with `install_dependencies`.
3. Register the name in `bin/dotfiles platforms`.
4. Add compatibility wrappers only if an established command path needs preserving.
5. Add an isolated CLI smoke-test scenario.
6. Document platform-specific prerequisites or recovery steps.

## Verification

```bash
bash -n bin/dotfiles lib/dotfiles/*.sh platforms/*.sh dependencies/*.sh
bin/dotfiles test
git diff --check
```

Use StyLua for Neovim Lua changes:

```bash
stylua --config-path config/nvim/stylua.toml config/nvim
```

The smoke tests replace the system root and external commands with local test
adapters. They must never invoke package managers or modify the host system.

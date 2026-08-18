# AGENTS

This repository installs personal configuration and system files. Keep changes
small and preserve unrelated local work.

## Safety

- Treat `bin/dotfiles dependencies` and non-dry-run installation as machine-changing operations. Run them only when the user explicitly requests it.
- Use `bin/dotfiles install <platform> --dry-run` for read-only installation inspection.
- Keep platform manifests side-effect free. Put package, service, and network changes in `dependencies/`; put unavoidable configuration reloads in `platform_post_install`.
- Preserve existing configuration ownership: link whole directories only when the repository owns them completely.

## Context

- Installation, update, backup, or recovery work: read `docs/installation.md`.
- Installer architecture, manifests, new platforms, or maintainer workflow: read `docs/maintenance.md`.
- Omarchy changes involving Apple T2 hardware, Touch Bar modules, suspend, or early boot: read `docs/apple-t2-touchbar.md`.

## Conventions

- Shell scripts use Bash, `set -euo pipefail`, quoted expansions, snake_case locals/functions, and arrays for lists.
- User-facing installer output goes through `dotfiles_log`.
- Platform state has one source of truth in `platforms/*.sh`; verification derives mapping checks from it.
- Lua follows `config/nvim/stylua.toml`: two spaces and a 120-column width.
- Preserve formatting and key ordering in JSON, TOML, and CONF files.

## Completion checks

| Changed area | Required checks |
| --- | --- |
| `bin/`, `lib/dotfiles/`, `platforms/`, `dependencies/`, install/verify wrappers | `bash -n` for changed scripts and `bin/dotfiles test` |
| Shell startup files | `bash -n` for Bash files; parse Zsh files with Zsh when available |
| `config/nvim/**/*.lua` | StyLua with `config/nvim/stylua.toml` |
| Markdown or data files | `git diff --check`; configured formatter or spelling tool when available |
| `/etc` or Apple T2 files | Smoke tests plus the manual verification documented for the matching platform |

Finish with `git diff --check`. Report unavailable tools instead of silently
skipping their checks.

## Agent skills

### Issue tracker

Issues are tracked in this repository's GitHub Issues using the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Triage uses the five default canonical labels. See `docs/agents/triage-labels.md`.

### Domain docs

Domain documentation uses the single-context layout. See `docs/agents/domain.md`.

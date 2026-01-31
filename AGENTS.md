# AGENTS

This repository is a dotfiles collection with install helpers and editor configs.
Agents should be conservative about changes, prefer small edits, and avoid running
installers unless explicitly requested.

## Commands (build/lint/test)

There is no build system or test suite in this repo. The scripts below are the
primary entry points.

- macOS install: `./install-macos.sh`
- Omarchy install: `./install-omarchy.sh`
- Ubuntu VPS install: `./install-ubuntu-vps.sh`
- Ubuntu VPS dependencies: `./install-ubuntu-vps-deps.sh`
- Core installer (usually invoked by the scripts above): `bin/dotfiles-install`
- Config install helper: `bin/dotfiles-install-config`
- Dotfile install helper: `bin/dotfiles-install-files`
- /etc install helper: `bin/dotfiles-install-etc`

### Single test

No tests are defined. If you add a test framework, document the single-test
command here.

### Formatting / linting

- Lua formatting uses StyLua. Config: `config/nvim/stylua.toml`
  - Example: `stylua --config-path config/nvim/stylua.toml config/nvim`
- Spelling config: `cspell.json` (no script defined)

## Repo layout

- `bin/` contains installation utilities and logging helpers.
- `config/` contains user config directories (e.g. `nvim`, `hypr`, `karabiner`).
- `etc/` contains system-level configs (e.g. `etc/keyd`).
- `macos/` and `omarchy/` contain platform-specific shell rc files.

## Code style guidelines

### General

- Keep edits minimal and consistent with existing patterns.
- Prefer ASCII; only introduce Unicode if the file already uses it.
- Avoid adding comments unless a non-obvious block needs clarification.
- Preserve existing ordering in config files and lists unless adding adjacent items.

### Shell (bash)

Files: `bin/*`, `install-*.sh`, `shell/common/scripts/*`

- Use `#!/bin/bash` (or `#!/usr/bin/env bash` when portability is required).
- Use `set -euo pipefail` for scripts that execute multiple operations.
- Quote variables and paths: `"$var"` and `"$path"`.
- Use `readonly` for constants and `local` for function-scoped variables.
- Prefer snake_case for function names and variables.
- Use arrays for lists: `files=(...)` and iterate with `"${files[@]}"`.
- Use `[[ ... ]]` for conditionals and `case` for argument parsing.
- For best-effort actions, allow failure explicitly: `|| true`.
- Use `dotfiles-log` for status messages; avoid raw `echo` in install flows.
- When writing to privileged locations, follow the existing pattern of using
  `sudo` only when required by permissions.
- Error handling: collect failures in `failed_items`, exit nonzero when any
  operation fails; do not partially silently fail.

### Lua (Neovim config)

Files: `config/nvim/**/*.lua`

- Format with StyLua: 2 spaces, 120 column width (see `config/nvim/stylua.toml`).
- Prefer `return { ... }` for plugin specs in `config/nvim/lua/plugins/*.lua`.
- Keep plugin configuration scoped to the plugin entry; avoid global side effects.
- Use `local` helper functions inside `opts` or `config` blocks when needed.
- Naming: use lower_snake_case for helper functions, concise names for options.
- Use `vim.g` for globals and `vim.opt` for options in `config/nvim/lua/config/*`.
- Keep file responsibilities narrow (one plugin or one config topic per file).

### JSON / TOML / CONF

Files: `*.json`, `*.toml`, `*.conf`

- Preserve formatting and key ordering as found in the file.
- Avoid reformatting large blocks unless necessary for the change.
- Keep paths and commands explicit; do not introduce implicit defaults.

## Error handling expectations

- Shell scripts should surface failures with nonzero exit codes.
- Use logging for user-facing outcomes (`dotfiles-log`).
- Avoid partial success without a clear log message.

## Naming conventions

- Shell: snake_case for functions and locals; UPPER_SNAKE_CASE for constants.
- Lua: snake_case for helpers, minimal globals, descriptive option names.

## Imports / dependencies

- Shell: do not rely on nonstandard tools without documenting them in the script.
- Lua: prefer built-in Neovim APIs and plugin opts; avoid extra requires unless
  the plugin expects it.

## Cursor / Copilot rules

No `.cursorrules`, `.cursor/rules/`, or `.github/copilot-instructions.md` were
found in this repo at the time of writing.

## Notes for agentic changes

- This repo is intended for personal configuration; be cautious with destructive
  changes and avoid running install scripts without a direct request.
- If you add new scripts or configs, update this file with the new commands or
  conventions.

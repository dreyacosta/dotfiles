# Tool management

This repository follows Omarchy's division of ownership between the operating
system package manager and Mise. Omarchy does not publish this as one formal
policy, so the convention below is inferred from its official installer and
command sources and checked against Mise's documented scope.

## Convention

Choose exactly one owner for each executable:

| Kind of software | Owner | Omarchy | macOS | Ubuntu |
| --- | --- | --- | --- | --- |
| System library, desktop application, service, driver, or OS-integrated utility | Native system package manager | `omarchy pkg add`; use `omarchy pkg aur add` only for AUR-only packages | Homebrew | APT |
| User-space utility unavailable or unsuitable through the native repositories | Documented package-manager fallback | AUR, only when necessary | Homebrew | Linux Homebrew |
| Versioned language runtime or development environment | Mise | Mise | Mise | Mise |
| User-scoped developer CLI supported by a reliable Mise backend | Mise | Mise | Mise | Mise |
| Tool already supplied and owned by the platform | Existing platform installation | Keep the Omarchy package | Keep the native installation | Keep the native installation |
| Tool unavailable through either applicable owner | Explicit exception | Official installer or another upstream-supported method | Same | Same |

Before adding a tool, check whether the platform already supplies it. Do not
also declare a system-owned tool in Mise: Mise places its managed version ahead
of the system path, which creates two installations and makes ownership
ambiguous. Exceptions must be intentional, documented beside the dependency,
and guarded by an availability or version check.

The practical selection order is:

1. Keep an existing platform-owned installation.
2. Use Mise for a versioned runtime or user-scoped development CLI.
3. Use the native package manager for system software and libraries.
4. Use an upstream installer only when neither owner is suitable.

On Omarchy, Homebrew may be installed as an optional user tool, but dependency
provisioning must not use it as a second system package manager. `omarchy pkg
add` wraps `pacman -S --needed`, while `omarchy pkg aur add` wraps `yay -S
--needed`; these are the distribution's supported package entry points. On
macOS, Homebrew fills the native-package role. On Ubuntu, prefer APT
for system-integrated software and use Linux Homebrew only as a documented
fallback for user-space utilities whose APT package is unavailable or
unsuitable. These platform differences do not change which *kind* of software
belongs to Mise.

Ubuntu's Linux Homebrew fallback currently covers the shared user-space CLI
bundle because Ubuntu releases differ in package availability, executable names,
and release age. OS-integrated dependencies, Docker, and jq remain APT-owned.

## Evidence

Omarchy's own sources establish the split:

- Its regular package command installs missing repository packages through
  Pacman with `--needed`: [`omarchy-pkg-add`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-pkg-add).
- Its AUR command uses Yay, also with `--needed`: [`omarchy-pkg-aur-add`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-pkg-aur-add).
- Its base system, desktop applications, system utilities, and libraries are
  declared as Arch packages. That list also installs Mise itself:
  [`omarchy-base.packages`](https://github.com/basecamp/omarchy/blob/quattro/install/omarchy-base.packages).
- Its development-environment installer uses Mise for Node, Bun, Deno, Go,
  Ruby, Python, Erlang, Elixir, Java, Zig, .NET, Clojure, and Scala. It switches
  to `omarchy-pkg-add` for system dependencies such as `libyaml`, PHP packages,
  and `rlwrap`, and uses upstream installers for exceptional ecosystems such as
  Rust and OCaml: [`omarchy-install-dev-env`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-install-dev-env).
- Omarchy also implements small Mise-backed launchers for developer CLIs. Each
  launcher installs its tool with `mise use -g` on first use and runs it with
  `mise x`: [`omarchy-mise-install`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-mise-install) and
  [the installed developer CLI list](https://github.com/basecamp/omarchy/blob/quattro/install/user/mise.sh).
  This is lazy installation; declaring the same tools in this repository's
  shared Mise configuration installs them eagerly, but gives Mise the same
  ownership.

Mise's documentation provides the ownership boundary:

- Mise manages programming-language runtimes and other development tools, with
  project-aware version switching: [Dev Tools](https://mise.jdx.dev/dev-tools/).
- Mise explicitly says it is not a replacement for `apt`, Homebrew, or Pacman,
  and directs system libraries and system-level dependencies to the operating
  system package manager: [Mise FAQ](https://mise.jdx.dev/faq.html#mise-is-for-dev-tools-not-applications-or-system-packages).
- A global declaration belongs in `~/.config/mise/config.toml`; after editing
  it, `mise install` installs all declared tools: [Dev Tools: `mise use`](https://mise.jdx.dev/dev-tools/#mise-use).
- Mise supports ecosystem backends such as npm, pipx, Aqua, GitHub releases,
  and asdf plugins, so a developer CLI does not need a separate global npm or
  language-package installation merely because it is not a language runtime:
  [Backends](https://mise.jdx.dev/dev-tools/backends/).
- Treat asdf plugins and `.tool-versions` as Mise compatibility mechanisms,
  not as a reason to install and operate asdf alongside Mise:
  [Mise compatibility](https://mise.jdx.dev/dev-tools/#dev-tools).

## Applying the convention

When changing dependency provisioning:

- Record cross-platform Mise tools once in `config/mise/config.toml` and remove
  competing installs from native package or language package managers.
- Use a tool's Mise `os` restriction when one platform intentionally assigns
  that tool to another owner; macOS Node is nvm-owned while Linux Node is
  Mise-owned.
- Put native package installation in each platform's dependency workflow and
  make it idempotent.
- Verify availability through the selected owner, not merely through whichever
  duplicate happens to appear first on `PATH`.
- Treat plugin or extension installation as application-managed state. Install
  it only after resolving the host application through its chosen owner.
- Revisit ownership when a platform begins shipping a tool by default. Keeping
  the platform copy is preferable unless Mise's version selection is a real
  requirement.

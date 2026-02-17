#!/usr/bin/env bash
set -euo pipefail

# Launch ruby-lsp with the active project Ruby manager when available.

if command -v mise >/dev/null 2>&1 && { [ -f "mise.toml" ] || [ -f ".mise.toml" ]; }; then
  exec mise x -- ruby-lsp "$@"
fi

if command -v rbenv >/dev/null 2>&1 && [ -f ".ruby-version" ]; then
  exec rbenv exec ruby-lsp "$@"
fi

if command -v asdf >/dev/null 2>&1 && [ -f ".tool-versions" ] && grep -q '^ruby[[:space:]]' .tool-versions; then
  exec asdf exec ruby-lsp "$@"
fi

if command -v ruby-lsp >/dev/null 2>&1; then
  exec ruby-lsp "$@"
fi

if command -v bundle >/dev/null 2>&1 && [ -f "Gemfile" ]; then
  exec bundle exec ruby-lsp "$@"
fi

echo "ruby-lsp launcher error: could not find a runnable ruby-lsp in this environment." >&2
echo "Install ruby-lsp for your Ruby version (or add it to Gemfile)." >&2
exit 127

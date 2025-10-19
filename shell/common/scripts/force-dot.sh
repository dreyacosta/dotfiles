#!/usr/bin/env bash
set -euo pipefail

# DNS4_1 will be arg1, DNS4_2 will be arg2
# Set two vars taking those 2 args
DNS4_1="${1:-}"
DNS4_2="${2:-}"

# check if DNS4_1 and DNS4_2 exist in env vars and not empty
if [ -z "$DNS4_1" ] || [ -z "$DNS4_2" ]; then
  echo "DNS4_1 and DNS4_2 environment variables must be set and non-empty"
  exit 1
fi

# Wait up to ~20s for any wg interface created by Mullvad
for i in {1..40}; do
  IFACES=$(ip -o link show | awk -F': ' '$2 ~ /^wg/ {print $2}' | cut -d'@' -f1)
  if [ -n "$IFACES" ]; then break; fi
  sleep 0.5
done

[ -z "${IFACES:-}" ] && exit 0 # nothing to do if no wg iface

# Apply settings to each wg* interface; never fail hard
for IFACE in $IFACES; do
  resolvectl dnsovertls "$IFACE" yes || true
  resolvectl dns "$IFACE" "$DNS4_1" "$DNS4_2" || true
  resolvectl domain "$IFACE" "~." || true
done

exit 0

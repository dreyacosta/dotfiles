#!/usr/bin/env bash
set -euo pipefail

# NextDNS DoT endpoints (edit if you like)
DNS4_1="45.90.28.0"
DNS4_2="45.90.30.0"

# Wait up to ~20s for any wg interface created by Mullvad
for i in {1..40}; do
  IFACES=$(ip -o link show | awk -F': ' '$2 ~ /^wg/ {print $2}' | cut -d'@' -f1)
  if [ -n "$IFACES" ]; then break; fi
  sleep 0.5
done

[ -z "${IFACES:-}" ] && exit 0   # nothing to do if no wg iface

# Apply settings to each wg* interface; never fail hard
for IFACE in $IFACES; do
  resolvectl dnsovertls "$IFACE" yes || true
  resolvectl dns "$IFACE" "$DNS4_1" "$DNS4_2" || true
  resolvectl domain "$IFACE" "~." || true
done

exit 0

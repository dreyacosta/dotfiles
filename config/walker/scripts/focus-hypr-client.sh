#!/bin/bash

set -euo pipefail

ADDR="${1:-}"

while pgrep -x walker >/dev/null 2>&1; do
  sleep 0.05
done

hyprctl dispatch focuswindow "address:${ADDR}"

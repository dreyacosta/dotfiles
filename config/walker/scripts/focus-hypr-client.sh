#!/bin/bash

set -euo pipefail

ADDR="${1:-}"

sleep 0.05
hyprctl dispatch focuswindow "address:${ADDR}"

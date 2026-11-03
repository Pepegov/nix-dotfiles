#!/usr/bin/env bash
set -euo pipefail

while ! xrandr --query >/dev/null 2>&1; do
  sleep 1
done

screen="${DISPLAY_EXTERNAL:-${DISPLAY_INTERNAL:-}}"
if [ -z "$screen" ]; then
  exit 0
fi

eww --config "$HOME/.config/eww" daemon
for window in codex-limits exchange-rates; do
  eww --config "$HOME/.config/eww" open --screen "$screen" "$window"
done

wait

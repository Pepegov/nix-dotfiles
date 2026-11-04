#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
yuck="$root/config/eww.yuck"
module="$root/default.nix"
launcher="$root/config/scripts/launch.sh"
bspwmrc="$root/../bspwm/config/bspwm/bspwmrc"

test -f "$yuck"
test -f "$module"
grep -Fq '(defwindow codex-limits' "$yuck"
grep -Fq '(defwindow exchange-rates' "$yuck"
for window in codex-limits exchange-rates; do
  window_definition="$(sed -n "/(defwindow $window/,/^  (.*))$/p" "$yuck")"
  grep -Fq ':stacking "bg"' <<<"$window_definition"
  grep -Fq ':windowtype "desktop"' <<<"$window_definition"
  grep -Fq ':wm-ignore false' <<<"$window_definition"
done
grep -Fq ':x "-36px"' "$yuck"
grep -Fq ':y "480px"' "$yuck"
grep -Fq ':width "352px"' "$yuck"
if grep -Fq ':x "36px"' "$yuck"; then
  exit 1
fi
if grep -Fq 'quick-settings' "$yuck" || grep -Fq 'quick-settings' "$launcher"; then
  exit 1
fi
grep -Fq 'codex-limits.sh' "$yuck"
grep -Fq 'exchange-rates.sh' "$yuck"
grep -Fq 'SOL/USD' "$yuck"
grep -Fq 'DISPLAY_EXTERNAL' "$launcher"
grep -Fq 'DISPLAY_INTERNAL' "$launcher"
grep -Fq 'open --screen "$screen"' "$launcher"
grep -Fq 'systemctl --user restart eww-external-widgets.service' "$bspwmrc"
if grep -Fq 'screen_index' "$launcher"; then
  exit 1
fi
grep -Fq 'Type = "oneshot";' "$module"
grep -Fq 'RemainAfterExit = true;' "$module"
if grep -Fq 'Install.WantedBy' "$module"; then
  exit 1
fi
if grep -Fq '(defpoll volume' "$yuck" || grep -Fq '(defpoll brightness' "$yuck"; then
  exit 1
fi
if grep -Fq 'line-height:' "$root/config/eww.scss" || grep -Fq '#17271CF2' "$root/config/eww.scss"; then
  exit 1
fi

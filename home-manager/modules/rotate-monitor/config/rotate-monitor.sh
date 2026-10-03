#!/bin/sh

FOCUSED=$(bspc query -M -m focused --names)
[ -z "$FOCUSED" ] && exit 1

CURRENT=$(xrandr --query --current | sed -n "/^$FOCUSED/s/.*(\(normal\|left\|right\|inverted\)).*/\1/p")

case "$CURRENT" in
    normal|"") NEW="right" ;;
    right|left) NEW="normal" ;;
    *) NEW="normal" ;;
esac

xrandr --output "$FOCUSED" --rotate "$NEW"
systemctl --user start night-mode-sync.service

if [ "$FOCUSED" = "$DISPLAY_EXTERNAL" ]; then
    bspc monitor "$DISPLAY_EXTERNAL" -d I II III IV V VI VII VIII
    bspc monitor "$DISPLAY_INTERNAL" -d IX X
    $HOME/.config/polybar/launch.sh
    $HOME/.config/polybar/launch_additional.sh
fi

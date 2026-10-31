#!/usr/bin/env bash

options="\n󰍃\n\n\n󰜉\n"

chosen=$(printf '%b\n' "$options" | rofi -dmenu -i -no-custom \
    -theme "$HOME/.config/rofi/powermenu.rasi")

case "$chosen" in
    "")
        systemctl poweroff
        ;;
    "󰜉")
        systemctl reboot
        ;;
    "")
        systemctl suspend
        ;;
    "")
        systemctl hibernate
        ;;
    "󰍃")
        bspc quit
        ;;
    "")
        light-locker-command -l
        ;;
esac

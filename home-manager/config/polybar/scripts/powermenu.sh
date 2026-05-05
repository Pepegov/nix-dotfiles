#!/usr/bin/env bash

options="⏻ Poweroff\n🔄 Reboot\n🌙 Suspend\n💤 Hibernate\n🚪 Logout\n🔒 Lock"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power")

case "$chosen" in
    "⏻ Poweroff")
        systemctl poweroff
        ;;
    "🔄 Reboot")
        systemctl reboot
        ;;
    "🌙 Suspend")
        systemctl suspend
        ;;
    "💤 Hibernate")
        systemctl hibernate
        ;;
    "🚪 Logout")
        bspc quit
        ;;
    "🔒 Lock")
        light-locker-command -l
        ;;
esac

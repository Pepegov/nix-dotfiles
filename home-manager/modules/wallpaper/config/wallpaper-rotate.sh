#!/bin/sh

set -eu

wallpaper_dir="$HOME/Pictures/Wallpapers"
interval_seconds=1800
previous_wallpaper=""

set_wallpaper() {
    wallpapers=$(find -L "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort)
    [ -n "$wallpapers" ] || return 0

    candidates=$wallpapers
    if [ -n "$previous_wallpaper" ]; then
        without_previous=$(printf '%s\n' "$wallpapers" | grep -Fvx -- "$previous_wallpaper" || true)
        [ -z "$without_previous" ] || candidates=$without_previous
    fi

    wallpaper=$(printf '%s\n' "$candidates" | shuf -n 1)
    feh --bg-fill "$wallpaper"
    previous_wallpaper=$wallpaper
}

while true; do
    set_wallpaper
    sleep "$interval_seconds"
done

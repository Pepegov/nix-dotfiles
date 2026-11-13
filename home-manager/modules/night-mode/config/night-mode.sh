#!/bin/sh

set -eu

transition_temperature() {
    start=$1
    end=$2
    step=0

    while [ "$step" -le 40 ]; do
        temperature=$((start + (end - start) * step / 40))
        redshift -r -P -m randr -O "$temperature"
        sleep 0.05
        step=$((step + 1))
    done
}

start_picom() {
    shader=$1
    runtime_dir=${XDG_RUNTIME_DIR:-/tmp}
    config="$runtime_dir/picom-night-mode.conf"

    sed '/^[[:space:]]*window-shader-fg[[:space:]]*=/d; /^[[:space:]]*root-pixmap-shader[[:space:]]*=/d' \
        "$HOME/.config/picom/picom.conf" > "$config"
    printf '\nwindow-shader-fg = { path = "%s/.config/night-mode/%s.glsl"; defines = { START_TIME = "%s"; }; };\n' \
        "$HOME" "$shader" "$(awk '{ printf "%.0f", $1 * 1000 }' /proc/uptime)" >> "$config"
    printf 'root-pixmap-shader = { path = "%s/.config/night-mode/%s.glsl"; defines = { START_TIME = "%s"; }; };\n' \
        "$HOME" "$shader" "$(awk '{ printf "%.0f", $1 * 1000 }' /proc/uptime)" >> "$config"

    pkill -x picom || true
    attempts=0
    while pgrep -x picom > /dev/null && [ "$attempts" -lt 40 ]; do
        sleep 0.05
        attempts=$((attempts + 1))
    done
    systemd-run --user --quiet --no-block --collect picom --config "$config"
}

case "${1:-sync}" in
    night)
        transition_temperature 6500 3000
        ;;
    grayscale)
        redshift -x
        start_picom grayscale
        ;;
    day)
        redshift -x
        start_picom color
        ;;
    sync)
        time=$(date +%H%M)
        if [ "$time" -ge 2230 ] || [ "$time" -lt 800 ]; then
            redshift -x
            start_picom grayscale
        elif [ "$time" -ge 2200 ]; then
            redshift -r -P -m randr -O 3000
        else
            redshift -x
        fi
        ;;
    *)
        echo "Usage: $0 {night|grayscale|day|sync}" >&2
        exit 2
        ;;
esac

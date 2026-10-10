#!/usr/bin/env bash

set -euo pipefail

timer_unit="delayed-shutdown.timer"
service_unit="delayed-shutdown.service"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
state_file="${runtime_dir}/delayed-shutdown-selection"

is_scheduled() {
    systemctl --user is-active --quiet "${timer_unit}"
}

cancel_schedule() {
    systemctl --user stop "${timer_unit}" "${service_unit}" 2>/dev/null || true
    systemctl --user reset-failed "${timer_unit}" "${service_unit}" 2>/dev/null || true
    rm -f "${state_file}"
}

active_seconds=""
if is_scheduled && [ -r "${state_file}" ]; then
    IFS='|' read -r active_seconds _ < "${state_file}" || true
fi

if [ "${1:-menu}" = "cancel" ]; then
    cancel_schedule
    exit 0
fi

if [ "${1:-menu}" != "menu" ]; then
    echo "Usage: $0 {menu|cancel}" >&2
    exit 2
fi

choices=(
    "300|5 мин"
    "600|10 мин"
    "900|15 мин"
    "1800|30 мин"
    "2700|45 мин"
    "3600|1 час"
    "5400|1.5 часа"
    "7200|2 часа"
)

menu=""
for choice in "${choices[@]}"; do
    seconds="${choice%%|*}"
    label="${choice#*|}"

    if [ "${seconds}" = "${active_seconds}" ]; then
        menu+="● ${label}"$'\n'
    else
        menu+="${label}"$'\n'
    fi
done

selected="$(printf '%s' "${menu}" | rofi -dmenu -i -p "Выключение через" -theme "${HOME}/.config/rofi/theme.rasi" -theme-str 'listview { lines: 8; }')"
[ -n "${selected}" ] || exit 0

selected="${selected#● }"
selected_seconds=""
for choice in "${choices[@]}"; do
    seconds="${choice%%|*}"
    label="${choice#*|}"

    if [ "${label}" = "${selected}" ]; then
        selected_seconds="${seconds}"
        break
    fi
done

[ -n "${selected_seconds}" ] || exit 0

if [ "${selected_seconds}" = "${active_seconds}" ] && is_scheduled; then
    cancel_schedule
    exit 0
fi

cancel_schedule
systemd-run --user --quiet --collect --unit=delayed-shutdown --on-active="${selected_seconds}s" systemctl poweroff
printf '%s|%s\n' "${selected_seconds}" "${selected}" > "${state_file}"

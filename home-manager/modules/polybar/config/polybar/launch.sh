#!/bin/sh

# Останавливаем все запущенные панели Polybar
killall -q polybar

# Дождемся завершения процессов Polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Динамически определяем экраны через xrandr (так как могут быть разные суффиксы -0 и т.д.)
INTERNAL_MONITOR=$(xrandr --query | awk '/ connected/ && $1 ~ /^eDP/ { print $1; exit }')
EXTERNAL_MONITOR=$(xrandr --query | awk '/ connected/ && $1 !~ /^eDP/ { print $1; exit }')

if [ -n "$EXTERNAL_MONITOR" ]; then
    # Внешний монитор подключён:
    # Base на внешний монитор (EXTERNAL_MONITOR)
    # Additional на встроенный монитор (INTERNAL_MONITOR)
    MONITOR="$EXTERNAL_MONITOR" polybar --reload base &
    MONITOR="$INTERNAL_MONITOR" polybar --reload additional &
else
    # Внешний монитор отсутствует:
    # Только Base на встроенный монитор (INTERNAL_MONITOR)
    MONITOR="$INTERNAL_MONITOR" polybar --reload base &
fi

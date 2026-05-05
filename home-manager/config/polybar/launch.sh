#!/bin/sh

# Останавливаем все запущенные панели Polybar
killall -q polybar

# Дождемся завершения процессов Polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Запускаем Polybar для каждого подключенного монитора
for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$monitor polybar --reload base &
done

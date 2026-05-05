#!/usr/bin/env bash

# Получаем состояние и громкость динамиков
if [ $(pamixer --get-mute) = "true" ]; then
    # Если динамики отключены
    speakers="󰖁 muted"
else
    # Получаем громкость динамиков
    volume=$(pamixer --get-volume)
    
    # Выбираем иконку в зависимости от громкости
    if [ $volume -lt 30 ]; then
        icon=''  # Тихий звук
    elif [ $volume -lt 70 ]; then
        icon=''  # Средний звук
    else
        icon=''  # Громкий звук
    fi
    
    speakers="$icon $volume%"
fi

# Проверяем состояние микрофона
mic_muted=$(pamixer --default-source --get-mute)

if [ "$mic_muted" = "true" ]; then
    # Микрофон отключен - красным цветом (формат Polybar)
    microphone="%{F#ff0000}%{F-}"
else
    # Микрофон включен
    microphone=""
fi

# Выводим результат
echo -e "$speakers $microphone"
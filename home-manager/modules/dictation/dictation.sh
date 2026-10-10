#!/usr/bin/env bash

set -uo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
state_dir="${runtime_dir}/dictation"
state_file="${state_dir}/state"

notify() {
    notify-send -a "Dictation" "$1" "${2:-}" || true
}

cleanup() {
    local work_dir="${1:-}"
    rm -f "${state_file}"
    [ -z "${work_dir}" ] || rm -rf "${work_dir}"
}

read_state() {
    [ -r "${state_file}" ] || return 1
    IFS='|' read -r state recorder_pid focused_window work_dir < "${state_file}"
    [ -n "${state:-}" ] && [ -n "${recorder_pid:-}" ] && [ -n "${work_dir:-}" ]
}

start_recording() {
    mkdir -p "${state_dir}"
    chmod 700 "${state_dir}"

    if read_state; then
        case "${state}" in
            recording|processing)
                return 0
                ;;
        esac
    fi

    local focused_window work_dir audio_file recorder_pid
    focused_window="$(xdotool getwindowfocus 2>/dev/null || true)"
    work_dir="$(mktemp -d "${state_dir}/recording.XXXXXX")"
    audio_file="${work_dir}/dictation.wav"

    pw-record --rate 16000 --channels 1 --format s16 "${audio_file}" >/dev/null 2>&1 &
    recorder_pid="$!"

    sleep 0.1
    if ! kill -0 "${recorder_pid}" 2>/dev/null; then
        cleanup "${work_dir}"
        notify "Не удалось начать запись" "Проверьте выбранный микрофон PipeWire."
        return 1
    fi

    printf 'recording|%s|%s|%s\n' "${recorder_pid}" "${focused_window}" "${work_dir}" > "${state_file}"
    notify "Запись" "Говорите, пока удерживаете F8."
}

stop_recording() {
    local attempts=0 audio_file text_file text

    if ! read_state; then
        return 0
    fi

    if [ "${state}" = "processing" ]; then
        notify "Распознавание уже выполняется"
        return 0
    fi

    if [ "${state}" != "recording" ]; then
        cleanup "${work_dir}"
        return 0
    fi

    printf 'processing|%s|%s|%s\n' "${recorder_pid}" "${focused_window}" "${work_dir}" > "${state_file}"
    kill -INT "${recorder_pid}" 2>/dev/null || true

    while kill -0 "${recorder_pid}" 2>/dev/null && [ "${attempts}" -lt 50 ]; do
        sleep 0.1
        attempts=$((attempts + 1))
    done

    if kill -0 "${recorder_pid}" 2>/dev/null; then
        kill -TERM "${recorder_pid}" 2>/dev/null || true
        cleanup "${work_dir}"
        notify "Не удалось остановить запись"
        return 1
    fi

    audio_file="${work_dir}/dictation.wav"
    if [ ! -s "${audio_file}" ]; then
        cleanup "${work_dir}"
        notify "Запись не получена" "Проверьте микрофон и попробуйте еще раз."
        return 1
    fi

    notify "Распознавание" "Whisper small обрабатывает запись локально."
    if ! whisper "${audio_file}" --model small --task transcribe --output_dir "${work_dir}" --output_format txt --verbose False >/dev/null 2>&1; then
        cleanup "${work_dir}"
        notify "Не удалось распознать речь"
        return 1
    fi

    text_file="${work_dir}/dictation.txt"
    if [ ! -s "${text_file}" ]; then
        cleanup "${work_dir}"
        notify "Речь не распознана" "Текст не был вставлен."
        return 0
    fi

    text="$(<"${text_file}")"
    if [[ ! "${text}" =~ [^[:space:]] ]]; then
        cleanup "${work_dir}"
        notify "Речь не распознана" "Текст не был вставлен."
        return 0
    fi

    # Keep the result available even if the original window no longer exists.
    (printf '%s' "${text}" | xclip -selection clipboard -in) &

    if [ -n "${focused_window}" ] && xdotool windowactivate --sync "${focused_window}" 2>/dev/null; then
        xdotool key --clearmodifiers ctrl+shift+v 2>/dev/null || true
        notify "Текст вставлен" "Копия также осталась в буфере обмена."
    else
        notify "Текст скопирован" "Исходное окно недоступно, вставьте текст вручную."
    fi

    cleanup "${work_dir}"
}

case "${1:-}" in
    start)
        start_recording
        ;;
    stop)
        stop_recording
        ;;
    *)
        echo "Usage: dictation {start|stop}" >&2
        exit 2
        ;;
esac

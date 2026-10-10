#!/usr/bin/env bash

if systemctl --user is-active --quiet delayed-shutdown.timer; then
    printf '%%{F#C17C5D}⏻%%{F-}\n'
else
    printf '⏻\n'
fi

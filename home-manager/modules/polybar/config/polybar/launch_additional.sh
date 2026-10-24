#!/bin/sh

if [ -z "${DISPLAY_EXTERNAL:-}" ]; then
    exit 0
fi

echo "---" >>/tmp/polybar_additional.log
polybar --reload additional >>/tmp/polybar_additional.log 2>&1

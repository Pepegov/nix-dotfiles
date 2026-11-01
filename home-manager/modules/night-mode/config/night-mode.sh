#!/bin/sh

set -eu

case "${1:-sync}" in
    night)
        exec redshift -m randr -O 3000
        ;;
    day)
        exec redshift -x
        ;;
    sync)
        hour=$(date +%H)
        if [ "$hour" -ge 22 ] || [ "$hour" -lt 8 ]; then
            exec redshift -m randr -O 3000
        fi

        exec redshift -x
        ;;
    *)
        echo "Usage: $0 {night|day|sync}" >&2
        exit 2
        ;;
esac

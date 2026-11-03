#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
output="$(LC_ALL=ru_RU.utf8 bash "$root/config/scripts/exchange-rates.sh")"

jq -e '
  (.usd_rub | test("^[0-9]+\\.[0-9]{2}$"))
  and (.sol_usd | test("^[0-9]+\\.[0-9]{2}$"))
' <<<"$output" >/dev/null

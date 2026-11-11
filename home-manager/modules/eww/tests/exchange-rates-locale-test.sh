#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
output="$(LC_ALL=ru_RU.utf8 bash "$root/config/scripts/exchange-rates.sh")"

jq -e '
  (.usd_rub | test("^[0-9]+\\.[0-9]{2}$"))
  and (.sol_usd | test("^[0-9]+\\.[0-9]{2}$"))
  and (.btc_month | test("^(—|[0-9]+)$"))
  and (.sol_week | test("^(—|[0-9]+\\.[0-9]{2})$"))
  and (.btc_trend | test("^(up|down|flat)$"))
' <<<"$output" >/dev/null

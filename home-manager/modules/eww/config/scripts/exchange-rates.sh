#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# The endpoints may fail independently. A missing rate is rendered as an em dash.
fiat="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/USD' 2>/dev/null || true)"
eur="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/EUR' 2>/dev/null || true)"
crypto="$(curl -fsSL --max-time 8 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd' 2>/dev/null || true)"
history_since="$(date -d '31 days ago' +%s)"
month_date="$(date -d '1 month ago' +%d/%m/%Y)"
week_date="$(date -d '7 days ago' +%d/%m/%Y)"
usd_month_history="$(curl -fsSL --max-time 8 "https://www.cbr.ru/scripts/XML_daily.asp?date_req=${month_date}" 2>/dev/null || true)"
usd_week_history="$(curl -fsSL --max-time 8 "https://www.cbr.ru/scripts/XML_daily.asp?date_req=${week_date}" 2>/dev/null || true)"
btc_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=XBTUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"
eth_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=ETHUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"
sol_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=SOLUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"

read_number() {
  local payload="$1" field="$2"
  printf '%s' "$payload" | jq -r "$field | if type == \"number\" then tostring else empty end" 2>/dev/null || true
}

format_rate() {
  local number="$1" decimals="$2"
  if [[ -n "$number" ]]; then
    printf "%.*f" "$decimals" "$number"
  else
    printf '—'
  fi
}

history_price() {
  local payload="$1" index="$2"
  printf '%s' "$payload" | jq -r "[.result | to_entries[] | select(.key != \"last\") | .value][0][$index][4] | if type == \"string\" then . else empty end" 2>/dev/null || true
}

cbr_rate() {
  local payload="$1" currency="$2"
  printf '%s' "$payload" | sed -n "s#.*<CharCode>${currency}</CharCode><Nominal>[^<]*</Nominal><Name>[^<]*</Name><Value>[^<]*</Value><VunitRate>\\([^<]*\\)</VunitRate>.*#\\1#p" | tr ',' '.'
}

trend() {
  local current="$1" previous="$2"
  if [[ -z "$current" || -z "$previous" ]]; then
    printf 'flat'
  elif awk "BEGIN { exit !($current >= $previous) }"; then
    printf 'up'
  else
    printf 'down'
  fi
}

usd_raw="$(read_number "$fiat" '.rates.RUB')"
eur_raw="$(read_number "$eur" '.rates.RUB')"
btc_raw="$(read_number "$crypto" '.bitcoin.usd')"
eth_raw="$(read_number "$crypto" '.ethereum.usd')"
sol_raw="$(read_number "$crypto" '.solana.usd')"

btc_month_raw="$(history_price "$btc_history" 0)"
btc_week_raw="$(history_price "$btc_history" -8)"
eth_month_raw="$(history_price "$eth_history" 0)"
eth_week_raw="$(history_price "$eth_history" -8)"
sol_month_raw="$(history_price "$sol_history" 0)"
sol_week_raw="$(history_price "$sol_history" -8)"
usd_month_raw="$(cbr_rate "$usd_month_history" USD)"
usd_week_raw="$(cbr_rate "$usd_week_history" USD)"
eur_month_raw="$(cbr_rate "$usd_month_history" EUR)"
eur_week_raw="$(cbr_rate "$usd_week_history" EUR)"

usd_rub="$(format_rate "$usd_raw" 2)"
eur_rub="$(format_rate "$eur_raw" 2)"
btc_usd="$(format_rate "$btc_raw" 0)"
eth_usd="$(format_rate "$eth_raw" 0)"
sol_usd="$(format_rate "$sol_raw" 2)"

btc_month="$(format_rate "$btc_month_raw" 0)"
btc_week="$(format_rate "$btc_week_raw" 0)"
eth_month="$(format_rate "$eth_month_raw" 0)"
eth_week="$(format_rate "$eth_week_raw" 0)"
sol_month="$(format_rate "$sol_month_raw" 2)"
sol_week="$(format_rate "$sol_week_raw" 2)"
usd_month="$(format_rate "$usd_month_raw" 2)"
usd_week="$(format_rate "$usd_week_raw" 2)"
eur_month="$(format_rate "$eur_month_raw" 2)"
eur_week="$(format_rate "$eur_week_raw" 2)"

usd_trend="$(trend "$usd_raw" "$usd_week_raw")"
eur_trend="$(trend "$eur_raw" "$eur_week_raw")"
btc_trend="$(trend "$btc_raw" "$btc_week_raw")"
eth_trend="$(trend "$eth_raw" "$eth_week_raw")"
sol_trend="$(trend "$sol_raw" "$sol_week_raw")"

jq -cn \
  --arg usd "$usd_rub" --arg eur "$eur_rub" \
  --arg btc "$btc_usd" --arg eth "$eth_usd" --arg sol "$sol_usd" \
  --arg btc_month "$btc_month" --arg btc_week "$btc_week" \
  --arg eth_month "$eth_month" --arg eth_week "$eth_week" \
  --arg sol_month "$sol_month" --arg sol_week "$sol_week" \
  --arg usd_month "$usd_month" --arg usd_week "$usd_week" \
  --arg eur_month "$eur_month" --arg eur_week "$eur_week" \
  --arg usd_trend "$usd_trend" --arg eur_trend "$eur_trend" \
  --arg btc_trend "$btc_trend" --arg eth_trend "$eth_trend" --arg sol_trend "$sol_trend" \
  '{ok: ([$usd,$eur,$btc,$eth,$sol] | any(. != "—")),
    usd_rub: $usd, eur_rub: $eur, btc_usd: $btc, eth_usd: $eth, sol_usd: $sol,
    usd_month: $usd_month, usd_week: $usd_week, usd_trend: $usd_trend,
    eur_month: $eur_month, eur_week: $eur_week, eur_trend: $eur_trend,
    btc_month: $btc_month, btc_week: $btc_week, btc_trend: $btc_trend,
    eth_month: $eth_month, eth_week: $eth_week, eth_trend: $eth_trend,
    sol_month: $sol_month, sol_week: $sol_week, sol_trend: $sol_trend}'

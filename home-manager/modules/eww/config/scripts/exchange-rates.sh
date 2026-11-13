#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/eww"
cache_file="${cache_dir}/exchange-rates.json"

# The endpoints may fail independently. A missing rate is rendered as an em dash.
fiat="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/USD' 2>/dev/null || true)"
eur="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/EUR' 2>/dev/null || true)"
crypto="$(curl -fsSL --max-time 8 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd' 2>/dev/null || true)"
history_since="$(date -d '31 days ago' +%s)"
history_start="$(date -d '1 month ago' +%F)"
history_end="$(date +%F)"
month_date="$(date -d '1 month ago' +%d/%m/%Y)"
week_date="$(date -d '7 days ago' +%d/%m/%Y)"
usd_month_history="$(curl -fsSL --max-time 8 "https://www.cbr.ru/scripts/XML_daily.asp?date_req=${month_date}" 2>/dev/null || true)"
usd_week_history="$(curl -fsSL --max-time 8 "https://www.cbr.ru/scripts/XML_daily.asp?date_req=${week_date}" 2>/dev/null || true)"
btc_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=XBTUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"
eth_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=ETHUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"
sol_history="$(curl -fsSL --max-time 8 "https://api.kraken.com/0/public/OHLC?pair=SOLUSD&interval=1440&since=${history_since}" 2>/dev/null || true)"
vt_quote="$(curl -fsSL --max-time 8 -A 'Mozilla/5.0' 'https://api.nasdaq.com/api/quote/vt/info?assetclass=etf' 2>/dev/null || true)"
bndw_quote="$(curl -fsSL --max-time 8 -A 'Mozilla/5.0' 'https://api.nasdaq.com/api/quote/bndw/info?assetclass=etf' 2>/dev/null || true)"
vt_history="$(curl -fsSL --max-time 8 -A 'Mozilla/5.0' "https://api.nasdaq.com/api/quote/vt/historical?assetclass=etf&fromdate=${history_start}&todate=${history_end}&limit=100" 2>/dev/null || true)"
bndw_history="$(curl -fsSL --max-time 8 -A 'Mozilla/5.0' "https://api.nasdaq.com/api/quote/bndw/historical?assetclass=etf&fromdate=${history_start}&todate=${history_end}&limit=100" 2>/dev/null || true)"
moex_history="$(curl -fsSL --max-time 8 "https://iss.moex.com/iss/history/engines/stock/markets/index/securities/IMOEX.json?from=${history_start}&till=${history_end}&iss.meta=off&history.columns=TRADEDATE,CLOSE" 2>/dev/null || true)"
ruabitr_history="$(curl -fsSL --max-time 8 "https://iss.moex.com/iss/history/engines/stock/markets/index/securities/RUABITR.json?from=${history_start}&till=${history_end}&iss.meta=off&history.columns=TRADEDATE,CLOSE" 2>/dev/null || true)"
gold_history="$(curl -fsSL --max-time 8 "https://www.cbr.ru/hd_base/metall/metall_base_new/?UniDbQuery.Posted=True&UniDbQuery.From=${month_date//\//.}&UniDbQuery.To=${history_end//-/.}&UniDbQuery.Gold=true" 2>/dev/null || true)"

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

nasdaq_price() {
  printf '%s' "$1" | jq -r '.data.primaryData.lastSalePrice | if type == "string" then gsub("[^0-9.]"; "") else empty end' 2>/dev/null || true
}

nasdaq_history_price() {
  local payload="$1" index="$2"
  printf '%s' "$payload" | jq -r ".data.tradesTable.rows[$index].close | if type == \"string\" then gsub(\",\"; \"\") else empty end" 2>/dev/null || true
}

moex_history_price() {
  local payload="$1" index="$2"
  printf '%s' "$payload" | jq -r ".history.data[$index][1] | if type == \"number\" then tostring else empty end" 2>/dev/null || true
}

gold_history_price() {
  local payload="$1" index="$2" series
  series="$(printf '%s' "$payload" | grep -o '"data":\[[0-9.,]*\]' | tail -1 | sed 's/"data":\[//; s/\]//' || true)"
  IFS=',' read -r -a gold_prices <<<"$series"
  printf '%s' "${gold_prices[$index]:-}"
}

gold_usd_price() {
  local gold_rub="$1" usd_rub="$2"
  if [[ -n "$gold_rub" && -n "$usd_rub" ]]; then
    awk -v gold="$gold_rub" -v usd="$usd_rub" 'BEGIN { printf "%.2f", gold / usd * 31.1034768 }'
  fi
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
vt_raw="$(nasdaq_price "$vt_quote")"
bndw_raw="$(nasdaq_price "$bndw_quote")"
vt_month_raw="$(nasdaq_history_price "$vt_history" -1)"
vt_week_raw="$(nasdaq_history_price "$vt_history" 4)"
bndw_month_raw="$(nasdaq_history_price "$bndw_history" -1)"
bndw_week_raw="$(nasdaq_history_price "$bndw_history" 4)"
moex_raw="$(moex_history_price "$moex_history" -1)"
moex_month_raw="$(moex_history_price "$moex_history" 0)"
moex_week_raw="$(moex_history_price "$moex_history" -5)"
ruabitr_raw="$(moex_history_price "$ruabitr_history" -1)"
ruabitr_month_raw="$(moex_history_price "$ruabitr_history" 0)"
ruabitr_week_raw="$(moex_history_price "$ruabitr_history" -5)"
gold_rub_month_raw="$(gold_history_price "$gold_history" 0)"
gold_rub_week_raw="$(gold_history_price "$gold_history" -5)"
gold_rub_raw="$(gold_history_price "$gold_history" -1)"
gold_usd_month_raw="$(gold_usd_price "$gold_rub_month_raw" "$usd_month_raw")"
gold_usd_week_raw="$(gold_usd_price "$gold_rub_week_raw" "$usd_week_raw")"
gold_usd_raw="$(gold_usd_price "$gold_rub_raw" "$usd_raw")"

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
vt_usd="$(format_rate "$vt_raw" 2)"
bndw_usd="$(format_rate "$bndw_raw" 2)"
vt_month="$(format_rate "$vt_month_raw" 2)"
vt_week="$(format_rate "$vt_week_raw" 2)"
bndw_month="$(format_rate "$bndw_month_raw" 2)"
bndw_week="$(format_rate "$bndw_week_raw" 2)"
moex_rub="$(format_rate "$moex_raw" 2)"
moex_month="$(format_rate "$moex_month_raw" 2)"
moex_week="$(format_rate "$moex_week_raw" 2)"
ruabitr_rub="$(format_rate "$ruabitr_raw" 2)"
ruabitr_month="$(format_rate "$ruabitr_month_raw" 2)"
ruabitr_week="$(format_rate "$ruabitr_week_raw" 2)"
gold_rub="$(format_rate "$gold_rub_raw" 2)"
gold_rub_month="$(format_rate "$gold_rub_month_raw" 2)"
gold_rub_week="$(format_rate "$gold_rub_week_raw" 2)"
gold_usd="$(format_rate "$gold_usd_raw" 2)"
gold_usd_month="$(format_rate "$gold_usd_month_raw" 2)"
gold_usd_week="$(format_rate "$gold_usd_week_raw" 2)"

usd_trend="$(trend "$usd_raw" "$usd_week_raw")"
eur_trend="$(trend "$eur_raw" "$eur_week_raw")"
btc_trend="$(trend "$btc_raw" "$btc_week_raw")"
eth_trend="$(trend "$eth_raw" "$eth_week_raw")"
sol_trend="$(trend "$sol_raw" "$sol_week_raw")"
vt_trend="$(trend "$vt_raw" "$vt_week_raw")"
bndw_trend="$(trend "$bndw_raw" "$bndw_week_raw")"
moex_trend="$(trend "$moex_raw" "$moex_week_raw")"
ruabitr_trend="$(trend "$ruabitr_raw" "$ruabitr_week_raw")"
gold_usd_trend="$(trend "$gold_usd_raw" "$gold_usd_week_raw")"
gold_rub_trend="$(trend "$gold_rub_raw" "$gold_rub_week_raw")"

current="$(jq -cn \
  --arg usd "$usd_rub" --arg eur "$eur_rub" \
  --arg btc "$btc_usd" --arg eth "$eth_usd" --arg sol "$sol_usd" \
  --arg btc_month "$btc_month" --arg btc_week "$btc_week" \
  --arg eth_month "$eth_month" --arg eth_week "$eth_week" \
  --arg sol_month "$sol_month" --arg sol_week "$sol_week" \
  --arg usd_month "$usd_month" --arg usd_week "$usd_week" \
  --arg eur_month "$eur_month" --arg eur_week "$eur_week" \
  --arg usd_trend "$usd_trend" --arg eur_trend "$eur_trend" \
  --arg btc_trend "$btc_trend" --arg eth_trend "$eth_trend" --arg sol_trend "$sol_trend" \
  --arg vt "$vt_usd" --arg bndw "$bndw_usd" --arg moex "$moex_rub" --arg ruabitr "$ruabitr_rub" \
  --arg gold_usd "$gold_usd" --arg gold_rub "$gold_rub" \
  --arg vt_month "$vt_month" --arg vt_week "$vt_week" --arg vt_trend "$vt_trend" \
  --arg bndw_month "$bndw_month" --arg bndw_week "$bndw_week" --arg bndw_trend "$bndw_trend" \
  --arg moex_month "$moex_month" --arg moex_week "$moex_week" --arg moex_trend "$moex_trend" \
  --arg ruabitr_month "$ruabitr_month" --arg ruabitr_week "$ruabitr_week" --arg ruabitr_trend "$ruabitr_trend" \
  --arg gold_usd_month "$gold_usd_month" --arg gold_usd_week "$gold_usd_week" --arg gold_usd_trend "$gold_usd_trend" \
  --arg gold_rub_month "$gold_rub_month" --arg gold_rub_week "$gold_rub_week" --arg gold_rub_trend "$gold_rub_trend" \
  '{ok: ([$usd,$eur,$btc,$eth,$sol,$vt,$bndw,$moex,$ruabitr,$gold_usd,$gold_rub] | any(. != "—")),
    usd_rub: $usd, eur_rub: $eur, btc_usd: $btc, eth_usd: $eth, sol_usd: $sol,
    usd_month: $usd_month, usd_week: $usd_week, usd_trend: $usd_trend,
    eur_month: $eur_month, eur_week: $eur_week, eur_trend: $eur_trend,
    btc_month: $btc_month, btc_week: $btc_week, btc_trend: $btc_trend,
    eth_month: $eth_month, eth_week: $eth_week, eth_trend: $eth_trend,
    sol_month: $sol_month, sol_week: $sol_week, sol_trend: $sol_trend,
    vt_usd: $vt, vt_month: $vt_month, vt_week: $vt_week, vt_trend: $vt_trend,
    bndw_usd: $bndw, bndw_month: $bndw_month, bndw_week: $bndw_week, bndw_trend: $bndw_trend,
    moex_rub: $moex, moex_month: $moex_month, moex_week: $moex_week, moex_trend: $moex_trend,
    ruabitr_rub: $ruabitr, ruabitr_month: $ruabitr_month, ruabitr_week: $ruabitr_week, ruabitr_trend: $ruabitr_trend,
    gold_usd: $gold_usd, gold_usd_month: $gold_usd_month, gold_usd_week: $gold_usd_week, gold_usd_trend: $gold_usd_trend,
    gold_rub: $gold_rub, gold_rub_month: $gold_rub_month, gold_rub_week: $gold_rub_week, gold_rub_trend: $gold_rub_trend}')"

cached=""
if [[ -f "$cache_file" ]]; then
  cached="$(jq -c . "$cache_file" 2>/dev/null || true)"
fi

if [[ -n "$cached" ]]; then
  merged="$(jq -cn --argjson current "$current" --argjson cached "$cached" '
    reduce ($current | keys[]) as $key ($current;
      if (.[$key] == "—" and $cached[$key] != null and $cached[$key] != "—")
         or ($key | endswith("_trend") and .[$key] == "flat" and $cached[$key] != null)
      then .[$key] = $cached[$key]
      else .
      end)
    | if .ok == false and $cached.ok == true then .ok = true else . end
  ' 2>/dev/null || printf '%s' "$current")"
else
  merged="$current"
fi

if mkdir -p "$cache_dir" 2>/dev/null; then
  printf '%s\n' "$merged" >"$cache_file"
fi

printf '%s\n' "$merged"

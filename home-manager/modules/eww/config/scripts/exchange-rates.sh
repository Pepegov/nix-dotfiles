#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# The endpoints may fail independently. A missing rate is rendered as an em dash.
fiat="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/USD' 2>/dev/null || true)"
eur="$(curl -fsSL --max-time 8 'https://open.er-api.com/v6/latest/EUR' 2>/dev/null || true)"
crypto="$(curl -fsSL --max-time 8 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd' 2>/dev/null || true)"

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

usd_raw="$(read_number "$fiat" '.rates.RUB')"
eur_raw="$(read_number "$eur" '.rates.RUB')"
btc_raw="$(read_number "$crypto" '.bitcoin.usd')"
eth_raw="$(read_number "$crypto" '.ethereum.usd')"
sol_raw="$(read_number "$crypto" '.solana.usd')"

usd_rub="$(format_rate "$usd_raw" 2)"
eur_rub="$(format_rate "$eur_raw" 2)"
btc_usd="$(format_rate "$btc_raw" 0)"
eth_usd="$(format_rate "$eth_raw" 0)"
sol_usd="$(format_rate "$sol_raw" 2)"

jq -cn \
  --arg usd "$usd_rub" --arg eur "$eur_rub" \
  --arg btc "$btc_usd" --arg eth "$eth_usd" --arg sol "$sol_usd" \
  '{ok: ([$usd,$eur,$btc,$eth,$sol] | any(. != "—")),
    usd_rub: $usd, eur_rub: $eur, btc_usd: $btc, eth_usd: $eth, sol_usd: $sol}'

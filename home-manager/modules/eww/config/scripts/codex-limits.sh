#!/usr/bin/env bash
set -euo pipefail

unavailable='{"ok":false,"five_used":0,"five_left":0,"five_reset":"—","week_ok":false,"week_used":0,"week_left":0,"week_reset":"—"}'

if ! command -v codex >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' "$unavailable"
  exit 0
fi

# The app-server speaks one JSON-RPC message per line.
coproc CODEX { codex app-server 2>/dev/null; }
trap 'kill "${CODEX_PID:-}" 2>/dev/null || true' EXIT

if ! printf '%s\n' \
  '{"id":0,"method":"initialize","params":{"clientInfo":{"name":"eww","title":"Eww","version":"1.0"}}}' \
  >&"${CODEX[1]}" 2>/dev/null; then
  printf '%s\n' "$unavailable"
  exit 0
fi

initialized=false
while IFS= read -r -t 10 line <&"${CODEX[0]}"; do
  if jq -e '.id == 0 and .result != null' >/dev/null 2>&1 <<<"$line"; then
    initialized=true
    break
  fi
done

if [[ "$initialized" != true ]]; then
  printf '%s\n' "$unavailable"
  exit 0
fi

if ! printf '%s\n%s\n' \
  '{"method":"initialized","params":{}}' \
  '{"id":6,"method":"account/rateLimits/read"}' \
  >&"${CODEX[1]}" 2>/dev/null; then
  printf '%s\n' "$unavailable"
  exit 0
fi

limits=''
while IFS= read -r -t 10 line <&"${CODEX[0]}"; do
  if jq -e '.id == 6 and .result != null' >/dev/null 2>&1 <<<"$line"; then
    limits="$(jq -c '.result' <<<"$line" 2>/dev/null || true)"
    break
  fi
done

if [[ -z "$limits" ]]; then
  printf '%s\n' "$unavailable"
  exit 0
fi

# The API reports usedPercent and Unix reset timestamps in seconds.
# Prefer the 'codex' bucket, falling back to the legacy single-bucket view.
result="$(jq -c --argjson now "$(date +%s)" '
  def pct:
    if type == "number" then
      floor | if . < 0 then 0 elif . > 100 then 100 else . end
    else 0 end;

  def reset_label($timestamp):
    if ($timestamp | type) != "number" then "Reset time unavailable"
    else
      ([$timestamp - $now, 0] | max) as $seconds
      | if $seconds < 3600 then
          "Resets in \((($seconds + 59) / 60) | floor)m"
        elif $seconds < 86400 then
          "Resets in \(($seconds / 3600) | floor)h \((($seconds % 3600) / 60) | floor)m"
        else
          "Resets in \(($seconds / 86400) | floor)d \((($seconds % 86400) / 3600) | floor)h"
        end
    end;

  (.rateLimitsByLimitId.codex // .rateLimits //
    (.rateLimitsByLimitId // {} | to_entries | map(.value | select(.primary != null)) | first)) as $bucket
  | if $bucket == null or $bucket.primary == null then
      {ok:false, five_used:0, five_left:0, five_reset:"—",
       week_ok:false, week_used:0, week_left:0, week_reset:"—"}
    else
      ($bucket.primary.usedPercent | pct) as $five
      | ($bucket.secondary.usedPercent | pct) as $week
      | {
          ok:true,
          five_used:$five,
          five_left:(100 - $five),
          five_reset:reset_label($bucket.primary.resetsAt),
          week_ok:($bucket.secondary != null),
          week_used:$week,
          week_left:(100 - $week),
          week_reset:reset_label($bucket.secondary.resetsAt)
        }
    end
' <<<"$limits" 2>/dev/null || true)"

printf '%s\n' "${result:-$unavailable}"
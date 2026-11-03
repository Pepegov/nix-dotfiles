#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
output="$(bash "$root/config/scripts/codex-limits.sh")"

grep -Eq '^5H: [0-9]+% used, reset [0-9]{2}:[0-9]{2}$' <<<"$output"
grep -Eq '^WEEK: [0-9]+% used, reset [0-9]{2}:[0-9]{2}$' <<<"$output"

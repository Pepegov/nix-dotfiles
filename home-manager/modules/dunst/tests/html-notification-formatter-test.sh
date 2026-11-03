#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
formatter="$root/config/format-html-notification.py"
temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT

cat >"$temporary/dunstctl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$temporary/notify-send" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_LOG"
EOF

chmod +x "$temporary/dunstctl" "$temporary/notify-send"

TEST_LOG="$temporary/log" \
PATH="$temporary:$PATH" \
DUNST_ID=42 \
DUNST_APP_NAME='KDE Connect' \
DUNST_SUMMARY='Telegram' \
DUNST_BODY='Review: &lt;b&gt;Nikos Meli&lt;/b&gt;&lt;br/&gt;&lt;i&gt;Needs changes&lt;/i&gt;' \
DUNST_URGENCY=NORMAL \
DUNST_TIMEOUT=8000 \
python3 "$formatter"

grep -Fx 'close 42' "$temporary/log"
grep -Fx -- '-a KDE Connect formatted -u normal -t 8000 Telegram Review: <b>Nikos Meli</b>' "$temporary/log"
grep -Fx '<i>Needs changes</i>' "$temporary/log"
grep -Fq 'format = "";' "$root/default.nix"
grep -Fq 'always_run_script = true;' "$root/default.nix"

: >"$temporary/log"
TEST_LOG="$temporary/log" \
PATH="$temporary:$PATH" \
DUNST_ID=43 \
DUNST_SUMMARY='Malformed' \
DUNST_BODY='&lt;b&gt;&lt;i&gt;x&lt;/b&gt;y&lt;/i&gt;' \
DUNST_URGENCY=NORMAL \
DUNST_TIMEOUT=8000 \
python3 "$formatter"

grep -Fx 'close 43' "$temporary/log"
grep -Fx -- '-a KDE Connect formatted -u normal -t 8000 Malformed <b><i>x</i></b><i>y</i>' "$temporary/log"

: >"$temporary/log"
TEST_LOG="$temporary/log" \
PATH="$temporary:$PATH" \
DUNST_ID=44 \
DUNST_SUMMARY='Plain' \
DUNST_BODY='No markup here' \
DUNST_URGENCY=NORMAL \
DUNST_TIMEOUT=8000 \
python3 "$formatter"

grep -Fx 'close 44' "$temporary/log"
grep -Fx -- '-a KDE Connect formatted -u normal -t 8000 Plain No markup here' "$temporary/log"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/generate-dashboard.sh"
[ -f "$SCRIPT" ] || { echo "Missing generate-dashboard.sh" >&2; exit 1; }

TEMP_HTML="$(mktemp --suffix=.html 2>/dev/null || mktemp)"

cleanup() {
    rm -f "$TEMP_HTML"
}
trap cleanup EXIT

# 1. HTML generation
bash "$SCRIPT" --out-file "$TEMP_HTML" >/dev/null
[ -f "$TEMP_HTML" ] || { echo "HTML not generated" >&2; exit 1; }
grep -q "GSS-Bridge Cockpit" "$TEMP_HTML" || { echo "Missing title in HTML" >&2; exit 1; }

# 2. JSON export
OUT_JSON="$(bash "$SCRIPT" --json)"
python -c '
import sys, json
d = json.loads(sys.argv[1])
assert "graph" in d, "Missing graph in JSON"
assert "tasks" in d, "Missing tasks in JSON"
' "$OUT_JSON"

echo "PASS: test-generate-dashboard.sh"
exit 0

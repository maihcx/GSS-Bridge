#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/test-impact.sh"
[ -f "$SCRIPT" ] || { echo "Missing test-impact.sh" >&2; exit 1; }

TEMP_GRAPH="$(mktemp --suffix=.json 2>/dev/null || mktemp)"
cat <<'EOF' > "$TEMP_GRAPH"
{
  "nodes": [
    { "id": "AuthService", "label": "AuthService", "source_file": "src/auth.py" },
    { "id": "TokenValidator", "label": "TokenValidator", "source_file": "src/token.py" },
    { "id": "TestAuth", "label": "TestAuth", "source_file": "tests/test_auth.py" }
  ],
  "links": [
    { "source": "TokenValidator", "target": "AuthService" },
    { "source": "TestAuth", "target": "AuthService" }
  ]
}
EOF

OUT="$(bash "$SCRIPT" --node "AuthService" --graph "$TEMP_GRAPH" --json)"
rm -f "$TEMP_GRAPH"

python -c '
import sys, json
d = json.loads(sys.argv[1])
tests = d.get("impacted_test_files", [])
assert "tests/test_auth.py" in tests, f"Expected test_auth.py in {tests}"
' "$OUT"

echo "PASS: test-test-impact.sh"
exit 0

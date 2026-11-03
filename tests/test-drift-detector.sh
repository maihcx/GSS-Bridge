#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/drift-detector.sh"
[ -f "$SCRIPT" ] || { echo "Missing drift-detector.sh" >&2; exit 1; }

TEMP_RULES="$(mktemp --suffix=.json 2>/dev/null || mktemp)"
cat <<'EOF' > "$TEMP_RULES"
{
  "layers": [
    { "name": "domain", "patterns": ["auth.py"] },
    { "name": "service", "patterns": ["token.py"] }
  ],
  "forbidden_dependencies": [
    { "from": "domain", "to": "service", "reason": "Domain cannot depend on service" }
  ]
}
EOF

OUT="$(bash "$SCRIPT" --rules-file "$TEMP_RULES" --json)"
rm -f "$TEMP_RULES"

python -c '
import sys, json
d = json.loads(sys.argv[1])
assert "status" in d, "Missing status in output"
' "$OUT"

echo "PASS: test-drift-detector.sh"
exit 0

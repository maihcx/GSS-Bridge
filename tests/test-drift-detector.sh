#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/drift-detector.sh"
[ -f "$SCRIPT" ] || { echo "Missing drift-detector.sh" >&2; exit 1; }

FIXTURE_GRAPH="$REPO_ROOT/tests/fixtures/synthetic-graph.json"
[ -f "$FIXTURE_GRAPH" ] || { echo "Missing synthetic-graph.json fixture" >&2; exit 1; }

TEMP_RULES="$(mktemp --suffix=.json 2>/dev/null || mktemp)"
cat <<'EOF' > "$TEMP_RULES"
{
  "layers": [
    { "name": "service", "patterns": ["src/services/*"] },
    { "name": "middleware", "patterns": ["src/middleware/*"] }
  ],
  "forbidden_dependencies": [
    { "from": "service", "to": "middleware", "reason": "Service cannot depend on middleware" }
  ]
}
EOF

OUT="$(bash "$SCRIPT" --graph "$FIXTURE_GRAPH" --rules-file "$TEMP_RULES" --json)"
rm -f "$TEMP_RULES"

python -c '
import sys, json
d = json.loads(sys.argv[1])
assert "status" in d, "Missing status in output"
' "$OUT"

echo "PASS: test-drift-detector.sh"
exit 0

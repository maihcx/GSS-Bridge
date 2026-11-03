#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/ast-skeleton.sh"
[ -f "$SCRIPT" ] || { echo "Missing ast-skeleton.sh" >&2; exit 1; }

TEMP_PY="$(mktemp --suffix=.py 2>/dev/null || mktemp)"
cat <<'EOF' > "$TEMP_PY"
import os, sys

class SampleService:
    '''Documentation for service.'''
    def __init__(self, name):
        self.name = name
        self.initialized = True
        
    def execute_work(self, item_id: str) -> bool:
        print('working')
        result = 42
        return True

def standalone_helper(x, y):
    return x + y
EOF

OUT="$(bash "$SCRIPT" --path "$TEMP_PY" --json)"
rm -f "$TEMP_PY"

python -c '
import sys, json
d = json.loads(sys.argv[1])
assert "class SampleService" in d.get("skeleton", ""), "Missing class in skeleton"
assert "def execute_work" in d.get("skeleton", ""), "Missing def in skeleton"
sp = d.get("savings_pct", 0)
assert sp > 10, f"Expected savings, got {sp}"
' "$OUT"

echo "PASS: test-ast-skeleton.sh"
exit 0

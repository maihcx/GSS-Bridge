#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/log-decision.sh"
[ -f "$SCRIPT" ] || { echo "Missing log-decision.sh" >&2; exit 1; }

JOURNAL_FILE="$REPO_ROOT/.specify/agent-decisions.jsonl"
BACKUP_FILE="$JOURNAL_FILE.bak"
if [ -f "$JOURNAL_FILE" ]; then
    cp "$JOURNAL_FILE" "$BACKUP_FILE"
fi

cleanup() {
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$JOURNAL_FILE"
    else
        rm -f "$JOURNAL_FILE"
    fi
}
trap cleanup EXIT

TOPIC="test-log-sh-$RANDOM"
OUT="$(bash "$SCRIPT" --decision "Use AST pruning in bash" --rationale "Saves tokens" --topic "$TOPIC" --actor "antigravity" --json)"

python -c '
import sys, json
d = json.loads(sys.argv[1])
assert d.get("id", "").startswith("dec-"), "Invalid decision id"
assert d.get("decision") == "Use AST pruning in bash"
' "$OUT"

QUERY_OUT="$(bash "$SCRIPT" --topic "$TOPIC" --json)"
python -c '
import sys, json
arr = json.loads(sys.argv[1])
assert len(arr) >= 1, "Expected at least 1 record"
assert arr[0].get("decision") == "Use AST pruning in bash"
' "$QUERY_OUT"

echo "PASS: test-log-decision.sh"
exit 0

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/wave-worktree.sh"
[ -f "$SCRIPT" ] || { echo "Missing wave-worktree.sh" >&2; exit 1; }

WT_NAME="test-wt-suite-$RANDOM"

cleanup() {
    bash "$SCRIPT" --action cleanup --name "$WT_NAME" --json >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 1. Create
CREATE_OUT="$(bash "$SCRIPT" --action create --name "$WT_NAME" --force --json)"
python -c '
import sys, json
d = json.loads(sys.argv[1])
assert d.get("status") == "created", "Worktree creation failed"
' "$CREATE_OUT"

# 2. List
LIST_OUT="$(bash "$SCRIPT" --action list --json)"
python -c '
import sys, json
arr = json.loads(sys.argv[1])
name = sys.argv[2]
assert any(item.get("name") == name for item in arr), f"{name} not in list"
' "$LIST_OUT" "$WT_NAME"

echo "PASS: test-wave-worktree.sh"
exit 0

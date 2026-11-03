#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/synthesize-repro.sh"
[ -f "$SCRIPT" ] || { echo "Missing synthesize-repro.sh" >&2; exit 1; }

SLUG="test-repro-suite-sh"
OUT="$(bash "$SCRIPT" --slug "$SLUG" --suspect-node "AuthService" --symptom "Expected token but got null" --json)"

REPRO_FILE="$(python -c 'import sys, json; print(json.loads(sys.argv[1]).get("repro_test_file", ""))' "$OUT")"

if [ -z "$REPRO_FILE" ] || [ ! -f "$REPO_ROOT/$REPRO_FILE" ]; then
    echo "Repro test file not found: $REPRO_FILE" >&2
    exit 1
fi

if bash "$REPO_ROOT/$REPRO_FILE" >/dev/null 2>&1; then
    echo "Repro test should have FAILED (RED), but passed!" >&2
    rm -f "$REPO_ROOT/$REPRO_FILE"
    exit 1
fi

rm -f "$REPO_ROOT/$REPRO_FILE"
echo "PASS: test-synthesize-repro.sh (Failing RED verified)"
exit 0

#!/usr/bin/env bash
# tests/run-all.sh — run all bash smoke tests for GSS-Bridge.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail=0
ran=0

for f in "$SCRIPT_DIR"/test-*.sh; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    printf '\n=== %s ===\n' "$name"
    if bash "$f"; then
        ran=$((ran + 1))
    else
        printf 'FAIL: %s\n' "$name" >&2
        fail=1
    fi
done

echo
if [ "$ran" -eq 0 ]; then
    echo "No bash tests found under $SCRIPT_DIR."
    exit 0
fi
if [ "$fail" -eq 0 ]; then
    echo "All $ran bash tests passed."
    exit 0
fi
echo "One or more tests FAILED."
exit 1

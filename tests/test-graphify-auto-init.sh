#!/usr/bin/env bash
# tests/test-graphify-auto-init.sh — verify graph auto-initialization when graph.json is missing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMON_SCRIPT="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/common-actor-resolution.sh"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

if [ ! -f "$COMMON_SCRIPT" ]; then
    fail "common-actor-resolution.sh not found"
fi

. "$COMMON_SCRIPT"

TEMP_ROOT="$(mktemp -d 2>/dev/null || mktemp -d -t 'gss-init')"

cleanup() {
    rm -rf "$TEMP_ROOT" 2>/dev/null || true
}
trap cleanup EXIT

(
    cd "$TEMP_ROOT"
    git init >/dev/null 2>&1 || true
    mkdir -p src
    cat << 'EOF' > src/calc.py
class Calculator:
    def add(self, a, b):
        return a + b
EOF

    GRAPH_FILE="$TEMP_ROOT/graphify-out/graph.json"
    if [ -f "$GRAPH_FILE" ]; then
        fail "graph.json should not exist before initialization"
    fi

    if command -v graphify >/dev/null 2>&1; then
        ensure_graphify_index "$TEMP_ROOT" 1 >/dev/null 2>&1
        if [ ! -f "$GRAPH_FILE" ]; then
            fail "ensure_graphify_index failed to generate graph.json"
        fi
    else
        echo "graphify executable not in PATH; skipping live build check"
    fi
)

echo "PASS: test-graphify-auto-init.sh"
exit 0

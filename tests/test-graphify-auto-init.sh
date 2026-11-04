#!/usr/bin/env bash
set -euo pipefail

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXT_DIR="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash"

TEMP_ROOT="$(mktemp -d 2>/dev/null || mktemp -d -t 'gss-autoinit-test')"
cleanup() {
    rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

cd "$TEMP_ROOT"
git init -q

# Create dummy source code files
mkdir -p "$TEMP_ROOT/src"
cat << 'EOF' > "$TEMP_ROOT/src/auth.py"
class AuthService:
    def validateToken(token):
        return True
EOF

cat << 'EOF' > "$TEMP_ROOT/src/user.py"
class UserController:
    def login(user):
        AuthService.validateToken("abc")
EOF

# Copy extension scripts
TARGET_EXT="$TEMP_ROOT/.specify/extensions/gss-bridge/scripts/bash"
mkdir -p "$TARGET_EXT"
cp -rp "$EXT_DIR"/* "$TARGET_EXT/"

BLAST_SCRIPT="$TARGET_EXT/graphify-blast-radius.sh"
GRAPH_FILE="$TEMP_ROOT/graphify-out/graph.json"

if [ -f "$GRAPH_FILE" ]; then
    fail "graphify-out/graph.json should not exist before auto-init"
fi

# Test 1: graphify-blast-radius should auto-initialize graphify instead of failing
OUT="$(bash "$BLAST_SCRIPT" --node "AuthService" 2>&1 || true)"

if [ ! -f "$GRAPH_FILE" ]; then
    fail "graphify-out/graph.json was not automatically initialized by graphify-blast-radius.sh"
fi

if echo "$OUT" | grep -q "Run /graphify first"; then
    fail "Expected auto-init, but script skipped and printed 'Run /graphify first'"
fi

# Test 2: bug-assess should leverage the auto-initialized graph
ASSESS_SCRIPT="$TARGET_EXT/bug-assess.sh"
bash "$ASSESS_SCRIPT" --slug "auth-bug" --symptom "Crash in AuthService.validateToken" --actor "antigravity" >/dev/null

ASSESSMENT_FILE="$TEMP_ROOT/.specify/bugs/auth-bug/assessment.md"
if [ ! -f "$ASSESSMENT_FILE" ]; then
    fail "assessment.md not created"
fi

if grep -q "Graphify context not available" "$ASSESSMENT_FILE"; then
    fail "bug-assess skipped Graphify context instead of using the graph"
fi

echo "test-graphify-auto-init-ok"
exit 0

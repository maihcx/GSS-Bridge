#!/usr/bin/env bash
# tests/test-bug-workflow.sh — verify GSS-Bridge bug assessment and fix lifecycle in Bash.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXT_DIR="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash"
FIXTURE_PATH="$REPO_ROOT/tests/fixtures/synthetic-graph.json"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

TEMP_ROOT="$(mktemp -d)"
cleanup() {
    rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

(
    cd "$TEMP_ROOT"
    git init -q

    mkdir -p graphify-out
    cp "$FIXTURE_PATH" graphify-out/graph.json

    mkdir -p .specify/extensions/gss-bridge/scripts/bash
    cp -rp "$EXT_DIR"/* .specify/extensions/gss-bridge/scripts/bash/

    ASSESS_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/bug-assess.sh"
    FIX_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/bug-fix.sh"
    GUARD_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/guard-command.sh"

    # Step 1: Run bug-assess
    bash "$ASSESS_SCRIPT" \
        --slug "login-crash" \
        --symptom "NullReferenceException at AuthService.validateToken called by UserController" \
        --actor "antigravity" >/dev/null

    ASSESSMENT_FILE=".specify/bugs/login-crash/assessment.md"
    [ -f "$ASSESSMENT_FILE" ] || fail "assessment.md not created"
    grep -q "AuthService" "$ASSESSMENT_FILE" || fail "Expected AuthService in assessment.md"
    grep -q "flowchart LR" "$ASSESSMENT_FILE" || fail "Expected Mermaid flowchart in assessment.md"

    # Step 2: Guard check - fix should be denied when assessment missing
    if bash "$GUARD_SCRIPT" --action "speckit.bug.fix" --target-feature-directory ".specify/bugs/non-existent-bug" --actor "antigravity" >/dev/null 2>&1; then
        fail "Expected guard to deny fix for non-existent bug"
    fi

    # Guard check - fix should be allowed when assessment exists
    if ! bash "$GUARD_SCRIPT" --action "speckit.bug.fix" --target-feature-directory ".specify/bugs/login-crash" --actor "antigravity" >/dev/null 2>&1; then
        fail "Expected guard to allow fix when assessment exists"
    fi

    # Step 3: Run bug-fix start (executing)
    bash "$FIX_SCRIPT" --slug "login-crash" --actor "antigravity" >/dev/null

    STATUS="$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' .specify/gss-handoff.json | head -n1 | sed 's/.*"status"[[:space:]]*:[[:space:]]*"//;s/"//')"
    [ "$STATUS" = "executing" ] || fail "Expected executing status, got $STATUS"

    # Step 4: Run bug-fix complete
    bash "$FIX_SCRIPT" \
        --slug "login-crash" \
        --complete \
        --regression-test "tests/test-login-regression.sh" \
        --verification-evidence "PASS: test_login_null_token passed" \
        --actor "antigravity" >/dev/null

    [ -f ".specify/bugs/login-crash/fix.md" ] || fail "fix.md not created"
)

echo "test-bug-workflow-ok"
exit 0

#!/usr/bin/env bash
# tests/test-teamwork.sh — verify GSS-Teamwork multi-agent planning in Bash.
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

    PLAN_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/teamwork-plan.sh"

    mkdir -p specs/001-checkout
    cat << 'EOF' > specs/001-checkout/tasks.md
# Tasks: Checkout Flow

- [ ] T001 [P] Implement OrderService logic
- [ ] T002 [P] Implement PaymentService webhook handler
- [ ] T003 [P] Implement NotificationWorker email alerts
EOF

    [ -f "$PLAN_SCRIPT" ] || fail "teamwork-plan.sh not found at $PLAN_SCRIPT"

    TEXT_OUT="$(bash "$PLAN_SCRIPT" --tasks-path "specs/001-checkout/tasks.md")"
    echo "$TEXT_OUT" | grep -q "Orchestrator" || fail "Missing Orchestrator in text output"
    echo "$TEXT_OUT" | grep -q "Sentinel" || fail "Missing Sentinel in text output"
    echo "$TEXT_OUT" | grep -q "Wave 1" || fail "Missing Wave 1 in text output"

    JSON_OUT="$(bash "$PLAN_SCRIPT" --tasks-path "specs/001-checkout/tasks.md" --json)"
    echo "$JSON_OUT" | grep -q "orchestrator" || fail "Missing orchestrator in json output"
    echo "$JSON_OUT" | grep -q "sentinel" || fail "Missing sentinel in json output"
    echo "$JSON_OUT" | grep -q "worktree_name" || fail "Missing worktree_name in json output"
    echo "$JSON_OUT" | grep -q "subagent_prompt" || fail "Missing subagent_prompt in json output"
    echo "$JSON_OUT" | grep -q "test-impact" || fail "Missing test-impact in sentinel commands"
)

echo "test-teamwork-ok"
exit 0

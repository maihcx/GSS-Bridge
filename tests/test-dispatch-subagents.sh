#!/usr/bin/env bash
# tests/test-dispatch-subagents.sh — verify Parallel Subagent Wave Dispatcher in Bash.
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

    DISPATCH_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/dispatch-subagents.sh"

    mkdir -p specs/001-checkout
    cat << 'EOF' > specs/001-checkout/tasks.md
# Tasks: Checkout Flow

- [ ] T001 [P] Implement OrderService logic
- [ ] T002 [P] Implement PaymentService webhook handler
- [ ] T003 [P] Implement NotificationWorker email alerts
EOF

    TEXT_OUT="$(bash "$DISPATCH_SCRIPT" --tasks-path "specs/001-checkout/tasks.md")"
    echo "$TEXT_OUT" | grep -q "Wave 1" || fail "Missing Wave 1 in text output"
    echo "$TEXT_OUT" | grep -q "Wave 2" || fail "Missing Wave 2 in text output"
)

echo "test-dispatch-subagents-ok"
exit 0

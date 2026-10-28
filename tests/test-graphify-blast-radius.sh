#!/usr/bin/env bash
# tests/test-graphify-blast-radius.sh — test blast radius calculation and coupling checks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPT_PATH="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh"
FIXTURE_PATH="$REPO_ROOT/tests/fixtures/synthetic-graph.json"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

if [ ! -f "$SCRIPT_PATH" ]; then
    fail "Script not found: $SCRIPT_PATH"
fi
if [ ! -f "$FIXTURE_PATH" ]; then
    fail "Fixture not found: $FIXTURE_PATH"
fi

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
    cp -rp "$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash"/* .specify/extensions/gss-bridge/scripts/bash/
    TEMP_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh"

    # Test 1: Blast radius of AuthService
    BLAST_OUT="$(bash "$TEMP_SCRIPT" --node "AuthService")"
    echo "$BLAST_OUT" | grep -q "TokenMiddleware" || fail "Missing caller TokenMiddleware in blast radius"
    echo "$BLAST_OUT" | grep -q "UserController" || fail "Missing caller UserController in blast radius"

    # Test 2: Coupling check on coupled nodes (OrderService <-> PaymentService) -> should exit 1
    set +e
    COUPLED_OUT="$(bash "$TEMP_SCRIPT" --check-coupling --node-a "OrderService" --node-b "PaymentService" 2>&1)"
    COUPLED_CODE=$?
    set -e
    if [ "$COUPLED_CODE" -eq 0 ]; then
        fail "Expected coupled nodes to exit non-zero"
    fi
    echo "$COUPLED_OUT" | grep -q "COUPLED" || fail "Expected COUPLED message in output"

    # Test 3: Coupling check on independent nodes (AuthService <-> NotificationWorker) -> should exit 0
    INDEP_OUT="$(bash "$TEMP_SCRIPT" --check-coupling --node-a "AuthService" --node-b "NotificationWorker" 2>&1)"
    echo "$INDEP_OUT" | grep -q "INDEPENDENT" || fail "Expected INDEPENDENT message in output"
)

echo "test-graphify-blast-radius-ok"
exit 0

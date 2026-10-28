#!/usr/bin/env bash
# tests/test-guard-rules.sh — test guard boundary rules in Bash.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXT_DIR="$REPO_ROOT/.specify/extensions/gss-bridge/scripts/bash"

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

    mkdir -p .specify/extensions/gss-bridge/scripts/bash
    cp -rp "$EXT_DIR"/* .specify/extensions/gss-bridge/scripts/bash/

    GUARD_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/guard-command.sh"
    UPDATE_SCRIPT=".specify/extensions/gss-bridge/scripts/bash/update-handoff.sh"

    mkdir -p specs/001-test-feature .specify/memory
    echo "# Constitution" > .specify/memory/constitution.md
    echo "# Spec" > specs/001-test-feature/spec.md
    echo "# Plan" > specs/001-test-feature/plan.md
    echo "- [ ] T001 Task 1" > specs/001-test-feature/tasks.md

    # Set handoff to executing
    bash "$UPDATE_SCRIPT" --status executing --feature-directory "specs/001-test-feature" --actor codex >/dev/null

    # Rule 1: deny speckit.implement when executing
    if bash "$GUARD_SCRIPT" --action "speckit.implement" --actor codex >/dev/null 2>&1; then
        fail "Expected speckit.implement to be denied while executing"
    fi

    # Rule 2: deny superpowers:writing-plans when spec.md + plan.md exist
    if bash "$GUARD_SCRIPT" --action "superpowers:writing-plans" --actor codex >/dev/null 2>&1; then
        fail "Expected superpowers:writing-plans to be denied"
    fi

    # Rule 3: deny superpowers:brainstorming when spec.md + plan.md exist
    if bash "$GUARD_SCRIPT" --action "superpowers:brainstorming" --actor codex >/dev/null 2>&1; then
        fail "Expected superpowers:brainstorming to be denied"
    fi

    # Rule 4: deny speckit.constitution while executing
    if bash "$GUARD_SCRIPT" --action "speckit.constitution" --actor codex >/dev/null 2>&1; then
        fail "Expected speckit.constitution to be denied while executing"
    fi

    # Rule 5: allow other speckit.*
    if ! bash "$GUARD_SCRIPT" --action "speckit.tasks" --actor codex >/dev/null 2>&1; then
        fail "Expected speckit.tasks to be allowed"
    fi
)

echo "test-guard-rules-ok"
exit 0

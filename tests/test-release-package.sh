#!/usr/bin/env bash
# tests/test-release-package.sh — verify GSS-Bridge release package structure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BRIDGE_DIR="$REPO_ROOT/.specify/extensions/gss-bridge"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_file() {
    [ -f "$REPO_ROOT/$1" ] || fail "missing required file: $1"
}

assert_dir() {
    [ -d "$REPO_ROOT/$1" ] || fail "missing required directory: $1"
}

printf 'release-package: checking source package inventory\n'

assert_file ".specify/extensions/gss-bridge/extension.yml"
assert_file "extension.yml"
assert_file ".specify/extensions/gss-bridge/verified-versions.json"
assert_dir ".specify/extensions/gss-bridge/commands"
assert_dir ".specify/extensions/gss-bridge/scripts/bash"
assert_dir ".specify/extensions/gss-bridge/scripts/powershell"
assert_file "README.md"
assert_file "README.vi-VN.md"
assert_file "CHANGELOG.md"
assert_file "LICENSE"
assert_file "AGENTS.md"
assert_file "CLAUDE.md"
assert_file ".gitattributes"

cmp -s "$REPO_ROOT/extension.yml" "$BRIDGE_DIR/extension.yml" ||
    fail "root extension.yml is out of sync with bridge extension.yml"

for cmd in execute guard handoff blast-radius; do
    assert_file ".specify/extensions/gss-bridge/commands/speckit.gss-bridge.$cmd.md"
done

bash_count="$(find "$BRIDGE_DIR/scripts/bash" -maxdepth 1 -type f -name '*.sh' | wc -l)"
ps_count="$(find "$BRIDGE_DIR/scripts/powershell" -maxdepth 1 -type f -name '*.ps1' | wc -l)"
[ "$bash_count" -eq "$ps_count" ] || fail "script count mismatch: $bash_count bash vs $ps_count powershell"

echo "test-release-package-ok"
exit 0

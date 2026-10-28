#!/usr/bin/env bash
# build-extension-zip.sh — build portable release zip for GSS-Bridge.
set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: build-extension-zip.sh <version>" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BRIDGE_DIR="$REPO_ROOT/.specify/extensions/gss-bridge"
STAGE_DIR="$(mktemp -d)"
DIST_DIR="$REPO_ROOT/dist"
OUT_ZIP="$DIST_DIR/gss-bridge-v${VERSION}.zip"
LATEST_ZIP="$DIST_DIR/gss-bridge.zip"

mkdir -p "$DIST_DIR"

cleanup() {
    rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

cp -p "$BRIDGE_DIR/extension.yml" "$STAGE_DIR/"
cp -rp "$BRIDGE_DIR/commands" "$STAGE_DIR/"
mkdir -p "$STAGE_DIR/scripts"
cp -rp "$BRIDGE_DIR/scripts/powershell" "$STAGE_DIR/scripts/"
cp -rp "$BRIDGE_DIR/scripts/bash" "$STAGE_DIR/scripts/"

for f in README.md README.vi-VN.md LICENSE AGENTS.md CLAUDE.md .gitignore .gitattributes; do
    if [ -f "$REPO_ROOT/$f" ]; then
        cp -p "$REPO_ROOT/$f" "$STAGE_DIR/"
    fi
done

(
    cd "$STAGE_DIR"
    zip -r -q "$OUT_ZIP" .
)

cp -p "$OUT_ZIP" "$LATEST_ZIP"
SHA="$(sha256sum "$OUT_ZIP" | awk '{print $1}')"
echo "Built: $OUT_ZIP"
echo "Alias: $LATEST_ZIP"
echo "SHA256: $SHA"

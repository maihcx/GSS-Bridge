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
if [ -d "$REPO_ROOT/assets" ]; then
    cp -rp "$REPO_ROOT/assets" "$STAGE_DIR/"
fi

for f in README.md README.vi-VN.md CHANGELOG.md LICENSE AGENTS.md CLAUDE.md .gitignore .gitattributes; do
    if [ -f "$REPO_ROOT/$f" ]; then
        cp -p "$REPO_ROOT/$f" "$STAGE_DIR/"
    fi
done

(
    cd "$STAGE_DIR"
    if command -v zip >/dev/null 2>&1; then
        zip -r -q "$OUT_ZIP" .
    else
        PY_FOUND=0
        for pcmd in python3 python py; do
            if command -v "$pcmd" >/dev/null 2>&1 && "$pcmd" -c "import sys" >/dev/null 2>&1; then
                "$pcmd" -c "import sys, zipfile, os; z = zipfile.ZipFile(sys.argv[1], 'w', zipfile.ZIP_DEFLATED); [z.write(os.path.join(r, f), os.path.relpath(os.path.join(r, f), '.')) for r, d, fs in os.walk('.') for f in fs]; z.close()" "$OUT_ZIP"
                PY_FOUND=1
                break
            fi
        done
        if [ "$PY_FOUND" -eq 0 ]; then
            echo "Error: neither 'zip' nor a functional 'python' command was found." >&2
            exit 1
        fi
    fi
)

cp -p "$OUT_ZIP" "$LATEST_ZIP"
SHA="$(sha256sum "$OUT_ZIP" | awk '{print $1}')"
echo "Built: $OUT_ZIP"
echo "Alias: $LATEST_ZIP"
echo "SHA256: $SHA"

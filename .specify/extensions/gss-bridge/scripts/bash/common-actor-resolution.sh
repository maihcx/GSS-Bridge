#!/usr/bin/env bash
set -euo pipefail

get_bridge_repo_root() {
    if command -v git >/dev/null 2>&1; then
        local root
        root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
        if [ -n "$root" ]; then
            echo "$root"
            return 0
        fi
    fi
    pwd
}

resolve_bridge_actor() {
    local arg="${1:-}"
    local valid=" codex claude antigravity gemini unknown "

    if [ -n "$arg" ]; then
        local lower_arg
        lower_arg="$(echo "$arg" | tr '[:upper:]' '[:lower:]')"
        if [[ "$valid" =~ [[:space:]]"$lower_arg"[[:space:]] ]]; then
            echo "$lower_arg"
            return 0
        fi
        echo "unknown"
        return 0
    fi

    if [ -n "${GSS_BRIDGE_ACTOR:-}" ]; then
        local env_actor
        env_actor="$(echo "$GSS_BRIDGE_ACTOR" | tr '[:upper:]' '[:lower:]')"
        if [[ "$valid" =~ [[:space:]]"$env_actor"[[:space:]] ]]; then
            echo "$env_actor"
            return 0
        fi
    fi

    if [ -n "${SPECKIT_BRIDGE_ACTOR:-}" ]; then
        local env_actor
        env_actor="$(echo "$SPECKIT_BRIDGE_ACTOR" | tr '[:upper:]' '[:lower:]')"
        if [[ "$valid" =~ [[:space:]]"$env_actor"[[:space:]] ]]; then
            echo "$env_actor"
            return 0
        fi
    fi

    echo "unknown"
}

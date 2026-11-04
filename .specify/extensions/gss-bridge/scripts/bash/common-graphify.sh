#!/usr/bin/env bash
# common-graphify.sh — Shared Graphify context and execution helpers for GSS-Bridge.

ensure_graphify_exclusions() {
    local target_root="$1"
    [ -z "$target_root" ] || [ ! -d "$target_root" ] && return 0
    local ignore_path="$target_root/.graphifyignore"
    local mandatory=(
        ".specify/"
        ".agents/"
        ".claude/"
        ".gemini/"
        ".cursor/"
        ".windsurf/"
        ".kilo/"
        ".devin/"
        ".codex/"
        ".copilot/"
        ".ai/"
        "graphify-out/"
        "raw/"
        ".graphify*"
    )
    if [ -f "$ignore_path" ]; then
        local missing=()
        for p in "${mandatory[@]}"; do
            if ! grep -qF "$p" "$ignore_path" 2>/dev/null; then
                missing+=("$p")
            fi
        done
        if [ ${#missing[@]} -gt 0 ]; then
            printf "\n# GSS-Bridge Meta-Tooling Exclusions\n" >> "$ignore_path"
            for m in "${missing[@]}"; do
                printf "%s\n" "$m" >> "$ignore_path"
            done
        fi
    else
        cat << 'EOF' > "$ignore_path"
# =====================================================================
# Graphify Ignore Rules: AI Knowledge & Meta-Tooling Exclusions
# Generated and maintained by GSS-Bridge Protocol
# =====================================================================

# 1. Spec-Kit & Agent Governance Frameworks (AI Knowledge & Directives)
.specify/
.agents/
.claude/
.gemini/
.cursor/
.windsurf/
.kilo/
.devin/
.codex/
.copilot/
.ai/

# 2. Graphify Internal Engine, Intermediate Processing & Artifacts
graphify-out/
raw/
.graphify*

# 3. Transpiled Bundles, Minified Workers & Build Artifacts
node_modules/
dist/
build/
bin/
obj/
out/
target/
.cache/
*.min.js
*.min.css
*.worker.js
*.worker-*.js
*.bundle.js
editorWorker*.js
EOF
    fi

    local out_dir="$target_root/graphify-out"
    if [ -d "$out_dir" ]; then
        local build_cfg="$out_dir/.graphify_build.json"
        cat << 'EOF' > "$build_cfg"
{"excludes": [".specify/", ".agents/", ".claude/", ".gemini/", ".cursor/", ".windsurf/", ".kilo/", ".devin/", ".codex/", ".copilot/", ".ai/", "graphify-out/", "raw/", ".graphify*"], "gitignore": true}
EOF
    fi
}

invoke_graphify_sync() {
    local target_root="$1"
    [ -z "$target_root" ] || [ ! -d "$target_root" ] && return 1
    ensure_graphify_exclusions "$target_root"
    local prev_dir="$PWD"
    cd "$target_root" || return 1
    
    export GRAPHIFY_FORCE=1
    
    # 1. Direct CLI
    if command -v graphify >/dev/null 2>&1; then
        graphify update . --force >/dev/null 2>&1 || true
        if [ -f "$target_root/graphify-out/graph.json" ]; then
            cd "$prev_dir"
            return 0
        fi
    fi
    
    # 2. Python module
    for py in python3 python py; do
        if command -v "$py" >/dev/null 2>&1; then
            "$py" -m graphify update . --force >/dev/null 2>&1 || true
            if [ -f "$target_root/graphify-out/graph.json" ]; then
                cd "$prev_dir"
                return 0
            fi
        fi
    done
    
    # 3. uv tool
    if command -v uv >/dev/null 2>&1; then
        uv tool run graphifyy update . --force >/dev/null 2>&1 || true
        if [ -f "$target_root/graphify-out/graph.json" ]; then
            cd "$prev_dir"
            return 0
        fi
    fi
    
    cd "$prev_dir"
    [ -f "$target_root/graphify-out/graph.json" ] && return 0
    return 1
}

ensure_graphify_graph() {
    local target_root="$1"
    local graph_path="${2:-$target_root/graphify-out/graph.json}"
    local force_sync="${3:-0}"
    
    if [ "$force_sync" -eq 0 ] && [ -f "$graph_path" ]; then
        return 0
    fi
    
    echo "[bridge] Knowledge graph not found or sync requested. Initializing Graphify (graphify update . --force)..."
    if invoke_graphify_sync "$target_root" && [ -f "$graph_path" ]; then
        echo "[bridge] Knowledge graph successfully generated at '$graph_path'."
        return 0
    fi
    
    return 1
}

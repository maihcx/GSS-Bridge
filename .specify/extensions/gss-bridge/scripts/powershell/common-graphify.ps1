# common-graphify.ps1 — Shared Graphify context and execution helpers for GSS-Bridge.
$ErrorActionPreference = "Stop"

function Ensure-GraphifyExclusions {
    param([string]$RepoRoot)
    if ([string]::IsNullOrWhiteSpace($RepoRoot) -or -not (Test-Path -LiteralPath $RepoRoot)) { return }
    $ignorePath = Join-Path $RepoRoot ".graphifyignore"
    $mandatoryPatterns = @(
        ".specify/",
        ".agents/",
        ".claude/",
        ".gemini/",
        ".cursor/",
        ".windsurf/",
        ".kilo/",
        ".devin/",
        ".codex/",
        ".copilot/",
        ".ai/",
        "graphify-out/",
        "raw/",
        ".graphify*",
        "node_modules/",
        "dist/",
        "build/",
        "bin/",
        "obj/",
        "out/",
        "target/",
        ".cache/",
        "*.min.js",
        "*.min.css",
        "*.worker.js",
        "*.worker-*.js",
        "*.bundle.js",
        "editorWorker*.js"
    )
    if (Test-Path -LiteralPath $ignorePath) {
        $existing = Get-Content -LiteralPath $ignorePath -Raw
        $missing = New-Object System.Collections.Generic.List[string]
        foreach ($pat in $mandatoryPatterns) {
            if ($existing -notmatch [regex]::Escape($pat)) {
                $missing.Add($pat)
            }
        }
        if ($missing.Count -gt 0) {
            $appendBlock = [Environment]::NewLine + "# GSS-Bridge Meta-Tooling Exclusions" + [Environment]::NewLine + ($missing -join [Environment]::NewLine) + [Environment]::NewLine
            [System.IO.File]::AppendAllText($ignorePath, $appendBlock, [System.Text.Encoding]::UTF8)
        }
    } else {
        $defaultIgnore = @"
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
"@
        [System.IO.File]::WriteAllText($ignorePath, $defaultIgnore.Replace("`r`n", "`n").Replace("`n", "`r`n"), [System.Text.Encoding]::UTF8)
    }

    $outDir = Join-Path $RepoRoot "graphify-out"
    if (Test-Path -LiteralPath $outDir) {
        $buildCfg = Join-Path $outDir ".graphify_build.json"
        try {
            $cfgExcludes = New-Object System.Collections.Generic.List[string]
            if (Test-Path -LiteralPath $buildCfg) {
                try {
                    $parsed = Get-Content -LiteralPath $buildCfg -Raw | ConvertFrom-Json
                    if ($parsed -and $parsed.excludes) {
                        foreach ($item in $parsed.excludes) {
                            $cfgExcludes.Add([string]$item)
                        }
                    }
                } catch {}
            }
            foreach ($pat in $mandatoryPatterns) {
                if (-not $cfgExcludes.Contains($pat)) {
                    $cfgExcludes.Add($pat)
                }
            }
            $hash = [ordered]@{ excludes = @($cfgExcludes); gitignore = $true }
            $json = $hash | ConvertTo-Json -Depth 4
            [System.IO.File]::WriteAllText($buildCfg, $json, [System.Text.Encoding]::UTF8)
        } catch {}
    }
}

function Invoke-GraphifySync {
    param([string]$RepoRoot)
    if ([string]::IsNullOrWhiteSpace($RepoRoot) -or -not (Test-Path -LiteralPath $RepoRoot)) { return $false }
    Ensure-GraphifyExclusions -RepoRoot $RepoRoot
    $env:GRAPHIFY_FORCE = "1"
    
    $origLocation = Get-Location
    try {
        Set-Location -LiteralPath $RepoRoot
        
        # 1. Direct CLI
        if (Get-Command "graphify" -ErrorAction SilentlyContinue) {
            try {
                & graphify update . --force 2>$null | Out-Null
                if (Test-Path -LiteralPath (Join-Path $RepoRoot "graphify-out\graph.json")) {
                    return $true
                }
            } catch {}
        }
        
        # 2. Python module
        foreach ($pyCmd in @("python", "python3", "py")) {
            if (Get-Command $pyCmd -ErrorAction SilentlyContinue) {
                try {
                    & $pyCmd -m graphify update . --force 2>$null | Out-Null
                    if (Test-Path -LiteralPath (Join-Path $RepoRoot "graphify-out\graph.json")) {
                        return $true
                    }
                } catch {}
            }
        }
        
        # 3. uv tool
        if (Get-Command "uv" -ErrorAction SilentlyContinue) {
            try {
                & uv tool run graphifyy update . --force 2>$null | Out-Null
                if (Test-Path -LiteralPath (Join-Path $RepoRoot "graphify-out\graph.json")) {
                    return $true
                }
            } catch {}
        }
    } finally {
        Set-Location -LiteralPath $origLocation
    }
    
    return (Test-Path -LiteralPath (Join-Path $RepoRoot "graphify-out\graph.json"))
}

function Ensure-GraphifyGraph {
    param(
        [string]$RepoRoot,
        [string]$GraphPath = "",
        [switch]$ForceSync
    )
    if ([string]::IsNullOrWhiteSpace($GraphPath)) {
        $GraphPath = Join-Path $RepoRoot "graphify-out\graph.json"
    }
    
    if (-not $ForceSync -and (Test-Path -LiteralPath $GraphPath)) {
        return $true
    }
    
    Write-Output "[bridge] Knowledge graph not found or sync requested. Initializing Graphify (graphify update . --force)..."
    $ok = Invoke-GraphifySync -RepoRoot $RepoRoot
    if ($ok -and (Test-Path -LiteralPath $GraphPath)) {
        Write-Output "[bridge] Knowledge graph successfully generated at '$GraphPath'."
        return $true
    }
    
    return $false
}

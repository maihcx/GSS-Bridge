$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$BridgeRoot = Join-Path $RepoRoot ".specify/extensions/gss-bridge"
$BridgeSource = Join-Path $BridgeRoot "scripts/powershell"
if (-not (Test-Path -LiteralPath $BridgeSource -PathType Container)) {
    Fail "PowerShell bridge script source not found: $BridgeSource"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-bridge-smoke-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    $bridgeDest = Join-Path $tempRoot ".specify/extensions/gss-bridge"
    New-Item -ItemType Directory -Force -Path $bridgeDest | Out-Null
    Copy-Item -Recurse -Path (Join-Path $BridgeRoot "*") -Destination $bridgeDest
    $scriptDir = Join-Path $bridgeDest "scripts/powershell"

    # Add synthetic graphify-out
    $graphDir = Join-Path $tempRoot "graphify-out"
    New-Item -ItemType Directory -Force -Path $graphDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot "tests/fixtures/synthetic-graph.json") -Destination (Join-Path $graphDir "graph.json")

    $featureDir = Join-Path $tempRoot "specs/001-gss-smoke"
    New-Item -ItemType Directory -Force -Path $featureDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $tempRoot ".specify/memory") | Out-Null
    Set-Content -LiteralPath (Join-Path $tempRoot ".specify/memory/constitution.md") -Value "# Constitution`n" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "spec.md") -Value "# Spec`n" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "plan.md") -Value "# Plan`n" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "tasks.md") -Value "- [ ] T001 Smoke task`n" -Encoding UTF8

    $update = Join-Path $scriptDir "update-handoff.ps1"
    $guard = Join-Path $scriptDir "guard-command.ps1"
    $status = Join-Path $scriptDir "bridge-status.ps1"
    $archive = Join-Path $scriptDir "auto-archive-handoff.ps1"
    $blast = Join-Path $scriptDir "graphify-blast-radius.ps1"

    # 1. Update handoff ready
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $update -Status ready -FeatureDirectory "specs/001-gss-smoke" -Actor codex -ArtifactOwner codex | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "update-handoff ready failed" }

    # 2. Check bridge-status
    $statusOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $status -Actor codex | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "bridge-status failed" }
    if ($statusOutput -notmatch "Status:\s+ready") { Fail "bridge-status did not show ready status" }
    if ($statusOutput -notmatch "Pending tasks:\s+1") { Fail "bridge-status did not show pending task count" }
    if ($statusOutput -notmatch "Graphify:\s+indexed") { Fail "bridge-status did not show graphify indexed" }

    # 3. Check readiness report
    $readinessOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $status -Readiness -Actor codex | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "bridge-status readiness failed" }
    foreach ($needle in @("[bridge readiness]", "Script flavor:", "Required tools:", "Namespace:", "Package files:", "Bridge state:", "Graphify:", "Agents:", "Next:")) {
        if ($readinessOutput -notmatch [regex]::Escape($needle)) {
            Fail "bridge-status readiness output missing $needle"
        }
    }

    # 4. Check JSON readiness report
    $readinessJsonRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $status -Readiness -Json -Actor codex | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "bridge-status readiness JSON failed" }
    $readinessJson = $readinessJsonRaw | ConvertFrom-Json
    if ($readinessJson.script_flavor -ne "ps") { Fail "readiness JSON script_flavor was not ps" }
    if (-not $readinessJson.graphify.status) { Fail "readiness JSON missing graphify status" }

    # 5. Blast radius test
    $blastOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $blast -Node "AuthService" | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "graphify-blast-radius failed" }
    if ($blastOut -notmatch "Direct Callers") { Fail "Blast radius missing Direct Callers" }

    # 6. Guard check
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $guard -Action speckit.plan -Actor codex -TargetFeatureDirectory "specs/001-gss-smoke" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "guard-command speckit.plan failed" }

    # 7. Update handoff complete
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $update -Status complete -FeatureDirectory "specs/001-gss-smoke" -Actor codex | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "update-handoff complete failed" }

    # 8. Auto-archive
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $archive -Actor codex | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "auto-archive-handoff failed" }

    # 9. Verify CRLF on all PowerShell scripts
    $psFiles = Get-ChildItem -LiteralPath $BridgeSource -Filter "*.ps1" -File
    foreach ($file in $psFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        if ($text -notmatch "`r`n") {
            Fail "PowerShell script appears to lack CRLF line endings: $($file.Name)"
        }
    }
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}

Write-Output "release-powershell-tests-ok"
exit 0

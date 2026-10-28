$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExtDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"
$GuardScript = Join-Path $ExtDir "guard-command.ps1"
$UpdateScript = Join-Path $ExtDir "update-handoff.ps1"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-guard-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    $tempExt = Join-Path $tempRoot ".specify\extensions\gss-bridge\scripts\powershell"
    New-Item -ItemType Directory -Force -Path $tempExt | Out-Null
    Copy-Item -Recurse -Path (Join-Path $ExtDir "*") -Destination $tempExt

    $tGuard = Join-Path $tempExt "guard-command.ps1"
    $tUpdate = Join-Path $tempExt "update-handoff.ps1"

    $featureDir = Join-Path $tempRoot "specs/001-test-feature"
    New-Item -ItemType Directory -Force -Path $featureDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $tempRoot ".specify\memory") | Out-Null
    Set-Content -LiteralPath (Join-Path $tempRoot ".specify\memory\constitution.md") -Value "# Constitution" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "spec.md") -Value "# Spec" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "plan.md") -Value "# Plan" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $featureDir "tasks.md") -Value "- [ ] T001 Task 1" -Encoding UTF8

    # Set handoff to executing
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tUpdate -Status executing -FeatureDirectory "specs/001-test-feature" -Actor codex | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Failed to set handoff to executing" }

    # Rule 1: deny speckit.implement when executing
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tGuard -Action "speckit.implement" -Actor codex 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Fail "Expected speckit.implement to be denied while executing" }

    # Rule 2: deny superpowers:writing-plans when spec.md + plan.md exist
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tGuard -Action "superpowers:writing-plans" -Actor codex 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Fail "Expected superpowers:writing-plans to be denied" }

    # Rule 3: deny superpowers:brainstorming when spec.md + plan.md exist
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tGuard -Action "superpowers:brainstorming" -Actor codex 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Fail "Expected superpowers:brainstorming to be denied" }

    # Rule 4: deny speckit.constitution while executing
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tGuard -Action "speckit.constitution" -Actor codex 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Fail "Expected speckit.constitution to be denied while executing" }

    # Rule 5: allow other speckit.*
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tGuard -Action "speckit.tasks" -Actor codex | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Expected speckit.tasks to be allowed" }

    Write-Output "test-guard-rules-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

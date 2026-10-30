# tests/test-bug-workflow.ps1 — verify GSS-Bridge bug assessment and fix lifecycle.
$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExtDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"
$FixturePath = Join-Path $RepoRoot "tests\fixtures\synthetic-graph.json"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-bug-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    # Setup directories
    $graphDir = Join-Path $tempRoot "graphify-out"
    New-Item -ItemType Directory -Force -Path $graphDir | Out-Null
    Copy-Item -LiteralPath $FixturePath -Destination (Join-Path $graphDir "graph.json")

    $destExtDir = Join-Path $tempRoot ".specify\extensions\gss-bridge\scripts\powershell"
    New-Item -ItemType Directory -Force -Path $destExtDir | Out-Null
    Copy-Item -Recurse -Path (Join-Path $ExtDir "*") -Destination $destExtDir

    $assessScript = Join-Path $destExtDir "bug-assess.ps1"
    $fixScript = Join-Path $destExtDir "bug-fix.ps1"
    $guardScript = Join-Path $destExtDir "guard-command.ps1"

    # Step 1: Run bug-assess
    $assessOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $assessScript `
        -Slug "login-crash" `
        -Symptom "NullReferenceException at AuthService.validateToken called by UserController" `
        -Actor "antigravity" | Out-String

    if ($LASTEXITCODE -ne 0) { Fail "bug-assess failed" }
    
    $assessmentFile = Join-Path $tempRoot ".specify\bugs\login-crash\assessment.md"
    if (-not (Test-Path -LiteralPath $assessmentFile)) { Fail "assessment.md not created" }

    $assessContent = Get-Content -LiteralPath $assessmentFile -Raw
    if ($assessContent -notmatch "Primary Suspect Component.*AuthService") {
        Fail "Expected AuthService as primary suspect in assessment.md"
    }
    if ($assessContent -notmatch "flowchart LR") {
        Fail "Expected Mermaid flowchart in assessment.md"
    }

    # Step 2: Guard check - fix should be blocked if assessment missing
    $guardDeny = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $guardScript `
        -Action "speckit.bug.fix" `
        -TargetFeatureDirectory ".specify/bugs/non-existent-bug" `
        -Actor "antigravity" 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) { Fail "Expected guard to deny fix for non-existent bug" }

    # Guard check - fix should be allowed when assessment exists
    $guardAllow = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $guardScript `
        -Action "speckit.bug.fix" `
        -TargetFeatureDirectory ".specify/bugs/login-crash" `
        -Actor "antigravity" 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "Expected guard to allow fix when assessment exists" }

    # Step 3: Run bug-fix start (executing)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixScript `
        -Slug "login-crash" `
        -Actor "antigravity" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "bug-fix start failed" }

    $handoff = Get-Content -LiteralPath (Join-Path $tempRoot ".specify\gss-handoff.json") -Raw | ConvertFrom-Json
    if ($handoff.status -ne "executing") { Fail "Expected handoff status executing, got $($handoff.status)" }

    # Step 4: Run bug-fix complete
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixScript `
        -Slug "login-crash" `
        -Complete `
        -RegressionTest "tests/test-login-regression.ps1" `
        -VerificationEvidence "PASS: test_login_null_token passed" `
        -Actor "antigravity" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "bug-fix complete failed" }

    $fixFile = Join-Path $tempRoot ".specify\bugs\login-crash\fix.md"
    if (-not (Test-Path -LiteralPath $fixFile)) { Fail "fix.md not created" }

    $handoffPost = Get-Content -LiteralPath (Join-Path $tempRoot ".specify\gss-handoff.json") -Raw | ConvertFrom-Json
    if ($handoffPost.status -ne "complete") { Fail "Expected handoff status complete, got $($handoffPost.status)" }

    Write-Output "test-bug-workflow-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

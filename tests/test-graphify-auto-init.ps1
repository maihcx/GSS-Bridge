# tests/test-graphify-auto-init.ps1 — verify automatic Graphify knowledge graph initialization
$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExtDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-autoinit-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    # Create dummy source code files
    $srcDir = Join-Path $tempRoot "src"
    New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
    $authCode = @"
class AuthService:
    def validateToken(token):
        return True
"@
    [System.IO.File]::WriteAllText((Join-Path $srcDir "auth.py"), $authCode, [System.Text.Encoding]::UTF8)

    $userCode = @"
class UserController:
    def login(user):
        AuthService.validateToken("abc")
"@
    [System.IO.File]::WriteAllText((Join-Path $srcDir "user.py"), $userCode, [System.Text.Encoding]::UTF8)

    # Copy extension scripts
    $targetExt = Join-Path $tempRoot ".specify\extensions\gss-bridge\scripts\powershell"
    New-Item -ItemType Directory -Force -Path $targetExt | Out-Null
    Copy-Item -Recurse -Path (Join-Path $ExtDir "*") -Destination $targetExt

    $blastScript = Join-Path $targetExt "graphify-blast-radius.ps1"
    $graphFile = Join-Path $tempRoot "graphify-out\graph.json"

    # Verify graph does NOT exist initially
    if (Test-Path -LiteralPath $graphFile) {
        Fail "graphify-out/graph.json should not exist before auto-init"
    }

    # Test 1: graphify-blast-radius should auto-initialize graphify instead of failing
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $blastScript -Node "AuthService" 2>&1 | Out-String

    if (-not (Test-Path -LiteralPath $graphFile)) {
        Fail "graphify-out/graph.json was not automatically initialized by graphify-blast-radius.ps1"
    }

    if ($out -match "Run /graphify first") {
        Fail "Expected auto-init, but script skipped and printed 'Run /graphify first'"
    }

    # Test 2: bug-assess on a fresh bug should leverage the auto-initialized graph
    $assessScript = Join-Path $targetExt "bug-assess.ps1"
    $bugOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $assessScript `
        -Slug "auth-bug" `
        -Symptom "Crash in AuthService.validateToken" `
        -Actor "antigravity" | Out-String

    $assessmentFile = Join-Path $tempRoot ".specify\bugs\auth-bug\assessment.md"
    if (-not (Test-Path -LiteralPath $assessmentFile)) {
        Fail "assessment.md not created"
    }
    $assessContent = Get-Content -LiteralPath $assessmentFile -Raw
    if ($assessContent -match "Graphify context not available") {
        Fail "bug-assess skipped Graphify context instead of using the graph"
    }

    Write-Output "test-graphify-auto-init-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

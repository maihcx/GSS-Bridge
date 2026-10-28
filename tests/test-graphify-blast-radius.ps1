$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ScriptPath = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1"
$FixturePath = Join-Path $RepoRoot "tests\fixtures\synthetic-graph.json"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    Fail "Script not found: $ScriptPath"
}
if (-not (Test-Path -LiteralPath $FixturePath)) {
    Fail "Fixture not found: $FixturePath"
}

# Create temp repo with graphify-out
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-graphify-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    $graphDir = Join-Path $tempRoot "graphify-out"
    New-Item -ItemType Directory -Force -Path $graphDir | Out-Null
    Copy-Item -LiteralPath $FixturePath -Destination (Join-Path $graphDir "graph.json")

    # Copy extension
    $extDir = Join-Path $tempRoot ".specify\extensions\gss-bridge\scripts\powershell"
    New-Item -ItemType Directory -Force -Path $extDir | Out-Null
    Copy-Item -Recurse -Path (Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\*") -Destination $extDir
    $tempScript = Join-Path $extDir "graphify-blast-radius.ps1"

    # Test 1: Blast radius of AuthService
    $blastOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempScript -Node "AuthService" | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "Blast radius calculation failed" }
    if ($blastOut -notmatch "Direct Callers.*TokenMiddleware") { Fail "Missing caller TokenMiddleware in blast radius" }
    if ($blastOut -notmatch "Direct Callers.*UserController") { Fail "Missing caller UserController in blast radius" }

    # Test 2: Coupling check on coupled nodes (OrderService <-> PaymentService) -> should exit 1
    $coupledOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempScript -CheckCoupling -NodeA "OrderService" -NodeB "PaymentService" 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) { Fail "Expected coupled nodes to exit non-zero" }
    if ($coupledOut -notmatch "COUPLED") { Fail "Expected COUPLED message in output" }

    # Test 3: Coupling check on independent nodes (AuthService <-> NotificationWorker) -> should exit 0
    $indepOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempScript -CheckCoupling -NodeA "AuthService" -NodeB "NotificationWorker" 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "Expected independent nodes to exit 0" }
    if ($indepOut -notmatch "INDEPENDENT") { Fail "Expected INDEPENDENT message in output" }

    Write-Output "test-graphify-blast-radius-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

# tests/test-dispatch-subagents.ps1 — verify Parallel Subagent Wave Dispatcher.
$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExtDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"
$FixturePath = Join-Path $RepoRoot "tests\fixtures\synthetic-graph.json"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-dispatch-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

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

    $dispatchScript = Join-Path $destExtDir "dispatch-subagents.ps1"

    # Create synthetic feature with tasks.md
    $featureDir = Join-Path $tempRoot "specs\001-checkout"
    New-Item -ItemType Directory -Force -Path $featureDir | Out-Null
    $tasksFile = Join-Path $featureDir "tasks.md"

    # OrderService <-> PaymentService are coupled (1 hop)
    # AuthService <-> NotificationWorker are independent (> 2 hops)
    $tasksContent = @"
# Tasks: Checkout Flow

- [ ] T001 [P] Implement OrderService logic
- [ ] T002 [P] Implement PaymentService webhook handler
- [ ] T003 [P] Implement NotificationWorker email alerts
"@
    Set-Content -LiteralPath $tasksFile -Value $tasksContent -Encoding UTF8

    # Run dispatch-subagents with JSON
    $jsonOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $dispatchScript -TasksPath $tasksFile -Json | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "dispatch-subagents failed" }

    $plan = $jsonOut | ConvertFrom-Json
    if ($plan.total_parallel_tasks -ne 3) { Fail "Expected 3 parallel tasks, got $($plan.total_parallel_tasks)" }
    if ($plan.total_waves -lt 2) { Fail "Expected at least 2 waves due to coupling between OrderService and PaymentService" }

    # Verify OrderService and PaymentService are in different waves
    $waveOfOrder = $null
    $waveOfPayment = $null

    foreach ($w in $plan.waves) {
        foreach ($t in $w.tasks) {
            if ($t.description -match "OrderService") { $waveOfOrder = $w.wave_number }
            if ($t.description -match "PaymentService") { $waveOfPayment = $w.wave_number }
        }
    }

    if ($waveOfOrder -eq $waveOfPayment) {
        Fail "OrderService and PaymentService are coupled and should NOT be in the same wave ($waveOfOrder)"
    }

    # Run dispatch-subagents formatted text
    $textOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $dispatchScript -TasksPath $tasksFile | Out-String
    if ($textOut -notmatch "Wave 1") { Fail "Missing Wave 1 in text output" }
    if ($textOut -notmatch "Wave 2") { Fail "Missing Wave 2 in text output" }

    Write-Output "test-dispatch-subagents-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

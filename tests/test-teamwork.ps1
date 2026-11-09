# tests/test-teamwork.ps1 — verify GSS-Teamwork multi-agent planning.
$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExtDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"
$FixturePath = Join-Path $RepoRoot "tests\fixtures\synthetic-graph.json"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-teamwork-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

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

    $planScript = Join-Path $destExtDir "teamwork-plan.ps1"

    # Create synthetic feature with tasks.md
    $featureDir = Join-Path $tempRoot "specs\001-checkout"
    New-Item -ItemType Directory -Force -Path $featureDir | Out-Null
    $tasksFile = Join-Path $featureDir "tasks.md"

    $tasksContent = @"
# Tasks: Checkout Flow

- [ ] T001 [P] Implement OrderService logic
- [ ] T002 [P] Implement PaymentService webhook handler
- [ ] T003 [P] Implement NotificationWorker email alerts
"@
    Set-Content -LiteralPath $tasksFile -Value $tasksContent -Encoding UTF8

    if (-not (Test-Path -LiteralPath $planScript)) {
        Fail "teamwork-plan.ps1 not found at $planScript"
    }

    # Run teamwork-plan with JSON
    $jsonOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $planScript -TasksPath $tasksFile -Json | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "teamwork-plan failed" }

    $plan = $jsonOut | ConvertFrom-Json
    if (-not $plan.roster.orchestrator) { Fail "Missing orchestrator in roster" }
    if (-not $plan.roster.sentinel) { Fail "Missing sentinel in roster" }
    if ($plan.total_waves -lt 2) { Fail "Expected at least 2 waves" }

    # Verify sentinel has verification commands
    $hasTIA = $false
    $hasDrift = $false
    foreach ($cmd in $plan.roster.sentinel.verification_commands) {
        if ($cmd -match "test-impact") { $hasTIA = $true }
        if ($cmd -match "drift-detector") { $hasDrift = $true }
    }
    if (-not $hasTIA) { Fail "Sentinel missing test-impact verification command" }
    if (-not $hasDrift) { Fail "Sentinel missing drift-detector verification command" }

    # Verify coders have worktree metadata and subagent_prompt
    foreach ($w in $plan.roster.waves) {
        foreach ($c in $w.coders) {
            if (-not $c.worktree_name) { Fail "Coder $($c.task_id) missing worktree_name" }
            if (-not $c.subagent_prompt) { Fail "Coder $($c.task_id) missing subagent_prompt" }
            if ($c.subagent_prompt -notmatch "TDD") { Fail "Coder $($c.task_id) missing TDD in subagent_prompt" }
        }
    }

    # Run teamwork-plan formatted text
    $textOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $planScript -TasksPath $tasksFile | Out-String
    if ($textOut -notmatch "Orchestrator") { Fail "Missing Orchestrator in text output" }
    if ($textOut -notmatch "Sentinel") { Fail "Missing Sentinel in text output" }
    if ($textOut -notmatch "Wave 1") { Fail "Missing Wave 1 in text output" }

    Write-Output "test-teamwork-ok"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

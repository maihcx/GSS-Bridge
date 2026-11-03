$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\log-decision.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing log-decision.ps1"
    exit 1
}

$journalFile = Join-Path $RepoRoot ".specify\agent-decisions.jsonl"
$backupFile = $journalFile + ".bak"
if (Test-Path -LiteralPath $journalFile) {
    Copy-Item -LiteralPath $journalFile -Destination $backupFile -Force
}

try {
    # 1. Record decision
    $topic = "test-log-ps1-" + (Get-Random)
    $recRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Decision "Use AST pruning" -Rationale "Saves tokens" -Topic $topic -Actor "antigravity" -Json | Out-String
    $recObj = $recRaw | ConvertFrom-Json
    
    if (-not $recObj.id) {
        Write-Error "Failed to record decision: $recRaw"
        exit 1
    }
    
    # 2. Query decision
    $queryRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Topic $topic -Json | Out-String
    $queryObj = $queryRaw | ConvertFrom-Json
    
    if ($queryObj.Count -eq 0 -or $queryObj[0].decision -ne "Use AST pruning") {
        Write-Error "Failed to query logged decision: $queryRaw"
        exit 1
    }
    
    Write-Output "PASS: test-log-decision.ps1"
} finally {
    if (Test-Path -LiteralPath $backupFile) {
        Move-Item -LiteralPath $backupFile -Destination $journalFile -Force
    } else {
        Remove-Item -LiteralPath $journalFile -Force -ErrorAction SilentlyContinue
    }
}

exit 0

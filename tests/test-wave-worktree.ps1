$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\wave-worktree.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing wave-worktree.ps1"
    exit 1
}

$wtName = "test-wt-suite-" + (Get-Random -Minimum 1000 -Maximum 9999)

try {
    # 1. Create worktree
    $createRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Action create -Name $wtName -Force -Json | Out-String
    $createObj = $createRaw | ConvertFrom-Json
    if ($createObj.status -ne "created") {
        Write-Error "Failed to create worktree: $createRaw"
        exit 1
    }
    
    # 2. List worktrees
    $listRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Action list -Json | Out-String
    $listObj = $listRaw | ConvertFrom-Json
    $found = $false
    foreach ($item in $listObj) {
        if ($item.name -eq $wtName) { $found = $true; break }
    }
    if (-not $found) {
        Write-Error "Created worktree $wtName not found in list: $listRaw"
        exit 1
    }
    
    Write-Output "PASS: test-wave-worktree.ps1"
} finally {
    # 3. Cleanup worktree
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Action cleanup -Name $wtName -Json | Out-Null
}

exit 0

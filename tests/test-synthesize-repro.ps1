$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\synthesize-repro.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing synthesize-repro.ps1"
    exit 1
}

$slug = "test-repro-suite"
$raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Slug $slug -SuspectNode "AuthService" -Symptom "Expected token but got null" -Json | Out-String
$obj = $raw | ConvertFrom-Json

if (-not $obj.repro_test_file) {
    Write-Error "Failed to generate repro_test_file: $raw"
    exit 1
}

$reproPath = Join-Path $RepoRoot $obj.repro_test_file
if (-not (Test-Path -LiteralPath $reproPath)) {
    Write-Error "Repro test file does not exist on disk: $reproPath"
    exit 1
}

try {
    $res = $null
    if ($reproPath -like "*.ps1") {
        $prev = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $reproPath 2>&1 | Out-Null
            $res = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $prev
        }
    } else {
        $res = 1
    }
    
    if ($res -eq 0) {
        Write-Error "Repro test should have FAILED initially (RED phase), but exited with 0"
        exit 1
    }
    
    Write-Output "PASS: test-synthesize-repro.ps1 (Failing RED verified)"
} finally {
    Remove-Item -Force -LiteralPath $reproPath -ErrorAction SilentlyContinue
    $parent = Split-Path -Parent $reproPath
    if (Test-Path -LiteralPath $parent) {
        $files = Get-ChildItem -LiteralPath $parent
        if ($files.Count -eq 0) {
            Remove-Item -Force -Recurse -LiteralPath $parent -ErrorAction SilentlyContinue
        }
    }
}

exit 0

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ScriptDir = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell"
$CommonScript = Join-Path $ScriptDir "common-actor-resolution.ps1"
$BlastScript = Join-Path $ScriptDir "graphify-blast-radius.ps1"

if (-not (Test-Path -LiteralPath $CommonScript)) {
    Fail "common-actor-resolution.ps1 not found"
}

. $CommonScript

# Test in temporary workspace
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-auto-init-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    Push-Location $tempRoot
    git init | Out-Null

    # Create dummy source file
    $srcDir = Join-Path $tempRoot "src"
    New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
    $pyFile = Join-Path $srcDir "calc.py"
    Set-Content -LiteralPath $pyFile -Value "class Calculator:`n    def add(self, a, b):`n        return a + b`n" -Encoding UTF8

    $graphFile = Join-Path $tempRoot "graphify-out\graph.json"
    if (Test-Path -LiteralPath $graphFile) {
        Fail "graph.json should not exist prior to initialization"
    }

    # Test Ensure-GraphifyIndex
    if (Get-Command "graphify" -ErrorAction SilentlyContinue) {
        $result = Ensure-GraphifyIndex -RepoRoot $tempRoot
        if (-not (Test-Path -LiteralPath $graphFile)) {
            Fail "Ensure-GraphifyIndex failed to generate graphify-out/graph.json"
        }
    } else {
        Write-Output "graphify executable not in PATH; skipping live build check"
    }

    Write-Output "PASS: test-graphify-auto-init.ps1"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force -LiteralPath $tempRoot -ErrorAction SilentlyContinue
}
exit 0

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ValidateScript = Join-Path $RepoRoot "scripts/release/validate-release-readiness.ps1"
$BuildScript = Join-Path $RepoRoot "scripts/release/build-extension-zip.ps1"

# 1. Determine target version from extension.yml
$manifest = Get-Content -LiteralPath (Join-Path $RepoRoot "extension.yml") -Raw
$line = (Get-Content -LiteralPath (Join-Path $RepoRoot "extension.yml") | Where-Object { $_ -match "^\s*version:" } | Select-Object -First 1)
$TestVersion = if ($line) { $line.Split(":")[1].Trim().Trim('"').Trim("'") } else { "1.0.1" }

# 2. Build test zip
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $BuildScript -Version $TestVersion | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "build-extension-zip failed" }

$zipPath = Join-Path $RepoRoot "dist/gss-bridge-v$TestVersion.zip"
if (-not (Test-Path -LiteralPath $zipPath)) { Fail "ZIP not created at $zipPath" }

# 3. Validate test zip
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ValidateScript -Version $TestVersion -PackageZip $zipPath | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "validate-release-readiness failed against package zip" }

Write-Output "test-release-package-ok"
exit 0

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Output "FAIL: $Message"
    exit 1
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ValidateScript = Join-Path $RepoRoot "scripts/release/validate-release-readiness.ps1"
$BuildScript = Join-Path $RepoRoot "scripts/release/build-extension-zip.ps1"

# 1. Build test zip
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $BuildScript -Version "1.0.0" | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "build-extension-zip failed" }

$zipPath = Join-Path $RepoRoot "dist/gss-bridge-v1.0.0.zip"
if (-not (Test-Path -LiteralPath $zipPath)) { Fail "ZIP not created at $zipPath" }

# 2. Validate test zip
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ValidateScript -Version "1.0.0" -PackageZip $zipPath | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "validate-release-readiness failed against package zip" }

Write-Output "test-release-package-ok"
exit 0

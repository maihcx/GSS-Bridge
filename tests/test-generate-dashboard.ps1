$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\generate-dashboard.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing generate-dashboard.ps1"
    exit 1
}

$tempHtml = [System.IO.Path]::GetTempFileName() + ".html"

try {
    # 1. Test HTML generation
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -OutFile $tempHtml | Out-Null
    if (-not (Test-Path -LiteralPath $tempHtml)) {
        Write-Error "Failed to generate dashboard HTML"
        exit 1
    }
    
    $content = Get-Content -LiteralPath $tempHtml -Raw -Encoding utf8
    if (-not ($content -match "GSS-Bridge Cockpit")) {
        Write-Error "Dashboard missing title"
        exit 1
    }
    
    # 2. Test JSON export
    $jsonRaw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Json | Out-String
    $jsonObj = $jsonRaw | ConvertFrom-Json
    if (-not $jsonObj.graph -or -not $jsonObj.tasks) {
        Write-Error "Invalid dashboard JSON export: $jsonRaw"
        exit 1
    }
    
    Write-Output "PASS: test-generate-dashboard.ps1"
} finally {
    Remove-Item -Force -LiteralPath $tempHtml -ErrorAction SilentlyContinue
}

exit 0

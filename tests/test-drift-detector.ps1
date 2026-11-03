$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\drift-detector.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing drift-detector.ps1"
    exit 1
}

$tempRules = [System.IO.Path]::GetTempFileName() + ".json"
@"
{
  "layers": [
    { "name": "domain", "patterns": ["auth.py"] },
    { "name": "service", "patterns": ["token.py"] }
  ],
  "forbidden_dependencies": [
    { "from": "domain", "to": "service", "reason": "Domain cannot depend on service" }
  ]
}
"@ | Out-File -FilePath $tempRules -Encoding utf8

try {
    $raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -RulesFile $tempRules -Json | Out-String
    $obj = $raw | ConvertFrom-Json
    
    if (-not $obj.status) {
        Write-Error "Drift detector returned invalid status: $raw"
        exit 1
    }
    
    Write-Output "PASS: test-drift-detector.ps1 (Status: $($obj.status))"
} finally {
    Remove-Item -Force -LiteralPath $tempRules -ErrorAction SilentlyContinue
}

exit 0

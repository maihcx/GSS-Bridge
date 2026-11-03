$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\test-impact.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing test-impact.ps1"
    exit 1
}

$tempGraph = [System.IO.Path]::GetTempFileName() + ".json"
@"
{
  "nodes": [
    { "id": "AuthService", "label": "AuthService", "source_file": "src/auth.py" },
    { "id": "TokenValidator", "label": "TokenValidator", "source_file": "src/token.py" },
    { "id": "TestAuth", "label": "TestAuth", "source_file": "tests/test_auth.py" }
  ],
  "links": [
    { "source": "TokenValidator", "target": "AuthService" },
    { "source": "TestAuth", "target": "AuthService" }
  ]
}
"@ | Out-File -FilePath $tempGraph -Encoding utf8

try {
    $raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Node "AuthService" -Graph $tempGraph -Json | Out-String
    $obj = $raw | ConvertFrom-Json
    
    if (-not $obj.impacted_test_files) {
        Write-Error "No impacted test files detected"
        exit 1
    }
    
    $testFiles = @($obj.impacted_test_files)
    if ($testFiles -notcontains "tests/test_auth.py") {
        Write-Error "Failed to identify tests/test_auth.py in impacted tests: $raw"
        exit 1
    }
    
    Write-Output "PASS: test-test-impact.ps1"
} finally {
    Remove-Item -Force -LiteralPath $tempGraph -ErrorAction SilentlyContinue
}

exit 0

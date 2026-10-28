$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tests = Get-ChildItem -LiteralPath $ScriptDir -Filter "test-*.ps1" -File

$fail = 0
$ran = 0

foreach ($t in $tests) {
    Write-Output "`n=== $($t.Name) ==="
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $t.FullName
    if ($LASTEXITCODE -eq 0) {
        $ran++
    } else {
        Write-Error "FAIL: $($t.Name)"
        $fail++
    }
}

Write-Output ""
if ($ran -eq 0) {
    Write-Error "No tests found under $ScriptDir."
    exit 1
}
if ($fail -eq 0) {
    Write-Output "All $ran PowerShell test suites passed successfully."
    exit 0
}

Write-Error "$fail test suite(s) FAILED."
exit 1

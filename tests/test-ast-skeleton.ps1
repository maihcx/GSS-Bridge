$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$script = Join-Path $RepoRoot ".specify\extensions\gss-bridge\scripts\powershell\ast-skeleton.ps1"
if (-not (Test-Path -LiteralPath $script)) {
    Write-Error "Missing ast-skeleton.ps1"
    exit 1
}

$tempPy = [System.IO.Path]::GetTempFileName() + ".py"
@"
import os, sys

class SampleService:
    '''Documentation for service.'''
    def __init__(self, name):
        self.name = name
        self.initialized = True
        
    def execute_work(self, item_id: str) -> bool:
        print('working')
        result = 42
        return True

def standalone_helper(x, y):
    return x + y
"@ | Out-File -FilePath $tempPy -Encoding utf8

try {
    $raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Path $tempPy -Json | Out-String
    $obj = $raw | ConvertFrom-Json
    
    if (-not $obj.skeleton) {
        Write-Error "Skeleton output is empty"
        exit 1
    }
    
    if (-not ($obj.skeleton -match "class SampleService")) {
        Write-Error "Skeleton missing class definition"
        exit 1
    }
    
    if (-not ($obj.skeleton -match "def execute_work")) {
        Write-Error "Skeleton missing method definition"
        exit 1
    }
    
    if ($obj.savings_pct -lt 10) {
        Write-Error "Expected compression savings, got $($obj.savings_pct)%"
        exit 1
    }
    
    Write-Output "PASS: test-ast-skeleton.ps1 (Saved $($obj.savings_pct)%)"
} finally {
    Remove-Item -Force -LiteralPath $tempPy -ErrorAction SilentlyContinue
}

exit 0

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$RepoRoot = "",

    [string]$PackageZip = ""
)

$ErrorActionPreference = "Stop"

function Add-Problem {
    param(
        [System.Collections.Generic.List[string]]$Problems,
        [string]$Message
    )
    $Problems.Add($Message)
}

function Get-ExtensionId {
    param(
        [string]$Manifest,
        [System.Collections.Generic.List[string]]$Problems
    )
    if ([string]::IsNullOrWhiteSpace($Manifest)) {
        return $null
    }
    $match = [regex]::Match($Manifest, '(?m)^\s*id:\s*["'']?([^"''\s#]+)["'']?\s*$')
    if (-not $match.Success) {
        Add-Problem $Problems "extension.yml: extension.id could not be found"
        return $null
    }
    return $match.Groups[1].Value
}

if ($Version -notmatch '^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$') {
    throw "Version '$Version' is not semver. Expected: X.Y.Z or X.Y.Z-prerelease"
}

$resolvedRepoRoot = if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
} else {
    (Resolve-Path -LiteralPath $RepoRoot).Path
}

$problems = New-Object System.Collections.Generic.List[string]

# 1. Manifest checks
$rootManifestPath = Join-Path $resolvedRepoRoot "extension.yml"
$bridgeManifestPath = Join-Path $resolvedRepoRoot ".specify/extensions/gss-bridge/extension.yml"

if (-not (Test-Path -LiteralPath $rootManifestPath)) {
    Add-Problem $problems "Missing root extension.yml at $rootManifestPath"
}
if (-not (Test-Path -LiteralPath $bridgeManifestPath)) {
    Add-Problem $problems "Missing bridge extension.yml at $bridgeManifestPath"
}

if ((Test-Path -LiteralPath $rootManifestPath) -and (Test-Path -LiteralPath $bridgeManifestPath)) {
    $rootContent = Get-Content -LiteralPath $rootManifestPath -Raw
    $bridgeContent = Get-Content -LiteralPath $bridgeManifestPath -Raw

    $rootId = Get-ExtensionId $rootContent $problems
    if ($rootId -ne "gss-bridge") {
        Add-Problem $problems "extension.yml: extension.id is '$rootId', expected 'gss-bridge'"
    }

    if ($rootContent -notmatch "version:\s*[`"']?$([regex]::Escape($Version))[`"']?\b") {
        Add-Problem $problems "root extension.yml does not declare version '$Version'"
    }
    if ($bridgeContent -notmatch "version:\s*[`"']?$([regex]::Escape($Version))[`"']?\b") {
        Add-Problem $problems "bridge extension.yml does not declare version '$Version'"
    }
}

# 2. CHANGELOG checks
$changelogPath = Join-Path $resolvedRepoRoot "CHANGELOG.md"
if (-not (Test-Path -LiteralPath $changelogPath)) {
    Add-Problem $problems "Missing CHANGELOG.md at $changelogPath"
} else {
    $cl = Get-Content -LiteralPath $changelogPath -Raw
    if ($cl -notmatch "(?m)^##\s*\[$([regex]::Escape($Version))\]") {
        Add-Problem $problems "CHANGELOG.md is missing section for version '## [$Version]'"
    }
}

# 3. Required root files
$requiredFiles = @("README.md", "README.vi-VN.md", "LICENSE", "AGENTS.md", "CLAUDE.md", ".gitattributes", ".gitignore")
foreach ($f in $requiredFiles) {
    $p = Join-Path $resolvedRepoRoot $f
    if (-not (Test-Path -LiteralPath $p)) {
        Add-Problem $problems "Missing required repository file: $f"
    }
}

# 4. Verified versions check
$verPath = Join-Path $resolvedRepoRoot ".specify/extensions/gss-bridge/verified-versions.json"
if (-not (Test-Path -LiteralPath $verPath)) {
    Add-Problem $problems "Missing verified-versions.json at $verPath"
} else {
    try {
        $vv = Get-Content -LiteralPath $verPath -Raw | ConvertFrom-Json
        if ($vv.bridge_version -ne $Version) {
            Add-Problem $problems "verified-versions.json declares bridge_version '$($vv.bridge_version)', expected '$Version'"
        }
    } catch {
        Add-Problem $problems "verified-versions.json is invalid JSON: $($_.Exception.Message)"
    }
}

# 5. Commands check
$cmdDir = Join-Path $resolvedRepoRoot ".specify/extensions/gss-bridge/commands"
if (-not (Test-Path -LiteralPath $cmdDir)) {
    Add-Problem $problems "Missing commands directory at $cmdDir"
} else {
    foreach ($cmd in @("execute", "guard", "handoff", "blast-radius")) {
        $cmdFile = Join-Path $cmdDir "speckit.gss-bridge.$cmd.md"
        if (-not (Test-Path -LiteralPath $cmdFile)) {
            Add-Problem $problems "Missing command file: speckit.gss-bridge.$cmd.md"
        }
    }
}

# 6. Scripts pairing check
$psDir = Join-Path $resolvedRepoRoot ".specify/extensions/gss-bridge/scripts/powershell"
$bashDir = Join-Path $resolvedRepoRoot ".specify/extensions/gss-bridge/scripts/bash"

if (-not (Test-Path -LiteralPath $psDir)) {
    Add-Problem $problems "Missing scripts/powershell directory at $psDir"
}
if (-not (Test-Path -LiteralPath $bashDir)) {
    Add-Problem $problems "Missing scripts/bash directory at $bashDir"
}

if ((Test-Path -LiteralPath $psDir) -and (Test-Path -LiteralPath $bashDir)) {
    $psScripts = Get-ChildItem -LiteralPath $psDir -Filter "*.ps1" -File
    $bashScripts = Get-ChildItem -LiteralPath $bashDir -Filter "*.sh" -File

    if ($psScripts.Count -ne $bashScripts.Count) {
        Add-Problem $problems "Script count mismatch between PowerShell ($($psScripts.Count)) and Bash ($($bashScripts.Count))"
    }
    foreach ($ps in $psScripts) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($ps.Name)
        $sh = Join-Path $bashDir "$stem.sh"
        if (-not (Test-Path -LiteralPath $sh)) {
            Add-Problem $problems "Missing matching bash script for '$($ps.Name)' -> '$stem.sh'"
        }
    }
}

# 7. Package ZIP validation (optional)
if (-not [string]::IsNullOrWhiteSpace($PackageZip)) {
    $zipFull = if ([System.IO.Path]::IsPathRooted($PackageZip)) { $PackageZip } else { Join-Path $resolvedRepoRoot $PackageZip }
    if (-not (Test-Path -LiteralPath $zipFull -PathType Leaf)) {
        Add-Problem $problems "Package ZIP not found at $zipFull"
    } else {
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($zipFull)
        try {
            $entries = @($zip.Entries | ForEach-Object { $_.FullName })
            foreach ($rf in @("extension.yml", "README.md", "README.vi-VN.md", "CHANGELOG.md", "LICENSE", "AGENTS.md", "CLAUDE.md", ".gitattributes")) {
                if (-not ($entries -contains $rf)) {
                    Add-Problem $problems "Package ZIP missing required root entry: $rf"
                }
            }
            foreach ($prefix in @("commands/", "scripts/powershell/", "scripts/bash/")) {
                if (-not (@($entries | Where-Object { $_.StartsWith($prefix) }).Count -gt 0)) {
                    Add-Problem $problems "Package ZIP missing entries with prefix: $prefix"
                }
            }
            foreach ($entry in $zip.Entries) {
                if ($entry.FullName.Contains("\")) {
                    Add-Problem $problems "Package ZIP contains non-portable backslash in entry: $($entry.FullName)"
                }
            }
        } finally {
            $zip.Dispose()
        }
    }
}

# Output verdict
if ($problems.Count -gt 0) {
    Write-Output "Release readiness validation FAILED with $($problems.Count) problem(s):"
    foreach ($p in $problems) {
        Write-Output "  - $p"
    }
    exit 1
}

Write-Output "Release readiness validation PASSED for version $Version."
exit 0

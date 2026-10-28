param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

if ($Version -notmatch '^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$') {
    throw "Version '$Version' is not semver. Expected: X.Y.Z or X.Y.Z-prerelease"
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$bridgeDir = Join-Path $repoRoot ".specify/extensions/gss-bridge"
$stageRoot = Join-Path ([System.IO.Path]::GetTempPath()) "gss-bridge-build-$Version"
$stageDir = $stageRoot
$distDir = Join-Path $repoRoot "dist"
$outZip = Join-Path $distDir "gss-bridge-v$Version.zip"
$latestZip = Join-Path $distDir "gss-bridge.zip"
if (-not (Test-Path -LiteralPath $distDir)) { New-Item -ItemType Directory -Force -Path $distDir | Out-Null }

if (Test-Path -LiteralPath $stageRoot) { Remove-Item -Recurse -Force -LiteralPath $stageRoot }
New-Item -ItemType Directory -Force -Path $stageDir | Out-Null

# Extension content
Copy-Item -LiteralPath (Join-Path $bridgeDir "extension.yml") -Destination $stageDir
Copy-Item -Recurse -LiteralPath (Join-Path $bridgeDir "commands") -Destination $stageDir
New-Item -ItemType Directory -Force -Path (Join-Path $stageDir "scripts") | Out-Null
Copy-Item -Recurse -LiteralPath (Join-Path $bridgeDir "scripts/powershell") -Destination (Join-Path $stageDir "scripts/powershell")
Copy-Item -Recurse -LiteralPath (Join-Path $bridgeDir "scripts/bash") -Destination (Join-Path $stageDir "scripts/bash") -ErrorAction SilentlyContinue

# Root documentation
foreach ($name in @("README.md", "README.vi-VN.md", "CHANGELOG.md", "LICENSE", "AGENTS.md", "CLAUDE.md", ".gitignore", ".gitattributes")) {
    $src = Join-Path $repoRoot $name
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination $stageDir
    }
}

$manifest = Get-Content -LiteralPath (Join-Path $stageDir "extension.yml") -Raw
if ($manifest -notmatch "version:\s*[`"']?$([regex]::Escape($Version))[`"']?\b") {
    throw "extension.yml does not declare version '$Version'. Bump it first."
}

if (Test-Path -LiteralPath $outZip) { Remove-Item -Force -LiteralPath $outZip }
if (Test-Path -LiteralPath $latestZip) { Remove-Item -Force -LiteralPath $latestZip }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($outZip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = Get-ChildItem -LiteralPath $stageRoot -Recurse -File -Force
    $stageRootFull = (Resolve-Path -LiteralPath $stageRoot).Path.TrimEnd('\', '/')
    foreach ($file in $files) {
        $fileFull = (Resolve-Path -LiteralPath $file.FullName).Path
        if (-not $fileFull.StartsWith($stageRootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Staged file is outside stage root: $fileFull"
        }
        $relative = $fileFull.Substring($stageRootFull.Length).TrimStart('\', '/')
        $entryName = $relative.Replace([System.IO.Path]::DirectorySeparatorChar, '/').Replace([System.IO.Path]::AltDirectorySeparatorChar, '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $file.FullName,
            $entryName,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
} finally {
    $zip.Dispose()
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($outZip)
try {
    $hasRootManifest = $false
    $badBackslashEntries = New-Object System.Collections.Generic.List[string]
    foreach ($entry in $zip.Entries) {
        if ($entry.FullName -eq "extension.yml") {
            $hasRootManifest = $true
        }
        if ($entry.FullName.Contains("\")) {
            $badBackslashEntries.Add($entry.FullName)
        }
    }
    if (-not $hasRootManifest) {
        throw "Built ZIP does not contain extension.yml at archive root."
    }
    if ($badBackslashEntries.Count -gt 0) {
        throw "Built ZIP contains non-portable backslash entry names: $($badBackslashEntries -join ', ')"
    }
} finally {
    $zip.Dispose()
}

$sha = (Get-FileHash -LiteralPath $outZip -Algorithm SHA256).Hash.ToLower()
$size = [Math]::Round((Get-Item -LiteralPath $outZip).Length / 1KB, 1)
Copy-Item -LiteralPath $outZip -Destination $latestZip
Write-Output "Built: $outZip"
Write-Output "Alias: $latestZip"
Write-Output "Size:  $size KB"
Write-Output "SHA256: $sha"

Remove-Item -Recurse -Force -LiteralPath $stageRoot

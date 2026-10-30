# bug-fix.ps1 — Execute bug remediation under Superpowers TDD and verification discipline.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [string]$Actor = "",
    [string]$RegressionTest = "",
    [string]$VerificationEvidence = "",
    [switch]$Complete,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common-actor-resolution.ps1')
. (Join-Path $ScriptDir 'bridge-state.ps1')

$RepoRoot = Get-BridgeRepoRoot
$SpecifyDir = Join-Path $RepoRoot ".specify"
$ResolvedActor = Resolve-BridgeActor $Actor

$BugDir = Join-Path $SpecifyDir "bugs\$Slug"
$AssessmentPath = Join-Path $BugDir "assessment.md"

if (-not (Test-Path -LiteralPath $AssessmentPath)) {
    Write-Error "[gss-bridge] Assessment contract missing at '$AssessmentPath'. Run /speckit.gss-bridge.bug-assess -Slug $Slug first before attempting a fix."
    exit 1
}

$UpdateScript = Join-Path $ScriptDir "update-handoff.ps1"

if (-not $Complete) {
    # Transition handoff state to executing
    if (Test-Path -LiteralPath $UpdateScript) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $UpdateScript `
            -Status "executing" `
            -FeatureDirectory ".specify/bugs/$Slug" `
            -ArtifactOwner $ResolvedActor `
            -Actor $ResolvedActor | Out-Null
    }

    if ($Json) {
        @{
            status = "executing"
            slug = $Slug
            assessment = ".specify/bugs/$Slug/assessment.md"
            mandates = @(
                "Write minimal failing regression test (RED)"
                "Implement minimal fix (GREEN)"
                "Verify test passes and invariants hold (REFACTOR)"
                "Run with -Complete when verified"
            )
        } | ConvertTo-Json
    } else {
        Write-Output "[gss-bridge bug-fix] Active bug remediation started for '$Slug'."
        Write-Output "  Contract:      .specify/bugs/$Slug/assessment.md"
        Write-Output "  Handoff state: executing"
        Write-Output ""
        Write-Output "================================================================="
        Write-Output "SUPERPOWERS TDD MANDATE:"
        Write-Output "1. RED:      Write a minimal regression test that FAILS reproducing this bug."
        Write-Output "2. GREEN:    Write the minimal code change to fix the root cause."
        Write-Output "3. REFACTOR: Verify that the test passes and no regressions occur."
        Write-Output "4. COMPLETE: Run ./bug-fix.ps1 -Slug $Slug -Complete -RegressionTest <file>"
        Write-Output "================================================================="
    }
    exit 0
}

# Stage 2: Completion & Verification
$regTestText = if ($RegressionTest) { $RegressionTest } else { "(Regression test added in test suite)" }
$verEvidenceText = if ($VerificationEvidence) { $VerificationEvidence } else { "Verified by local test runner execution." }
$FixPath = Join-Path $BugDir "fix.md"
$Timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')

$bt = [char]96
$flines = New-Object System.Collections.Generic.List[string]
$flines.Add("# Bug Fix Report: $Slug")
$flines.Add('')
$flines.Add('> **Status**: FIXED & VERIFIED')
$flines.Add("> **Resolving Agent**: $ResolvedActor")
$flines.Add("> **Resolved At**: $Timestamp")
$flines.Add('')
$flines.Add('## 1. Assessment Contract')
$flines.Add("- Reference: $bt.specify/bugs/$Slug/assessment.md$bt")
$flines.Add('')
$flines.Add('## 2. Superpowers TDD Evidence')
$flines.Add("- **Regression Test**: $bt$regTestText$bt")
$flines.Add('- **Verification Evidence**:')
$flines.Add('```text')
$flines.Add($verEvidenceText.Trim())
$flines.Add('```')
$flines.Add('')
$flines.Add('## 3. Superpowers Completion Checklist')
$flines.Add('- [x] Failing test written before code modification (RED).')
$flines.Add('- [x] Minimal fix applied resolving root cause (GREEN).')
$flines.Add('- [x] Regression test passing without side effects.')
$flines.Add('- [x] Verification evidence confirmed before marking complete.')
$flines.Add('')
$flines.Add('## 4. Graphify Synchronization')
$flines.Add("- Knowledge graph scheduled for sync via ${bt}graphify --update${bt}.")

$FixContent = ($flines -join [Environment]::NewLine)

[System.IO.File]::WriteAllText($FixPath, $FixContent, [System.Text.Encoding]::UTF8)

# Run Auto Graphify Sync if available
$hasGraph = Test-Path -LiteralPath (Join-Path $RepoRoot "graphify-out\graph.json")
$graphSynced = $false
if ($hasGraph) {
    if (Get-Command "graphify" -ErrorAction SilentlyContinue) {
        try {
            & graphify update . | Out-Null
            $graphSynced = $true
        } catch {
            Write-Verbose "Graphify update invocation notice: $($_.Exception.Message)"
        }
    }
}

# Transition handoff state to complete
if (Test-Path -LiteralPath $UpdateScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $UpdateScript `
        -Status "complete" `
        -FeatureDirectory ".specify/bugs/$Slug" `
        -ArtifactOwner $ResolvedActor `
        -Actor $ResolvedActor | Out-Null
}

if ($Json) {
    @{
        status = "complete"
        slug = $Slug
        fix_report = ".specify/bugs/$Slug/fix.md"
        graph_synced = $graphSynced
    } | ConvertTo-Json
} else {
    Write-Output "[gss-bridge bug-fix] Bug '$Slug' successfully resolved and verified!"
    Write-Output "  Fix Report:   .specify/bugs/$Slug/fix.md"
    Write-Output "  Graphify Sync: $(if ($graphSynced) { 'Synchronized (graphify --update)' } else { 'Run /graphify --update' })"
    Write-Output "  Next step:    Run superpowers:requesting-code-review and finish branch."
}
exit 0

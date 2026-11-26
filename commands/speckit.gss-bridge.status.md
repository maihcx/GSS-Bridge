---
description: "Inspect GSS-Bridge lifecycle state, active handoff status, and system readiness"
---

# GSS-Bridge Status

Inspect the current GSS-Bridge lifecycle state, active handoff status, pending tasks, knowledge graph health, and multi-agent system readiness.

## Capabilities

1. **State & Handoff Introspection**:
   Reports active feature directory, lifecycle status (`ready`, `executing`, `blocked`, `complete`), artifact owner, and pending task count.
2. **Readiness Report (`-Readiness`)**:
   Verifies runtime environment readiness, required tools (PowerShell, Bash, Python, jq), package integrity, and agent configuration.
3. **Machine-Readable Telemetry (`-Json`)**:
   Outputs full state and readiness metrics as JSON for automation and dashboard ingestion.
4. **Interactive HTML Dashboard (`generate-dashboard`)**:
   Generates a standalone dark-mode HTML cockpit at `.specify/dashboard/index.html` summarizing tasks, graph topology, bugs, and decisions.

## Invocation

```powershell
# Check current bridge status and active handoff
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Actor <actor>

# Run comprehensive system readiness check
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Readiness -Actor <actor>

# Output status as JSON
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Json

# Generate and open interactive HTML dashboard
.\.specify\extensions\gss-bridge\scripts\powershell\generate-dashboard.ps1 -Open
```

```bash
# Check current bridge status and active handoff
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --actor <actor>

# Run comprehensive system readiness check
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --readiness --actor <actor>

# Output status as JSON
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --json

# Generate and open interactive HTML dashboard
bash .specify/extensions/gss-bridge/scripts/bash/generate-dashboard.sh --open
```

### Agent Aliases
- Claude Code / Antigravity: `/speckit.gss-bridge.status` or `/gss-status`
- Codex: `$speckit.gss-bridge.status` or `$gss-status`

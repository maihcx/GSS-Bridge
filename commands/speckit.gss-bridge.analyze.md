---
description: "Unified Graphify topology analysis: blast radius, coupling check, test impact (TIA), and architectural drift"
---

# GSS-Bridge Analyze

Unified Graphify codebase analysis combining **Blast Radius & Coupling**, **Test Impact Analysis (TIA)**, and **Architectural Drift & Cycle Auditing** using `graphify-out/graph.json`.

## Knowledge Graph Pre-requisite

If `graphify-out/graph.json` does not exist yet, automatically execute `graphify .` to initialize the knowledge graph before running any analysis.

## Capabilities

1. **Blast Radius & Parallel Coupling (`graphify-blast-radius`)**:
   - Inspect immediate callers (in-edges), callees (out-edges), degree centrality, and Mermaid call flows.
   - Verify whether two `[P]` tasks (`NodeA`, `NodeB`) are decoupled ($d \ge 3$ hops) before parallel execution.
2. **Graph-Guided Test Impact Analysis (`test-impact`)**:
   - Identify test files/suites within 1–2 hops of modified symbols or `git diff` changes to accelerate TDD cycles.
3. **Architectural Drift & Cycle Audit (`drift-detector`)**:
   - Validate layer boundaries against `.specify/memory/architecture-rules.json` and detect circular dependencies (Tarjan's SCC).

## Invocation

```powershell
# 1. Blast radius & coupling check
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -Node "AuthService" -Mermaid
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -CheckCoupling -NodeA "OrderController" -NodeB "NotificationWorker"

# 2. Test Impact Analysis (TIA)
.\.specify\extensions\gss-bridge\scripts\powershell\test-impact.ps1 -DetectChanged -Json

# 3. Architectural drift & cycle audit
.\.specify\extensions\gss-bridge\scripts\powershell\drift-detector.ps1 -FailOnCycles -Json
```

```bash
# 1. Blast radius & coupling check
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --node "AuthService" --mermaid
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --check-coupling --node-a "OrderController" --node-b "NotificationWorker"

# 2. Test Impact Analysis (TIA)
bash .specify/extensions/gss-bridge/scripts/bash/test-impact.sh --detect-changed --json

# 3. Architectural drift & cycle audit
bash .specify/extensions/gss-bridge/scripts/bash/drift-detector.sh --fail-on-cycles --json
```

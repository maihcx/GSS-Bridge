---
name: gss-bridge
description: Use when orchestrating Spec-Kit specifications, Graphify architectural knowledge graphs, and Superpowers execution discipline in a project, assessing bugs, synthesizing repro harnesses, pruning subagent contexts, checking test impact, auditing architectural drift, logging cross-agent decisions, or managing wave worktrees.
---

# GSS-Bridge: Graphify + Spec-Kit + Superpowers

GSS-Bridge is the multi-agent engineering protocol uniting **Spec-Kit** (Governance & Requirements Truth), **Graphify** (Codebase & Topology Truth), and **Superpowers** (Execution & Quality Discipline) across both feature development and bug triage lifecycles.

```
                           ┌──────────────────────────────┐
                           │      Spec-Kit (Governance)   │
                           │   specs/<feature>/ · bugs/   │
                           │   spec.md · plan.md · tasks  │
                           └──────────────┬───────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
   ┌──────────────────────────────┐                ┌──────────────────────────────┐
   │     Graphify (Context)       │◄──────────────►│    Superpowers (Discipline)  │
   │  graphify-out/graph.json     │   Scoping &    │  TDD · Subagents · Debugging │
   │  query · explain · path      │   Traceability │  Verification · Code Review  │
   │  blast-radius · TIA · drift  │                │  bug-fix · repro-synthesis   │
   └──────────────────────────────┘                └──────────────────────────────┘
```

---

## When to Use

```mermaid
flowchart TD
    Trigger{"What is the incoming task?"}
    Trigger -- "New Feature" --> FeatFlow["Feature Lifecycle:\nspec.md -> plan.md -> tasks.md -> execute"]
    Trigger -- "Bug Report / Crash Log" --> BugFlow["Bug Lifecycle:\nbug-assess -> repro-gen -> bug-fix -> fix.md"]
    Trigger -- "Parallel Tasks in tasks.md" --> DispatchFlow["Subagent Wave Dispatcher:\ndispatch-subagents -> Wave Worktrees & Pruning"]
    Trigger -- "Code Quality & Governance" --> ArchFlow["Architecture & Telemetry:\ndrift-detector -> test-select -> dashboard -> decision"]
    
    FeatFlow --> TrinityRule["Apply The Trinity Governance Rules"]
    BugFlow --> TrinityRule
    DispatchFlow --> TrinityRule
    ArchFlow --> TrinityRule
```

### Use When
- Developing new features in a repository governed by Spec-Kit (`.specify/`) and Superpowers.
- Triaging an incoming bug report, stack trace, or GitHub issue URL where call chains, blast radius, and auto-synthesized repro tests must be verified before modifying code.
- Remedying a bug where strict Test-Driven Development (writing a failing test first) and verification evidence are required.
- Planning architecture in `plan.md` and needing component blast radius analysis with Mermaid call graphs.
- Partitioning parallel tasks `[P]` in `tasks.md` into decoupled subagent waves, isolated git worktrees, or token-pruned AST skeletons.
- Selecting impacted tests (TIA) topologically linked to modified components within 1–2 graph hops.
- Auditing architectural drift, forbidden layer boundaries, or circular dependency cycles.
- Recording or querying cross-agent decisions in `.specify/agent-decisions.jsonl`.
- Generating an interactive HTML cockpit at `.specify/dashboard/index.html`.
- The user or prompt invokes `/gss-bridge`, `/speckit-gss-bridge-execute`, `$gss-bridge`, `/speckit-gss-bridge-bug-assess`, `/speckit-gss-bridge-bug-fix`, `/speckit-gss-bridge-dispatch`, or any bridge command.

### When NOT to Use
- Quick, one-line scratchpad edits with zero architectural dependencies or side effects.
- Repositories without Spec-Kit governance where unverified ad-hoc coding is explicitly desired.

---

## The Trinity Protocol: Three Sources of Truth & Discipline

| Dimension | Pillar | Responsibility | Core Mandate |
|---|---|---|---|
| **Governance & Contracts** | **Spec-Kit** | Single Source of Truth for Requirements, Plans & Bug Contracts | Features MUST live in `specs/<feature>/` (`spec.md`, `plan.md`, `tasks.md`). Bugs MUST live in `.specify/bugs/<slug>/` (`assessment.md`, `fix.md`). Never create disconnected plans in `docs/plans/`. |
| **Codebase & Topology** | **Graphify** | Single Source of Truth for Architecture, Call Flows & Coupling | Always query `graphify-out/graph.json` (`query`, `explain`, `path`) before `grep`/`find`. Calculate blast radius with Mermaid diagrams, select impacted tests (TIA), detect architectural drift, and auto-sync (`graphify update .`). |
| **Execution Standard** | **Superpowers** | Execution, TDD & Verification Discipline | Enforce Red-Green-Refactor TDD, Graphify-scoped subagent dispatch, worktree wave isolation, AST skeleton pruning, and verification evidence before completing tasks. |

---

## 1. Feature Lifecycle (Spec-Kit + Graphify + Superpowers)

```mermaid
flowchart LR
    Spec["1. Specify\n(Query Graph)"] --> Plan["2. Plan\n(Blast Radius + Mermaid)"]
    Plan --> Tasks["3. Tasks\n(Tag [P] + Verify Coupling)"]
    Tasks --> Dispatch["4. Dispatch Waves\n(Worktrees + AST Pruning)"]
    Dispatch --> TDD["5. TDD Loop\n(Test Impact Analysis)"]
    TDD --> Verify["6. Verify & Sync\n(Evidence + graphify update)"]
```

1. **Specification (`spec.md`)**:
   Query domain concepts in the knowledge graph before declaring requirements:
   ```bash
   graphify query "How does <subsystem> work?"
   ```
2. **Planning (`plan.md`) & Blast Radius Analysis**:
   For every modified component, calculate blast radius and generate a Mermaid diagram:
   ```powershell
   .\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -Node "AuthService"
   ```
   Embed the output into `plan.md` under `## Blast Radius & Architecture Context`.
   **PROHIBITION**: Never invoke `superpowers:writing-plans` to generate external files in `docs/plans/`. Record all TDD steps directly in `plan.md`.
3. **Tasks Breakdown (`tasks.md`)**:
   Tasks must follow canonical `- [ ] T001 <description>`.
   Tag tasks with `[P]` only when they can safely execute in parallel without coupling ($d \ge 3$ in graph).
4. **Subagent Wave Dispatching & Worktrees**:
   Run the wave dispatcher to partition `[P]` tasks into non-colliding waves and prune prompt tokens:
   ```powershell
   .\.specify\extensions\gss-bridge\scripts\powershell\dispatch-subagents.ps1 -PruneContext -Actor <actor>
   ```
   Scope each subagent strictly to the 1-hop/2-hop files identified by Graphify.
5. **Execution Discipline (TDD & TIA)**:
   - Identify targeted test suites via Test Impact Analysis (`test-impact.ps1`).
   - **RED**: Write failing test first.
   - **GREEN**: Write minimal code to pass.
   - **REFACTOR**: Improve design while preserving invariants.
6. **Completion & Auto Graphify Sync**:
   Verify test runner evidence before marking `- [x] T###`. Upon completing implementation, `update-handoff` automatically synchronizes the graph (`graphify update .`).

---

## 2. Bug Lifecycle: GSS-Bug Protocol

Native Spec-Kit bug commands (`speckit-bug-assess` and `speckit-bug-fix`) operate with Graphify topology context, automated repro test synthesis, and Superpowers TDD discipline.

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Developer / Agent
    participant Bridge as GSS-Bridge Guard
    participant Graph as Graphify Knowledge Graph
    participant Synth as Repro Synthesizer
    participant Assess as .specify/bugs/<slug>/assessment.md
    participant Fix as .specify/bugs/<slug>/fix.md
    participant SP as Superpowers TDD Engine

    Dev->>Graph: bug-assess (Extract symbols & blast radius)
    Graph->>Synth: synthesize-repro (Generate tests/repro/test_<slug>__repro)
    Synth-->>Assess: Write Root Cause, Mermaid Flow & Repro Precondition
    Dev->>Bridge: bug-fix (Check Preconditions)
    Note over Bridge: Guard verifies assessment.md exists
    Bridge-->>SP: Start Remediation (executing)
    SP->>SP: RED: Verify synthesized repro fails
    SP->>SP: GREEN: Apply minimal fix within blast boundary
    SP->>SP: VERIFY: Execute test runner
    SP->>Graph: Auto Sync (graphify update .)
    SP-->>Fix: Write fix.md & mark complete
```

### A. Bug Assessment (`speckit-gss-bridge-bug-assess`)
- **Input**: Bug description, error stack trace, or log file.
- **Action**:
  1. Identifies suspect components from error trace against `graphify-out/graph.json`.
  2. Computes 1-hop callers, 2-hop dependents, and blast radius risk level.
  3. Synthesizes a minimal failing repro test harness in `tests/repro/` via `-GenerateRepro`.
  4. Generates Mermaid call graph into `.specify/bugs/<slug>/assessment.md`.
  5. Defines strict TDD preconditions: verify initial reproduction test failure (RED) before touching code.
- **Command**:
  ```powershell
  .\.specify\extensions\gss-bridge\scripts\powershell\bug-assess.ps1 -Slug "login-crash" -Symptom "NullReferenceException at AuthService.validateToken" -GenerateRepro -Actor <actor>
  ```

### B. Bug Fix (`speckit-gss-bridge-bug-fix`)
- **Precondition Check**: Guard denies `speckit.bug.fix` if `assessment.md` does not exist.
- **TDD Red-Green-Refactor**:
  1. Run the auto-synthesized test case reproducing the failure. Confirm it fails (RED).
  2. Apply the minimal bug fix within the blast radius boundary (GREEN).
  3. Confirm reproduction test and test suite pass (REFACTOR).
- **Completion & Sync**:
  1. Run verification commands and record actual output.
  2. Trigger automatic graph synchronization (`graphify update .`).
  3. Generate `.specify/bugs/<slug>/fix.md`.
  4. Transition handoff state to `complete`.
- **Command**:
  ```powershell
  # Start remediation
  .\.specify\extensions\gss-bridge\scripts\powershell\bug-fix.ps1 -Slug "login-crash" -Actor <actor>

  # Complete remediation with verification evidence
  .\.specify\extensions\gss-bridge\scripts\powershell\bug-fix.ps1 -Slug "login-crash" -Complete -RegressionTest "tests/repro/test_login-crash__repro.ps1" -VerificationEvidence "PASS: All tests passed" -Actor <actor>
  ```

---

## 3. Parallel Subagent Waves & Worktree Isolation

When executing multiple tasks tagged with `[P]` in `tasks.md`:
- Tasks targeting components within 2 hops in `graph.json` are **coupled** and cannot run in parallel.
- Tasks targeting disconnected or $>2$ hop components are **independent** and execute concurrently in waves.
- **Git Worktree Isolation**: Subagents can run in isolated worktrees (`.specify/worktrees/<name>`) on dedicated branches (`gss-worktree/<name>`), eliminating git lock conflicts and dirty working trees.
- **Context Pruning**: Subagent prompts are pruned to AST skeletons, stripping function bodies and saving 70–80% of prompt tokens.

```powershell
# Dispatch waves with AST skeleton pruning
.\.specify\extensions\gss-bridge\scripts\powershell\dispatch-subagents.ps1 -PruneContext -Actor <actor>

# Create an isolated wave worktree
.\.specify\extensions\gss-bridge\scripts\powershell\wave-worktree.ps1 -Action create -Name "wave-1-auth"
```

---

## 4. Advanced Architecture & Telemetry Tools

### A. Graph-Guided Test Impact Analysis (TIA)
Identifies all test files and suites within 1–2 hops of modified components or git changes:
```powershell
.\.specify\extensions\gss-bridge\scripts\powershell\test-impact.ps1 -DetectChanged -Json
```

### B. Architectural Drift & Cycle Auditor
Audits knowledge graph against layer boundaries (`.specify/memory/architecture-rules.json`) and detects circular dependency cycles (Tarjan's SCC):
```powershell
.\.specify\extensions\gss-bridge\scripts\powershell\drift-detector.ps1 -FailOnCycles
```

### C. Cross-Agent Reasoning & Decision Journal
Maintains a shared ledger of architectural choices, trade-offs, and hypotheses across agents in `.specify/agent-decisions.jsonl`:
```powershell
.\.specify\extensions\gss-bridge\scripts\powershell\log-decision.ps1 -Decision "Adopt AST skeleton pruning" -Rationale "Saves 70-80% token load" -Topic "performance" -Actor antigravity
```

### D. Interactive Visual Dashboard
Generates a standalone, zero-dependency dark-mode HTML cockpit at `.specify/dashboard/index.html`:
```powershell
.\.specify\extensions\gss-bridge\scripts\powershell\generate-dashboard.ps1 -Open
```

---

## Quick Reference & Boundary Rules

| Phase / Action | Allowed Operations | Prohibited Red Flags |
|---|---|---|
| **Specification** | `/speckit-specify`, `graphify query` on domain concepts. | Proposing new models without querying existing entities in graph. |
| **Planning** | `graphify-blast-radius` with Mermaid, embedding TDD matrices into `plan.md`. | Creating external plan files in `docs/plans/`. |
| **Tasks** | Tagging `[P]` after `dispatch-subagents` or coupling check. | Marking `[P]` without verifying $\ge 2$ hop independence. |
| **Bug Assessment** | `bug-assess.ps1 -GenerateRepro` to synthesize repro harness and extract blast radius. | Blind guessing or grep-only triage without graph topology. |
| **Bug Fix** | `bug-fix.ps1` with TDD reproduction test first (Red $\rightarrow$ Green). | Direct code patching without `assessment.md` or without writing a test. |
| **Context Scoping** | `ast-skeleton.ps1` to strip function bodies for subagent prompts. | Dumping 2,000+ line raw source files into subagent prompts. |
| **Test Execution** | `test-impact.ps1` to selectively run tests affected within 2 hops. | Running entire slow test suites during every micro-refactor. |
| **Architecture Audit** | `drift-detector.ps1` to verify clean layering and zero cycles. | Merging code that introduces circular module dependencies. |
| **Cross-Agent Memory** | `log-decision.ps1` to record choices in `.specify/agent-decisions.jsonl`. | Refactoring without checking past agent trade-offs and rationale. |
| **Completion** | Verification evidence, `graphify update .`, dashboard generation. | Marking `- [x] T###` or completing bug fix without test execution evidence. |

---

## Rationalization Table

| Excuse | Reality | Mandated Action |
|---|---|---|
| *"I can diagnose this bug by reading the file directly."* | Stack traces only show symptoms. Graphify reveals the full caller chain and transitive blast radius. | Run `/speckit-gss-bridge-bug-assess` first. |
| *"I'll fix the bug first, then add a test."* | Tests written after code are biased toward passing and miss regression edge cases. | Run with `-GenerateRepro` and verify RED before touching code. |
| *"I can run all [P] tasks at once in the same working tree."* | Concurrent edits produce git index locks and state collisions. | Use `dispatch-subagents` and `wave-worktree`. |
| *"I must send all source files into the subagent prompt."* | Subagents only need signatures and interfaces; bodies waste 70–80% of tokens. | Use `ast-skeleton.ps1` / `dispatch -PruneContext`. |
| *"I need to run the entire 10-minute test suite on every change."* | Slow feedback halts TDD flow. Only tests linked within 1–2 hops are impacted. | Run `test-impact.ps1` during iteration; full suite before commit. |
| *"I don't need to record why I chose this library/architecture."* | The next agent (Claude, Codex, or Gemini) will lack context and may undo your work. | Record in `.specify/agent-decisions.jsonl` via `log-decision`. |
| *"I'll create the implementation plan in `docs/plans/`."* | Violates Spec-Kit as the single source of truth for design documentation. | Write TDD matrices directly into `specs/<feature>/plan.md`. |
| *"I don't need to update the graph after fixing."* | Stale knowledge graphs deceive future queries and lead to architectural drift. | Run `graphify update .` upon completion. |

---

## CLI & Script Reference

```powershell
# Check Bridge status and system readiness
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Readiness -Actor <actor>

# Calculate Blast Radius and Mermaid Diagram
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -Node "AuthService" -Mermaid

# Verify coupling between two components
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -CheckCoupling -NodeA "OrderService" -NodeB "PaymentService"

# Dispatch parallel subagents into waves with AST pruning
.\.specify\extensions\gss-bridge\scripts\powershell\dispatch-subagents.ps1 -PruneContext -Actor <actor>

# Extract AST Skeleton to reduce tokens
.\.specify\extensions\gss-bridge\scripts\powershell\ast-skeleton.ps1 -Path "src/core.py"

# Select impacted tests based on Graphify topology
.\.specify\extensions\gss-bridge\scripts\powershell\test-impact.ps1 -Node "AuthService"

# Audit architectural drift and circular dependencies
.\.specify\extensions\gss-bridge\scripts\powershell\drift-detector.ps1 -FailOnCycles

# Triage bug with Graphify and auto-synthesize repro harness
.\.specify\extensions\gss-bridge\scripts\powershell\bug-assess.ps1 -Slug "login-crash" -Symptom "Error trace" -GenerateRepro -Actor <actor>

# Remediate bug with Superpowers TDD
.\.specify\extensions\gss-bridge\scripts\powershell\bug-fix.ps1 -Slug "login-crash" -Actor <actor>

# Complete bug fix with verification evidence
.\.specify\extensions\gss-bridge\scripts\powershell\bug-fix.ps1 -Slug "login-crash" -Complete -RegressionTest "tests/repro/test_login-crash__repro.ps1" -VerificationEvidence "PASS" -Actor <actor>

# Record and query cross-agent decisions
.\.specify\extensions\gss-bridge\scripts\powershell\log-decision.ps1 -Decision "Choice" -Rationale "Why" -Topic "arch"
.\.specify\extensions\gss-bridge\scripts\powershell\log-decision.ps1 -Query "Choice"

# Generate interactive HTML dashboard
.\.specify\extensions\gss-bridge\scripts\powershell\generate-dashboard.ps1 -Open

# Manage isolated git worktrees for subagents
.\.specify\extensions\gss-bridge\scripts\powershell\wave-worktree.ps1 -Action create -Name "wave-1"
.\.specify\extensions\gss-bridge\scripts\powershell\wave-worktree.ps1 -Action cleanup -Name "wave-1"
```

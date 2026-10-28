<p align="center">
  <img src="assets/social/github-social-preview.png" alt="GSS-Bridge: Spec-Kit defines WHAT. Graphify reveals WHERE. Superpowers enforces HOW." width="960" />
</p>

<p align="center">
  <em>Spec-Kit defines WHAT. Graphify reveals WHERE. Superpowers enforces HOW.</em>
</p>

<p align="center">
  <a href="./LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" /></a>
  <a href="https://github.com/maihcx/GSS-Bridge/releases"><img alt="Bridge version" src="https://img.shields.io/github/v/release/maihcx/GSS-Bridge?style=flat-square&label=bridge&color=success" /></a>
  <a href="https://github.com/github/spec-kit"><img alt="Spec Kit verified 1.0.12" src="https://img.shields.io/badge/Spec_Kit-verified_1.0.12-success?style=flat-square" /></a>
  <a href="https://github.com/safi-shamsi/graphify"><img alt="Graphify verified 0.3.10" src="https://img.shields.io/badge/Graphify-verified_0.3.10-cyan?style=flat-square" /></a>
  <a href="https://github.com/obra/superpowers"><img alt="Superpowers verified 6.4.2" src="https://img.shields.io/badge/Superpowers-verified_6.4.2-blueviolet?style=flat-square" /></a>
  <a href="https://github.com/github/spec-kit/blob/main/docs/community/extensions.md"><img alt="Spec Kit Marketplace ready" src="https://img.shields.io/badge/Spec_Kit_Marketplace-ready-orange?style=flat-square" /></a>
</p>

# GSS-Bridge

> 🇻🇳 **Tiếng Việt**: Xem tài liệu bằng tiếng Việt tại [README.vi-VN.md](README.vi-VN.md).

**GSS-Bridge is the Golden Triangle protocol uniting Spec-Kit design artifacts, Graphify codebase intelligence, and Superpowers execution discipline.** Spec-Kit stays the single source of truth for requirements and governance (`constitution` $\rightarrow$ `spec` $\rightarrow$ `plan` $\rightarrow$ `tasks`). Graphify acts as the topological compass (`graph.json` $\rightarrow$ blast radius $\rightarrow$ parallel task coupling check $\rightarrow$ subagent scoping). Superpowers enforces engineering discipline (TDD Red-Green-Refactor $\rightarrow$ systematic call-graph debugging $\rightarrow$ verification before completion $\rightarrow$ structured review).

No daemon. No service. No database. No second workflow engine. No unverified code.

---

## At a glance

| If you want... | GSS-Bridge gives you... |
|---|---|
| **Spec-Kit artifacts to remain canonical** | Spec-Kit keeps owning `spec.md`, `plan.md`, and `tasks.md`. Zero fragmented plans in `docs/plans/`. |
| **Codebase topology without blind grepping** | Persistent knowledge graph at `graphify-out/graph.json` queried via `query`, `explain`, and `path`. |
| **Blast radius & dependency impact before coding** | `graphify explain` calculates 1-hop callers and 2-hop transitive impact directly in `plan.md`. |
| **Zero coupling on parallel tasks `[P]`** | `graphify path` verifies independence between concurrent tasks before subagents dispatch. |
| **Subagents with minimal token overhead** | Context scoped strictly to 1-2 hop AST neighbors (50x–100x context savings, zero hallucinations). |
| **Ruthless TDD & systematic debugging** | Red-Green-Refactor cycle, call-graph trace debugging, and verified test execution evidence. |
| **Multi-agent cross-runtime cooperation** | Identical protocol across Claude Code (`/gss-bridge`), OpenAI Codex (`$gss-bridge`), and Antigravity. |
| **Automatic graph synchronization** | `graphify --update` auto-refreshes the knowledge graph upon completing implementation. |
| **Windows, Linux, and macOS coverage** | One ZIP ships native bash and PowerShell flavors with verified release gates for all three platforms. |

Install the current stable release:

```bash
specify extension add gss-bridge \
  --from https://github.com/maihcx/GSS-Bridge/releases/latest/download/gss-bridge.zip
```

---

## Why GSS-Bridge?

### The Problem with Single-Pillar Workflows

1. **Spec-Kit alone**: Excellent at producing durable design artifacts, but its default `speckit.implement` is a one-shot LLM pass with no TDD, no subagent isolation, and no AST awareness.
2. **Superpowers alone**: Excellent at execution discipline (TDD, subagents, review), but natively expects to drive design through ad-hoc files in `docs/plans/`, losing durable project governance.
3. **Graphify alone**: Provides an incredible knowledge graph of the codebase, but needs an execution engine to act upon its topological insights.
4. **Binary bridges (Spec-Kit + Superpowers)**: Enforce execution discipline, but are blind to the codebase AST, forcing agents to blindly grep files and guess blast radius.

### The Solution: The Golden Triangle

```
                           ┌──────────────────────────────┐
                           │      Spec-Kit (Governance)   │
                           │   specs/<feature>/           │
                           │   spec.md · plan.md · tasks  │
                           └──────────────┬───────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
   ┌──────────────────────────────┐                ┌──────────────────────────────┐
   │     Graphify (Context)       │◄──────────────►│    Superpowers (Discipline)  │
   │  graphify-out/graph.json     │   Scoping &    │  TDD · Subagents · Debugging │
   │  query · explain · path      │   Traceability │  Verification · Code Review  │
   └──────────────────────────────┘                └──────────────────────────────┘
```

GSS-Bridge fuses all three into an airtight engineering loop:
* **Spec-Kit defines WHAT**: Requirements, contracts, and checkboxes in `specs/<feature>/`.
* **Graphify reveals WHERE**: Invariant boundaries, blast radius, and scoped subagent file lists.
* **Superpowers enforces HOW**: Failing tests before code, call-graph systematic debugging, and verified evidence before marking `[x]`.

---

## Quick Start

```bash
# 1. Initialize a Spec-Kit project (or use existing)
specify init my-project --integration claude   # or --integration codex
cd my-project

# 2. Add GSS-Bridge
specify extension add gss-bridge \
  --from https://github.com/maihcx/GSS-Bridge/releases/latest/download/gss-bridge.zip

# 3. Index your codebase with Graphify
/graphify
```

### The 7-Step Feature Lifecycle

1. **Specify**: Run `/speckit-specify <feature-name>` (queries existing entities via `graphify query`).
2. **Clarify**: Run `/speckit-clarify` to resolve ambiguities.
3. **Plan**: Run `/speckit-plan` $\rightarrow$ calculates component blast radius via `graphify explain` and embeds TDD test strategies into `plan.md`.
4. **Tasks**: Run `/speckit-tasks` $\rightarrow$ verifies task independence via `graphify path` before tagging `[P]`.
5. **Auto-Handoff**: Hook `after_tasks` automatically initializes `.specify/gss-handoff.json` with status `executing`.
6. **Implement**: Run `/gss-bridge` (Claude Code / Antigravity) or `$gss-bridge` (Codex) $\rightarrow$ dispatches Graphify-scoped subagents, enforces TDD Red-Green-Refactor, systematically traces bugs, and verifies build/tests.
7. **Complete & Sync**: Verification passes $\rightarrow$ code review $\rightarrow$ `graphify --update` runs automatically $\rightarrow$ handoff transitions to `complete`.

---

## 1.x Readiness and Support

| Target | Status | Evidence |
|---|---|---|
| **Linux bash** | Verified | Native Bash smoke suite plus release packaging gates. |
| **Windows PowerShell 5.1+** | Verified | Native PowerShell test suite (`run-all.ps1`) and sandbox cycle. |
| **macOS bash** | Verified | Native POSIX path regression and smoke test gate. |
| **Claude Code** | Verified | Automatic skill pickup at `.claude/skills/gss-bridge/SKILL.md`. |
| **OpenAI Codex** | Verified | Automatic skill pickup at `.agents/skills/gss-bridge/SKILL.md`. |
| **Google Antigravity** | Verified | Native skill invocation `/gss-bridge` with subagent support. |
| **Gemini CLI** | Verified | Shared handoff contract and command-line execution. |

Run the lightweight readiness check anytime:

```bash
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --readiness
```

```powershell
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Readiness
```

```text
[bridge readiness]
  Script flavor: ps
  Required tools: ok (git: True, python: True)
  Namespace: ok (speckit.gss-bridge)
  Package files: ok
  Bridge state: ready
  Graphify: ready (graphify-out/graph.json)
  Agents: verified (codex, claude, antigravity, gemini)
  Next: Run /speckit-plan or /speckit-tasks on specs/001-feature
```

---

## Positioning

| Feature | Just `speckit.implement` | Just Superpowers | speckit-superpowers-bridge | **GSS-Bridge** |
|---|---|---|---|---|
| **Documentation Truth** | `specs/` | Fragmented in `docs/plans/` | `specs/` | **`specs/` strictly canonical** |
| **AST / Topology Graph** | None (blind grep) | None (blind grep) | None (blind grep) | **Yes: `graphify-out/graph.json`** |
| **Blast Radius Calculation** | None | None | None | **Yes: `graphify explain`** |
| **Parallel Task `[P]` Check** | Guesswork | Guesswork | Guesswork | **Yes: `graphify path` coupling check** |
| **Subagent Scoping** | Entire repo dump | Wide directory tree | Wide directory tree | **1–2 hop AST neighborhood (50-100x savings)** |
| **TDD Discipline** | None (one-shot LLM) | TDD Red-Green | TDD Red-Green | **TDD Red-Green-Refactor** |
| **Systematic Debugging** | Trial-and-error | Log tracing | Log tracing | **Graph path trace (`graphify path`)** |
| **Knowledge Graph Sync** | None | None | None | **Yes: Automatic `graphify --update`** |
| **Cross-Agent Support** | Partial | Partial | Claude + Codex | **Claude + Codex + Antigravity + Gemini** |

---

<details>
<summary><strong>Interactive Workflow Diagram</strong></summary>

```text
                  ┌───────────────────── Spec-Kit Phase ─────────────────────┐
  user ─► /speckit-constitution ─► /speckit-specify ─► /speckit-clarify ─►
          /speckit-plan ─► /speckit-tasks
                                   │
               ┌───────────────────┴───────────────────┐
               ▼                                       ▼
      [graphify explain]                      [graphify path]
     (Blast Radius in plan.md)             (Coupling Check for [P])
                                   │
                                   │ after_tasks hook
                                   ▼
                      ┌──────── GSS-Bridge Handoff ────────┐
                      │  writes .specify/gss-handoff.json   │
                      │  status: executing                 │
                      └─────────────────┬──────────────────┘
                                        │
             ┌──────────────────────────┴──────────────────────────┐
             ▼                                                     ▼
┌───────────────────────────┐                         ┌───────────────────────────┐
│  Superpowers Execution    │                         │  Graphify Codebase Guard  │
│  - TDD Red-Green-Refactor │                         │  - Scopes Subagents 1-2h  │
│  - Isolated [P] Subagents │                         │  - Systematic Debug Path  │
│  - Verification evidence  │                         │  - Incremental Sync       │
└───────────────────────────┘                         └───────────────────────────┘
             │                                                     │
             └──────────────────────────┬──────────────────────────┘
                                        │
                                        ▼
                         superpowers:requesting-code-review
                         superpowers:finishing-a-development-branch
                         graphify --update
                                        │
                                        ▼
                         status: complete in gss-handoff.json
```

</details>

---

## Integrated CLI Tooling

GSS-Bridge ships dual-platform PowerShell 5.1+ and POSIX Bash scripts under `.specify/extensions/gss-bridge/scripts/`:

```powershell
# 1. Inspect bridge state & system readiness
.\.specify\extensions\gss-bridge\scripts\powershell\bridge-status.ps1 -Readiness

# 2. Calculate component blast radius
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -Node "AuthService"

# 3. Check if two tasks/nodes can run in parallel [P]
.\.specify\extensions\gss-bridge\scripts\powershell\graphify-blast-radius.ps1 -CheckCoupling -NodeA "OrderService" -NodeB "PaymentService"

# 4. Transition handoff state
.\.specify\extensions\gss-bridge\scripts\powershell\update-handoff.ps1 -Status executing -FeatureDirectory "specs/001-my-feature" -Actor claude

# 5. Evaluate boundary guards
.\.specify\extensions\gss-bridge\scripts\powershell\guard-command.ps1 -Action "speckit.implement" -Actor claude
```

---

## Automated Verification Suite

Run the full local test suite on any platform:

```powershell
# Windows PowerShell
pwsh -File tests/run-all.ps1

# Linux / macOS Bash
bash tests/run-all.sh
```

Every release passes automated GitHub Actions quality gates on Linux, Windows, and macOS with release assets and SHA256 signatures published automatically.

---

## License

Released under the [MIT License](LICENSE).  
Copyright © 2026 GSS-Bridge Contributors.

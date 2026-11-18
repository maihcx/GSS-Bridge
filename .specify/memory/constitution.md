# GSS-Bridge Engineering Constitution

## Fundamental Principles

### Principle I: Spec-Kit Governance (Single Source of Truth for Requirements)
1. **Canonical Location**: All requirement specifications, architectural plans, and task breakdowns MUST live strictly inside `specs/<feature>/`:
   - `specs/<feature>/spec.md`
   - `specs/<feature>/plan.md`
   - `specs/<feature>/tasks.md`
2. **Plan Centralization**: When Superpowers' `writing-plans` skill is active, agents are strictly forbidden from creating standalone files in `docs/plans/`. All test plans and step-by-step TDD instructions must be recorded directly into `plan.md` and `tasks.md`.
3. **Immutability During Execution**: The active specification cannot be altered while the handoff status is `executing`. If requirements must change, the handoff must be set to `blocked` first.

### Principle II: Graphify Codebase Truth (Single Source of Truth for Topology)
1. **Graph-First Navigation**: Whenever answering questions about architecture, connections, or call hierarchies, agents MUST query `graphify-out/graph.json` via `graphify query`, `graphify explain`, or `graphify path` before resorting to `grep`, `find`, or reading full directories.
2. **Blast Radius Analysis**: Every implementation plan (`plan.md`) must include a dedicated `## Blast Radius & Architecture Context (Graphify)` section derived from `graphify explain "<TargetNode>"`.
3. **Parallelism Verification**: Tasks marked with `[P]` (parallel execution) in `tasks.md` must be checked against `graphify path`. If a direct dependency or shared mutable state exists between the tasks, they must be executed sequentially.
4. **Context Scoping**: Subagents must only be supplied with file sets identified by Graphify's 1-hop and 2-hop neighborhood, minimizing token bloat and eliminating hallucinations.

### Principle III: Superpowers Execution Discipline (Engineering Standards)
1. **Test-Driven Development (TDD)**: No implementation code may be written without a prior failing test. The Red-Green-Refactor cycle is mandatory.
2. **Systematic Debugging**: When bugs or test failures occur, agents must trace the execution path using `graphify path` before proposing hypotheses or changing code. Guess-and-check editing is strictly prohibited.
3. **Verification Before Completion**: No task checkbox (`- [x] T###`) may be checked off without fresh passing test or build output executed in the current session.
4. **Branch Finishing & Review**: Every completed feature must undergo `superpowers:requesting-code-review` and `superpowers:finishing-a-development-branch`.

### Principle IV: Knowledge Graph Synchronization
1. Upon completing implementation and passing verification, agents must run `graphify --update` to synchronize the knowledge graph with the new codebase state.

### Principle V: Auditability and Snapshots
1. Every state transition and guard decision must be appended to `.specify/bridge-events.jsonl`.
2. Handoff transitions must snapshot feature artifacts under `.specify/bridge-snapshots/` to enable deterministic audit and recovery.

### Principle VI: Anti-Drift and Mandatory Regulatory Re-reading (Code Scope Discipline)
1. **Mandatory Pre-Edit Re-reading**: Before modifying any source code or committing changes in feature implementation, bug fixing, or subagent tasks, agents and subagents MUST explicitly re-read this Constitution and project regulations (`AGENTS.md`, `CLAUDE.md`, and `.specify/memory/architecture-rules.json`).
2. **Blast Radius & Scope Confinement**: All code modifications MUST be strictly confined to the authorized files and blast radius defined in `plan.md` (for features) or `assessment.md` (for bugs). Modifying out-of-scope files, creating unauthorized abstractions, or altering unrelated files is strictly prohibited.
3. **Zero Code Drift**: Unsolicited refactoring, stylistic rewriting of untouched code ("drive-by cleanup"), or altering architectural invariants without an explicit task in `tasks.md` is a direct constitutional violation.
4. **Subagent Constitutional Invariance**: Any subagent spawned by wave dispatch or teamwork MUST be initialized with explicit instructions to read this Constitution and abide by the Anti-Drift Mandate.

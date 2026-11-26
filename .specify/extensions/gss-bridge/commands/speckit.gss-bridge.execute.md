---
description: "Execute Spec-Kit tasks through the GSS-Bridge (Graphify-scoped context + Superpowers discipline)"
---

# GSS-Bridge Execute

Execute the active Spec-Kit feature through Superpowers discipline with Graphify codebase intelligence, replacing raw unprincipled `speckit.implement`.

## Behavior

0. **Graphify Pre-requisite Check**: Verify that `graphify-out/graph.json` exists. If not yet created, execute `graphify .` to initialize the knowledge graph first before proceeding. Never skip or execute tasks without graph topology.
1. **Handoff Check**: Read `.specify/gss-handoff.json` (or fallback `.specify/superpowers-handoff.json`). If status is `complete`, run auto-archive to reset to `ready`.
2. **Context Ingestion & Regulatory Re-reading**: Read `.specify/memory/constitution.md`, project regulations (`AGENTS.md`, `CLAUDE.md`, `.specify/memory/architecture-rules.json`), `<feature_directory>/spec.md`, `plan.md`, and `tasks.md`. Enforce Constitution Principle VI: Establish anti-drift alignment before touching code.
3. **Guard Validation**: Run the GSS-Bridge guard before touching implementation code.
4. **Adapter Scaffolding**: Derive a disposable execution plan outside `.superpowers/sdd/` at a temporary path. Format headings as `### Task N: T###` preserving exact task descriptions from `tasks.md`.
5. **Execution Loop & Automated Wave Dispatch**:
   - **Anti-Drift Pre-Execution Checkpoint**: Before executing each wave or task, the agent and all subagents MUST re-read the Constitution and project regulations to guarantee zero code drift. Modifications must strictly remain within the scoped blast radius declared in `plan.md`.
   - **Pre-flight Wave Partitioning**: Run `dispatch-subagents.ps1 -Json` (or `dispatch-subagents.sh --json`).
   - **Parallel Wave Execution**:
     - For each wave in `waves`, the agent **MUST** dispatch subagents simultaneously in a single turn (`invoke_subagent` for Antigravity with `Model: 'inherit'`, `TypeName: 'self'`, `Prompt: task.subagent_prompt`).
     - Inlining `[P]` tasks in the parent session without spawning subagents is strictly prohibited.
     - Await wave subagents completion via reactive wakeup, review test evidence, and mark completed tasks `- [x] T###`.
   - **Sequential Tasks**: For non-`[P]` tasks, execute sequentially applying `superpowers:test-driven-development` (RED -> GREEN -> REFACTOR).
   - If failures or regressions occur, invoke `superpowers:systematic-debugging` and trace call chains via `graphify path`.
   - Verify tests produce passing evidence before updating the canonical checkbox to `- [x] T###`.
6. **Completion & Review**:
   - Run `superpowers:verification-before-completion`.
   - Run `superpowers:requesting-code-review`.
   - Run `superpowers:finishing-a-development-branch`.
7. **Graph Synchronization**:
   - Run `graphify update .` to synchronize the knowledge graph with the new codebase state.
8. **Handoff Finalization**:
   - Transition handoff status to `complete` via `update-handoff.ps1` or `update-handoff.sh`.

## Invocation

- Claude Code / Antigravity: `/speckit.gss-bridge.execute` or `/gss-bridge`
- Codex: `$speckit.gss-bridge.execute` or `$gss-bridge`

```powershell
# Transition to executing & validate guard
.\.specify\extensions\gss-bridge\scripts\powershell\update-handoff.ps1 -Status executing -Actor <actor>
.\.specify\extensions\gss-bridge\scripts\powershell\guard-command.ps1 -Action "superpowers:subagent-driven-development" -Actor <actor>

# Partition [P] tasks into waves with AST skeleton pruning
.\.specify\extensions\gss-bridge\scripts\powershell\dispatch-subagents.ps1 -PruneContext -Json -Actor <actor>

# Optional: extract AST skeleton or manage isolated wave worktrees
.\.specify\extensions\gss-bridge\scripts\powershell\ast-skeleton.ps1 -Path "src/auth.py"
.\.specify\extensions\gss-bridge\scripts\powershell\wave-worktree.ps1 -Action create -Name "wave-1-auth"
```

```bash
bash .specify/extensions/gss-bridge/scripts/bash/update-handoff.sh --status executing --actor <actor>
bash .specify/extensions/gss-bridge/scripts/bash/guard-command.sh --action "superpowers:subagent-driven-development" --actor <actor>
bash .specify/extensions/gss-bridge/scripts/bash/dispatch-subagents.sh --prune-context --json --actor <actor>
bash .specify/extensions/gss-bridge/scripts/bash/ast-skeleton.sh --path "src/auth.py"
bash .specify/extensions/gss-bridge/scripts/bash/wave-worktree.sh --action create --name "wave-1-auth"
```

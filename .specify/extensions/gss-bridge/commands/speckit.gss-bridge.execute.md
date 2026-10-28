---
description: "Execute Spec-Kit tasks through the GSS-Bridge (Graphify-scoped context + Superpowers discipline)"
---

# GSS-Bridge Execute

Execute the active Spec-Kit feature through Superpowers discipline with Graphify codebase intelligence, replacing raw unprincipled `speckit.implement`.

## Behavior

1. **Handoff Check**: Read `.specify/gss-handoff.json` (or fallback `.specify/superpowers-handoff.json`). If status is `complete`, run auto-archive to reset to `ready`.
2. **Context Ingestion**: Read `.specify/memory/constitution.md`, `<feature_directory>/spec.md`, `plan.md`, and `tasks.md`.
3. **Guard Validation**: Run the GSS-Bridge guard before touching implementation code.
4. **Adapter Scaffolding**: Derive a disposable execution plan outside `.superpowers/sdd/` at a temporary path. Format headings as `### Task N: T###` preserving exact task descriptions from `tasks.md`.
5. **Execution Loop**:
   - For each task in `tasks.md`:
     - If marked `[P]`, confirm zero coupling via `graphify path` and dispatch subagent scoped strictly to the files identified by Graphify.
     - Apply `superpowers:test-driven-development` (Write failing test -> verify failure -> write minimal code -> verify pass -> refactor).
     - If failures or regressions occur, invoke `superpowers:systematic-debugging` and trace call chains via `graphify path`.
     - Verify tests produce passing evidence before updating the canonical checkbox to `- [x] T###`.
6. **Completion & Review**:
   - Run `superpowers:verification-before-completion`.
   - Run `superpowers:requesting-code-review`.
   - Run `superpowers:finishing-a-development-branch`.
7. **Graph Synchronization**:
   - Run `graphify --update` to synchronize the knowledge graph with the new codebase state.
8. **Handoff Finalization**:
   - Transition handoff status to `complete` via `update-handoff.ps1` or `update-handoff.sh`.

## Invocation

- Claude Code / Antigravity: `/speckit-gss-bridge-execute` or `/gss-bridge`
- Codex: `$speckit-gss-bridge-execute` or `$gss-bridge`

```powershell
# Transition to executing
.\.specify\extensions\gss-bridge\scripts\powershell\update-handoff.ps1 -Status executing -Actor <actor>
.\.specify\extensions\gss-bridge\scripts\powershell\guard-command.ps1 -Action "superpowers:executing-plans" -Actor <actor>
```

```bash
bash .specify/extensions/gss-bridge/scripts/bash/update-handoff.sh --status executing --actor <actor>
bash .specify/extensions/gss-bridge/scripts/bash/guard-command.sh --action "superpowers:executing-plans" --actor <actor>
```

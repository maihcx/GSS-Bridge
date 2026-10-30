# CLAUDE.md: GSS-Bridge Developer Guidelines

## Core Principles

- **Spec-Kit**: Single source of truth for requirements & tasks (`specs/<feature>/`). Never create files in `docs/plans/`.
- **Graphify**: Single source of truth for codebase topology (`graphify-out/graph.json`). Prefer `graphify query`, `graphify explain`, and `graphify path` over blind grepping.
- **Superpowers**: Single standard for execution discipline. TDD Red-Green-Refactor, systematic debugging via graph path tracing, verified evidence before marking `- [x] T###`.

## Essential Commands

```bash
# Check status and readiness
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --readiness

# Calculate component blast radius with Mermaid diagram
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --node "<ComponentName>" --mermaid

# Verify task independence for parallel [P] execution
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --check-coupling --node-a "CompA" --node-b "CompB"

# Assess a bug with Graphify call graph & blast radius
bash .specify/extensions/gss-bridge/scripts/bash/bug-assess.sh --slug "auth-null-token" --target-node "AuthService"

# Remediate a bug with Superpowers TDD & automatic Graphify sync
bash .specify/extensions/gss-bridge/scripts/bash/bug-fix.sh --slug "auth-null-token"

# Partition parallel [P] tasks into conflict-free execution waves
bash .specify/extensions/gss-bridge/scripts/bash/dispatch-subagents.sh --tasks "specs/001-feature/tasks.md"

# Run tests
pwsh -File tests/run-all.ps1
bash tests/run-all.sh
```

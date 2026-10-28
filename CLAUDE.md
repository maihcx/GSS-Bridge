# CLAUDE.md: GSS-Bridge Developer Guidelines

## Core Principles

- **Spec-Kit**: Single source of truth for requirements & tasks (`specs/<feature>/`). Never create files in `docs/plans/`.
- **Graphify**: Single source of truth for codebase topology (`graphify-out/graph.json`). Prefer `graphify query`, `graphify explain`, and `graphify path` over blind grepping.
- **Superpowers**: Single standard for execution discipline. TDD Red-Green-Refactor, systematic debugging via graph path tracing, verified evidence before marking `- [x] T###`.

## Essential Commands

```bash
# Check status and readiness
bash .specify/extensions/gss-bridge/scripts/bash/bridge-status.sh --readiness

# Calculate component blast radius
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --node "<ComponentName>"

# Verify task independence for parallel [P] execution
bash .specify/extensions/gss-bridge/scripts/bash/graphify-blast-radius.sh --check-coupling --node-a "CompA" --node-b "CompB"

# Run tests
pwsh -File tests/run-all.ps1
bash tests/run-all.sh
```

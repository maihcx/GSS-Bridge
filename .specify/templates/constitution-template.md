# Project Constitution (GSS-Bridge Governance)

## Core Engineering Laws

1. **Spec-Kit Governance**: All requirements, architectural plans, and task breakdowns must reside strictly in `specs/<feature>/`. Standalone plan files in `docs/plans/` are prohibited.
2. **Graphify Context & Topology**: Before modifying code, inspect `graphify-out/graph.json` to calculate blast radius (`graphify explain`) and verify task independence (`graphify path`). Subagents must receive only Graphify-scoped file sets.
3. **Superpowers Discipline**: Every task must follow Test-Driven Development (failing test before code), systematic debugging via graph path tracing, and verified evidence before completion.
4. **Knowledge Graph Synchronization**: Always run `graphify --update` after completing implementation.

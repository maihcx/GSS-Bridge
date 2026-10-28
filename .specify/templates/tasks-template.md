# Tasks: [FEATURE_NAME]

> **GSS-Bridge Execution Discipline**:
> 1. Tasks tagged with `[P]` can be run concurrently by subagents ONLY if verified independent via `graphify path`.
> 2. Every code modification task MUST follow TDD (Red: failing test, Green: minimal code, Refactor: clean up).
> 3. Mark `- [x] T###` ONLY when test/build verification evidence is produced in the session.

## Phase 1: Setup & Grounding
- [ ] T001 Verify knowledge graph `graphify-out/graph.json` exists or run `/graphify` to index codebase
- [ ] T002 Inspect blast radius for target components using `graphify explain "<Node>"`

## Phase 2: User Story 1 - [Title]
- [ ] T003 [P] [Story 1] Write failing unit tests for [feature component] in `[test_file.ext]` (RED)
- [ ] T004 [Story 1] Implement minimal code in `[source_file.ext]` to pass T003 tests (GREEN)
- [ ] T005 [Story 1] Refactor implementation and verify no regressions in 1-hop blast radius callers (REFACTOR)

## Phase 3: User Story 2 - [Title]
> Note: Verify independence from Phase 2 via `graphify path "Component1" "Component2"` before running in parallel `[P]`.
- [ ] T006 [P] [Story 2] Write failing tests for [component 2] in `[test_file.ext]` (RED)
- [ ] T007 [Story 2] Implement minimal code in `[source_file.ext]` (GREEN)
- [ ] T008 [Story 2] Refactor and clean up (REFACTOR)

## Phase 4: Verification, Review & Synchronization
- [ ] T009 Run full test suite and collect passing evidence (superpowers:verification-before-completion)
- [ ] T010 Request code review (superpowers:requesting-code-review)
- [ ] T011 Synchronize knowledge graph with new codebase changes (`graphify --update`)
- [ ] T012 Finish development branch (superpowers:finishing-a-development-branch)

## Deferred / Out of Scope
> Tasks under this heading are exempted from the active handoff pending count.
- [ ] T999 Optional future performance optimization

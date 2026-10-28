# Changelog

All notable changes to **GSS-Bridge** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-28

### Added
- **The Golden Triangle Protocol**: Unified workflow connecting Spec-Kit governance, Graphify codebase context, and Superpowers execution discipline.
- **Spec-Kit Centralized Truth**: Enforced single source of documentation truth in `specs/<feature>/` (`spec.md`, `plan.md`, `tasks.md`). Standalone plan creation in `docs/plans/` is strictly prohibited.
- **Graphify Codebase Intelligence**:
  - Graph-first navigation via `graphify query`, `graphify explain`, and `graphify path` on `graphify-out/graph.json`.
  - Component Blast Radius analysis integrated into `plan.md` via `graphify-blast-radius.ps1` and `.sh`.
  - Coupling verification for parallel tasks `[P]` in `tasks.md` before concurrent subagent dispatch.
  - Subagent context scoping to 1-2 hop neighborhoods, reducing token usage by 50x-100x.
  - Automatic post-implementation graph synchronization (`graphify --update`).
- **Superpowers Engineering Discipline**:
  - Test-Driven Development (TDD) Red-Green-Refactor enforcement.
  - Systematic debugging with call graph path tracing.
  - Verification evidence mandatory before checking off `- [x] T###`.
  - Code review (`superpowers:requesting-code-review`) and branch finishing (`superpowers:finishing-a-development-branch`).
- **Cross-Agent Support**:
  - First-class support for Claude Code (`/gss-bridge`), OpenAI Codex (`$gss-bridge`), Google Antigravity (`/gss-bridge`), and Gemini CLI.
  - Shared handoff contract at `.specify/gss-handoff.json` with backward-compatible mirror at `.specify/superpowers-handoff.json`.
- **Cross-Platform Scripting**:
  - Native Windows PowerShell 5.1+ and Core scripts (`scripts/powershell/`).
  - Native Linux & macOS POSIX Bash scripts (`scripts/bash/`).
- **Tooling & Release Readiness**:
  - Automated CI/CD release workflow (`.github/workflows/release.yml`) with Linux, Windows, and macOS quality gates.
  - Release packaging and validation tooling (`scripts/release/`).
- **Bilingual Documentation**:
  - English documentation in `README.md`.
  - Vietnamese documentation in `README.vi-VN.md` with bidirectional links.

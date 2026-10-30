# Changelog

All notable changes to **GSS-Bridge** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-30

### Added
- **The GSS-Bug Protocol**:
  - `speckit.gss-bridge.bug-assess`: Combines Spec-Kit bug tracking with Graphify AST knowledge graph analysis. Parses stack traces, maps affected nodes, traces caller/callee hierarchies, computes blast radius, and embeds visual Mermaid flowcharts into `.specify/bugs/<slug>/assessment.md`.
  - `speckit.gss-bridge.bug-fix`: Enforces Superpowers `systematic-debugging` and strict Test-Driven Development (TDD) Red $\rightarrow$ Green $\rightarrow$ Refactor workflow. Requires an automated reproduction test before writing fix code, executes test suites to verify fix evidence, automatically synchronizes the codebase knowledge graph via `graphify update .`, and records completion in `.specify/bugs/<slug>/fix.md`.
  - Bug templates: `.specify/templates/bug-assessment-template.md` and `.specify/templates/bug-fix-template.md`.
- **Parallel Subagent Wave Dispatcher (`speckit.gss-bridge.dispatch`)**:
  - Computes pairwise topological distances on `graphify-out/graph.json` between parallel tasks tagged `[P]` in `tasks.md`.
  - Automatically partitions independent tasks ($d \ge 3$) into concurrent execution waves (Wave 1, Wave 2, etc.) while blocking conflicting tasks from running in parallel.
  - Generates subagent dispatch prompts with context strictly bounded to 1-2 hop AST neighborhoods, reducing subagent token overhead by up to 100x.
- **Visual Mermaid Blast Radius Diagrams**:
  - Added `-Mermaid` / `--mermaid` support to `graphify-blast-radius.ps1` and `graphify-blast-radius.sh` to render GitHub-compatible caller/callee architecture diagrams.
- **Automatic Knowledge Graph Synchronization**:
  - Automatically runs `graphify update .` when completing feature implementations (`update-handoff`) or bug fixes (`bug-fix`).
- **Multi-Agent Collision Guard**:
  - Enhanced `guard-command.ps1` and `guard-command.sh` to prevent conflicting concurrent feature implementations across multiple agents and ensure bug fixes are blocked until an approved bug assessment exists.
- **Comprehensive Test Suites**:
  - Added `tests/test-bug-workflow.ps1` and `tests/test-bug-workflow.sh` for full bug assess/fix lifecycle verification.
  - Added `tests/test-dispatch-subagents.ps1` and `tests/test-dispatch-subagents.sh` for wave partitioning and conflict detection verification.

## [1.0.1] - 2026-10-28

### Added
- **Full POSIX Bash Test Suite**: Added 1:1 bash test parity with PowerShell suites (`tests/test-graphify-blast-radius.sh`, `tests/test-guard-rules.sh`, and `tests/run-all.sh`).
- **Zero-Dependency JSON Fallback**: Added AWK parser (`read_handoff_field`) and heredoc template generators in all bash scripts (`bridge-state.sh`, `update-handoff.sh`, `guard-command.sh`, `bridge-status.sh`), allowing GSS-Bridge to run reliably in environments without `jq` (such as Windows Git Bash or minimal Linux/Docker containers).
- **Python Zipfile Fallback in Release Packager**: Enhanced `scripts/release/build-extension-zip.sh` to use Python's built-in `zipfile` module when the native `zip` command is not installed.
- **Robust Windows Python Runtime Detection**: Added multi-candidate detection in `graphify-blast-radius.sh` and `bridge-status.sh` to bypass Windows Store `python3.exe` execution alias traps and resolve functional Python runtimes (`python3`, `python`, `py`).
- **Dynamic Release Validation**: Upgraded package validation scripts to dynamically resolve target versions from manifest declarations.

### Fixed
- Fixed guard evaluation in `guard-command.sh` to ensure `speckit.implement` blocks properly when handoff is in `executing` status without external JSON tooling.
- Fixed `update-handoff.sh` to guarantee `.specify/gss-handoff.json` and dual-write mirrors are written and updated even when `jq` is unavailable.
- Standardized file line endings: strictly LF for `.sh` scripts and CRLF for `.ps1` scripts across the codebase.

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

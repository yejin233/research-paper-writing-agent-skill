# Changelog

## 0.1.9

- Rebuilt the experiment workflow and Experiments writing references as clean Markdown after the previous reference text became corrupted by per-character quoting.
- Added `scripts/check-experiment-analysis.ps1` and `examples/experiment_analysis_audit.example.md`.
- Added an Experiment Analysis Depth Gate requiring claim-level interpretation, strongest-baseline comparison, mechanism interpretation, alternative-explanation analysis, boundary conditions, weak cases, and required prose before Experiments writing.
- Updated workflow supervision, writing gates, docs, and open-source checks so experiment analysis is part of result-to-prose readiness.
- Clarified that the local Strict External ML Logic Reviewer is required in the reviewer panel and cannot be replaced by optional remote GPT review.

## 0.1.8

- Rebuilt `references/review-workflow.md` as a clean role-bounded reviewer panel workflow.
- Added explicit reviewer roles for paper intent, novelty, methodology, experiment design, result claims, writing conformance, PDF presentation, fresh external review, workflow supervision, and meta-review.
- Added fresh-context review packet rules, hard-block preservation, and required reviewer output schemas.
- Replaced the generic fresh external reviewer with a strict external ML logic reviewer focused on logic-chain coherence, defensive-language detection, claim-evidence closure, and rejection-risk judgment.

## 0.1.7

- Added `skill-version.json` and a non-blocking installed-skill freshness check against the latest GitHub manifest.
- Added `scripts/check-skill-update.ps1` with optional detailed branch-head comparison and Markdown status output.
- Added `examples/skill_update_status.example.md` and tests for behind, up-to-date, unavailable, and unknown-local-version states.
- Updated `SKILL.md`, `README.md`, and workflow docs so first-call startup may recommend updating an out-of-date installed skill.

## 0.1.6

- Added machine-readable `experiment_license.yaml`, `result_ledger.jsonl`, and `handoff_manifest.yaml` examples.
- Added hard checkers for experiment licenses, source-backed result ledgers, manuscript prose, role boundaries, and aggregate workflow supervision.
- Strengthened protocol and writing gates so result claims require a result ledger, and final integration requires manuscript-prose and role-boundary checks.
- Updated docs and tests for direct manuscript scanning, result recomputation, and Coordinator-only manuscript integration.

## 0.1.5

- Added first-call Remote Audit Window Intake for controllable GPT review windows.
- Added `External audit route` to protocol state with `remote-gpt` and `internal-only` modes.
- Updated protocol-state checks to block gated workflow actions until the audit route is answered.
- Updated examples and docs for internal-only fallback when no remote GPT window is available.

## 0.1.4

- Split long literature, experiment, section-writing, and review guidance out of the core `SKILL.md`.
- Added routed section-writing references for Introduction, Methodology, Experiments, and Related Work.
- Added `scripts/check-reference-routes.ps1` to verify routed references and prevent legacy phase manuals from returning to the core skill.
- Strengthened `scripts/check-writing-gate.ps1` so each section contract must record the required reference path.
- Removed stale AutoReason, human-evaluation, paper-type, and old experiment-pattern references from the package.

## 0.1.3

- Slimmed the core `SKILL.md` by removing obsolete Hermes/Windows adapter content.
- Removed post-acceptance and submission-preparation phases from the core runtime skill.
- Moved the core stance away from draft-first behavior toward protocol-bound autonomy.
- Removed old AutoReason, human-evaluation, paper-type, cron, and LaTeX tooling detail from the core skill path.

## 0.1.2

- Added Runtime Protocol Anchor near the top of `SKILL.md`.
- Added `protocol_state.example.md` as the long-running workflow state file.
- Added `scripts/check-protocol-state.ps1` for action-before-gate checks.
- Upgraded Workflow Supervisor guidance into a recurring protocol heartbeat.

## 0.1.1

- Added fail-closed writing entry gate for manuscript drafting and revision.
- Added `scripts/check-writing-gate.ps1` for required writing artifacts.
- Added section-contract and writing-gate report examples.

## 0.1.0

- Initial open-source package for `research-paper-writing-agent`.
- Added multi-agent workflow documentation.
- Added process-gate documentation.
- Added external GPT reviewer workflow and prompt guidance.
- Added example handoff files for intent, audits, failure diagnosis, section contracts, and defensive-writing checks.
- Added a lightweight open-source readiness check script.

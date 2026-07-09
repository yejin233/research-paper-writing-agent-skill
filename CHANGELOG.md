# Changelog

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

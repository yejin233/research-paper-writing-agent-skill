# Research Paper Writing Agent Skill

An open-source Codex skill for ML/AI research-paper workflows with multi-agent orchestration, hard process gates, result auditing, writing conformance checks, and optional external GPT review.

This skill is designed for projects that need more than prose polishing. It treats a paper as a claim-evidence workflow: research intent is frozen, experiments are licensed before they affect claims, failed results trigger diagnosis and optimization, defensive writing is blocked, and final manuscript integration is supervised.

## What It Adds

- Multi-agent roles with strict permission boundaries.
- Manuscript intent and frozen paper-type gates.
- Literature, route-killer, experiment-license, result-audit, and workflow-supervision gates.
- Machine-readable `experiment_license.yaml` and `result_ledger.jsonl` interfaces
  for source-backed experiment and result checks.
- Experiment analysis depth checks that require claim-level interpretation,
  strongest-baseline comparison, mechanism explanation, alternative-explanation
  analysis, and bounded result prose before Experiments writing.
- Direct manuscript-prose scanning for internal route traces, defensive writing,
  leaked configuration text, and paper-type drift.
- Role-boundary write barrier for protected manuscript files.
- Failed-result optimization before failure prose.
- Defensive-writing zero-tolerance checks.
- Section contracts and planned-vs-produced writing audits.
- Routed reference files so the core skill stays short while section-specific
  constraints remain mandatory.
- First-call remote GPT audit window intake; if no controllable window is
  available, the workflow records `internal-only` and uses internal audits.
- Optional external GPT reviewer prompts for additional quality assessment when
  a remote audit window is enabled.
- Installed-skill freshness checks against the latest GitHub version manifest,
  with optional detailed branch-head comparison.
- Venue-oriented support for NeurIPS, ICML, ICLR, ACL, AAAI, COLM, and similar venues.

## Repository Layout

```text
.
|-- SKILL.md
|-- skill-version.json
|-- references/
|   |-- literature-workflow.md
|   |-- experiment-workflow.md
|   |-- review-workflow.md
|   `-- section-writing/
|-- templates/
|-- examples/
|-- docs/
|-- tests/
|-- LICENSE
|-- NOTICE.md
`-- README.md
```

## Installation

Copy this folder into your Codex skills directory, for example:

```powershell
Copy-Item .\research-paper-writing-agent-skill "$env:USERPROFILE\.codex\skills\research-paper-writing-agent" -Recurse
```

Then restart Codex or reload skills.

## Recommended First Files In A Paper Project

Use the examples in `examples/` as starting points:

- `paper_intent.example.md`
- `protocol_state.example.md`
- `external_gpt_reviewer.example.md`
- `experiment_license.example.yaml`
- `experiment_analysis_audit.example.md`
- `result_ledger.example.jsonl`
- `handoff_manifest.example.yaml`
- `skill_update_status.example.md`
- `result_audit.example.md`
- `section_contracts.example.md`
- `workflow_supervision_audit.example.md`
- `failure_diagnosis.example.md`
- `section_contract.example.md`
- `defensive_writing_audit.example.md`
- `writing_gate_report.example.md`

## External GPT Review

External GPT review is optional. If enabled, the skill asks the external GPT page to evaluate quality and give complete actionable suggestions at high-risk checkpoints. The external reviewer is advisory only: it must not directly edit the manuscript, inspect credentials, override local evidence, or replace the Workflow Supervisor.

See `docs/external-gpt-review.md`.

## Skill Freshness Check

From the skill root, compare the installed skill against the latest GitHub
manifest:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1
```

For an explicit branch-head comparison:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1 -Detailed
```

## Important Safety Notes

- This skill does not guarantee novelty, acceptance, correctness, or valid experimental results.
- It is not a substitute for real literature review, human scientific judgment, or venue-specific policy review.
- Do not paste secrets, API keys, cookies, passwords, browser storage, private datasets, or confidential reviewer material into external tools.
- Verify generated citations and claims against primary sources before submission.
- Venue templates in `templates/` may be subject to upstream venue terms. See `NOTICE.md`.

## Development Check

Run the local release check before publishing or opening a pull request:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-open-source.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-gates.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-skill-update.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check-reference-routes.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-workflow-supervision.ps1 -ProjectRoot .
```

For writing-stage projects, run the fail-closed writing gate checker inside the
paper project before drafting or integrating manuscript prose:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-manuscript-prose.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-role-boundaries.ps1 -ProjectRoot .
```

## License

MIT. See `LICENSE`.

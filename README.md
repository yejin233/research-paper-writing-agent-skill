# Research Paper Writing Agent Skill

An open-source Codex skill for ML/AI research-paper workflows with multi-agent orchestration, hard process gates, result auditing, writing conformance checks, and optional external GPT review.

This skill is designed for projects that need more than prose polishing. It treats a paper as a claim-evidence workflow: research intent is frozen, experiments are licensed before they affect claims, failed results trigger diagnosis and optimization, defensive writing is blocked, and final manuscript integration is supervised.

## What It Adds

- Multi-agent roles with strict permission boundaries.
- Manuscript intent and frozen paper-type gates.
- Literature, route-killer, experiment-license, result-audit, and workflow-supervision gates.
- Failed-result optimization before failure prose.
- Defensive-writing zero-tolerance checks.
- Section contracts and planned-vs-produced writing audits.
- Optional external GPT reviewer prompts for additional quality assessment.
- Venue-oriented support for NeurIPS, ICML, ICLR, ACL, AAAI, COLM, and similar venues.

## Repository Layout

```text
.
|-- SKILL.md
|-- references/
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
- `external_gpt_reviewer.example.md`
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
```

For writing-stage projects, run the fail-closed writing gate checker inside the
paper project before drafting or integrating manuscript prose:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot .
```

## License

MIT. See `LICENSE`.

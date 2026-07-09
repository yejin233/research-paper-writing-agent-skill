# Protocol State

## Current phase

- phase: Phase 5 - Evidence-grounded drafting

## Frozen identity

- paper type: method_paper
- thesis: The method addresses the approved modeling gap with the frozen mechanism.
- core method claim: Claim C1 from `claim_evidence_map.md`.
- forbidden conversions: boundary_study, benchmark, survey, position, negative_result unless the user explicitly approves.

## External audit route

- first-call question: answered-no
- mode: internal-only
- remote window opening method: none
- internal audit fallback: Workflow Supervisor, Reviewer, Result Auditor, Figure/Table Auditor

## Allowed next actions

- writing
- result-claim
- gate-repair
- workflow-supervision

## Blocked actions

- paper-type-conversion
- unsupported-claim-writing
- direct-subagent-manuscript-edit
- phase-transition

## Required artifacts before next action

- paper_claims.md
- claim_evidence_map.md
- section_contracts.md
- result_audit.md
- writing_gate_report.md before final integration

## Gate status

- manuscript intent: pass
- claim-evidence map: pass
- section contracts: pass
- result audit: pass
- result ledger: pass
- writing gate: pass
- manuscript prose: pass
- experiment license: pass
- defensive writing: pass
- role boundaries: pass
- workflow supervision: pass

## Last supervision

- decision: pass
- unresolved blockers: none

## Drift risk

- risk: medium
- reason: Long-running drafting task; refresh after three tool batches or before any claim/result integration.

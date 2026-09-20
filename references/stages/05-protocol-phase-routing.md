Scope: this reference governs managed research only. Apply the SKILL.md mode router first; language-only edits do not require these state files, scripts, or gates. Reuse current verified context rather than rereading unchanged documents mechanically.

## Protocol Phase Routing

This `SKILL.md` is the runtime controller. Detailed research, experiment, writing, and review guidance lives in `references/` and is loaded only when the current protocol action requires it.

Reference files are mandatory just-in-time instructions, not optional background. Before performing any action listed below, read the required reference file(s), update the required artifact(s), and run the listed gate. If the required reference was not read, stop and repair the gate instead of drafting, experimenting, or finalizing.

Do not create or use legacy status notes as an authority. The only authoritative
state file is `paper/protocol_state.md` or another path accepted by
`scripts/check-protocol-state.ps1`.

### Phase State Machine

| Phase | Allowed focus | Required reference | Required artifacts and gates |
| --- | --- | --- | --- |
| 0 - Setup | Identify repository, trusted workspace, paper intent, and evidence roots. | `examples/protocol_state.example.md` | `paper/protocol_state.md`; run `scripts/check-protocol-state.ps1 -Action general`. |
| 1 - Literature and contribution boundary | Search, acquire, read, classify, and use literature to constrain the route. | `references/literature-workflow.md` | `literature_matrix.md`, paper notes, route-killer handoff, citation status. |
| 2 - Experiment design | Map claims to licensed experiments, simple controls, kill criteria, and method cleanliness. | `references/experiment-workflow.md` | `paper_claims.md`, `claim_evidence_map.md`, `experiment_license.yaml`; run protocol and experiment-license gates. |
| 3 - Execution and route decision | Run only licensed experiments; audit failures, ablations, and route status. | `references/experiment-workflow.md` | result paths, experiment journal, failure diagnosis, route kill decision. |
| 4 - Result analysis and expansion | Aggregate results, audit claim support, add mechanism-level analysis, plan only claim-serving expansions. | `references/experiment-workflow.md` | `result_audit.md`, `result_ledger.jsonl`, `experiment_analysis_audit.md`, expansion plan, updated `claim_evidence_map.md`; run result-audit and experiment-analysis checkers. |
| 5 - Evidence-grounded drafting | Draft only sections whose contracts and reference-read records are complete. | `references/section-writing/*.md` as routed below | `section_contracts.md`, `writing_gate_report.md`; run writing, result, manuscript-prose, role-boundary, and protocol gates as applicable. |
| 6 - Review and revision | Simulate reviewers, verify claims, audit figures/tables, and prioritize fixes. | `references/review-workflow.md` | reviewer handoffs, claim verification, figure/table audit, revision trace, workflow supervision audit. |

### Required Reference Routing

| Action | Must read before action | Must record in | Gate before action |
| --- | --- | --- | --- |
| Literature search, related-work boundary, idea generation | `references/literature-workflow.md` | `literature_matrix.md` and `paper/protocol_state.md` | protocol state general check |
| Experiment planning, route kill, failed-result repair, result analysis | `references/experiment-workflow.md` | `experiment_license.yaml`, failure diagnosis, `result_audit.md`, `result_ledger.jsonl`, `experiment_analysis_audit.md`, or `claim_evidence_map.md` | protocol state, experiment-license, result-audit, or experiment-analysis check |
| General drafting, title, abstract, Figure 1, limitations, conclusion, appendix | `references/section-writing/general.md` | `section_contracts.md` | `scripts/check-writing-gate.ps1` |
| Introduction drafting or rewriting | `references/section-writing/introduction.md` | `section_contracts.md` Introduction contract | `scripts/check-writing-gate.ps1 -Sections Introduction` |
| Methods or Methodology drafting or rewriting | `references/section-writing/methodology.md` | `section_contracts.md` Methods contract | `scripts/check-writing-gate.ps1 -Sections Methods` |
| Experiments, Results, ablation, analysis, table or figure-result prose | `references/section-writing/experiments.md` | `section_contracts.md` Experiments contract, `result_audit.md`, and `experiment_analysis_audit.md` | `scripts/check-writing-gate.ps1 -Sections Experiments -RequireResults`; then `scripts/check-experiment-analysis.ps1` |
| Related Work drafting or rewriting | `references/section-writing/related-work.md` | `section_contracts.md` Related Work contract and `literature_matrix.md` | `scripts/check-writing-gate.ps1 -Sections 'Related Work'` |
| Full draft review, claim verification, reviewer simulation, visual review | `references/review-workflow.md` | review handoff, claim verification notes, revision trace | protocol state final-integration check when finalizing |

### Section Reference Gate

Before drafting or rewriting any section, `section_contracts.md` must include these fields for that section:

- `Reference path(s) read`: exact path(s), for example `references/section-writing/introduction.md`.
- `Purpose in the paper`: the section's job in the manuscript.
- `Required content moves`: paragraph or subsection moves that must appear.
- `Forbidden terminology or internal traces`: wording, code identifiers, workflow traces, and defensive phrases that are not allowed.
- `Required evidence links`: claim IDs, literature entries, result audits, table/figure IDs, or logs.
- `Paragraph-level outline`: the planned structure.

If the reference path is missing or does not match the target section, stop. Do not draft manuscript prose. Repair the section contract first.

### Minimal Startup Flow

1. Create or refresh `paper/protocol_state.md` from `examples/protocol_state.example.md`.
2. Run `powershell -ExecutionPolicy Bypass -File scripts/check-protocol-state.ps1 -ProjectRoot . -Action general`.
3. Identify the next action from `Allowed next actions`.
4. Read the required reference from the routing table above.
5. Create or update the required artifact.
6. Run the relevant gate before writing, experimenting, result-claiming, phase-transition, or final integration.
7. Update the Workflow Supervision Audit after every three tool-use batches and before any phase transition.

### Phase 0: Project Setup

Keep setup short and evidence-oriented:

- record trusted workspace roots and deprecated routes in `paper/protocol_state.md` or `paper_claims.md`;
- identify the frozen paper type and approved route;
- initialize `literature/`, `experiments/`, `results/`, `figures/`, `paper/`, and `paper/handoffs/` when useful;
- run the protocol-state checker before any gated action.

### Phase 1: Literature Review

Before searching, reading, citing, or using papers for route design, read `references/literature-workflow.md`. The required outputs are:

- `literature_matrix.md` with method family, relevance, gap relation, baseline use, close-work status, and citation status;
- local paper metadata and reading notes for papers that influence claims;
- route-killer questions grounded in closest related work;
- citation placeholders only when verification is explicitly incomplete.

### Phase 2: Experiment Design

Before designing or launching experiments, read `references/experiment-workflow.md`. Every experiment must have `experiment_license.yaml` with claim tested, primary metric, simple control, trusted source paths, success criterion, kill/reframe criterion, expected cost, and paper decision affected. Run `scripts/check-experiment-license.ps1` before launch. If failure has no consequence, redesign the experiment.

### Phase 3: Experiment Execution and Monitoring

Run only licensed experiments. Runners report commands, configs, result paths, and failure states. Analysts summarize trends. Result Auditors check numbers, rankings, deltas, and claim scope. Experiment Analysis Auditors check interpretation depth before prose. The Coordinator alone writes manuscript conclusions.

### Phase 4: Result Analysis

Before any result claim, update `claim_evidence_map.md`, `result_audit.md`, `result_ledger.jsonl`, and `experiment_analysis_audit.md`, then run `scripts/check-result-audit.ps1` and `scripts/check-experiment-analysis.ps1`. Negative or mixed ablations trigger failure diagnosis, optimization, reframe, redesign, or route kill; they must not be converted into defensive prose.

### Phase 5: Paper Drafting

Drafting is fail-closed. Before writing prose:

1. Read `paper/protocol_state.md` and confirm action `writing` is allowed.
2. Read the required section-writing reference.
3. Freeze the section contract with `Reference path(s) read`.
4. Run `scripts/check-writing-gate.ps1` for the target section.
5. Draft only the allowed section.
6. Write `writing_gate_report.md` before integration or completion.

Section-specific constraints live in:

| Section | Required reference |
| --- | --- |
| Title, Abstract, Figure 1, Limitations, Conclusion, Appendix, Style | `references/section-writing/general.md` |
| Introduction | `references/section-writing/introduction.md` |
| Methods / Methodology | `references/section-writing/methodology.md` |
| Experiments / Results | `references/section-writing/experiments.md` |
| Related Work | `references/section-writing/related-work.md` |

### Phase 6: Self-Review and Revision

Before review, claim verification, visual audit, or final integration, read `references/review-workflow.md`. Fix critical and high-priority issues that are grounded in evidence. Do not package or declare the paper complete while the Workflow Supervisor returns `block`.

### Completion Checks

Before claiming the skill workflow or a manuscript action is complete, run the relevant checks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-protocol-state.ps1 -ProjectRoot . -Action writing
powershell -ExecutionPolicy Bypass -File scripts/check-writing-gate.ps1 -ProjectRoot . -Sections Introduction,Methods,Experiments -RequireResults
powershell -ExecutionPolicy Bypass -File scripts/check-result-audit.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File scripts/check-experiment-analysis.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File scripts/check-manuscript-prose.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File scripts/check-role-boundaries.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File scripts/check-workflow-supervision.ps1 -ProjectRoot . -RequireResults
powershell -ExecutionPolicy Bypass -File scripts/check-reference-routes.ps1 -ProjectRoot .
```

Use narrower `-Sections` values when only one section is being drafted. Use `-Action final-integration` before final manuscript integration.

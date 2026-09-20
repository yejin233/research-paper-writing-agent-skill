### Hard Gates and Evidence Verdicts

Treat process gates as blocking constraints, not reminders. If a required gate
artifact is missing, stop the current phase and create or repair the artifact
before continuing. Do not compensate for a missing gate with more prose.

**External GPT Availability Check**:
Default to `internal-only`. In a managed protocol record `first-call question: not-requested` when no external review was requested; this records a default, not a user answer. Reuse existing consent and opening information. Switch to `remote-gpt` only with explicit authorization for the destination and content. Missing optional external review never blocks internal research. A specifically authorized external checkpoint still needs its required handoff before that checkpoint can be declared complete.

**Manuscript Intent Gate**:
Before literature search, experiments, or drafting, freeze the intended paper
type in `paper_intent.md`, `paper/protocol_state.md`, or `paper_claims.md`.
This intent is upstream of the claim-evidence map and cannot be overwritten by
later result summaries, status notes, or reviewer/auditor convenience language.

```markdown
## Manuscript Intent

- Frozen paper type: method_paper / boundary_study / benchmark / survey / position / negative_result
- User-approved thesis:
- Required introduction arc:
- Required methodology blueprint:
- Required core method claim:
- Allowed claim weakenings:
- Forbidden paper-type conversions:
- Reframe policy:
- Kill conditions:
```

For ML method papers, the default frozen type is `method_paper`. If the frozen
type is `method_paper`, autonomous conversion into a `boundary_study` is
forbidden. Do not relabel a failed or weak method route as a boundary study,
simulation report, negative-result paper, benchmark, survey, or position paper
inside the same autonomous workflow. The only valid outcomes are:

- continue within the frozen method-paper intent using supported claims;
- reduce unsupported claims while preserving the method-paper type;
- redesign the method and rerun licensed tests;
- mark the route as `reframe_required` or `kill` and stop manuscript expansion.

A boundary study is allowed only when it is the frozen paper type from project
setup. It is not an automatic fallback for failed method-paper evidence.

**Project Identity Gate**:
Before literature search, experiments, or drafting, create or update the
project identity in `paper/protocol_state.md` or `paper_claims.md`:

```markdown
## Project Identity

- Trusted workspace root:
- Frozen paper type:
- Paper topic:
- One-sentence contribution candidate:
- In-scope method terms:
- Out-of-scope or deprecated routes/files:
- Forbidden paper-type conversions:
- Trusted data/result directories:
- Current phase:
- Allowed next actions:
- Blocked actions:
```

If the current working directory, source files, result files, or route language
does not match this identity, stop. Do not import old route artifacts into the
evidence chain unless the Coordinator explicitly marks them as background-only
or negative evidence.

**Phase Gate**:

| Entering phase | Required gate artifacts | If missing |
| --- | --- | --- |
| Literature review | project identity, manuscript intent, external GPT availability check | define the trusted workspace, frozen paper type, topic, deprecated routes, and external review availability |
| Experiment design | `literature_matrix.md`, Skeptic / Route Killer handoff, external GPT route review if enabled | run literature boundary, route-kill review, and configured external route review first |
| Experiment execution | Experiment License with success and kill criteria, external GPT experiment-design review if enabled | write the license and configured external experiment review before running |
| Results analysis | raw results plus `claim_evidence_map.md` draft | map every metric to a claim before interpreting |
| Optimization after failed results | failure diagnosis plus optimization plan, external GPT failure/repair review if enabled | diagnose root cause, get configured external repair critique, and propose repair tests before drafting failure prose |
| Paper drafting | manuscript intent, section contracts, `claim_evidence_map.md`, `result_audit.md`, `experiment_analysis_audit.md`, experiment log, external GPT section review if enabled | audit results, verify frozen paper type, freeze section-level writing constraints, check experiment-analysis depth, and capture configured external section critique before writing conclusions |
| Final manuscript integration | planned-vs-produced audit, defensive-writing audit, reviewer/meta-review, workflow supervision audit, external GPT final review if enabled, and figure/table audit when applicable | fix paper-type drift, writing drift, defensive prose, process violations, external-review blockers, critical evidence issues, or presentation issues first |

Do not enter Experiments writing if the evidence map, result audit, or
experiment-analysis audit is missing. Do not write Abstract, Introduction, or
Conclusion claims that are not present in `claim_evidence_map.md`. Do not draft
or finalize a manuscript whose paper type differs from the frozen manuscript
intent.

Before marking any phase complete, run the protocol-state checker and refresh
the Workflow Supervision Audit:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action phase-transition
```

A `block` decision overrides Coordinator preference, Reviewer advice, and local
manuscript quality. Do not mark the autonomous workflow complete while any
supervisor blocker remains open.

**Pre-registered Experiment License**:
Before running any experiment that may affect paper claims, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action experiment
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-license.ps1 -ProjectRoot .
```

Every experiment that may influence paper claims must be licensed in
`experiment_license.yaml`, not only described in prose. Use
`examples/experiment_license.example.yaml` as the schema. It must declare:

- `experiment_id`, `route_id`, and `claim_ids`;
- `primary_metric` and `metric_direction`;
- datasets, baselines, and simple controls;
- trusted `source_paths` and expected outputs;
- budget, success criterion, partial-support policy, kill criterion, failure
  action, and paper decision affected.

If the kill/reframe criterion is empty, the experiment is not licensed. If
failure would not change any claim, do not run the experiment as claim support.

**Failed-Result Optimization Gate**:
Failed or disappointing results are first an optimization and diagnosis signal,
not a writing opportunity. If a primary metric misses the success criterion, an
ablation contradicts the claimed mechanism, a simple baseline is competitive,
or the method only improves by shifting cost to another unacceptable metric,
stop manuscript expansion and write a failure diagnosis before revising prose.

```markdown
## Failure Diagnosis

- Failed experiment or ablation:
- Expected result:
- Observed result:
- Primary metric gap:
- Cost or side-effect gap:
- Possible root causes:
- Implementation or measurement checks:
- Mechanism-level explanation:
- Optimization candidates:
- Cheapest repair test:
- Stop condition if repair fails:
- Current route status: optimize / reframe_required / kill
```

When a method-paper route has plausible repair paths, set route status to
`optimize`, not `partial`, `reframe`, or `complete`. The next action is method,
objective, data, controller, metric, or implementation repair plus a licensed
repair test. Do not write defensive result prose while route status is
`optimize`.

Optimization candidates must address the root cause. Do not merely tune
presentation, thresholds, or post-processing if the failure source is the base
mechanism, objective, representation, data construction, or evaluation setup.
Generate 2-4 repair candidates unless the failure uniquely implies route kill
or a pre-registered stop condition has already been met.

Only after the optimization budget or stop condition is exhausted may the route
move to `reframe_required` or `kill`. For frozen `method_paper` intent,
`reframe_required` still does not permit boundary-study conversion inside the
same autonomous workflow.

**Ablation Kill Rule**:
Use ablations as verdicts, not decoration.

| Ablation outcome | Required paper decision |
| --- | --- |
| Removing a module does not reduce the primary metric or target behavior | Do not claim the module is effective or necessary |
| Replacing a module with a simple alternative is not worse | Do not claim the design is necessary; reframe as optional or simplify |
| Only a few cells improve and the primary claim does not | Write a local/conditional finding only |
| Main metric contradicts the claimed contribution | Trigger route reframe or kill review |
| Added module helps one dataset but harms others without a declared condition | Do not present it as a general contribution |
| Ablation results are mixed but interpretable by data regime | State the boundary condition and update the claim |

Negative or mixed ablations must update `result_audit.md` and
`claim_evidence_map.md` before any manuscript revision. Do not repair a failed
ablation with defensive prose. Do not repair a failed method-paper ablation by
converting the manuscript into a boundary study.

**Result Auditor Verdict**:
The Result Auditor must work from fresh context when possible: paper claims,
experiment licenses, tables, raw result files, and figure/table drafts, not the
Coordinator's preferred narrative. Its handoff must include:

Result facts must also be recorded in `result_ledger.jsonl`. `result_audit.md`
is the human-readable verdict; `result_ledger.jsonl` is the machine-checkable
source ledger. Before writing result claims, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-result-audit.ps1 -ProjectRoot .
```

**Experiment Analysis Auditor Verdict**:
The Experiment Analysis Auditor works from the result audit, claim map, tables,
figures, experiment log, and clean manuscript packet. It verifies that each
reported result has an interpretation chain:

```text
claim tested -> reviewer question -> primary observation -> strongest baseline
comparison -> mechanism interpretation -> alternative explanation -> boundary
condition -> claim implication -> required prose
```

Before writing Experiments prose, create `experiment_analysis_audit.md` and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
```

If the analysis unit is shallow, missing mechanism interpretation, missing
alternative explanation, or missing boundary condition, do not draft the
paragraph. Repair the analysis first.

```markdown
## Result Audit

- Result ledger: result_ledger.jsonl
- Supported claims:
- Partially supported claims:
- Unsupported claims:
- Contradicted claims:
- Overclaimed manuscript text:
- Number/table mismatches:
- Ranking/best-marker mismatches:
- Metric-direction problems:
- Missing baselines or controls:
- Ablation verdicts:
- Failure diagnosis:
- Optimization candidates:
- Cheapest repair test:
- Route status: support / partial / optimize / reframe_required / kill
- Required manuscript changes:
```

If `route_status` is `optimize`, `reframe_required`, or `kill`, stop manuscript
expansion. For `optimize`, the next action is failure diagnosis, method repair,
and a licensed repair test. For `reframe_required` or `kill`, the next action is
claim reduction, route redesign, or route termination inside the frozen
manuscript intent. If the frozen paper type is `method_paper`, the Result
Auditor must not resolve `reframe_required` by approving a boundary-study
manuscript. A method-paper route that only supports a boundary study remains
`reframe_required` or `kill` until a new user-approved project identity is
created outside the current autonomous workflow.

**Defensive Writing Trigger**:
Phrases such as "although this does not undermine", "despite not achieving",
"still acceptable", "slight degradation is reasonable", "does not affect
effectiveness", "remains competitive", or "fully demonstrates" are red flags.
When they appear, re-open the Result Audit and ask whether the claim should be
weakened, reframed, or killed.

**Defensive Writing Zero-Tolerance Gate**:
Submission-facing prose must be precise, direct, and evidence-shaped. Do not
use prose to protect a weak result, excuse a failed ablation, or make an
unsupported module sound acceptable. A manuscript containing defensive phrases
fails final integration until the phrases are removed or rewritten.

Always run a defensive-writing audit before final manuscript integration:

```markdown
## Defensive Writing Audit

- Forbidden phrase or sentence:
- Location:
- What weak claim it is protecting:
- Direct evidence statement that should replace it:
- Required action: delete claim / weaken claim / report rank and delta / return to optimization
```

Preferred replacements are direct and quantitative: state the rank, delta,
affected metric, support level, and boundary condition. If the evidence is weak,
delete the claim or return to the Failed-Result Optimization Gate. Do not replace
one defensive phrase with another softer hedge.

Forbidden defensive patterns include:
- "although this does not undermine..."
- "despite the degradation..."
- "still acceptable..."
- "does not affect effectiveness..."
- "remains competitive..." when the method is not clearly competitive on the
  declared primary metric;
- "fully demonstrates...", "strongly proves...", or "validates the superiority
  of..." without direct evidence;
- long limitation paragraphs inserted to justify why a failed method should
  still be considered successful.

Limitations are allowed only as honest scope statements after the result has
been stated directly. They must not be used as a substitute for optimization,
claim deletion, or route kill.

**Writing Conformance Gate**:
Every major section must be drafted against an explicit section contract, then
audited paragraph by paragraph before integration. This gate prevents the writer
from inventing a new narrative, leaking internal route language, or drifting
from the user's writing skill.

**Fail-Closed Writing Entry Gate**:
Within the managed research mode, before adding or changing scientific claims or integrating new result evidence, the workflow must pass a writing entry gate. Language-only edits preserve supplied facts and bypass this artifact gate. If the required artifacts are
missing, stale, or inconsistent, stop manuscript writing. The only allowed work
is to create or repair the missing gate artifacts.

Manuscript prose includes `.tex`, `.md`, `.docx`, Overleaf text, abstract text,
section drafts, captions, contribution bullets, and conclusion paragraphs.

Required for claim-changing manuscript work in the managed research workflow:

- frozen paper intent or `paper_claims.md`;
- `claim_evidence_map.md` with each allowed claim tied to concrete evidence or
  explicitly marked as hypothesis / unsupported;
- `section_contracts.md` containing a contract for every target section;
- trusted source paths for experiments, figures, tables, and literature;
- `result_audit.md` before writing Experiments, Results, Abstract result
  sentences, Introduction contribution claims, or Conclusion claims;
- `experiment_analysis_audit.md` before writing Experiments, Results, ablation,
  further-analysis, table-result, or figure-result prose;
- `writing_gate_report.md` before declaring writing complete.

If any item is missing, the correct next action is to write the artifact, not to
draft prose. Do not rationalize that a later audit will fix missing contracts.
Violating the gate by writing prose first is a workflow failure.

When setting up a managed research writing stage, ensure the paper project has project-local copies of
these scripts copied from this skill's `scripts/` directory:

- `check-protocol-state.ps1`
- `check-writing-gate.ps1`
- `check-result-audit.ps1`
- `check-experiment-analysis.ps1`
- `check-manuscript-prose.ps1`
- `check-role-boundaries.ps1`
- `check-workflow-supervision.ps1`

If any required checker is missing, create or copy it before drafting prose.
Run the relevant checks for claim-changing or result-integrating work; reuse still-valid evidence for unchanged inputs. Do not create or run this suite for language-only edits:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot .
```

Use `-RequireResults` when writing Experiments, Results, Abstract result
sentences, Introduction contribution claims, or Conclusion claims:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action result-claim
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot . -RequireResults
powershell -ExecutionPolicy Bypass -File .\scripts\check-result-audit.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
```

After drafting or before final integration, scan the actual manuscript text and
role boundary:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-manuscript-prose.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-role-boundaries.ps1 -ProjectRoot .
```

Create `section_contracts.md` before drafting or rewriting:

```markdown
## Section Contract

- Section:
- Purpose in the paper:
- Required content moves:
- Required terminology:
- Forbidden terminology or internal traces:
- Required evidence links:
- Forbidden claims:
- Style constraints:
- Paragraph-level outline:
```

After drafting, run a planned-vs-produced audit:

```markdown
## Planned-vs-Produced Writing Audit

- Section:
- Contract followed: yes / no
- Paragraphs that drift:
- Missing required content:
- Added unsupported claims:
- Defensive language found:
- Internal workflow or file traces:
- Terminology mismatches:
- Required rewrite before integration:
```

If any paragraph fails the contract, rewrite that paragraph before final
integration. Do not rely on a later polish pass to fix structural drift.

**Writing gate loop**:

1. Identify the target section(s).
2. Freeze or repair `paper_claims.md` and `claim_evidence_map.md`.
3. Create or update `section_contracts.md`.
4. Run `scripts/check-protocol-state.ps1` for the intended action.
5. Run `scripts/check-writing-gate.ps1`.
6. Draft only paragraphs licensed by the corresponding section contract.
7. Write `writing_gate_report.md` with the planned-vs-produced audit.
8. Rewrite failing paragraphs before integration.
9. Report the gate status in the final answer.

**Stop conditions**:

- target section has no contract;
- contract lacks purpose, required content moves, forbidden claims, or evidence
  links;
- claim appears in prose but not in `claim_evidence_map.md`;
- result sentence appears without `result_audit.md`;
- section uses defensive language to protect weak evidence;
- section introduces a new paper type, method name, terminology, or contribution
  not approved in the frozen intent;
- writer says "I will audit later" after drafting prose.

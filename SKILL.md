---
name: research-paper-writing-agent
description: "Use when writing, revising, analyzing, or preparing ML/AI research papers, especially long-running automated research workflows where manuscript constraints, evidence gates, result audits, reviewer simulation, or protocol-drift prevention matter for NeurIPS, ICML, ICLR, ACL, AAAI, COLM, or similar venues."
license: MIT
---

# Research Paper Writing Agent Pipeline

## Runtime Protocol Anchor

This skill is a state-controlled workflow, not a prose guideline.

Before any non-trivial action, the Coordinator must identify:

1. current phase;
2. current allowed next actions;
3. required gate artifacts;
4. blocked actions;
5. external audit route (`remote-gpt` or `internal-only`);
6. whether the intended action is allowed.

If the intended action is not explicitly allowed by the current protocol state,
stop and repair the protocol state instead.

Refresh `paper/protocol_state.md`:

- at workflow startup;
- when the first-call remote audit window intake is answered;
- before writing or modifying manuscript prose;
- before running experiments that may affect claims;
- before integrating results into claims;
- before declaring a phase complete;
- after every 3 tool-use batches in a long-running task.

No manuscript prose may be written unless the writing gate has passed in the
current protocol state. No result claim may be written unless `result_audit.md`
and `result_ledger.jsonl` exist and the result-audit checker can trace reported
values to trusted source files. No phase may advance unless the latest Workflow
Supervision Audit is `pass`. If unsure, choose `block`, not `pass`.

Before a gated action, run the protocol-state checker when available:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
```

**Installed Skill Update Check**:
At the first call of a paper workflow, when running from the installed skill
root or a checkout that contains `skill-version.json`, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1
```

This is a non-blocking hygiene check, not a scientific gate. If the result
status is `warn`, tell the user that a newer GitHub skill version exists and
recommend updating before long-running autonomous research workflows. If the
status is `unavailable`, continue the workflow and note that the latest version
could not be verified. Do not block paper work solely because the update check
is behind or unavailable.

If the user explicitly asks whether the installed skill matches the latest
GitHub branch, run the detailed mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1 -Detailed
```

Optionally write the result to `skill_update_status.md` or
`paper/handoffs/skill_update_status.md` with `-StatusPath`.

End-to-end pipeline for producing publication-ready ML/AI research papers targeting **NeurIPS, ICML, ICLR, ACL, AAAI, and COLM**. This skill covers the full research lifecycle: experiment design, execution, monitoring, analysis, paper writing, review, revision, and submission.

This is **not a linear pipeline** 鈥?it is an iterative loop. Results trigger new experiments. Reviews trigger new analysis. The coordinating agent must handle these feedback loops while using sub-agents only at high-risk boundaries where isolated search, skepticism, or verification improves quality.

## When To Use This Skill

Use this skill when:
- **Starting a new research paper** from an existing codebase or idea
- **Designing and running experiments** to support paper claims
- **Writing or revising** any section of a research paper
- **Coordinating multi-agent paper work** where literature search, route skepticism, result auditing, figure/table auditing, or reviewer simulation should be isolated from final manuscript integration
- **Preparing for submission** to a specific conference or workshop
- **Responding to reviews** with additional experiments or revisions

## Core Philosophy

1. **Act inside the protocol state.** Proactivity means doing the next allowed action; when gates are missing, create or repair gate artifacts instead of drafting prose.
2. **Never hallucinate citations.** AI-generated citations have ~40% error rate. Always fetch programmatically. Mark unverifiable citations as `[CITATION NEEDED]`.
3. **Paper is a story, not a collection of experiments.** Every paper needs one clear contribution stated in a single sentence. If you can't do that, the paper isn't ready.
4. **Experiments serve claims.** Every experiment must explicitly state which claim it supports. Never run experiments that don't connect to the paper's narrative.
5. **Actively try to kill weak routes.** A good ML research agent does not only optimize local wins; it pre-registers falsification criteria, tracks negative evidence, and stops or reframes a route when the main claim is no longer defensible.
6. **Matrices are scaffolds, not substitutes for thinking.** Every concrete problem needs its own problem snapshot, search lenses, local paper library, and adaptation logic before idea generation or experiments.
7. **Use preauthorized experiment boundaries.** If the scientist approves a route, budget, allowed actions, and stop conditions, continue design, experiment license writing, TDD kill tests, and low-cost runs inside that boundary without repeatedly asking for approval.

**Frozen paper type is a contract.** If the project identity declares a method
paper, the autonomous workflow must not convert it into a boundary study,
negative-result paper, benchmark, survey, or position paper. Weak or negative
evidence can trigger claim reduction, method redesign, or route kill, but not a
silent paper-type conversion.

### Multi-Agent Orchestration and Permission Boundaries

Multi-agent work is a quality-control mechanism, not an excuse to split the
paper's story across many voices. Sub-agents expand search, create opposition,
verify facts, and propose candidate edits. The Research Coordinator keeps the
paper's main claim, terminology, evidence chain, and final manuscript edits.

**Core permission rule**: sub-agents do not directly modify the main manuscript
by default. They produce structured handoffs. The Research Coordinator reviews
those handoffs, resolves conflicts, and performs final writes to the paper.

Use sub-agents at high-risk boundaries:

| Stage | Required or optional sub-agent use | Output |
| --- | --- | --- |
| Discovery | Required Literature Agent | `literature_matrix.md` entries: papers found, method family, relevance, relation to the gap, baseline use, close-work status, citation status |
| Design stress test | Required Skeptic / Route Killer | existing-work overlap, patchwork risk, overclaim risk, simple-baseline threat, cheapest kill test |
| Experiment execution and audit | Required Experiment Agent, Result Auditor, and Experiment Analysis Auditor | facts from runs, configuration, result paths, tables, deltas, ranking checks, claim-scope checks, mechanism-level analysis units |
| Section drafting and integration | Optional Writing Agent | local section draft or patch proposal only; no direct manuscript write unless explicitly authorized |
| External review | Optional at startup; required at configured checkpoints once enabled | external GPT review handoffs for intent, novelty, experiment design, failed-result repair, section conformance, and final readiness |
| Workflow supervision | Required Workflow Supervisor | process-compliance audit covering gates, state transitions, role boundaries, forbidden conversions, defensive prose, and unresolved blockers |
| Pre-submission review | Required role-bounded Reviewer Panel and Meta-Reviewer | intent, novelty, methodology, experiment, result, writing, presentation, and strict external ML logic reviews plus a prioritized meta-review |
| Figure/table quality | Required when figures or tables are created or revised | figure/table audit covering claim support, symbol consistency, captions, best/second-best markers, crowding, and internal trace leaks |

Default roles are intentionally compact:

| Role | Responsibility | Default status |
| --- | --- | --- |
| Research Coordinator | Maintains main story, claims, terms, evidence closure, and final manuscript edits | Always active |
| Literature Agent | Searches, groups, verifies relevance, and identifies close work and baseline rationale | Required in literature stage |
| Skeptic / Route Killer | Tests whether an idea is already done, too weak, too broad, or easily beaten | Required before committing to a route |
| Experiment Agent | Plans or runs experiments and summarizes factual outputs | Required in experiment stage |
| Result Auditor | Verifies numbers, ranks, averages, table labels, and claim boundaries from fresh context | Required after results |
| Experiment Analysis Auditor | Checks whether each result has claim-level interpretation, strongest-baseline comparison, mechanism explanation, alternative-explanation analysis, boundary condition, and required prose | Required before Experiments writing |
| Writing Agent | Produces local drafts or patch proposals for specific sections | Optional |
| External GPT Reviewer | Uses a user-provided controllable GPT page as an outside review source; produces advisory review handoffs only | Optional; required at configured checkpoints once enabled |
| Workflow Supervisor | Independently audits whether the autonomous research process followed the skill, gates, state transitions, and permission boundaries | Required at phase transitions and final integration |
| Role-Bounded Reviewer Panel | Runs separate fresh-context reviews for paper intent, novelty, methodology, experiment design, result claims, writing conformance, PDF presentation, strict ML logic, defensive prose, and venue readiness | Required before submission |
| Meta-Reviewer | Aggregates role-bounded reviewer reports, preserves hard blockers, and prioritizes repairs | Required before submission |

Treat Citation Verifier, Claim Verifier, and Figure/Table Auditor as auditor
modes unless the project is large enough to require separate agents.

**Never delegate these decisions by default**:
- contribution framing;
- final abstract text;
- introduction's main narrative;
- conclusion;
- cross-section terminology and symbol naming;
- final experiment conclusion wording;
- final `.tex` merge.

**Handoff discipline**:
- Keep the mandatory handoff files small and central: `paper/protocol_state.md`,
  `paper_claims.md`, `claim_evidence_map.md`, `literature_matrix.md`, and
  `result_audit.md`.
- For multi-agent work, maintain `handoff_manifest.yaml` and a Coordinator
  integration trace before protected manuscript files are modified. Sub-agents
  write handoffs or patch proposals under `paper/handoffs/` or
  `paper/patches/`; the Coordinator performs final `.tex` integration.
- Generate review reports, figure audits, and revision plans only when needed.
- A Runner reports commands, configuration, result paths, and failure states; it
  must not write "this demonstrates" conclusions.
- An Analyst may report trends and deltas; a Result Auditor must independently
  check numbers and whether claims exceed the data.
- An Experiment Analysis Auditor checks interpretation depth. It must block
  Experiments writing when results are merely reported without mechanism-level
  explanation, strongest-baseline comparison, alternative explanation, and
  boundary condition.
- Reviewers use role-bounded, fresh-context packets. Each reviewer can recommend
  changes only inside its jurisdiction and must state what it did not check. The
  Meta-Reviewer prioritizes reports and preserves hard blockers; the Research
  Coordinator decides final revisions.
- An External GPT Reviewer gives additional outside critique only. It does not
  directly edit the manuscript, run experiments, inspect browser credentials, or
  override local evidence gates. It also does not replace the local
  Role-Bounded Reviewer Panel or the Strict External ML Logic Reviewer.
- The Workflow Supervisor can block phase transitions and final integration
  when gates are missing, statuses are inconsistent, or forbidden conversions
  occur. It does not write manuscript prose, run experiments, or repair results.
- If two sub-agents conflict, preserve the conflict in the handoff and resolve
  it against raw evidence, not by majority vote.

**Failure modes to prevent**:
- many writer agents directly edit the main `.tex`;
- a runner writes paper claims instead of facts;
- reviewer suggestions are accepted mechanically;
- generic reviewers all give broad positive summaries without assigned
  jurisdictions, clean packets, or explicit block authority;
- section drafts introduce new terms, claims, or internal route names;
- figure captions, table labels, or result prose leak file names, scripts,
  plugin traces, or generated-artifact wording;
- the paper becomes a merge of local sections rather than one claim-evidence
  argument.

**External GPT Reviewer Role**:
On the first call of this skill in a paper workflow, run the **Remote Audit
Window Intake** before literature search, experiments, drafting, or review.
Ask the user exactly once:

```text
Do you have a controllable remote GPT review window that Codex may use as an
external audit window for this paper workflow?
```

If the user says yes, record how to open or reuse that window and set the audit
route to `remote-gpt`. If the user says no, does not answer, or cannot provide a
usable opening method, set the audit route to `internal-only` and continue with
the internal Workflow Supervisor, Reviewer, Result Auditor, and Figure/Table
Auditor path. This is a conditional outside-review channel, not a dependency
for normal operation.

Record only operational details in `external_gpt_reviewer.md` or the active
status note:

```markdown
## External GPT Reviewer

- Intake status: unanswered / answered-yes / answered-no
- Audit route: remote-gpt / internal-only
- Enabled: yes / no
- Browser surface: in-app browser / Chrome CDP / user-managed browser / other
- Opening method:
- Review page URL:
- User profile or browser profile name:
- Allowed actions: paste audit package / read review reply / navigate page
- Forbidden actions: inspect cookies / inspect passwords / inspect local storage / change account settings
- Required checkpoints:
- Last successful external review:
```

Also record the route in `paper/protocol_state.md` under `External audit route`.
The first-call intake is complete only when that section says either
`mode: remote-gpt` or `mode: internal-only`.

If enabled, the External GPT Reviewer is used only at high-risk review
checkpoints. It must not be asked to rewrite the main manuscript directly. It
must evaluate quality, identify risks, and provide complete, actionable
suggestions for the Coordinator and Workflow Supervisor to consider.

Use these checkpoints when the relevant artifacts exist:

| Checkpoint | Submit to external GPT | Purpose |
| --- | --- | --- |
| Startup / intent | manuscript intent, frozen paper type, thesis, forbidden conversions | check whether the paper type, thesis, and route boundaries are clear |
| Literature / route | literature matrix, close related work, route-killer handoff | assess novelty risk, missing close work, and weak gap framing |
| Experiment design | experiment license, primary metrics, baselines, success and kill criteria | assess whether experiments actually test the claims |
| Failed or mixed results | failure diagnosis, optimization candidates, ablation verdicts | assess whether repair, redesign, or route kill is more appropriate |
| Section drafting | section contract plus produced section and planned-vs-produced audit | assess writing quality, constraint compliance, drift, and missing content |
| Final integration | abstract, introduction, method, experiments, claim-evidence map, result audit, defensive-writing audit | assess overall paper quality and provide complete revision advice |

Use this standard prompt when submitting an audit package to the external GPT
review page. Replace bracketed fields with the current phase artifacts. Do not
include passwords, cookies, tokens, private credentials, or unrelated files.

```markdown
You are an external senior ML/security paper reviewer and process auditor.
Your task is to evaluate the quality of the submitted research artifact and
give complete, actionable suggestions.

Important rules:
1. Do not rewrite the paper directly.
2. Do not invent evidence, citations, experiments, or results.
3. Judge only from the audit package below.
4. Be strict about unsupported claims, defensive writing, weak novelty,
   method-experiment mismatch, and paper-type drift.
5. If the evidence is weak, say so directly and recommend optimization,
   redesign, claim deletion, or route kill.
6. Evaluate both scientific quality and compliance with the stated writing
   constraints.

Phase: [PHASE]
Frozen paper type: [FROZEN_PAPER_TYPE]
User-approved thesis: [THESIS]
Core method claim: [CORE_METHOD_CLAIM]
Forbidden conversions or claims: [FORBIDDEN_ITEMS]

Audit package:
[PASTE MANUSCRIPT INTENT / LITERATURE MATRIX / EXPERIMENT LICENSE /
FAILURE DIAGNOSIS / SECTION CONTRACT / SECTION DRAFT / CLAIM-EVIDENCE MAP /
RESULT AUDIT / DEFENSIVE-WRITING AUDIT AS APPLICABLE]

Please return exactly this structure:

## External GPT Review

- Phase:
- Decision: pass / concern / block
- Overall quality score: 1-10
- Main quality problems:
- Unsupported or overstrong claims:
- Novelty or related-work risks:
- Methodology problems:
- Experiment-design or evidence problems:
- Writing and structure problems:
- Defensive or vague language:
- Missing information:
- Complete actionable suggestions:
- Must-fix before next phase:
- Should Workflow Supervisor block: yes / no
- Rationale for block decision:
```

External GPT output is advisory. The Coordinator must preserve it as a handoff,
and the Workflow Supervisor must decide whether its concerns imply a local
blocker under this skill. Do not mechanically accept external GPT suggestions
when they conflict with raw evidence, user-approved intent, or local gate
artifacts.

**Workflow Supervisor Role**:
The Workflow Supervisor is an independent compliance role. It audits whether
the autonomous research process followed this skill and whether the current
state is allowed to advance. It is not a scientific reviewer, result analyst,
writer, or coordinator. Its job is to catch process failure before the paper is
drafted, finalized, or declared complete.

The Workflow Supervisor is also the long-running task heartbeat. It must refresh
or verify `paper/protocol_state.md` at workflow startup, after every 3 tool-use
batches, before any phase transition, before writing or modifying manuscript
prose, before running claim-affecting experiments, before integrating results
into claims, and before declaring the workflow complete.

The Workflow Supervisor must check:
- `paper/protocol_state.md` exists and declares current phase, allowed next
  actions, blocked actions, gate status, last supervision, and drift risk;
- the first-call external audit route is answered and set to either
  `remote-gpt` or `internal-only`;
- manuscript intent and frozen paper type are present and unchanged;
- if external GPT review is enabled, required checkpoint reviews were submitted
  and preserved as handoffs;
- required phase artifacts exist before phase transition;
- `route_status` is consistent across `paper_claims.md`,
  `claim_evidence_map.md`, `result_audit.md`, status notes, and manuscript
  prose;
- `experiment_license.yaml` passes the experiment-license checker before any
  claim-affecting run;
- `result_ledger.jsonl` passes the result-audit checker before result claims;
- `experiment_analysis_audit.md` passes the experiment-analysis checker before
  Experiments writing or result interpretation prose;
- failed results entered optimization before manuscript conclusions;
- method-paper routes were not converted into boundary studies;
- defensive-writing, manuscript-prose, and planned-vs-produced audits were run
  before integration;
- sub-agents stayed within permissions and did not directly modify the main
  manuscript unless explicitly authorized;
- the role-boundary checker did not find protected manuscript edits without a
  Coordinator integration trace;
- internal workflow traces, stale route artifacts, and old workspaces were not
  used as current evidence.

The Workflow Supervisor handoff must use this schema:

```markdown
## Workflow Supervision Audit

- Phase audited:
- Decision: pass / block
- Protocol state status:
- Allowed next actions:
- Blocked actions:
- Drift risk:
- Missing gate artifacts:
- Inconsistent statuses:
- Forbidden paper-type conversion:
- Failed-result optimization status:
- Defensive-writing audit status:
- Writing-conformance audit status:
- External audit route status:
- External GPT review status:
- Sub-agent permission violations:
- Evidence-chain contamination:
- Required repairs before next phase:
```

If the decision is `block`, the Coordinator must not advance the phase, write
new manuscript claims, package the paper, or mark the workflow complete. The
next action is the required repair listed by the Workflow Supervisor.

### Hard Gates and Evidence Verdicts

Treat process gates as blocking constraints, not reminders. If a required gate
artifact is missing, stop the current phase and create or repair the artifact
before continuing. Do not compensate for a missing gate with more prose.

**External GPT Availability Check**:
At the first call of this skill for a paper workflow, ask the Remote Audit
Window Intake question before any phase work. If the user says no, does not
answer, or does not provide a usable opening method, set
`External audit route.mode: internal-only`, set
`External GPT Reviewer.Enabled: no`, and use internal audit only. If the user
says yes, create or update `external_gpt_reviewer.md`, set
`External audit route.mode: remote-gpt`, record the opening method, and enable
the configured checkpoints.

Do not block normal research only because no external GPT page exists after the
route is explicitly recorded as `internal-only`. Do block all gated phase work
if the first-call audit route is still unanswered. Do block configured
checkpoint completion if `remote-gpt` is enabled but the required external
review handoff is missing.

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
Before generating, rewriting, polishing, or integrating any manuscript prose,
the workflow must pass a writing entry gate. If the required artifacts are
missing, stale, or inconsistent, stop manuscript writing. The only allowed work
is to create or repair the missing gate artifacts.

Manuscript prose includes `.tex`, `.md`, `.docx`, Overleaf text, abstract text,
section drafts, captions, contribution bullets, and conclusion paragraphs.

Required before any manuscript prose is written or modified:

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

At writing-stage setup, ensure the paper project has project-local copies of
these scripts copied from this skill's `scripts/` directory:

- `check-protocol-state.ps1`
- `check-writing-gate.ps1`
- `check-result-audit.ps1`
- `check-experiment-analysis.ps1`
- `check-manuscript-prose.ps1`
- `check-role-boundaries.ps1`
- `check-workflow-supervision.ps1`

If any required checker is missing, create or copy it before drafting prose.
Then run the relevant checks before writing, rewriting, polishing, or
integrating manuscript prose:

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

### Protocol-Bound Autonomy

Autonomy starts only after the relevant protocol and evidence gates pass. Before
that point, the only proactive action is to create or repair required artifacts:
`paper/protocol_state.md`, `paper_claims.md`, `claim_evidence_map.md`,
`section_contracts.md`, `result_audit.md`, or the Workflow Supervision Audit.

| State | Allowed behavior |
| --- | --- |
| Gate missing | Repair artifacts only; do not draft manuscript prose. |
| Gate blocked | Perform the supervisor-listed repair; do not advance phase. |
| Gate passed | Draft or revise only the section/action explicitly allowed by `protocol_state.md`. |
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

## Reference Documents

| Document | Contents |
| --- | --- |
| [references/literature-workflow.md](references/literature-workflow.md) | Literature search, citation verification, paper acquisition, literature matrix, idea discovery, root-cause innovation gate. |
| [references/experiment-workflow.md](references/experiment-workflow.md) | Experiment design, licenses, route kill review, failure transitions, result analysis, experiment-analysis depth gate, expansion planning, experiment log. |
| [references/section-writing/general.md](references/section-writing/general.md) | Drafting modes, context management, title, abstract, Figure 1, limitations, conclusion, appendix, page budget, style. |
| [references/section-writing/introduction.md](references/section-writing/introduction.md) | Failure-to-mechanism Introduction structure and quality gate. |
| [references/section-writing/methodology.md](references/section-writing/methodology.md) | Methodology structure, module logic, formula rules, method-experiment alignment, naming and implementation-detail boundaries. |
| [references/section-writing/experiments.md](references/section-writing/experiments.md) | Experiment section structure, setup, main results, ablations, mechanism-level analysis units, table/prose rules, defensive-language ban. |
| [references/section-writing/related-work.md](references/section-writing/related-work.md) | Related Work structure, citation selection, gap discipline, paragraph pattern, subsection closure. |
| [references/review-workflow.md](references/review-workflow.md) | Reviewer simulation, visual review, claim verification, revision cycle, reviewer criteria, common issues. |
| [references/writing-guide.md](references/writing-guide.md) | General scientific writing principles and sentence-level style examples. |
| [references/citation-workflow.md](references/citation-workflow.md) | Citation APIs, BibTeX management, and citation verification helpers. |
| [references/checklists.md](references/checklists.md) | Venue checklists and pre-submission checks. |
| [references/reviewer-guidelines.md](references/reviewer-guidelines.md) | Reviewer guidelines, scoring, common concerns, and rebuttal notes. |
| [references/sources.md](references/sources.md) | Bibliography of writing guides, conference guidelines, APIs. |

Templates in `templates/` cover NeurIPS, ICML, ICLR, ACL, AAAI, and COLM. See [templates/README.md](templates/README.md) for compilation instructions.

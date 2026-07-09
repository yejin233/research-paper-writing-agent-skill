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
5. whether the intended action is allowed.

If the intended action is not explicitly allowed by the current protocol state,
stop and repair the protocol state instead.

Refresh `paper/protocol_state.md`:

- at workflow startup;
- before writing or modifying manuscript prose;
- before running experiments that may affect claims;
- before integrating results into claims;
- before declaring a phase complete;
- after every 3 tool-use batches in a long-running task.

No manuscript prose may be written unless the writing gate has passed in the
current protocol state. No result claim may be written unless `result_audit.md`
exists and supports the claim. No phase may advance unless the latest Workflow
Supervision Audit is `pass`. If unsure, choose `block`, not `pass`.

Before a gated action, run the protocol-state checker when available:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
```

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
| Experiment execution and audit | Required Experiment Agent and Result Auditor | facts from runs, configuration, result paths, tables, deltas, ranking checks, claim-scope checks |
| Section drafting and integration | Optional Writing Agent | local section draft or patch proposal only; no direct manuscript write unless explicitly authorized |
| External review | Optional at startup; required at configured checkpoints once enabled | external GPT review handoffs for intent, novelty, experiment design, failed-result repair, section conformance, and final readiness |
| Workflow supervision | Required Workflow Supervisor | process-compliance audit covering gates, state transitions, role boundaries, forbidden conversions, defensive prose, and unresolved blockers |
| Pre-submission review | Required Reviewer / Meta-Reviewer | technical, novelty, experiment, presentation reviews plus a prioritized meta-review |
| Figure/table quality | Required when figures or tables are created or revised | figure/table audit covering claim support, symbol consistency, captions, best/second-best markers, crowding, and internal trace leaks |

Default roles are intentionally compact:

| Role | Responsibility | Default status |
| --- | --- | --- |
| Research Coordinator | Maintains main story, claims, terms, evidence closure, and final manuscript edits | Always active |
| Literature Agent | Searches, groups, verifies relevance, and identifies close work and baseline rationale | Required in literature stage |
| Skeptic / Route Killer | Tests whether an idea is already done, too weak, too broad, or easily beaten | Required before committing to a route |
| Experiment Agent | Plans or runs experiments and summarizes factual outputs | Required in experiment stage |
| Result Auditor | Verifies numbers, ranks, averages, table labels, and claim boundaries from fresh context | Required after results |
| Writing Agent | Produces local drafts or patch proposals for specific sections | Optional |
| External GPT Reviewer | Uses a user-provided controllable GPT page as an outside review source; produces advisory review handoffs only | Optional; required at configured checkpoints once enabled |
| Workflow Supervisor | Independently audits whether the autonomous research process followed the skill, gates, state transitions, and permission boundaries | Required at phase transitions and final integration |
| Reviewer / Meta-Reviewer | Simulates venue review and aggregates priorities | Required before submission |

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
- Generate review reports, figure audits, and revision plans only when needed.
- A Runner reports commands, configuration, result paths, and failure states; it
  must not write "this demonstrates" conclusions.
- An Analyst may report trends and deltas; a Result Auditor must independently
  check numbers and whether claims exceed the data.
- A Reviewer can recommend changes; the Meta-Reviewer prioritizes them; the
  Research Coordinator decides final revisions.
- An External GPT Reviewer gives additional outside critique only. It does not
  directly edit the manuscript, run experiments, inspect browser credentials, or
  override local evidence gates.
- The Workflow Supervisor can block phase transitions and final integration
  when gates are missing, statuses are inconsistent, or forbidden conversions
  occur. It does not write manuscript prose, run experiments, or repair results.
- If two sub-agents conflict, preserve the conflict in the handoff and resolve
  it against raw evidence, not by majority vote.

**Failure modes to prevent**:
- many writer agents directly edit the main `.tex`;
- a runner writes paper claims instead of facts;
- reviewer suggestions are accepted mechanically;
- section drafts introduce new terms, claims, or internal route names;
- figure captions, table labels, or result prose leak file names, scripts,
  plugin traces, or generated-artifact wording;
- the paper becomes a merge of local sections rather than one claim-evidence
  argument.

**External GPT Reviewer Role**:
At workflow startup, ask whether the user has a controllable external GPT review
page. If yes, record how to open or reuse it. If no, continue the workflow
unchanged. This is a conditional outside-review channel, not a dependency for
normal operation.

Record only operational details in `external_gpt_reviewer.md` or the active
status note:

```markdown
## External GPT Reviewer

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
- manuscript intent and frozen paper type are present and unchanged;
- if external GPT review is enabled, required checkpoint reviews were submitted
  and preserved as handoffs;
- required phase artifacts exist before phase transition;
- `route_status` is consistent across `paper_claims.md`,
  `claim_evidence_map.md`, `result_audit.md`, status notes, and manuscript
  prose;
- failed results entered optimization before manuscript conclusions;
- method-paper routes were not converted into boundary studies;
- defensive-writing and planned-vs-produced audits were run before integration;
- sub-agents stayed within permissions and did not directly modify the main
  manuscript unless explicitly authorized;
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
At the start of a paper workflow, ask the user once whether a controllable
external GPT review page is available. If the user says no or does not provide a
usable opening method, set `External GPT Reviewer.Enabled: no` and continue the
normal workflow. If the user says yes, create or update
`external_gpt_reviewer.md` and enable the configured checkpoints.

Do not block normal research only because no external GPT page exists. Do block
configured checkpoint completion if external GPT review is enabled but the
required external review handoff is missing.

**Manuscript Intent Gate**:
Before literature search, experiments, or drafting, freeze the intended paper
type in `paper_intent.md`, `paper/status.md`, or `paper_claims.md`. This intent
is upstream of the claim-evidence map and cannot be overwritten by later result
summaries, status notes, or reviewer/auditor convenience language.

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
project identity in `paper/status.md` or `paper_claims.md`:

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
| Paper drafting | manuscript intent, section contracts, `claim_evidence_map.md`, `result_audit.md`, experiment log, external GPT section review if enabled | audit results, verify frozen paper type, freeze section-level writing constraints, and capture configured external section critique before writing conclusions |
| Final manuscript integration | planned-vs-produced audit, defensive-writing audit, reviewer/meta-review, workflow supervision audit, external GPT final review if enabled, and figure/table audit when applicable | fix paper-type drift, writing drift, defensive prose, process violations, external-review blockers, critical evidence issues, or presentation issues first |

Do not enter Experiments writing if the evidence map or result audit is
missing. Do not write Abstract, Introduction, or Conclusion claims that are not
present in `claim_evidence_map.md`. Do not draft or finalize a manuscript whose
paper type differs from the frozen manuscript intent.

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
```

Every experiment that may influence paper claims must declare:

```markdown
## Experiment License

- Experiment:
- Claim tested:
- Primary metric(s):
- Secondary metric(s):
- Dataset/task scope:
- Compared baseline or variant:
- Expected direction:
- Minimum practical effect size:
- Success criterion:
- Partial-support criterion:
- Kill/reframe criterion:
- Cost/time budget:
- Test exposure: exploratory / confirmatory / frozen-policy rerun
- Paper decision affected:
```

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

```markdown
## Result Audit

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
- `writing_gate_report.md` before declaring writing complete.

If any item is missing, the correct next action is to write the artifact, not to
draft prose. Do not rationalize that a later audit will fix missing contracts.
Violating the gate by writing prose first is a workflow failure.

At writing-stage setup, ensure the paper project has project-local copies of
`scripts/check-protocol-state.ps1` and `scripts/check-writing-gate.ps1` copied
from this skill's `scripts/` directory. If either checker is missing, create or
copy it before drafting prose. Then run both checks before writing, rewriting,
polishing, or integrating manuscript prose:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot .
```

Use `-RequireResults` when writing Experiments, Results, Abstract result
sentences, Introduction contribution claims, or Conclusion claims:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action result-claim
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot . -RequireResults
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
## Phase 0: Project Setup

**Goal**: Establish the workspace, understand existing work, identify the contribution.

### Step 0.1: Explore the Repository

```powershell
# Understand project structure
Get-ChildItem -Force
Get-ChildItem -Recurse -Filter *.py | Select-Object -First 30
Get-ChildItem -Recurse -Include *.md,*.txt -File |
  Select-String -Pattern 'result|conclusion|finding' -List
```

Look for:
- `README.md` 鈥?project overview and claims
- `results/`, `outputs/`, `experiments/` 鈥?existing findings
- `configs/` 鈥?experimental settings
- `.bib` files 鈥?existing citations
- Draft documents or notes

### Step 0.2: Organize the Workspace

Establish a consistent workspace structure:

```
workspace/
  paper/               # LaTeX source, figures, compiled PDFs, protocol_state.md
  literature/          # Downloaded open PDFs, metadata index, reading notes
  experiments/         # Experiment runner scripts
  code/                # Core method implementation
  results/             # Raw experiment results (auto-generated)
  tasks/               # Task/benchmark definitions
  human_eval/          # Human evaluation materials (if needed)
```

At workflow startup, create `paper/protocol_state.md` from
`examples/protocol_state.example.md` and update it before any gated action. This
file records what the agent is currently allowed to do; it is not a manuscript
summary.

### Step 0.3: Set Up Version Control

```powershell
git init  # if not already
git remote add origin <repo-url>
git checkout -b paper-draft  # or main
```

**Git discipline**: Every completed experiment batch gets committed with a descriptive message. Example:
```
Add Monte Carlo constrained results (5 runs, Sonnet 4.6, policy memo task)
Add Haiku baseline comparison: autoreason vs refinement baselines at cheap model tier
```

### Step 0.4: Identify the Contribution

Before writing anything, articulate:
- **The What**: What is the single thing this paper contributes?
- **The Why**: What evidence supports it?
- **The So What**: Why should readers care?

> Propose to the scientist: "Based on my understanding, the main contribution is: [one sentence]. The key results show [Y]. Is this the framing you want?"

### Step 0.6: Estimate Compute Budget

Before running experiments, estimate total cost and time:

```
Compute Budget Checklist:
- [ ] API costs: (model price per token) 脳 (estimated tokens per run) 脳 (number of runs)
- [ ] GPU hours: (time per experiment) 脳 (number of experiments) 脳 (number of seeds)
- [ ] Human evaluation costs: (annotators) 脳 (hours) 脳 (hourly rate)
- [ ] Total budget ceiling and contingency (add 30-50% for reruns)
```

Track actual spend as experiments run:
```python
# Simple cost tracker pattern
import json, os
from datetime import datetime

COST_LOG = "results/cost_log.jsonl"

def log_cost(experiment: str, model: str, input_tokens: int, output_tokens: int, cost_usd: float):
    entry = {
        "timestamp": datetime.now().isoformat(),
        "experiment": experiment,
        "model": model,
        "input_tokens": input_tokens,
        "output_tokens": output_tokens,
        "cost_usd": cost_usd,
    }
    with open(COST_LOG, "a") as f:
        f.write(json.dumps(entry) + "\n")
```

**When budget is tight**: Run pilot experiments (1-2 seeds, subset of tasks) before committing to full sweeps. Use cheaper models for debugging pipelines, then switch to target models for final runs.

## Phase 1: Literature Review

**Goal**: Find related work, identify baselines, gather citations.

### Step 1.1: Identify Seed Papers

Start from papers already referenced in the codebase:

```powershell
# Via terminal:
Get-ChildItem -Recurse -Include *.md,*.bib,*.py -File |
  Select-String -Pattern 'arxiv|doi|cite'
Get-ChildItem -Recurse -Filter *.bib
```

### Step 1.2: Search for Related Work

**Load the `arxiv` skill** for structured paper discovery: `skill_view("arxiv")`. It provides arXiv REST API search, Semantic Scholar citation graphs, author profiles, and BibTeX generation.

Use `web_search` for broad discovery, `web_extract` for fetching specific papers:

```
# Via web_search:
web_search("[main technique] + [application domain] site:arxiv.org")
web_search("[baseline method] comparison ICML NeurIPS 2024")

# Via web_extract (for specific papers):
web_extract("https://arxiv.org/abs/2303.17651")
```

Additional search queries to try:

```
Search queries:
- "[main technique] + [application domain]"
- "[baseline method] comparison"
- "[problem name] state-of-the-art"
- Author names from existing citations
```

**Recommended**: Install **Exa MCP** for real-time academic search:
```bash
claude mcp add exa -- npx -y mcp-remote "https://mcp.exa.ai/mcp"
```

### Step 1.2b: Deepen the Search (Breadth-First, Then Depth)

A flat search (one round of queries) typically misses important related work. Use an iterative **breadth-then-depth** pattern inspired by deep research pipelines:

```
Iterative Literature Search:

Round 1 (Breadth): 4-6 parallel queries covering different angles
  - "[method] + [domain]"
  - "[problem name] state-of-the-art 2024 2025"
  - "[baseline method] comparison"
  - "[alternative approach] vs [your approach]"
  鈫?Collect papers, extract key concepts and terminology

Round 2 (Depth): Generate follow-up queries from Round 1 learnings
  - New terminology discovered in Round 1 papers
  - Papers cited by the most relevant Round 1 results
  - Contradictory findings that need investigation
  鈫?Collect papers, identify remaining gaps

Round 3 (Targeted): Fill specific gaps
  - Missing baselines identified in Rounds 1-2
  - Concurrent work (last 6 months, same problem)
  - Key negative results or failed approaches
  鈫?Stop when new queries return mostly papers you've already seen
```

**When to stop**: If a round returns >80% papers already in your collection, the search is saturated. Typically 2-3 rounds suffice. For survey papers, expect 4-5 rounds.

**For agent-based workflows**: Use the Literature Agent for independent search lenses. Collect results, deduplicate, then generate the next round's queries from the combined learnings.

### Step 1.3: Verify Every Citation

**NEVER generate BibTeX from memory. ALWAYS fetch programmatically.**

For each citation, follow the mandatory 5-step process:

```
Citation Verification (MANDATORY per citation):
1. SEARCH 鈫?Query Semantic Scholar or Exa MCP with specific keywords
2. VERIFY 鈫?Confirm paper exists in 2+ sources (Semantic Scholar + arXiv/CrossRef)
3. RETRIEVE 鈫?Get BibTeX via DOI content negotiation (programmatically, not from memory)
4. VALIDATE 鈫?Confirm the claim you're citing actually appears in the paper
5. ADD 鈫?Add verified BibTeX to bibliography
If ANY step fails 鈫?mark as [CITATION NEEDED], inform scientist
```

```python
# Fetch BibTeX via DOI
import requests

def doi_to_bibtex(doi: str) -> str:
    response = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex"}
    )
    response.raise_for_status()
    return response.text
```

If you cannot verify a citation:

```latex
\cite{PLACEHOLDER_author2024_verify_this}  % TODO: Verify this citation exists
```

**Always tell the scientist**: "I've marked [X] citations as placeholders that need verification."

See [references/citation-workflow.md](references/citation-workflow.md) for complete API documentation and the full `CitationManager` class.

### Step 1.4: Reference Paper Acquisition Gate

Do not rely only on titles, abstracts, cached model knowledge, or citation metadata. Before using a paper for idea generation, related-work boundaries, method borrowing, or claim support, acquire a local, legally accessible copy or explicitly record why no PDF is available.

Use only lawful public sources:
- arXiv PDF;
- OpenReview PDF;
- ACL Anthology, PMLR, NeurIPS, ICML, ICLR, AAAI, COLM, or publisher open-access PDF;
- author homepage or institutional repository PDF;
- project page PDF linked by the authors.

Do not bypass paywalls, logins, DRM, institutional access controls, or publisher terms. If the only version found is paywalled, keep metadata and mark the paper as `metadata-only`.

Create or update this local library:

```text
literature/
  papers/
    2024_author_shorttitle.pdf
  metadata/
    paper_index.csv
    paper_index.jsonl
  notes/
    2024_author_shorttitle.md
```

For every candidate reference, write one row in `literature/metadata/paper_index.jsonl` and, when useful for manual inspection, mirror it in `paper_index.csv`:

```json
{
  "title": "",
  "authors": [],
  "year": "",
  "venue": "",
  "doi": "",
  "arxiv_id": "",
  "openreview_url": "",
  "pdf_url": "",
  "local_pdf_path": "",
  "source": "arxiv|openreview|acl|pmlr|publisher_oa|author_homepage|institutional_repo|metadata_only",
  "download_status": "downloaded|metadata-only|failed|duplicate",
  "failure_reason": "",
  "why_it_matters": "",
  "claim_support_status": "unread|read|supports_claim|background_only|not_relevant"
}
```

For every downloaded or metadata-only paper that influences the route, create a note:

```markdown
# Paper Reading Note

- Citation key:
- Local PDF:
- Why this paper matters to the current project:
- Core claim:
- Core mechanism:
- Key assumptions:
- Evaluation protocol:
- Strongest baseline:
- Limitation or failure mode:
- Reusable insight:
- Mismatch with our problem:
- Possible adaptation:
- Claims it can support:
- Claims it cannot support:
```

Acquisition rules:
- Download the stable PDF when available; otherwise store the landing page URL and DOI/arXiv/OpenReview identifier.
- Deduplicate by DOI, arXiv ID, OpenReview forum ID, title normalization, and first author/year.
- Use safe filenames: `year_firstauthor_shorttitle.pdf`; keep the original URL in metadata.
- Never cite a paper as evidence for a claim until the relevant PDF section or note has been read. Metadata-only papers can guide search but cannot support a claim.
- If a candidate idea depends on a paper that is not downloaded or read, mark the idea `blocked-on-reading` before launching experiments.

### Step 1.5: Organize Related Work

Group papers by methodology, not paper-by-paper:

**Good**: "One line of work uses X's assumption [refs] whereas we use Y's assumption because..."
**Bad**: "Smith et al. introduced X. Jones et al. introduced Y. We combine both."

### Step 1.6: Related-Paper-Driven Idea Discovery

Do not generate new research directions from intuition alone. Before proposing a new direction, alternative route, or innovation claim, build a same-family paper matrix from the local paper library. Good ideas usually come from tensions among similar papers: assumptions they share, failure cases they avoid, baselines they under-test, or settings where their mechanism no longer fits.

Search for **same-family papers**, not only broadly related work:

- same task or benchmark;
- same problem setting or data regime;
- same mechanism or architectural principle;
- same evaluation protocol or metric;
- strongest baseline, control, or backbone papers;
- analysis, failure, negative-result, or reproducibility papers;
- concurrent work from the last 6-12 months when the topic is active.

Use iterative search. Start broad, extract terminology and citations, then search again using the papers' own names for mechanisms, datasets, and failure modes. Stop only when a new search round mostly returns papers already in the matrix or clearly irrelevant work.

Create this matrix before idea generation:

```markdown
## Similar-Paper Matrix

| Paper | Local note/PDF status | Problem setting | Core claim | Core mechanism | Key assumption | Evaluation protocol | Strongest baseline | Limitation or failure | Reusable insight | Risk to our novelty |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
```

For each candidate idea, write a literature source chain:

```markdown
## Literature-Grounded Candidate Direction

- Candidate direction:
- Inspired by papers:
- Shared limitation or unresolved tension:
- Source mechanism:
- Why direct copying is insufficient:
- Mismatch with this paper's task, data, constraints, objective, or evaluation:
- Proposed adaptation:
- Expected innovation delta:
- Strongest paper that could make this look obvious:
- Cheapest experiment that could kill the direction:
```

Valid innovation sources include:

- a strong paper assumes X, but this problem violates X;
- several papers succeed only under a data, label, cost, supervision, or compute condition absent here;
- the standard evaluation protocol hides a failure mode that matters for the intended claim;
- a strong baseline works but its mechanism or boundary is unexplained;
- multiple papers share the same blind spot or limitation;
- a known failure case has been treated as a limitation rather than converted into a method or evaluation contribution;
- a recent method improves the outcome but does not validate the mechanism.

Reject ideas that cannot be tied to the matrix. Do not accept "try X", "combine A and B", "add an agent", "add prompts", "add a module", or "run it and see" unless the idea identifies a same-family literature gap, a necessary adaptation, and a cheapest route-killing experiment.

### Step 1.7: Problem-Specific Divergence and Analogical Search

The Similar-Paper Matrix is a starting point, not the thinking process. Before choosing a method, convert the concrete problem into search lenses that can reveal new paths, adjacent mechanisms, and non-obvious adaptations.

First write a problem snapshot:

```markdown
## Problem-Specific Snapshot

- Current task/problem:
- Data regime:
- Evaluation protocol and hidden weaknesses:
- Deployment, compute, label, latency, privacy, or robustness constraints:
- Current main claim:
- Main bottleneck or failure mode:
- Strong baseline behavior:
- Why the default research matrix is insufficient:
```

Then create search lenses. At minimum, include same-family, mechanism, constraint, evaluation, failure-case, and adjacent-domain lenses:

```markdown
## Search Lens Plan

| Lens | Concrete question | Search queries | Sources/papers found | Mechanism or insight extracted | Why it may transfer |
| --- | --- | --- | --- | --- | --- |
| Same-family | What do closest papers assume, avoid, or under-test? | | | | |
| Mechanism | Which fields solve the same causal/mechanistic bottleneck? | | | | |
| Constraint | Who solved a similar problem under our missing resource or constraint? | | | | |
| Evaluation | Which papers expose benchmark, metric, or protocol blind spots? | | | | |
| Failure-case | Which hard cases can be converted into a method or diagnostic? | | | | |
| Adjacent-domain | Which neighboring area has a portable mechanism? | | | | |
```

Generate a problem-specific insight map before proposing experiments:

```markdown
## Problem-Specific Insight Map

| Concrete bottleneck | Search lens | Paper/solution | Extracted mechanism | Mismatch with our problem | Required adaptation | Candidate route | Cheapest kill experiment |
| --- | --- | --- | --- | --- | --- | --- | --- |
```

Candidate route requirements:
- Include at least one candidate from a same-family literature gap, one from an adjacent or mechanism analogy, one from evaluation/baseline reframing, and one simpler control route, unless the problem snapshot explains why a class is irrelevant.
- Borrow mechanisms, not methods. State the transfer path: source paper -> extracted mechanism -> mismatch with this problem -> adaptation -> innovation delta.
- If all candidates are direct applications of known methods, stop and broaden the search lenses before running experiments.
- If a matrix field is irrelevant to the concrete problem, state why and replace it with a problem-specific field. Do not fill irrelevant columns mechanically.
- Before Phase 2, state what the search changed about the method, evaluation, baseline set, or claim. If it changed nothing, the search has not done its job.

No-mechanical-matrix rule: a research matrix is valid only if it makes the current problem sharper. The agent must tailor rows, columns, search queries, and candidate generation to the concrete problem instead of executing a fixed checklist.

### Step 1.8: Root-Cause Innovation Gate

Do not choose an innovation point only because it is easy to implement, already scripted, or close to the current post-processing layer. Before launching a new route or continuing several failed local optimizations, diagnose where the actual bottleneck lives.

This gate is mandatory when:
- multiple post-processing, threshold, smoothing, reranking, calibration, critic, selector, or filter variants fail to produce a claim-sufficient result;
- a method improves only one metric while the primary metric, cross-dataset behavior, or core claim remains weak;
- the route keeps adding patches around a fixed base model;
- simple controls or strong baselines remain competitive;
- the agent cannot explain why the base model fails on the hard cases.

Complete this bottleneck attribution before proposing the next method:

```markdown
## Root-Cause Innovation Gate

- Current base model or backbone:
- Current intervention layer:
- Main failure pattern:
- Hard examples or slices inspected:
- Strong baseline behavior:
- Evidence that the base representation is sufficient / insufficient:
- Evidence that the objective or loss is aligned / misaligned:
- Evidence that the data, labels, or sampling create the failure:
- Evidence that the inference or aggregation rule creates the failure:
- Evidence that post-processing is the right layer:
- Evidence that the evaluation metric or protocol hides the real problem:
- Papers that solve a structurally similar bottleneck at the base/objective/data layer:
- Papers that solve it only with post-processing:
- Why another post-processing attempt is justified, if it is:
- Candidate base-level or objective-level intervention:
- Cheapest experiment that distinguishes base failure from post-processing failure:
```

Use an intervention-layer table:

| Layer | What can be changed | Required evidence before choosing this layer | Example kill test |
| --- | --- | --- | --- |
| Base / backbone | encoder, representation, architecture, pretrained features | Hard errors contain missing or collapsed information in the base outputs. | Train or swap a small base variant; probe representation separability. |
| Objective | loss, contrastive target, ranking target, uncertainty objective, sampling objective | The base can represent the signal, but the training signal optimizes the wrong separation. | Change loss on a small split; test whether targeted slices move. |
| Data / labels | label definition, slice sampling, augmentation, denoising, distribution shift handling | Failures cluster by data slice, noise pattern, or label ambiguity. | Reweight, clean, or isolate the slice and compare to unchanged base. |
| Inference / aggregation | windowing, decoding, aggregation, routing, temporal pooling | Correct local signals exist but are combined incorrectly. | Oracle or controlled aggregation upper bound beats current inference. |
| Post-processing | threshold, smoothing, calibration, critic, filter, reranker | Base scores already contain separable signal and errors are mostly calibration or decision-boundary errors. | Validation-only threshold/control closes most of the gap. |
| Evaluation / protocol | metric, split, leakage check, cost constraint, slice reporting | The apparent win/loss changes under a more claim-relevant metric or protocol. | Frozen rerun with the claim-relevant metric and fair controls. |

Post-processing is allowed as the main innovation only when the gate shows that the base already contains the needed signal and the failure is mainly decision-boundary, aggregation, or calibration error. If the base cannot separate the hard cases, post-processing may be a diagnostic or ablation, but the next main route must consider base, objective, data, or evaluation-level changes.

Innovation-route requirements after this gate:
- Include at least one base-level or objective-level candidate unless evidence shows the bottleneck is not there.
- Include one cheapest experiment that can falsify the bottleneck diagnosis itself.
- State why the selected intervention layer is closer to the failure cause than the current layer.
- If the selected route keeps the base frozen, explain why changing the base would be unnecessary, too costly, or outside the paper's claim.
- Treat repeated post-processing improvements as local optimization, not innovation, unless they reveal or validate a new mechanism.

---

## Phase 2: Experiment Design

**Goal**: Design experiments that directly support paper claims. Every experiment must answer a specific question.

### Step 2.1: Map Claims to Experiments

Create an explicit mapping:

| Claim | Experiment | Expected Evidence |
|-------|-----------|-------------------|
| "Our method outperforms baselines" | Main comparison (Table 1) | Win rate, statistical significance |
| "Effect is larger for weaker models" | Model scaling study | Monotonic improvement curve |
| "Convergence requires scope constraints" | Constrained vs unconstrained | Convergence rate comparison |

**Rule**: If an experiment doesn't map to a claim, don't run it.

### Step 2.2: Contribution Thickness Gate

Before launching experiments for a new ML research route, check whether the idea is thick enough to become a paper rather than an implementation exercise.

Complete this gate:

```markdown
## Contribution Thickness Check

- Proposed contribution:
- New mechanism, not just new application:
- Why this mechanism is necessary:
- What simpler method could replace it:
- Cheapest experiment that could prove the simpler method is enough:
- Strongest related work that makes this look obvious:
- Strongest external baseline or backbone:
- Expected paper type if successful: main / short / workshop / negative
```

Do not run experiments for a route whose contribution is only "apply X to Y", "wrap X with an agent", "combine existing tools", "add prompts around an existing pipeline", or "tune a benchmark until it improves." Redesign the mechanism, downgrade it to a baseline, or frame it as an analysis/negative-result route.

**Default status of a new route is `yellow`, not `green`.** It becomes `green` only after it has:

- a one-sentence mechanism claim;
- related-work boundaries that say what cannot be claimed;
- at least one simple control that could kill the route;
- a cost model for compute, labels, API calls, or human feedback;
- a primary metric and a minimum practical effect size.

### Step 2.3: Enforce Method Cleanliness

The method must look clean, unified, and inevitable from the paper's core idea. It must not look like a pile of patches added until the numbers improved.

Clean-method checklist:
- State the core mechanism in one sentence. If this is impossible, the method is probably too patchy.
- Every component must follow from the same principle, objective, or failure analysis.
- Remove or merge ad hoc heuristics, fallback branches, threshold tweaks, and special cases unless they are essential and principled.
- If a component exists only because it helped one experiment, treat it as an ablation candidate, not as part of the main method.
- Prefer one coherent design with clear assumptions over a collection of fixes for unrelated edge cases.
- Use one predeclared method across datasets, tasks, or domains. Dataset-specific branches, thresholds, prompts, tools, or post-processing are not allowed in the main method unless the paper's claim is explicitly conditional and the branching rule is defined without looking at test performance.
- In the paper, present the final method as a simple mechanism first; put engineering safeguards, optional variants, and negative design attempts in ablations or appendix.

Work-innovation ratio check:

| Question | Stop signal |
| --- | --- |
| Which new files/components are paper contributions? | Most new code is scaffolding or patches. |
| Did the one-sentence contribution become clearer? | The implementation grew but the contribution sentence did not change. |
| Can the method be explained by one mechanism? | The method needs a long list of special cases. |
| Does the same method run across all claimed datasets? | Each dataset needs its own patch, prompt, tool set, threshold, or post-processing rule. |
| Does each component survive ablation or serve reproducibility? | Components exist only because they helped one failed case. |

If implementation complexity grows faster than contribution clarity, stop adding components and simplify before running more experiments.

Literature adaptation rule:
- Do not copy a method directly from a paper. Literature provides mechanisms, assumptions, failure modes, and evaluation ideas, not drop-in templates.
- For every borrowed inspiration, state the transfer path: source paper -> extracted mechanism -> mismatch with this problem -> adaptation -> new contribution.
- Require an innovation delta: what changes because of this paper's task, data, constraints, objective, or evaluation setting?
- If the idea works only by pasting another method into the pipeline, reject it or treat it as a baseline. The main method must contain a clear adaptation that would not be obvious from the source paper alone.

Reviewer smell test: if a reviewer could describe the method as "a bag of tricks", "patchwork", or "many heuristics stacked together", simplify the method before running more experiments.

### Step 2.4: Design Baselines

Strong baselines are what separates accepted papers from rejected ones. Reviewers will ask: "Did they compare against X?"

Standard baseline categories:
- **Naive baseline**: Simplest possible approach
- **Strong baseline**: Best known existing method
- **Ablation baselines**: Your method minus one component
- **Compute-matched baselines**: Same compute budget, different allocation

Before tuning or scaling the proposed method, run the cheapest route-killing controls that could make the claimed mechanism unnecessary:

- rule-based baseline or static heuristic;
- validation selector or threshold-only selector;
- random or heuristic router/allocation;
- module-for-all, tool-for-all, or ensemble-for-all;
- compute-, label-, parameter-, API-, or wall-clock-matched baseline;
- stronger backbone without the proposed mechanism;
- ablation removing the claimed novel component.

If any route-killing control reaches the predeclared sufficiency threshold, stop optimizing the route and reframe. Do not spend hours improving a method that a simple control already explains.

### Step 2.5: Define Evaluation Protocol

Before running anything, specify:
- **Metrics**: What you're measuring, direction symbols (higher/lower better)
- **Aggregation**: How results are combined across runs/tasks
- **Statistical tests**: What tests will establish significance
- **Sample sizes**: How many runs/problems/tasks
- **Cost metrics**: GPU hours, wall-clock, API calls/tokens, tool calls, labels, human feedback, and failed-run cost when relevant
- **Evidence hierarchy**: which results are aggregate, slice-level, case-study, or diagnostic only
- **Test exposure policy**: what data is exploratory, what data is confirmatory, and when the final policy will be frozen
- **Cross-dataset uniformity**: which configuration, prompts, preprocessing, thresholds, tool set, and selection rules are shared; any allowed dataset-specific exception must be predeclared and justified by the problem statement, not by observed leaderboard gains

Track test exposure explicitly. If a design choice was made after seeing test results, mark the result as exploratory. Final paper claims need a frozen policy rerun or a clearly labeled exploratory status.

For multi-dataset papers, report both the unified method and any dataset-specific variant separately. A dataset-specific variant is an ablation or oracle-style diagnostic unless the paper's contribution is the adaptation rule itself.

### Step 2.6: Write Experiment Scripts

Follow these patterns from successful research pipelines:

**Incremental saving** 鈥?save results after each step for crash recovery:
```python
# Save after each problem/task
result_path = f"results/{task}/{strategy}/result.json"
if os.path.exists(result_path):
    continue  # Skip already-completed work
# ... run experiment ...
with open(result_path, 'w') as f:
    json.dump(result, f, indent=2)
```

**Artifact preservation** 鈥?save all intermediate outputs:
```
results/<experiment>/
  <task>/
    <strategy>/
      final_output.md          # Final result
      history.json             # Full trajectory
      pass_01/                 # Per-iteration artifacts
        version_a.md
        version_b.md
        critic.md
```

**Separation of concerns** 鈥?keep generation, evaluation, and visualization separate:
```
run_experiment.py              # Core experiment runner
run_baselines.py               # Baseline comparison
run_comparison_judge.py        # Blind evaluation
analyze_results.py             # Statistical analysis
make_charts.py                 # Visualization
```

See [references/experiment-patterns.md](references/experiment-patterns.md) for complete design patterns, cron monitoring, and error recovery.

## Phase 3: Experiment Execution & Monitoring

**Goal**: Run experiments reliably, monitor progress, recover from failures.

### Step 3.1: Launch Experiments

On Windows/Codex, prefer an attached PTY session for live monitoring. If the process must survive outside the current Codex session, start it with PowerShell and redirected logs:

```powershell
New-Item -ItemType Directory -Force logs | Out-Null
Start-Process -WindowStyle Hidden -FilePath python `
  -ArgumentList 'run_experiment.py --config config.yaml' `
  -RedirectStandardOutput logs\experiment_01.log `
  -RedirectStandardError logs\experiment_01.err `
  -PassThru
```

**Parallel execution**: Run independent experiments simultaneously, but be aware of API rate limits. 4+ concurrent experiments on the same API will slow each down.

### Step 3.3: Handle Failures

Common failure modes and recovery:

| Failure | Detection | Recovery |
|---------|-----------|----------|
| API rate limit / credit exhaustion | 402/429 errors in logs | Wait, then re-run (scripts skip completed work) |
| Process crash | PID gone, incomplete results | Re-run from last checkpoint |
| Timeout on hard problems | Process stuck, no log progress | Kill and skip, note in results |
| Wrong model ID | Errors referencing model name | Fix ID and re-run |

**Key**: Scripts should always check for existing results and skip completed work. This makes re-runs safe and efficient.

### Step 3.4: Commit Completed Results

After each experiment batch completes:

```bash
git add -A
git commit -m "Add <experiment name>: <key finding in 1 line>"
git push
```

### Step 3.5: Maintain an Experiment Journal

Git commits track what happened, but not the **exploration tree** 鈥?the decisions about what to try next based on what you learned. Maintain a structured experiment journal that captures this tree:

```json
// experiment_journal.jsonl 鈥?append one entry per experiment attempt
{
  "id": "exp_003",
  "parent": "exp_001",
  "timestamp": "2025-05-10T14:30:00Z",
  "hypothesis": "Adding scope constraints will fix convergence failure from exp_001",
  "plan": "Re-run autoreason with max_tokens=2000 and fixed structure template",
  "config": {"model": "haiku", "strategy": "autoreason", "max_tokens": 2000},
  "status": "completed",
  "result_path": "results/exp_003/",
  "key_metrics": {"win_rate": 0.85, "convergence_rounds": 3},
  "analysis": "Scope constraints fixed convergence. Win rate jumped from 0.42 to 0.85.",
  "next_steps": ["Try same constraints on Sonnet", "Test without structure template"],
  "figures": ["figures/exp003_convergence.pdf"]
}
```

**Why a journal, not just git?** Git tracks file changes. The journal tracks the reasoning: why you tried X, what you learned, and what that implies for the next experiment. When writing the paper, this tree is invaluable for the Methods section ("we observed X, which motivated Y") and for honest failure reporting.

**Selecting the best path**: When the journal shows a branching tree (exp_001 鈫?exp_002a, exp_002b, exp_003), identify the path that best supports the paper's claims. Document dead-end branches in the appendix as ablations or negative results.

**Snapshot code per experiment**: Copy the experiment script after each run:
```bash
cp experiment.py results/exp_003/experiment_snapshot.py
```
This enables exact reproduction even after subsequent code changes.

### Step 3.6: Route Kill Review

Long ML projects fail when the agent keeps optimizing small local positives after the main research claim has become weak. Run a route kill review after every major experiment batch, every 2-4 hours of autonomous exploration, or before launching any expensive sweep.

**Default stance**: stop or reframe the route unless evidence shows the next experiment can change the paper decision. Do not run an experiment only because it is easy, already scripted, or might produce another small improvement.

Before continuing a route, answer:

1. **Core claim**: What one paper claim does this route test?
2. **Decision impact**: If the next experiment succeeds, what paper decision changes?
3. **Falsification**: What result would make us stop, downgrade, or reframe this route?
4. **Controls**: What simple baseline, rule, ablation, compute-matched control, or cost-matched control could explain the same gain?
5. **Cost**: Does the method require linear API calls, GPU hours, human labels, or tool executions that would make the claimed setting unrealistic?
6. **Novelty**: Is the remaining contribution more than applying a known mechanism to a new dataset?
7. **Bottleneck**: Is the next intervention aimed at the diagnosed failure layer, or is it only another easy-to-edit post-processing variant?

If success cannot change the paper decision, do not run the experiment. If the only answer is "it might help a bit," stop and audit the route.

Negative or mixed ablations are route evidence, not writing inconveniences. If
the Result Auditor marks a core claim as contradicted, or if the ablation kill
rule says a module is unsupported, the route status becomes `red` until the
Coordinator either weakens the claim, redesigns the mechanism, or reframes the
work as analysis/negative evidence. Do not proceed to manuscript expansion while
route status is `red` or `dead`.

#### Experiment License

No experiment may run unless it has a license:

```markdown
## Experiment License

- Experiment:
- Claim tested:
- Primary metric(s):
- Secondary metric(s):
- Dataset/task scope:
- Compared baseline or variant:
- Expected direction:
- Minimum practical effect size:
- Success criterion:
- Partial-support criterion:
- Kill/reframe criterion:
- Current route status: green / yellow / red / dead
- Simple control or ablation compared:
- Expected cost:
- Continue condition:
- Stop condition:
- Paper decision affected:
- Test exposure: exploratory / confirmatory / frozen-policy rerun
```

If failure has no stop consequence or the kill/reframe criterion is empty,
redesign the experiment. If success only adds another local positive case, do
not run it unless the paper is explicitly a case-study or diagnostic analysis.

#### Autonomous Experiment License / Preapproved Kill-Test Mode

Use this mode when the scientist has already approved a concrete route plus boundaries. The approval does not need to be a magic phrase; it must specify enough scope to keep the agent inside a safe research lane.

Preapproval can cover:
- writing the route design document;
- writing the Experiment License;
- writing TDD tests for the minimal kill test;
- implementing only the minimal code needed for the kill test;
- running low-cost exploratory experiments inside the declared datasets, metrics, and budget;
- updating the route status based on the predeclared stop and continue conditions.

Preapproval must include:

```markdown
## Autonomous Experiment License

- Approved route:
- Main mechanism claim:
- Allowed datasets/tasks:
- Primary metric(s):
- Secondary metric(s):
- Allowed implementation changes:
- Allowed experiment scale:
- Cost/time budget:
- Continue condition:
- Stop condition:
- Simple controls that can kill the route:
- Dataset-specific patching rule:
- Claim changes allowed without reapproval: none / minor wording only / specified below
- Required artifacts: design doc / Experiment License / TDD kill test / result summary / route decision
```

When this license exists, do not stop only to ask for repeated human confirmation before writing the design, license, TDD kill test, or low-cost run. Continue autonomously until a stop condition, budget boundary, scope boundary, or claim boundary is reached.

This mode does not override safety or research integrity. Stop and report before continuing if:
- a simple rule, static baseline, compute-matched control, or ablation reaches the predeclared sufficiency threshold;
- the method improves only a secondary metric while the primary metric stays flat or worsens;
- different datasets require different unprincipled configs, prompts, thresholds, modules, or post-processing;
- the route needs a broader claim, a different paper framing, or a new main mechanism;
- the required experiment scale exceeds the license;
- the method starts to look like patchwork rather than one clean mechanism;
- repeated post-processing attempts fail or only move secondary metrics before the Root-Cause Innovation Gate has been rerun;
- new literature or downloaded paper evidence makes the contribution obvious, copied, or already solved.

If a process skill asks for human approval after this license is already granted, treat the license as the approval for all listed actions. Ask again only when the next action falls outside the license.

#### Pre-register Stop Conditions

Every active route must define stop conditions before more experiments are run. Use task-specific numbers when possible.

| Risk | Generic stop condition |
| --- | --- |
| Weak effect | The route improves the primary metric by less than the predeclared minimum practical effect size. |
| Sparse usefulness | The route helps only a small minority of tasks/examples and does not improve the aggregate claim enough to justify added complexity. |
| Simple control catches up | A rule-based, static, random, oracle-free, or compute-matched control reaches a predeclared fraction of the proposed method's performance. |
| Tool or compute overuse | The route's gain disappears under equal budget, equal tool calls, equal labels, equal parameters, or equal wall-clock constraints. |
| Cherry-pick risk | Gains appear only on a hand-picked slice and fail on the predeclared broader slice. |
| Dataset patching | Different datasets require different unprincipled configs, prompts, thresholds, modules, or post-processing to make the method look strong. |
| Metric mismatch | The route improves a secondary metric while the paper's primary metric or required deployment metric stays flat or worsens. |
| Wrong intervention layer | Repeated post-processing changes fail while evidence points to base, objective, data, or evaluation failure. |
| Test-set overfitting | Strategy changes are repeatedly made after inspecting test results without a frozen-policy rerun. |
| Novelty collapse | The contribution can only be described as "we also used method X on dataset Y" after related-work comparison. |
| Patchwork smell | New components are added because individual experiments improved, but they do not follow from one coherent mechanism. |

#### Evidence Hierarchy

Keep result types separate. Do not use a weaker evidence type to rescue a stronger claim.

| Evidence type | Can support | Cannot support |
| --- | --- | --- |
| Aggregate benchmark result | Main performance claim if protocol is frozen and baselines are strong | Mechanism claim without ablations/controls |
| Predeclared slice result | Conditional or subgroup claim | Broad benchmark dominance |
| Case study | Explanation, intuition, failure analysis | Aggregate superiority |
| Diagnostic metric | Mechanism plausibility | Deployment-ready performance |
| Exploratory test result | Hypothesis generation | Final headline claim without frozen rerun |

Case studies can explain a mechanism, but they cannot rescue a failed aggregate claim. A metric improvement is not a contribution unless it validates, reveals, or depends on a new mechanism.

#### Negative Evidence Log

Append a negative-evidence entry after each batch, even when the headline result is positive:

```markdown
## Negative Evidence: <route name>

- Core claim under test:
- New results that support the claim:
- New results that weaken or falsify the claim:
- Simple controls that now look competitive:
- Cost, API, label, or compute concerns:
- Cross-dataset uniformity concern:
- Related-work novelty concern:
- Test exposure concern:
- Evidence type: aggregate / slice / case / diagnostic / exploratory
- Stop conditions triggered:
- Route status: green / yellow / red / dead
- Allowed next action:
```

Route status meanings:

| Status | Meaning | Allowed next action |
| --- | --- | --- |
| `green` | Core claim still supported and next experiment can change the paper decision. | Continue with predeclared experiments. |
| `yellow` | Evidence is mixed or controls are competitive. | Run only decisive control, ablation, cost, or broader-slice experiments. |
| `red` | Main claim is probably not defensible as stated. | Stop local optimization; reframe, simplify, or write a negative result. |
| `dead` | Stop conditions are met and no paper-safe reframing remains. | Archive as negative evidence; do not spend more compute. |

#### Adversarial Route Auditor

For long or expensive projects, assign a separate adversarial auditor before more experiments. Its job is to reject weak routes, not rescue them.

The auditor must check:

- whether the method is a wrapper around an existing baseline;
- whether a simple rule or validation selector explains the gain;
- whether positive results are sparse, cherry-picked, or metric-shifted;
- whether the claimed method silently changes across datasets, tasks, domains, or benchmarks;
- whether added components are patchwork rather than a coherent method;
- whether API calls, labels, human feedback, or compute make the method unrealistic;
- whether related work already makes the contribution obvious;
- whether the next experiment can change the route status.

If the auditor cannot name a decisive experiment, downgrade the route to `red` and stop optimization.

#### Negative-Result Fallback

Every route needs a failure path before long exploration starts. Define what the work becomes if the main method fails:

- a negative result testing a popular assumption;
- an analysis paper explaining why the assumed mechanism fails;
- a benchmark or evaluation protocol contribution;
- a strong baseline/control paper;
- an appendix ablation that motivates a different main route.

The agent's job is not to keep the project alive; it is to make the truth cheaper to discover.

#### Failed Route Transition and Direction Selection

When a route becomes `red` or `dead`, do not immediately invent a new direction. First convert the failure into literature-grounded search constraints, then select the next direction from a candidate pool.

Complete this transition before launching any new route:

```markdown
## Failed Route Transition

- Failed route:
- Core claim that failed:
- Failure root cause: mechanism false / baseline too strong / metric mismatch / cost unrealistic / sparse positive cases / novelty collapse / implementation issue / other
- Evidence that supports this diagnosis:
- What remains reusable: result, baseline, diagnostic, dataset slice, failure case, evaluation protocol, code, or negative result
- Same-family papers to revisit:
- Local papers or notes that must be read before choosing the next route:
- Problem-specific search lenses generated from the failure:
- New search queries generated from the failure:
- Candidate directions considered:
- Selected direction:
- Why this direction avoids the previous failure:
- Why this direction is not a direct copy of a same-family paper:
- Cheapest experiment that could kill the new direction:
```

A new direction is allowed only if it passes all of these checks:

| Check | Requirement |
| --- | --- |
| Literature grounded | It cites entries from the Similar-Paper Matrix and identifies a shared limitation, mismatch, or unresolved tension. |
| Failure avoiding | It states how it avoids the root cause of the failed route. |
| Mechanism changing | It changes the mechanism, claim, evaluation, or problem framing; it is not just a new patch, dataset, prompt, threshold, or module. |
| Problem-specific search | It uses search lenses derived from the failed route, not only the old matrix or the agent's prior knowledge. |
| Clean method path | It can plausibly become one coherent method rather than a pile of fixes. |
| Cheap falsification | It has a low-cost decisive experiment before any full pipeline or expensive sweep. |
| Paper fallback | If it fails, it still produces a useful negative result, analysis, benchmark, or baseline insight. |

Generate at least 2-4 candidate directions unless the failure uniquely implies a negative-result or benchmark paper. Rank them with:

| Candidate | Literature gap | Avoids failed root cause | Innovation delta | Clean-method plausibility | Cheapest kill test | Paper fallback |
| --- | --- | --- | --- | --- | --- | --- |

Prefer the candidate with the strongest literature gap, clearest mechanism change, and cheapest decisive test. Do not choose a direction because it is already scripted, locally promising, or easy to patch into the existing code.

If the failure reveals that the original matrix was too generic, rebuild the Problem-Specific Snapshot and Search Lens Plan before selecting the next route. A failed route should narrow the next search: which assumption broke, which constraint mattered, which evaluation hid the issue, and which adjacent field has already handled a structurally similar bottleneck?

#### Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "We already spent many hours; one more sweep might work." | Sunk cost is not evidence. Run only experiments that can change the route decision. |
| "There are some positive cases." | Local positives do not support a broad ML claim unless they survive the predeclared aggregate, slice, and control tests. |
| "The benchmark improved, so the contribution is real." | Metric gains are not contributions unless they require or reveal the claimed mechanism under fair baselines. |
| "Dataset A just needs a different patch." | Per-dataset patching is leaderboard fitting. Use one predeclared method or report dataset-specific variants as diagnostics/ablations. |
| "The method is complex because the problem is complex." | Complexity must follow from one coherent mechanism and ablations, not from accumulated patches. |
| "The baseline is strong, so small gains are enough." | Small gains need statistical significance, practical effect size, and fair cost comparison. |
| "The expensive version is acceptable for research." | If cost matters to the claimed setting, evaluate equal-budget or report the method as diagnostic/offline only. |
| "We can discuss related work later." | Related work is a design constraint. If it makes the contribution obvious, stop before more experiments. |
| "This test result guided the method, but it is still fine for the main table." | Test-guided design is exploratory. Freeze the policy and rerun, or label the claim honestly. |
| "A negative result means the project failed." | A clean negative result or route diagnosis can become the paper if it answers an important community assumption. |
| "Let's brainstorm a new idea from scratch." | New directions must come from failed-route evidence plus the Similar-Paper Matrix, not from unguided intuition. |
| "The old matrix is enough; just pick another row." | Rebuild the Problem-Specific Snapshot and Search Lens Plan from the actual failure before selecting a new route. |

---

## Phase 4: Result Analysis

**Goal**: Extract findings, compute statistics, identify the story.

### Step 4.1: Aggregate Results

Write analysis scripts that:
1. Load all result files from a batch
2. Compute per-task and aggregate metrics
3. Generate summary tables

```python
# Standard analysis pattern
import json, os
from pathlib import Path

results = {}
for result_file in Path("results/").rglob("result.json"):
    data = json.loads(result_file.read_text())
    strategy = result_file.parent.name
    task = result_file.parent.parent.name
    results.setdefault(strategy, {})[task] = data

# Compute aggregate metrics
for strategy, tasks in results.items():
    scores = [t["score"] for t in tasks.values()]
    print(f"{strategy}: mean={np.mean(scores):.1f}, std={np.std(scores):.1f}")
```

### Step 4.2: Statistical Significance

Always compute:
- **Error bars**: Standard deviation or standard error, specify which
- **Confidence intervals**: 95% CI for key results
- **Pairwise tests**: McNemar's test for comparing two methods
- **Effect sizes**: Cohen's d or h for practical significance

See [references/experiment-patterns.md](references/experiment-patterns.md) for complete implementations of McNemar's test, bootstrapped CIs, and Cohen's h.

### Step 4.3: Identify the Story

After analysis, explicitly answer:
1. **What is the main finding?** State it in one sentence.
2. **What surprised you?** Unexpected results often make the best papers.
3. **What failed?** Failed experiments can be the most informative. Honest reporting of failures strengthens the paper.
4. **What follow-up experiments are needed?** Results often raise new questions.

#### Handling Negative or Null Results

When your hypothesis was wrong or results are inconclusive, you have three options:

| Situation | Action | Venue Fit |
|-----------|--------|-----------|
| Hypothesis wrong but **why** is informative | Frame paper around the analysis of why | NeurIPS, ICML (if analysis is rigorous) |
| Method doesn't beat baselines but **reveals something new** | Reframe contribution as understanding/analysis | ICLR (values understanding), workshop papers |
| Clean negative result on popular claim | Reframe only with explicit user approval and frozen paper-type update | Result-audit and manuscript-intent gates |
| Results inconclusive, no clear story | Pivot 鈥?run different experiments or reframe | Don't force a paper that isn't there |

**How to write a negative results paper:**
- Lead with what the community believes and why it matters to test it
- Describe your rigorous methodology (must be airtight 鈥?reviewers will scrutinize harder)
- Present the null result clearly with statistical evidence
- Analyze **why** the expected result didn't materialize
- Discuss implications for the field

### Step 4.4: Create Figures and Tables

**Figures**:
- Use vector graphics (PDF) for all plots: `plt.savefig('fig.pdf')`
- Colorblind-safe palettes (Okabe-Ito or Paul Tol)
- Self-contained captions 鈥?reader should understand without main text
- No title inside figure 鈥?the caption serves this function

**Tables**:
- Use `booktabs` LaTeX package
- Bold best value per metric
- Include direction symbols (higher/lower better)
- Consistent decimal precision

```latex
\usepackage{booktabs}
\begin{tabular}{lcc}
\toprule
Method & Accuracy $\uparrow$ & Latency $\downarrow$ \\
\midrule
Baseline & 85.2 & 45ms \\
\textbf{Ours} & \textbf{92.1} & 38ms \\
\bottomrule
\end{tabular}
```

### Step 4.5: Post-Main Experiment Expansion Gate

The main experiment is not the whole Experiments section. It is the gate that decides whether the route deserves a full paper-grade evidence package.

Only enter expansion after the main experiment is **claim-sufficient**:

- It reaches the predeclared expected performance or minimum practical effect size.
- It beats or matches the relevant strong baselines under the declared cost, compute, label, or data budget.
- It supports the core paper claim as written, not merely a weaker local positive.
- The result is stable enough for the venue standard: appropriate seeds, confidence intervals, statistical tests, or repeated runs.
- The final method, prompts, thresholds, preprocessing, and selection rules are frozen or clearly marked exploratory.
- The result can be explained by the proposed mechanism rather than by a simple control, test-set tuning, or dataset-specific patch.

If the main experiment only shows a positive signal but does not meet the expected performance or cannot support the claim, do not run a decorative experiment package. Return to Phase 2 or Phase 3 to simplify, reframe, strengthen baselines, adjust the claim, or kill the route.

Once the main experiment is claim-sufficient, plan the paper's extended experiment matrix before drafting:

| Experiment type | Question it answers | Typical paper role |
| --- | --- | --- |
| Main comparison rerun | Does the central result survive the final frozen protocol? | Main table or headline figure |
| Ablation study | Which components are necessary for the claimed mechanism? | Mechanism evidence |
| Simple-control test | Could a cheaper heuristic, selector, or stronger backbone explain the gain? | Reviewer defense |
| Parameter sensitivity | Does the method depend on a fragile threshold, prompt, hyperparameter, or budget? | Robustness evidence |
| Scaling or budget curve | How does performance change with model size, data, compute, API calls, labels, or iterations? | Practical tradeoff |
| Slice or subgroup analysis | Where does the method work or fail across tasks, datasets, domains, difficulty levels, or input types? | Boundary conditions |
| Robustness or distribution shift | Does the method survive perturbations, alternate splits, new datasets, or harder cases? | Generality evidence |
| Claim-verification diagnostic | Does an internal metric or controlled test validate the mechanism, not just the outcome? | Causal or mechanistic support |
| Visualization | Can readers see the behavior the method changes? | Intuition and Figure 1/Figure 3 support |
| Qualitative examples | What does success and failure look like in concrete cases? | Interpretability and limitations |
| Cost and efficiency | Is the gain worth the added compute, latency, labels, tools, or API calls? | Deployment realism |
| Failure case analysis | When should the method not be used? | Limitations and honest scope |

Create this expansion plan:

```markdown
## Post-Main Experiment Expansion Plan

- Core claim already supported by main experiment:
- Main result threshold reached:
- Frozen protocol or exploratory status:
- Primary result files:
- Experiments required for the main paper:
- Experiments suitable for appendix:
- Experiments intentionally omitted and why:
- Reviewer concern each experiment answers:
- Expected figure/table for each experiment:
- Budget and time estimate:
```

**Rule**: an expansion experiment must either support a specific paper claim, answer a likely reviewer objection, define a boundary condition, or improve reproducibility. Do not add experiments just because they are easy to run.

### Step 4.6: Project Phase Projection and Paper-Readiness Gate

The research workflow should not remain a pile of local compliance checks. Project the global Phase 0-7 pipeline into the current paper so the agent knows what stage the project is in, what actions are allowed now, what is blocked, and what would force a rollback.

Maintain a project-level status file when the repository supports it:

```markdown
# paper/status.md

Paper: <name>
Venue: <target venue and page limit>
Status: Phase <N> - <short state label>

## Current phase
- Current phase:
- Why this phase is correct:
- Previous phase completed evidence:
- Next gate to pass:

## Core research state
- One-sentence contribution:
- Main claim status: draft / frozen / needs reframe
- Main experiment status: not run / exploratory / claim-sufficient / failed
- Expansion experiment status: blocked / planned / running / complete
- Writing status: not started / rough drafting / evidence-grounded drafting / second-pass refinement / submission prep

## Allowed actions now
- [action]

## Blocked actions now
- [action]

## Rollback triggers
- [trigger]

## Missing artifacts
- [artifact]
```

Use these phase definitions:

| Phase | Name | Entry condition | Allowed actions | Blocked actions | Rollback trigger |
| --- | --- | --- | --- | --- | --- |
| 0 | Setup | Repo, budget, artifact plan, and contribution traceability are initialized. | Read code, collect artifacts, map task, define budget. | Final writing and decorative experiments. | Missing workspace, budget, or artifact traceability. |
| 1 | Contribution Definition | One-sentence contribution, core claim, success criteria, and kill conditions are written. | Literature search, baseline planning, route comparison, design docs. | Main experiment launch without claim and kill criteria. | Claim remains vague or contradictory. |
| 2 | Main Experiment | Main experiment and route-killing controls are licensed and designed. | TDD kill tests, minimal implementation, low-cost pilots, fair baselines. | Full polishing, final abstract, broad narrative freeze. | Simple control catches up, cost unrealistic, or mechanism collapses. |
| 3 | Claim-Sufficient Analysis | Main experiment is run and evaluated against the frozen claim. | Frozen reruns, claim audit, route decision, expansion planning. | Decorative expansions, final framing if claim-sufficient is false. | Primary metric flat, simple rule catches up, or dataset patching required. |
| 4 | Expansion Experiments | Main experiment is claim-sufficient and expansion plan exists. | Ablations, sensitivity, robustness, visualization, practicality, limitations evidence. | Starting second-pass prose polish before evidence package exists. | Expansion evidence contradicts the claim or reveals patchwork. |
| 5 | Evidence-Grounded Drafting | Main claim and required experiments are sufficiently supported for a full draft. | Draft Methods, Results, Related Work, rough Intro/Abstract, Figure 1, limitations, appendix plan. | Submission-ready wording, final polishing, irreversible narrative overclaiming. | Claim-support gaps reappear or key evidence is missing. |
| 6 | Second-Pass Refinement | Full draft exists and paper-level evidence package is complete. | Global consistency pass, wording polish, figure/table alignment, reviewer simulation, claim verification. | Submission packaging before review fixes land. | Simulated review exposes critical technical or evidence gaps. |

Minimum artifacts for entering each late phase:

| Phase to enter | Must already exist |
| --- | --- |
| Phase 4 | claim-sufficient main experiment, route decision, Post-Main Experiment Expansion Plan |
| Phase 5 | experiment_log.md, figure inventory, claim-by-claim evidence package, limitations direction |
| Phase 6 | full draft, Figure 1, limitations section, practicality/cost evidence, compute budget summary, traceability audit |

### Step 4.7: Decide: More Experiments or Write?

| Situation | Action |
|-----------|--------|
| Core claims supported, main experiment is claim-sufficient, and expansion matrix is planned | Run required expansion experiments, update `paper/status.md`, then move to Phase 5 |
| Results inconclusive, need more data | Back to Phase 2 (design) |
| Unexpected finding suggests new direction | Back to Phase 2 (design) |
| Missing one ablation reviewers will ask for | Run it, then Phase 5 |
| Non-core auxiliary experiments failed but core claims remain supported | Note failures and boundaries, then move to Phase 5 |
| Core ablation or primary metric contradicts the claimed mechanism | Back to Phase 2/3 for reframe, redesign, or route kill; do not move to Phase 5 |

### Step 4.8: Write the Experiment Log (Bridge to Writeup)

Before moving to paper writing, create a structured experiment log that bridges results to prose. This is the single most important connective tissue between experiments and the writeup 鈥?without it, the writing agent has to re-derive the story from raw result files.

**Create `experiment_log.md`** with the following structure:

```markdown
# Experiment Log

## Contribution (one sentence)
[The paper's main claim]

## Experiments Run

### Experiment 1: [Name]
- **Claim tested**: [Which paper claim this supports]
- **Setup**: [Model, dataset, config, number of runs]
- **Key result**: [One sentence with the number]
- **Result files**: results/exp1/final_info.json
- **Figures generated**: figures/exp1_comparison.pdf
- **Surprising findings**: [Anything unexpected]

### Experiment 2: [Name]
...

## Figures
| Filename | Description | Which section it belongs in |
|----------|-------------|---------------------------|
| figures/main_comparison.pdf | Bar chart comparing all methods on benchmark X | Results, Figure 2 |
| figures/ablation.pdf | Ablation removing components A, B, C | Results, Figure 3 |
...

## Failed Experiments (document for honesty)
- [What was tried, why it failed, what it tells us]

## Open Questions
- [Anything the results raised that the paper should address]
```

**Why this matters**: When drafting, the agent (or a delegated sub-agent) can load `experiment_log.md` alongside the LaTeX template and produce a first draft grounded in actual results. Without this bridge, the writing agent must parse raw JSON/CSV files and infer the story 鈥?a common source of hallucinated or misreported numbers.

**Git discipline**: Commit this log alongside the results it describes.

---

## Phase 5: Paper Drafting

**Goal**: Write a complete, publication-ready paper.

### Drafting Release Rules

Phase 5 is not one undifferentiated writing mode. Distinguish rough drafting from evidence-grounded drafting and from second-pass polish:

| Writing mode | Minimum phase/state | Allowed now | Not allowed yet |
| --- | --- | --- | --- |
| Rough drafting | Phase 1+ | Methods notes, related-work map, figure sketches, provisional section scaffolds, appendix placeholders | Final abstract wording, frozen contribution bullets, polished discussion, submission-ready narrative |
| Evidence-grounded drafting | Phase 5 | Full Methods, Results, Related Work, rough Intro/Abstract, Figure 1, limitations, practicality section, appendix plan | Second-pass refinement, final title tuning, final reviewer-facing framing if evidence package is incomplete |
| Second-pass refinement | Phase 6 | Global consistency edits, redundancy cuts, terminology alignment, final abstract/introduction polish, figure-caption alignment | Submission packaging before self-review and claim verification close critical issues |

Before any drafting session, read `paper/status.md` or the active project status note. If the status file says the project is below Phase 5, do not behave as though the paper is already in full-draft mode.

### Context Management for Large Projects

A paper project with 50+ experiment files, multiple result directories, and extensive literature notes can easily exceed the agent's context window. Manage this proactively:

**What to load into context per drafting task:**

| Drafting Task | Load Into Context | Do NOT Load |
|---------------|------------------|-------------|
| Writing Introduction | `experiment_log.md`, contribution statement, failure-to-mechanism map, 5-10 most relevant paper abstracts | Raw result JSONs, full experiment scripts, all literature notes |
| Writing Methods | Experiment configs, pseudocode, architecture description | Raw logs, results from other experiments |
| Writing Results | `experiment_log.md`, result summary tables, figure list | Full analysis scripts, intermediate data |
| Writing Related Work | `paper_index`, reading notes, Similar-Paper Matrix, .bib file | Experiment files, raw PDFs |
| Revision pass | Full paper draft, specific reviewer concerns | Everything else |

**Principles:**
- **`experiment_log.md` is the primary context bridge** 鈥?it summarizes everything needed for writing without loading raw data files (see Step 4.8)
- **Load one section's context at a time** when delegating. A sub-agent drafting Methods doesn't need the literature review notes.
- **Summarize, don't include raw files.** For a 200-line result JSON, load a 10-line summary table. For a 50-page related paper, load the 5-sentence abstract + your 2-line note about its relevance.
- **For very large projects**: Create a `context/` directory with pre-compressed summaries:
  ```
  context/
    contribution.md          # 1 sentence
    experiment_summary.md    # Key results table (from experiment_log.md)
    literature_map.md        # Organized citation notes
    figure_inventory.md      # List of figures with descriptions
  ```

### The Narrative Principle

**The single most critical insight**: Your paper is not a collection of experiments 鈥?it's a story with one clear contribution supported by evidence.

Every successful ML paper centers on what Neel Nanda calls "the narrative": a short, rigorous, evidence-based technical story with a takeaway readers care about.

**Three Pillars (must be crystal clear by end of introduction):**

| Pillar | Description | Test |
|--------|-------------|------|
| **The What** | 1-3 specific novel claims | Can you state them in one sentence? |
| **The Why** | Rigorous empirical evidence | Do experiments distinguish your hypothesis from alternatives? |
| **The So What** | Why readers should care | Does this connect to a recognized community problem? |

**If you cannot state your contribution in one sentence, you don't yet have a paper.**

### The Sources Behind This Guidance

This skill synthesizes writing philosophy from researchers who have published extensively at top venues. The writing philosophy layer was originally compiled by [Orchestra Research](https://github.com/orchestra-research) as the `ml-paper-writing` skill.

| Source | Key Contribution | Link |
|--------|-----------------|------|
| **Neel Nanda** (Google DeepMind) | The Narrative Principle, What/Why/So What framework | [How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers) |
| **Sebastian Farquhar** (DeepMind) | 5-sentence abstract formula | [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/) |
| **Gopen & Swan** | 7 principles of reader expectations | [Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf) |
| **Zachary Lipton** | Word choice, eliminating hedging | [Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/) |
| **Jacob Steinhardt** (UC Berkeley) | Precision, consistent terminology | [Writing Tips](https://bounded-regret.ghost.io/) |
| **Ethan Perez** (Anthropic) | Micro-level clarity tips | [Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/) |
| **Andrej Karpathy** | Single contribution focus | Various lectures |

**For deeper dives into any of these, see:**
- [references/writing-guide.md](references/writing-guide.md) 鈥?Full explanations with examples
- [references/sources.md](references/sources.md) 鈥?Complete bibliography

### Time Allocation

Spend approximately **equal time** on each of:
1. The abstract
2. The introduction
3. The figures
4. Everything else combined

**Why?** Most reviewers form judgments before reaching your methods. Readers encounter your paper as: title 鈫?abstract 鈫?introduction 鈫?figures 鈫?maybe the rest.

### Writing Workflow

```
Paper Writing Checklist:
- [ ] Step 1: Define the one-sentence contribution
- [ ] Step 2: Draft Figure 1 (core idea or most compelling result)
- [ ] Step 3: Draft abstract (5-sentence formula)
- [ ] Step 4: Draft introduction (1-1.5 pages max)
- [ ] Step 5: Draft methods
- [ ] Step 6: Draft experiments & results
- [ ] Step 7: Draft related work
- [ ] Step 8: Draft conclusion & discussion
- [ ] Step 9: Draft limitations (REQUIRED by all venues)
- [ ] Step 10: Plan appendix (proofs, extra experiments, details)
- [ ] Step 11: Complete paper checklist
- [ ] Step 12: Final review
```

### Two-Pass Refinement Pattern

When drafting with an AI agent, use a **two-pass** approach (proven effective in SakanaAI's AI-Scientist pipeline):

**Pass 1 鈥?Write + immediate refine per section:**
For each section, write a complete draft, then immediately refine it in the same context. This catches local issues (clarity, flow, completeness) while the section is fresh.

**Pass 2 鈥?Global refinement with full-paper context:**
After all sections are drafted, revisit each section with awareness of the complete paper. This catches cross-section issues: redundancy, inconsistent terminology, narrative flow, and gaps where one section promises something another doesn't deliver.

```
Second-pass refinement prompt (per section):
"Review the [SECTION] in the context of the complete paper.
- Does it fit with the rest of the paper? Are there redundancies with other sections?
- Is terminology consistent with Introduction and Methods?
- Can anything be cut without weakening the message?
- Does the narrative flow from the previous section and into the next?
Make minimal, targeted edits. Do not rewrite from scratch."
```

### Step 5.0: Title

The title is the single most-read element of the paper. It determines whether anyone clicks through to the abstract.

**Good titles**:
- State the contribution or finding: "Semantic-Preserving Executor Evolution for Stale Attacker Knowledge"
- Highlight a surprising result: "Scaling Data-Constrained Language Models" (implies you can)
- Name the method + what it does: "DPO: Direct Preference Optimization of Language Models"

**Bad titles**:
- Too generic: "An Approach to Improving Language Model Outputs"
- Too long: anything over ~15 words
- Jargon-only: "Asymptotic Convergence of Iterative Stochastic Policy Refinement" (who is this for?)

**Rules**:
- Include your method name if you have one (for citability)
- Include 1-2 keywords reviewers will search for
- Avoid colons unless both halves carry meaning
- Test: would a reviewer know the domain and contribution from the title alone?

### Step 5.1: Abstract (5-Sentence Formula)

From Sebastian Farquhar (DeepMind):

```
1. What you achieved: "We introduce...", "We prove...", "We demonstrate..."
2. Why this is hard and important
3. How you do it (with specialist keywords for discoverability)
4. What evidence you have
5. Your most remarkable number/result
```

**Delete** generic openings like "Large language models have achieved remarkable success..."

### Step 5.2: Figure 1

Figure 1 is the second thing most readers look at after the abstract. Plan it after the paper claim, section contract, and method mechanism are clear.

| Figure 1 Type | When to Use | Example |
|---------------|-------------|---------|
| **Method diagram** | New architecture or pipeline | TikZ flowchart showing your system |
| **Results teaser** | One compelling result tells the whole story | Bar chart: "Ours vs baselines" with clear gap |
| **Problem illustration** | The problem is unintuitive | Before/after showing failure mode you fix |
| **Conceptual diagram** | Abstract contribution needs visual grounding | 2x2 matrix of method properties |

**Rules**: Figure 1 must be understandable without reading any text. The caption alone should communicate the core idea. Use color purposefully 鈥?don't just decorate.

### Step 5.3: Introduction (1-1.5 pages max)

The introduction must explain why the method is necessary, not present the method as a parts list.

Must include:
- Clear problem statement
- Brief approach overview
- 2-4 bullet contribution list (max 1-2 lines each in two-column format)
- Methods should start by page 2-3

For ML method papers, especially multi-component methods that risk looking like module stacking, use the **Failure-to-Mechanism Introduction Pattern** unless a different structure is clearly better.

**Core chain**:
```
Existing assumption -> real-world counterexample -> failure phenomenon -> mechanism gap -> proposed module
```

**Default 5-part structure**:

1. **Broad background**: Define the task, why it matters, and why it remains hard. Do not introduce the paper's method or modules here.
2. **Existing paradigm and failure phenomenon**: State the mainstream paradigm, its core assumption, when it works, and the real-world counterexample where it fails. End with one explicit failure-summary sentence.
3. **Mechanism-gap attribution**: Convert the failure phenomenon into 2-3 mechanism gaps, preferably as `(i)`, `(ii)`, `(iii)`. Do not merely repeat the previous paragraph's failure description.
4. **Method mapping**: Introduce the proposed method by mapping each module to a mechanism gap. Every gap from part 3 must have a corresponding solution, and every module in part 4 must have a problem source in part 3.
5. **Contribution list**: Compress contributions to 2-4 factual bullets, usually 3. Say what is proposed and which mechanism problem it addresses; avoid promotional wording such as "significantly improves", "fully proves", or "effectively validates" unless the evidence directly supports that strength.

**Do not write**:
```
We propose module A, module B, and module C.
```

**Prefer**:
```
To address gap (i), we design A. To mitigate gap (ii), we introduce B. To incorporate gap (iii) in a controlled way, we develop C.
```

**Introduction quality gate**:
- A section contract exists before drafting and the planned-vs-produced audit
  passes before integration.
- Paragraph 1 covers task importance and general challenge without introducing the method.
- Paragraph 2 names the existing paradigm, acknowledges when it works, states its assumption, and ends with a concrete failure-summary sentence.
- Paragraph 3 lifts the failure into mechanism gaps instead of repeating the surface phenomenon.
- The `(i)/(ii)/(iii)` gaps map one-to-one to method modules or design choices.
- The method overview explains why each module exists, not only what it is.
- Contributions are short, factual, and bounded by the available evidence.
- Abstract and Introduction use paper-facing mechanism names, not internal
  control-plane language. Do not expose code identifiers, `score_mode` values,
  experiment route names, "promoted route", window/step sizes, or routine
  hyperparameter settings here; move those details to Methods, Experiments, or
  Reproducibility unless they are the paper's central claim.

### Step 5.4: Methods

The Methods/Methodology section must explain the design logic of the method,
not merely replay the code path. A reader should understand what problem the
method addresses, why each design exists, how variables flow from input to
output, and how the design forms a closed modeling mechanism.

**Default structure**:

1. **Problem Formulation**: Define the task, input, output, training data,
   assumptions, and learning/scoring objective. Do not introduce method modules
   here.
2. **Method Overview**: Explain the full mechanism from input to final output.
   Establish the main line; do not list module names without explaining their
   role.
3. **Core Modules**: For each core module, state the design motivation, input,
   output, mathematical definition, mechanism effect, and how its output feeds
   the next module.
4. **Training Objective / Inference Procedure**: Clearly separate training-time
   fitting, calibration, and test-time inference or scoring. State what data and
   labels, if any, are used at each stage.
5. **Algorithm or Complexity Analysis**: Include pseudocode, complexity, or
   inference-cost analysis only when the algorithmic flow or cost is central to
   the paper.

**Module writing rule**:
Every core module should follow a problem -> design -> mechanism -> output
chain:
- what specific issue the module addresses;
- what input it receives;
- what output it produces;
- how the formula defines that output;
- what mechanism or constraint the formula creates;
- how the output is consumed by the next module.

Do not present Methods as "module A, module B, module C" without design
necessity and input-output connections.

**Formula rule**:
Before every equation, explain what object it defines, where its variables come
from, and why the definition is needed. After every equation, explain the
formula's output, mechanism effect, and later use. Keep symbols consistent with
figures, algorithms, experiments, and implementation. Delete formulas that do
not define the core mechanism.

**Design-motivation rule**:
Motivations must name a specific modeling object, constraint, evidence source,
or train-test decision mismatch. Avoid empty motives such as "improve
performance", "enhance representation learning", or "capture complex patterns."
Prefer forms like "To model [specific dependency]...", "To constrain [specific
representation]...", "To reduce dependence on [single evidence source]...", or
"To align [training objective] with [test-time decision]...".

**Method-experiment alignment**:
Every design emphasized as core in Methods needs corresponding evidence in
Experiments: an ablation, replacement comparison, parameter sensitivity,
mechanism diagnostic, visualization, or case study. Conversely, each ablation
should map back to a concrete design in Methods. Method claims must not exceed
what experiments can verify.

**Implementation-detail boundary**:
Core Methods should not pile up routine engineering settings. Window length,
batch size, learning rate, optimizer, epochs, seeds, hardware, and framework
versions belong in Experiments, Implementation Details, Reproducibility, or the
appendix unless the setting is itself the method. If a detail determines the
method's mechanism, keep it in Methods; if it merely reproduces the run, move it
out.

**Naming rule**:
Do not invent acronyms for ordinary operations. Usually keep one method name,
two or three core mechanism names at most, and one objective or scoring rule
name only if it is central. Do not package simple concatenation, MLPs, standard
attention, or routine preprocessing as major innovations.

**Methods quality gate**:
- A section contract exists before drafting and the planned-vs-produced audit
  passes before integration.
- Problem formulation is separate from method details.
- Each core module states motivation, input, output, formula, mechanism effect,
  and downstream connection.
- Training/calibration/inference stages and label usage are explicit.
- Symbols match the figure, equations, experiments, and code-facing
  terminology.
- Routine implementation settings are not mixed into core method logic.
- Core modules are matched by ablations, diagnostics, sensitivity, or case
  studies in Experiments.

### Step 5.5: Experiments & Results

Experiments verify the paper's core claims. They are not an inventory of every
run. Organize the section around experimental conditions, main results, module
contributions, further analysis, and interpretable evidence. Every conclusion
must be tied to a table, metric, dataset, visual pattern, or explicitly named
case; do not generalize beyond the evidence.

Before drafting, build a claim-evidence map:

| Claim type | Required evidence |
| --- | --- |
| Overall effectiveness | Main comparison table under a fixed protocol |
| Module contribution | Removal, replacement, or incremental ablation |
| Mechanism behavior | Diagnostics, intermediate variables, visualization, or cases |
| Robustness | Sensitivity to parameters, prompts, thresholds, seeds, budget, or shift |
| Practicality | Cost, latency, compute, labels, memory, or model-size tradeoffs |
| Limitations | Failure cases, negative examples, and conditions where the method should not be used |

If a category is omitted, state why in the experiment log or appendix plan. Do
not hide missing evidence by over-describing the main result.

**Default section structure**:
1. **Experimental Setup**: datasets, baselines, evaluation metrics/protocol,
   implementation details. This subsection reports conditions only; it does not
   analyze results.
2. **Overall Performance / Main Results**: the main table and bounded answer to
   where the method improves over strong baselines.
3. **Ablation Study**: tests whether each core design contributes to the claim.
4. **Further Analysis**: only analyses that answer likely reviewer questions:
   sensitivity, robustness, efficiency, complexity, generalization, data scale,
   noise, thresholds, failure cases, stability, or intermediate variables.
5. **Visualization / Case Study**: auxiliary evidence explaining behavior, not a
   replacement for quantitative results.

When space is limited, keep setup, main results, core ablation, and the single
most important further analysis in the body. Move extra sweeps, efficiency
details, additional cases, and supplemental statistics to the appendix.

**Experimental Setup rules**:
- Datasets: report task type, scale, dimensionality, train/test split,
  anomaly/class ratio if relevant, and evaluation unit. Avoid long application
  background.
- Baselines: explain why the chosen methods are fair and what route each family
  represents. Cover classic methods, strong recent methods, close methods, and
  necessary simple baselines.
- Metrics and protocol: define metric direction, thresholding, repetitions,
  statistics, and the evaluation unit. For anomaly detection, state whether F1
  is threshold-selected, point-adjusted, event-level, or score-level.
- Implementation details: centralize reproducibility settings here, including
  search ranges, optimizer/training details, seeds, compute, and hardware.
- Do not put result analysis or defensive fairness prose in Setup.

**Main Results rules**:
- Use the pattern: phenomenon -> comparison with strongest or closest baselines
  -> bounded conclusion.
- Prioritize best/second-best counts, deltas to the strongest baseline, changes
  on key datasets, stable metric trends, and metrics where gains are not
  consistent.
- Do not write "outperforms all baselines" unless every reported dataset and
  metric supports it. Do not write "consistently superior" unless the result is
  truly consistent.

**Ablation rules**:
- Each core module should map to a verifiable removal, replacement, or
  incremental ablation.
- State what changes, which claim is tested, which metric is affected, whether
  the effect is consistent, and how far the conclusion can go.
- Apply the Ablation Kill Rule before writing prose. If removing a module does
  not reduce the primary metric or target behavior, do not claim that module is
  effective or necessary. If a simple replacement is not worse, simplify or
  reframe the claimed design. If the main metric contradicts the contribution,
  stop expansion and trigger route reframe or kill review.
- Avoid absolute claims such as "fully demonstrates", "indispensable", or
  "essential for all cases" unless all relevant datasets and metrics support
  that statement.

**Further analysis and visualization rules**:
- Further Analysis is not an experiment dumping ground; include only analyses
  that answer a core claim or likely reviewer concern.
- Sensitivity analysis should report ranges and trends, mark the default value,
  and avoid over-interpreting a single peak.
- Efficiency analysis must report comparison objects and measurement settings,
  not only this method's cost.
- Case studies and visualizations must state the selection criterion and serve
  an explanatory purpose. They can illustrate a mechanism but cannot prove
  superiority by themselves.

**Table and prose rules**:
- Main tables must have clear dataset grouping, metric direction, consistent
  decimals, method categories, the proposed method placed last, and best/second
  markers when the table is intended for ranking.
- Ablation tables must use clear variant names, change one key factor at a
  time, and avoid unexplained abbreviations.
- Do not use defensive result language such as "although this does not
  undermine", "despite not achieving", "still acceptable", "slight degradation
  is reasonable", "does not affect effectiveness", or "remains competitive" to
  cover weak results. Report rank, delta, and scope directly.
- Do not leak internal workflow details: code filenames, temporary variable
  names, log paths, script names, generated-file wording, saved-result wording,
  plugin traces, or engineering process narration. Keep paper-body experiments
  reader-facing; put reproducibility engineering in release documentation.

Requirements:
- Error bars with methodology (std dev vs std error)
- Hyperparameter search ranges
- Compute infrastructure (GPU type, total hours)
- Seed-setting methods

### Step 5.6: Related Work

Related Work must position the paper in the research space. It should answer:
what main routes already exist, what each route solves, and which specific
under-handled position this paper enters. It is not a citation dump.

**Default structure for ML method papers**:

1. **Task-related methods**: Main method families for the target task and how
   the field usually handles the problem.
2. **Technique-related methods**: Work related to the paper's core mechanism,
   model structure, training objective, evidence source, or inference procedure.
3. **Closely related methods**: The nearest neighbors to this paper. State the
   similarity, the difference, and the precise entry point of this work.

Adjust the emphasis to the paper type: task-driven papers give more space to
task-related methods; method-driven papers give more space to technique-related
methods. If the method could look like a combination of existing methods, the
closely related subsection is mandatory. Do not organize ordinary ML Related
Work chronologically unless writing a survey.

**Citation selection gate**:
Every cited paper must serve at least one purpose:
- represents an important method family;
- defines the task, paradigm, or common baseline;
- is a strong recent related method from roughly the last 3-5 years;
- is one of the closest methods to the paper;
- appears in the experimental baselines or comparison pool;
- helps explain the paper's specific gap.

Do not cite a paper only because the name is similar, the year is recent, the
topic is fashionable, or the bibliography looks thin. If a citation does not
help explain the problem, method, gap, or experiment design, delete it.

**Paragraph pattern**:
Each paragraph should cover one method family or technical issue:
1. define the group's common goal or assumption;
2. cite representative work;
3. summarize the group's core mechanism or evidence source;
4. relate it to the paper's problem;
5. close with a specific positioning sentence.

Avoid paper-by-paper lists such as "A proposed X. B proposed Y. C proposed Z."

**Gap discipline**:
The gap must come from a modeling boundary, not a generic criticism. First state
what existing work solves, then state what remains insufficiently addressed.
Common gap types are modeling-object gaps, evidence-source gaps, structural
constraint gaps, and objective-mismatch gaps. Only write gaps that the proposed
method actually addresses.

**Subsection closure gate**:
Each Related Work subsection must end by saying how the grouped work relates to
this paper's entry point. Prefer concrete closures such as:
- "These methods mainly address [A], while [B] remains less explored."
- "They are related to our work in [A], but differ from our focus on [B]."
- "Although these methods improve [A], they still rely on [B], leaving [C]
  insufficiently addressed."

Avoid empty closures such as "existing methods still have limitations" or
"therefore, we propose a novel method."

**Related Work quality gate**:
- Important experimental baselines have a place in Related Work.
- The nearest related methods are discussed explicitly, not hidden in a broad
  paragraph.
- Classification axes are consistent within each subsection.
- Related Work does not repeat the Introduction's application background,
  contribution list, or motivation prose.
- The section connects to Method and Experiments: readers can tell why the
  baselines are fair and how this paper differs from close prior work.

### Step 5.7: Limitations (REQUIRED)

All major conferences require this. Honesty helps:
- Reviewers are instructed not to penalize honest limitation acknowledgment
- Pre-empt criticisms by identifying weaknesses first
- Explain why limitations don't undermine core claims

### Step 5.8: Conclusion & Discussion

**Conclusion** (required, 0.5-1 page):
- Restate the contribution in one sentence (different wording from abstract)
- Summarize key findings (2-3 sentences, not a list)
- Implications: what does this mean for the field?
- Future work: 2-3 concrete next steps (not vague "we leave X for future work")

**Discussion** (optional, sometimes combined with conclusion):
- Broader implications beyond immediate results
- Connections to other subfields
- Honest assessment of when the method does and doesn't work
- Practical deployment considerations

**Do NOT** introduce new results or claims in the conclusion.

### Step 5.9: Appendix Strategy

Appendices are unlimited at all major venues and are essential for reproducibility. Structure:

| Appendix Section | What Goes Here |
|-----------------|---------------|
| **Proofs & Derivations** | Full proofs too long for main text. Main text can state theorems with "proof in Appendix A." |
| **Additional Experiments** | Ablations, scaling curves, per-dataset breakdowns, hyperparameter sensitivity |
| **Implementation Details** | Full hyperparameter tables, training details, hardware specs, random seeds |
| **Dataset Documentation** | Data collection process, annotation guidelines, licensing, preprocessing |
| **Prompts & Templates** | Exact prompts used (for LLM-based methods), evaluation templates |
| **Additional Figures** | Per-task breakdowns, trajectory visualizations, failure case examples |

**Rules**:
- The main paper must be self-contained 鈥?reviewers are not required to read appendices
- Never put critical evidence only in the appendix
- Cross-reference: "Full results in Table 5 (Appendix B)" not just "see appendix"
- Use `\appendix` command, then `\section{A: Proofs}` etc.

### Page Budget Management

When over the page limit:

| Cut Strategy | Saves | Risk |
|-------------|-------|------|
| Move proofs to appendix | 0.5-2 pages | Low 鈥?standard practice |
| Condense related work | 0.5-1 page | Medium 鈥?may miss key citations |
| Combine tables with subfigures | 0.25-0.5 page | Low 鈥?often improves readability |
| Use `\vspace{-Xpt}` sparingly | 0.1-0.3 page | Low if subtle, high if obvious |
| Remove qualitative examples | 0.5-1 page | Medium 鈥?reviewers like examples |
| Reduce figure sizes | 0.25-0.5 page | High 鈥?figures must remain readable |

**Do NOT**: reduce font size, change margins, remove required sections, or use `\small`/`\footnotesize` for main text.

### Writing Style

**Sentence-level clarity (Gopen & Swan's 7 Principles):**

| Principle | Rule |
|-----------|------|
| Subject-verb proximity | Keep subject and verb close |
| Stress position | Place emphasis at sentence ends |
| Topic position | Put context first, new info after |
| Old before new | Familiar info 鈫?unfamiliar info |
| One unit, one function | Each paragraph makes one point |
| Action in verb | Use verbs, not nominalizations |
| Context before new | Set stage before presenting |

**Word choice (Lipton, Steinhardt):**
- Be specific: "accuracy" not "performance"
- Eliminate hedging: drop "may" unless genuinely uncertain
- Consistent terminology throughout
- Avoid incremental vocabulary: "develop", not "combine"

**Full writing guide with examples**: See [references/writing-guide.md](references/writing-guide.md)

## Phase 6: Self-Review & Revision

**Goal**: Simulate the review process before submission. Catch weaknesses early.

### Step 6.1: Simulate Reviews (Ensemble Pattern)

Generate reviews from multiple perspectives. The key insight from automated research pipelines (notably SakanaAI's AI-Scientist): **ensemble reviewing with a meta-reviewer produces far more calibrated feedback than a single review pass.**

**Step 1: Generate N independent reviews** (N=3-5)

Use different models or temperature settings. Each reviewer sees only the paper, not other reviews. **Default to negative bias** 鈥?LLMs have well-documented positivity bias in evaluation.

```
You are an expert reviewer for [VENUE]. You are critical and thorough.
If a paper has weaknesses or you are unsure about a claim, flag it clearly
and reflect that in your scores. Do not give the benefit of the doubt.

Review this paper according to the official reviewer guidelines. Evaluate:

1. Soundness (are claims well-supported? are baselines fair and strong?)
2. Clarity (is the paper well-written? could an expert reproduce it?)
3. Significance (does this matter to the community?)
4. Originality (new insights, not just incremental combination?)

Provide your review as structured JSON:
{
  "summary": "2-3 sentence summary",
  "strengths": ["strength 1", "strength 2", ...],
  "weaknesses": ["weakness 1 (most critical)", "weakness 2", ...],
  "questions": ["question for authors 1", ...],
  "missing_references": ["paper that should be cited", ...],
  "soundness": 1-4,
  "presentation": 1-4,
  "contribution": 1-4,
  "overall": 1-10,
  "confidence": 1-5
}
```

**Step 2: Meta-review (Area Chair aggregation)**

Feed all N reviews to a meta-reviewer:

```
You are an Area Chair at [VENUE]. You have received [N] independent reviews
of a paper. Your job is to:

1. Identify consensus strengths and weaknesses across reviewers
2. Resolve disagreements by examining the paper directly
3. Produce a meta-review that represents the aggregate judgment
4. Use AVERAGED numerical scores across all reviews

Be conservative: if reviewers disagree on whether a weakness is serious,
treat it as serious until the authors address it.

Reviews:
[review_1]
[review_2]
...
```

**Step 3: Reflection loop** (optional, 2-3 rounds)

Each reviewer can refine their review after seeing the meta-review. Use an early termination sentinel: if the reviewer responds "I am done" (no changes), stop iterating.

**Model selection for reviewing**: Reviewing is best done with the strongest available model, even if you wrote the paper with a cheaper one. The reviewer model should be chosen independently from the writing model.

**Few-shot calibration**: If available, include 1-2 real published reviews from the target venue as examples. This dramatically improves score calibration. See [references/reviewer-guidelines.md](references/reviewer-guidelines.md) for example reviews.

### Step 6.1b: Visual Review Pass (VLM)

Text-only review misses an entire class of problems: figure quality, layout issues, visual consistency. If you have access to a vision-capable model, run a separate **visual review** on the compiled PDF:

```
You are reviewing the visual presentation of this research paper PDF.
Check for:
1. Figure quality: Are plots readable? Labels legible? Colors distinguishable?
2. Figure-caption alignment: Does each caption accurately describe its figure?
3. Layout issues: Orphaned section headers, awkward page breaks, figures far from their references
4. Table formatting: Aligned columns, consistent decimal precision, bold for best results
5. Visual consistency: Same color scheme across all figures, consistent font sizes
6. Grayscale readability: Would the figures be understandable if printed in B&W?

For each issue, specify the page number and exact location.
```

This catches problems that text-based review cannot: a plot with illegible axis labels, a figure placed 3 pages from its first reference, inconsistent color palettes between Figure 2 and Figure 5, or a table that's clearly wider than the column width.

### Step 6.1c: Claim Verification Pass

After simulated reviews, run a separate verification pass. This catches factual errors that reviewers might miss:

```
Claim Verification Protocol:
1. Extract every factual claim from the paper (numbers, comparisons, trends)
2. For each claim, trace it to the specific experiment/result that supports it
3. Verify the number in the paper matches the actual result file
4. Flag any claim without a traceable source as [VERIFY]
```

For agent-based workflows: delegate verification to a **fresh sub-agent** that receives only the paper text and the raw result files. The fresh context prevents confirmation bias 鈥?the verifier doesn't "remember" what the results were supposed to be.

### Step 6.2: Prioritize Feedback

After collecting reviews, categorize:

| Priority | Action |
|----------|--------|
| **Critical** (technical flaw, missing baseline) | Must fix. May require new experiments 鈫?back to Phase 2 |
| **High** (clarity issue, missing ablation) | Should fix in this revision |
| **Medium** (minor writing issues, extra experiments) | Fix if time allows |
| **Low** (style preferences, tangential suggestions) | Note for future work |

### Step 6.3: Revision Cycle

For each critical/high issue:
1. Identify the specific section(s) affected
2. Draft the fix
3. Verify the fix doesn't break other claims
4. Update the paper
5. Re-check against the reviewer's concern

### Step 6.4: Rebuttal Writing

When responding to actual reviews (post-submission), rebuttals are a distinct skill from revision:

**Format**: Point-by-point. For each reviewer concern:
```
> R1-W1: "The paper lacks comparison with Method X."

We thank the reviewer for this suggestion. We have added a comparison with 
Method X in Table 3 (revised). Our method outperforms X by 3.2pp on [metric] 
(p<0.05). We note that X requires 2x our compute budget.
```

**Rules**:
- Address every concern 鈥?reviewers notice if you skip one
- Lead with the strongest responses
- Be concise and direct 鈥?reviewers read dozens of rebuttals
- Include new results if you ran experiments during the rebuttal period
- Never be defensive or dismissive, even of weak criticisms
- Thank reviewers for specific, actionable feedback (not generic praise)

**What NOT to do**: "We respectfully disagree" without evidence. "This is out of scope" without explanation. Ignoring a weakness by only responding to strengths.

### Step 6.5: Paper Evolution Tracking

Save snapshots at key milestones:
```
paper/
  paper.tex                    # Current working version
  paper_v1_first_draft.tex     # First complete draft
  paper_v2_post_review.tex     # After simulated review
  paper_v3_pre_submission.tex  # Final before submission
  paper_v4_camera_ready.tex    # Post-acceptance final
```

---

## Reviewer Evaluation Criteria

Understanding what reviewers look for helps focus effort:

| Criterion | What They Check |
|-----------|----------------|
| **Quality** | Technical soundness, well-supported claims, fair baselines |
| **Clarity** | Clear writing, reproducible by experts, consistent notation |
| **Significance** | Community impact, advances understanding |
| **Originality** | New insights (doesn't require new method) |

**Scoring (NeurIPS 6-point scale):**
- 6: Strong Accept 鈥?groundbreaking, flawless
- 5: Accept 鈥?technically solid, high impact
- 4: Borderline Accept 鈥?solid, limited evaluation
- 3: Borderline Reject 鈥?weaknesses outweigh
- 2: Reject 鈥?technical flaws
- 1: Strong Reject 鈥?known results or ethics issues

See [references/reviewer-guidelines.md](references/reviewer-guidelines.md) for detailed guidelines, common concerns, and rebuttal strategies.

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Abstract too generic | Delete first sentence if it could prepend any ML paper. Start with your specific contribution. |
| Abstract or introduction leaks internal route/config text | Replace code identifiers, `score_mode` values, "promoted route", and window/step settings with paper-facing mechanism names; move exact configuration to Methods, Experiments, or Reproducibility. |
| Introduction exceeds 1.5 pages | Split background into Related Work. Front-load contribution bullets. |
| Introduction reads like a module list | Rebuild it with the Failure-to-Mechanism Introduction Pattern: existing assumption, real-world counterexample, failure phenomenon, mechanism gaps, then module-by-gap method mapping. |
| Related Work reads like a citation list | Rebuild it around task-related, technique-related, and closely related method groups. End each group with a concrete positioning sentence tied to the paper's gap, method, or baselines. |
| Experiments lack explicit claims | Add: "This experiment tests whether [specific claim]..." before each one. |
| Experimental setup mixes setup and analysis | Keep Setup to datasets, baselines, metrics/protocol, and implementation details. Move result interpretation, fairness defense, and claims to Main Results or later analysis. |
| Experiments section only has the main result | After the main experiment reaches expected performance and supports the core claim, create the Post-Main Experiment Expansion Plan. Add ablations, sensitivity, visualization, slice analysis, claim-verification diagnostics, cost analysis, and failure cases as needed for the paper's claims. |
| Experiments use defensive result language | Replace "although this does not undermine", "despite not achieving", "still acceptable", "does not affect effectiveness", and "remains competitive" with direct ranks, deltas, affected metrics, and bounded conclusions. |
| Experiments leak internal files or workflow traces | Remove code filenames, CSV/log paths, script names, generated-file wording, saved-result wording, plugin traces, and temporary variable names from the paper body. Keep reader-facing protocol details in Implementation Details and engineering traces in release documentation. |
| Reviewers find paper hard to follow | Add signposting, use consistent terminology, make figure captions self-contained. |
| Methods reads like code flow | Rebuild it around Problem Formulation, Method Overview, Core Modules, and Training/Inference. For every module, state motivation, input, output, formula, mechanism effect, and downstream connection. Move routine configuration to Experiments or Reproducibility. |
| Method feels like patchwork | Reduce it to one core mechanism. Remove ad hoc heuristics, fallback branches, and special cases unless each has a principled reason and ablation support. |
| Method looks copied from literature | Extract the source mechanism, identify the mismatch with this paper's problem, and redesign the component so the adaptation creates a clear innovation delta. If no adaptation exists, move it to baselines or related work. |
| New idea appears from intuition only | Build the Similar-Paper Matrix first. Generate candidate directions only from same-family paper limitations, shared assumptions, evaluation gaps, strong-baseline behavior, or failed-route evidence. Reject ideas without a literature source chain and cheapest kill test. |
| Agent mechanically executes the research matrix | Build the Problem-Specific Snapshot, Search Lens Plan, and Problem-Specific Insight Map. Tailor the matrix fields to the concrete task, constraints, failures, and adjacent analogies before choosing a method. |
| Agent keeps optimizing post-processing around a weak base | Run the Root-Cause Innovation Gate. Attribute the failure to base/backbone, objective, data, inference, post-processing, or evaluation before choosing the next route. If the base lacks the needed signal, require a base-level or objective-level candidate instead of another filter, threshold, reranker, critic, or smoothing patch. |
| Candidate papers are only metadata or abstracts | Run the Reference Paper Acquisition Gate. Download lawful public PDFs when available, write `paper_index` metadata and reading notes, and mark metadata-only papers as unable to support claims. |
| Inspiration is copied without adaptation | Borrow mechanisms, not methods. Write the transfer path from source paper to extracted mechanism to mismatch to adaptation to innovation delta before experiments. |
| Agent stops because it wants another approval phrase | If an Autonomous Experiment License already covers the route, budget, allowed actions, and stop conditions, continue inside that license. Ask again only when the next action exceeds the license or hits a stop condition. |
| Workflow is compliant but the paper is not converging | Update `paper/status.md`, identify the current project phase, list allowed and blocked actions, and force the next gate decision before doing more local work. Do not stay in rough drafting or endless experiment loops without a phase transition. |
| Skill constraints are treated as advice instead of gates | Apply the Phase Gate table. If project identity, literature matrix, route-killer handoff, experiment license, claim-evidence map, or result audit is missing, stop and create the missing artifact before continuing. |
| Workflow is marked complete without independent supervision | Run the Workflow Supervisor audit. If the decision is `block`, do not package, finalize, or call the research workflow complete until every listed process repair is done. |
| External GPT page exists but is not used consistently | Apply the External GPT Reviewer Role. Record `external_gpt_reviewer.md`, use the standard prompt at configured checkpoints, preserve the GPT response as a handoff, and let the Workflow Supervisor decide whether it creates a local blocker. |
| External GPT gives vague advice | Re-submit with the standard prompt and require quality score, `pass / concern / block`, must-fix items, and complete actionable suggestions. Do not accept generic praise or unsourced rewrites as an audit. |
| Method paper silently becomes a boundary study | Apply the Manuscript Intent Gate. If the frozen paper type is `method_paper`, boundary-study conversion is prohibited; mark the route `reframe_required` or `kill` instead of drafting or completing a boundary-study manuscript. |
| Workspace or old route artifacts pollute the evidence chain | Re-open the Project Identity Gate. Confirm the trusted workspace root, topic, in-scope method terms, deprecated routes/files, and trusted result directories before using any artifact. |
| Failed results are turned into prose instead of repair | Apply the Failed-Result Optimization Gate. Set route status to `optimize`, write a failure diagnosis, propose 2-4 root-cause repair candidates, and run the cheapest licensed repair test before writing manuscript conclusions. |
| Ablation results contradict the method but the draft still claims success | Apply the Ablation Kill Rule. Remove unsupported module claims, update `result_audit.md` and `claim_evidence_map.md`, and trigger reframe/redesign/kill review before any manuscript expansion. |
| Result prose protects weak evidence | Apply the Defensive Writing Zero-Tolerance Gate. Locate the sentence, name the weak claim it protects, then delete the claim, weaken it with direct ranks/deltas, or return to optimization. |
| Section prose ignores the user's writing constraints | Apply the Writing Conformance Gate. Freeze a section contract, audit each paragraph against it, and rewrite failing paragraphs before integration. |
| Sub-agents directly edit the main manuscript | Revoke direct manuscript writes. Require structured handoffs, then let the Research Coordinator integrate terms, claims, and final LaTeX edits. |
| Experiment runner writes paper conclusions | Split facts from interpretation. Runner reports commands, configuration, result paths, and failure states; Analyst reports trends; Result Auditor checks numbers and claim scope; Coordinator writes conclusions. |
| Reviewer panel creates noisy or conflicting advice | Use a Meta-Reviewer to aggregate priorities. Fix critical/high issues grounded in evidence; do not mechanically accept every reviewer suggestion. |
| Multi-agent drafts introduce inconsistent terms | Freeze the paper-facing terminology in `paper_claims.md` or `claim_evidence_map.md`. Writers may propose edits, but the Coordinator owns cross-section naming. |
| Handoffs become scattered or too heavy | Keep the mandatory handoff set to `paper/protocol_state.md`, `paper_claims.md`, `claim_evidence_map.md`, `literature_matrix.md`, and `result_audit.md`; generate extra review or figure-audit files only when needed. |
| Missing statistical significance | Add error bars, number of runs, statistical tests, confidence intervals. |
| Scope creep in experiments | Every experiment must map to a specific claim. Cut experiments that don't. |
| Reviewers question reproducibility | Document code, hyperparameters, seeds, compute details, and result source paths. |

---

## Reference Documents

| Document | Contents |
|----------|----------|
| [references/writing-guide.md](references/writing-guide.md) | Gopen & Swan 7 principles, Perez micro-tips, Lipton word choice, Steinhardt precision, figure design |
| [references/citation-workflow.md](references/citation-workflow.md) | Citation APIs, Python code, CitationManager class, BibTeX management |
| [references/checklists.md](references/checklists.md) | NeurIPS 16-item, ICML, ICLR, ACL requirements, universal pre-submission checklist |
| [references/reviewer-guidelines.md](references/reviewer-guidelines.md) | Evaluation criteria, scoring, common concerns, rebuttal template |
| [references/sources.md](references/sources.md) | Complete bibliography of all writing guides, conference guidelines, APIs |
| [references/experiment-patterns.md](references/experiment-patterns.md) | Experiment design patterns, evaluation protocols, monitoring, error recovery |

### LaTeX Templates

Templates in `templates/` for: **NeurIPS 2025**, **ICML 2026**, **ICLR 2026**, **ACL**, **AAAI 2026**, **COLM 2025**.

See [templates/README.md](templates/README.md) for compilation instructions.

### Key External Sources

**Writing Philosophy:**
- [Neel Nanda: How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers)
- [Sebastian Farquhar: How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/)
- [Gopen & Swan: Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf)
- [Lipton: Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/)
- [Perez: Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/)

**APIs:** [Semantic Scholar](https://api.semanticscholar.org/api-docs/) | [CrossRef](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) | [arXiv](https://info.arxiv.org/help/api/basics.html)

**Venues:** [NeurIPS](https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles) | [ICML](https://icml.cc/Conferences/2025/AuthorInstructions) | [ICLR](https://iclr.cc/Conferences/2026/AuthorGuide) | [ACL](https://github.com/acl-org/acl-style-files)

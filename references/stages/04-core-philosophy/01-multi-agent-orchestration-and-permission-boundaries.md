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
Default to `internal-only`; do not interrupt normal work with an external-review intake. Reuse any explicit existing external-review authorization. Only when the user requests external review, or a configured external checkpoint needs missing access information, ask:

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

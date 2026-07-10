# Review Workflow

Detailed reference for self-review, reviewer simulation, visual review, claim
verification, revision, rebuttal notes, reviewer criteria, and common issues.
Use this after a complete evidence-grounded draft exists or when a supervisor
gate requests review.

## Phase 6: Self-Review and Revision

Goal: simulate the review process before submission. Catch weak novelty,
unsupported claims, paper-type drift, method-experiment mismatch, presentation
problems, and workflow violations before final integration.

Process compliance is not paper quality. A workflow may pass process gates while
the manuscript still fails as a paper. The reviewer panel must judge the current
manuscript, not whether it improved over earlier drafts.

## Review Isolation Rule

Default to fresh-context review packets. A reviewer should see only the files
needed for its role, not project progress notes, repair history, previous review
passes, patch proposals, or the Coordinator's private rationale.

Allowed in review packets:

- rendered manuscript PDF or extracted paper text;
- `main.tex` or section text when needed for textual inspection;
- frozen paper intent, paper type, thesis, and forbidden conversions;
- public `claim_evidence_map.md` or a sanitized claim-evidence extract;
- `literature_matrix.md` or a sanitized related-work extract;
- `result_audit.md`, `result_ledger.jsonl`, tables, figures, and source result
  paths when the role checks evidence;
- section contracts and planned-vs-produced writing audits when the role checks
  writing conformance.

Exclude from reviewer packets unless the role is Workflow Supervisor:

- `paper/protocol_state.md` except for frozen intent fields;
- `progress.md`, `status.md`, task plans, and old route history;
- previous reviewer reports;
- patch proposals and repair logs;
- agent handoffs unrelated to that role;
- stale workspaces or deprecated route artifacts.

The reviewer must not reward careful limitation language unless the frozen paper
type explicitly permits a boundary, benchmark, negative-result, or position
paper. For a frozen method paper, "bounded prototype behavior" is a warning
unless supported by a clear method contribution and adequate evidence.

## Reviewer Panel Roles

Do not create several generic reviewers. Use role-bounded reviewers. Each role
has a jurisdiction, a clean input packet, block authority, and explicit
non-coverage statement.

| Role | Jurisdiction | Required input | May block final integration when |
| --- | --- | --- | --- |
| Paper-Type and Intent Reviewer | Paper identity, thesis, contribution shape, forbidden conversions | Manuscript, frozen paper intent, paper type, forbidden conversions | A method paper reads as a boundary study, benchmark, survey, negative-result paper, or prototype report without user approval |
| Novelty and Related Work Reviewer | Novelty risk, close related work, method-family positioning, baseline rationale | Manuscript, literature matrix, BibTeX or citation list, close-work notes | Closest work is missing, related work is a citation list, or the gap is not specific to the method |
| Methodology Reviewer | Method design logic, problem formulation, input-output chain, formulas, module necessity, naming | Manuscript, method section, section contract, claim map | Method is code flow, taxonomy, patchwork, unmotivated modules, or inconsistent with experiments |
| Experiment Design Reviewer | Claim-serving experiments, primary metric, baselines, controls, ablations, kill criteria, failure repair | Manuscript, experiment license, result audit, tables, experiment plan | Experiments do not test the stated claims, lack simple controls, hide failed ablations, or cannot support the paper type |
| Result and Claim Auditor | Numeric values, ranks, deltas, best markers, source paths, claim boundaries | Manuscript, tables, figures, result audit, result ledger, source result files | Any reported value, rank, marker, or claim cannot be traced to trusted evidence |
| Writing Conformance Reviewer | Section roles, section contracts, defensive language, internal traces, narrative structure | Manuscript, section contracts, writing gate report | Sections violate their contracts, introduce internal route text, use defensive prose, or drift from the required structure |
| Presentation and PDF Reviewer | Rendered PDF quality, title/author state, figures, table density, captions, layout, first-viewport paper maturity | Rendered PDF, figure/table files when available | The PDF looks like an internal report, has no required method figure, unreadable tables, broken layout, or submission-facing metadata gaps |
| Strict External ML Logic Reviewer | Professional, severe ML paper review focused on logic-chain coherence, claim-evidence closure, defensive language, methodology, and submission maturity | Clean review packet only; no process history | The logic chain is broken, evidence does not support claims, defensive prose hides weak results, or the paper would likely be rejected despite passing internal gates |
| Workflow Supervisor | Process compliance only: protocol state, gates, role boundaries, evidence contamination | Protocol state, gate outputs, handoff manifest, audit traces | Required gates are missing, stale, inconsistent, or role permissions were violated |
| Meta-Reviewer | Aggregates role reports and prioritizes repairs | Reviewer reports, manuscript, frozen paper intent | Any role issued a justified block that remains unresolved |

Protocol Supervisor and Workflow Supervisor are not scientific reviewers. They
can block process violations, but they must not issue a paper-quality pass.
Process pass cannot override a paper-quality block.

## Role Prompts

Use these as role headers. Add the current manuscript and role-specific packet
after the header.

### Paper-Type and Intent Reviewer

```text
You are the Paper-Type and Intent Reviewer. Judge whether the current manuscript
matches the frozen paper type, thesis, and contribution contract. Do not reward
the manuscript for being safer than previous drafts. Judge only the submitted
paper.

Check:
1. Does the paper read as the frozen paper type?
2. Does the introduction, method, experiment section, and conclusion support the
   same thesis?
3. Does the manuscript silently convert a method paper into a boundary study,
   prototype report, benchmark, survey, position paper, or negative-result paper?
4. Are contributions stated as method contributions rather than process repairs?
5. Are limitations honest scope statements rather than a replacement for method
   evidence?
```

### Novelty and Related Work Reviewer

```text
You are the Novelty and Related Work Reviewer. Judge whether the paper is
properly positioned in the research space and whether the claimed gap is real,
specific, and supported by the cited work.

Check:
1. Are task-related, technique-related, and closest related methods separated?
2. Are the closest works discussed with concrete similarities and differences?
3. Does every cited paper serve positioning, baseline rationale, or gap
   definition?
4. Is the contribution more than a simple combination of known modules?
5. Are important baselines from experiments represented in Related Work?
```

### Methodology Reviewer

```text
You are the Methodology Reviewer. Judge whether the method section explains
design logic rather than code flow.

Check:
1. Are problem formulation, method overview, core modules, and training or
   inference procedure clearly separated?
2. For each module, are motivation, input, output, formula, mechanism effect,
   and downstream connection present?
3. Are formulas introduced and explained instead of dropped in isolation?
4. Are implementation details kept out of the core method unless they define the
   method?
5. Do method claims have corresponding experiments or ablations?
```

### Experiment Design Reviewer

```text
You are the Experiment Design Reviewer. Judge whether the experiments can
actually support the claims and paper type.

Check:
1. Does each experiment state the claim it tests?
2. Are primary metrics, baselines, simple controls, success criteria, and kill
   criteria explicit?
3. Do ablations test claimed modules rather than decorative variants?
4. If results are failed or mixed, did the workflow diagnose and optimize before
   writing conclusion prose?
5. Are claims reduced, redesigned, or killed when the evidence is weak?
```

### Result and Claim Auditor

```text
You are the Result and Claim Auditor. Verify factual consistency. Do not assess
writing style except when wording overstates the evidence.

Check:
1. Extract every numeric claim, ranking claim, comparison, trend, and best or
   second-best marker.
2. Trace each claim to a result ledger entry and trusted source file.
3. Verify reported values, rank order, deltas, averages, and table labels.
4. Mark claims as supported, partially supported, unsupported, or contradicted.
5. Block any conclusion whose strength exceeds the verified evidence.
```

### Writing Conformance Reviewer

```text
You are the Writing Conformance Reviewer. Judge whether each section follows its
section contract and the required writing constraints.

Check:
1. Does the Introduction follow the required failure-to-mechanism structure?
2. Does Related Work group methods by role rather than listing papers?
3. Does Methodology explain design logic with clear variable flow?
4. Does Experiments state setup, main results, ablations, and analysis without
   defensive language?
5. Does the manuscript contain internal route names, promoted-route wording,
   script names, raw config text, or generated-artifact traces?
```

### Presentation and PDF Reviewer

```text
You are the Presentation and PDF Reviewer. Judge the rendered PDF as a
submission-facing research paper.

Check:
1. Does the title, author block, abstract, section order, and first page look
   like a mature paper rather than an internal report?
2. Is there a clear Figure 1 or equivalent method overview when the paper needs
   one?
3. Are tables readable, correctly aligned, and not overcrowded?
4. Are captions self-contained and consistent with the text?
5. Are figures legible in grayscale, correctly referenced, and visually
   consistent?
```

### Strict External ML Logic Reviewer

```text
You are a strict external senior reviewer for machine learning research papers.
You have deep expertise in ML methodology, experimental validation, academic
paper writing, and top-tier conference review standards such as NeurIPS, ICML,
ICLR, ACL, AAAI, and COLM.

You are not part of the research workflow. You must not consider the authors'
intentions, repair history, internal gates, previous drafts, or process logs.
Judge only the clean review packet as a real conference submission.

Your primary job is not to be helpful or encouraging. Your job is to determine
whether the paper's scientific argument is logically coherent, evidence-backed,
and written without defensive language that hides weak results.

Core review stance:
1. Be strict, skeptical, and precise.
2. Do not give the benefit of the doubt.
3. Do not infer missing evidence.
4. Do not reward cautious wording if it is used to protect weak claims.
5. Do not accept process compliance as paper quality.
6. Do not rewrite the paper. Diagnose failures and specify required repairs.
7. If the paper would likely be rejected, say so directly.

Review the manuscript through this logic chain:

problem -> gap -> method mechanism -> experimental test -> result -> claim -> conclusion

For every major claim, ask:
1. What exact problem is claimed?
2. What gap justifies this problem?
3. What mechanism is proposed to address it?
4. What experiment tests that mechanism?
5. What result supports it?
6. Does the conclusion say exactly what the evidence allows, no more?

Hard-block conditions:
Return `block` if any of the following occurs:
1. The declared paper type is a method paper, but the manuscript reads like a
   boundary study, prototype report, engineering note, benchmark note, or
   failure analysis.
2. The introduction, methodology, experiments, and conclusion do not support the
   same central thesis.
3. The method section describes modules or implementation flow but does not
   explain the design logic and mechanism.
4. A claimed core module lacks a corresponding ablation, control, sensitivity
   analysis, or direct validation.
5. Experimental results are weak, failed, mixed, or negative, but the paper uses
   defensive prose to preserve the claim.
6. The paper uses phrases such as "still effective", "remains competitive",
   "does not undermine", "despite the degradation", "acceptable", "promising",
   or "validates" without direct quantitative support.
7. The paper lacks strong baselines, simple controls, primary metrics, or clear
   success and failure criteria for its central claims.
8. The manuscript contains internal workflow traces, route names, raw config
   details, generated-artifact wording, or process-repair language.
9. The main contribution is mostly a recombination of known components without a
   clearly argued innovation delta.
10. The PDF or manuscript presentation is not mature enough for submission.

Defensive language audit:
For every defensive or vague sentence, identify:
- the exact sentence;
- what weakness it is trying to protect;
- whether the underlying claim should be deleted, weakened, or returned to
  experiment optimization;
- the direct evidence statement that should replace it.

Evaluate these dimensions:

1. Central Thesis
- Is there one clear paper-level thesis?
- Is it specific enough for an ML paper?
- Does every section serve it?

2. Introduction Logic
- Does the introduction move from concrete problem to specific gap to method?
- Does it avoid generic background dumping?
- Does it avoid premature contribution claims not supported later?

3. Related Work and Novelty
- Are closest methods discussed concretely?
- Is the gap derived from modeling boundaries rather than vague limitations?
- Is the innovation more than module combination?

4. Methodology
- Is the method explained as design logic, not code flow?
- Are inputs, outputs, variables, formulas, and module connections clear?
- Does every named component have a real reason to exist?

5. Experiments
- Does each experiment test a stated claim?
- Are baselines, controls, metrics, datasets, ablations, and failure cases
  sufficient?
- Do the results actually support the claimed mechanism?

6. Claim-Evidence Alignment
- Which claims are supported?
- Which are partially supported?
- Which are unsupported or contradicted?
- Which conclusions exceed the evidence?

7. Writing Quality
- Is the prose precise, direct, and reviewer-facing?
- Are there defensive, vague, promotional, or internally generated sentences?
- Does the paper read like a mature ML paper rather than an internal draft?

8. Submission Readiness
- Would this paper likely survive a serious review?
- What are the top reasons for rejection today?
- What must be fixed before submission?

Return exactly this structure:

## Strict External ML Logic Review

- Target venue:
- Declared paper type:
- Decision: pass / concern / block
- Likely reviewer score:
- Confidence: low / medium / high

## One-Sentence Verdict
[State the core judgment directly.]

## Central Logic Chain

- Problem:
- Gap:
- Proposed mechanism:
- Evidence provided:
- Claimed conclusion:
- Logic chain status: coherent / incomplete / broken
- Broken links:

## Major Blocking Issues

| Severity | Location | Issue | Why it matters | Required repair |
| --- | --- | --- | --- | --- |

## Claim-Evidence Audit

| Claim | Evidence cited | Support status | Problem | Required action |
| --- | --- | --- | --- | --- |

## Defensive Language Audit

| Location | Sentence | Hidden weakness | Required action | Direct replacement style |
| --- | --- | --- | --- | --- |

## Methodology Assessment

- Design logic:
- Mechanism clarity:
- Module necessity:
- Formula and symbol clarity:
- Method-experiment alignment:
- Required repairs:

## Experiment Assessment

- Primary metric adequacy:
- Baseline adequacy:
- Control adequacy:
- Ablation adequacy:
- Failure handling:
- Missing must-have experiments:

## Writing and Presentation Assessment

- Section structure:
- Precision:
- Reviewer-facing clarity:
- Internal traces:
- PDF / figure / table maturity:

## Rejection Risk

- Would this be rejected today? yes / no
- Main rejection reasons:
- Minimum repairs before resubmission:

## What This Reviewer Did Not Check

[List anything outside the provided clean packet.]
```

### Workflow Supervisor

```text
You are the Workflow Supervisor. Audit process compliance only. Do not judge
paper quality and do not write manuscript prose.

Check:
1. Required gates and protocol state are current.
2. External audit route is answered and used when enabled.
3. Review packets were isolated from process history when required.
4. Sub-agents did not directly modify protected manuscript files.
5. Blocks from role reviewers were preserved for Meta-Reviewer aggregation.
```

### Meta-Reviewer

```text
You are the Meta-Reviewer. Aggregate role-bounded reviewer reports into a
repair plan. Do not average away blockers.

Rules:
1. If any role issues a justified block, the final decision is block until the
   issue is repaired or the user explicitly overrides it.
2. Process pass cannot override paper-quality block.
3. Paper-quality pass cannot override missing evidence or process gates.
4. Resolve conflicts using raw manuscript evidence, result files, and frozen
   intent, not majority vote.
5. Output a prioritized repair plan with critical, high, medium, and low items.
```

## Required Reviewer Output Schema

Every reviewer, including external GPT reviewers when applicable, must return
this structure:

```markdown
## Reviewer Verdict

- Role:
- Review packet used:
- Fresh context: yes / no
- Decision: pass / concern / block
- Confidence: low / medium / high
- Blocking issues:
- Evidence from manuscript or artifacts:
- Required repairs:
- Suggestions:
- What this reviewer did not check:
```

The `What this reviewer did not check` line is mandatory. It prevents a narrow
role from being mistaken for full-paper clearance.

## Meta-Review Output Schema

```markdown
## Meta-Review

- Decision: pass / concern / block
- Blocking roles:
- Unresolved hard blocks:
- Process-pass cannot override paper-quality block: confirmed / violated
- Paper-quality-pass cannot override evidence gate: confirmed / violated
- Critical repairs before final integration:
- High-priority repairs:
- Medium-priority repairs:
- Low-priority notes:
- Items requiring user decision:
- Evidence checked to resolve reviewer conflicts:
```

## Claim Verification Pass

After reviewer simulation, run a separate claim verification pass. This catches
factual errors that reviewers may miss:

1. Extract every factual claim from the manuscript: numbers, comparisons,
   trends, ranks, ablation claims, and conclusion claims.
2. Trace each claim to the specific experiment, table, figure, or result source.
3. Verify that paper numbers match the actual result files.
4. Flag untraceable claims as `[VERIFY]`.
5. Update `claim_evidence_map.md`, `result_audit.md`, and the revision trace.

For agent-based workflows, delegate verification to a fresh context that
receives only paper text and raw result files. The verifier should not know what
the result was supposed to show.

## Visual Review Pass

Text-only review misses figure quality, layout issues, and visual consistency.
When a PDF exists, run a separate visual review:

1. figure readability, labels, legends, and grayscale legibility;
2. caption accuracy and self-contained explanation;
3. table alignment, decimal consistency, best and second-best markers;
4. title, author block, abstract, first page, and section ordering;
5. orphaned headings, awkward page breaks, overfull tables, and figure distance
   from first reference;
6. internal file paths, script names, and generated-artifact traces in captions
   or table notes.

If a method paper has no clear method figure or has a table-only main narrative,
the Presentation and PDF Reviewer should normally return `block` for
submission-ready workflows.

## Feedback Prioritization

After collecting reviews, categorize issues:

| Priority | Action |
| --- | --- |
| Critical | Must fix before final integration. May require new experiments, route redesign, or claim deletion. |
| High | Should fix in this revision. Includes missing ablations, unclear method logic, weak related-work positioning, or section contract drift. |
| Medium | Fix if time allows. Includes minor writing, extra analysis, or presentation polish. |
| Low | Note for future work or optional refinement. |

Critical or high issues grounded in evidence must be resolved before final
integration. Do not mechanically accept every suggestion, but do not ignore a
block by relabeling it as taste.

## Revision Cycle

For each critical or high issue:

1. identify the specific section, figure, table, result, or claim affected;
2. decide whether the repair requires writing, experiment redesign, result
   audit, literature update, or user decision;
3. apply the repair through the relevant phase gate;
4. verify the repair does not break other claims;
5. update the revision trace;
6. re-run the reviewer role that raised the issue, using a clean packet.

## Rebuttal Writing

When responding to actual reviews after submission, write point-by-point
responses. For each reviewer concern:

```markdown
> R1-W1: "The paper lacks comparison with Method X."

We added Method X to Table 3. On [metric], the revised comparison shows [direct
value, rank, and delta]. We also updated Section 4.2 to state the remaining
boundary condition.
```

Rules:

- address every concern;
- lead with direct evidence;
- include new results if they were run during rebuttal;
- avoid defensive or dismissive phrasing;
- thank reviewers for specific actionable feedback, not generic praise.

## Common Issues and Solutions

| Issue | Solution |
| --- | --- |
| Reviewers are too generic | Assign role-bounded reviewers with narrow jurisdiction and required non-coverage statements; use the Strict External ML Logic Reviewer for overall submission logic, defensive prose, and rejection-risk judgment. |
| Review is biased by shared context | Use clean packets and exclude process history, previous reviews, and patch proposals. |
| Method paper becomes boundary study | Paper-Type and Intent Reviewer blocks final integration unless user explicitly approves conversion. |
| Abstract or Introduction leaks internal route text | Writing Conformance Reviewer blocks until internal names, config text, and generated traces are removed. |
| Related Work reads like a citation list | Novelty and Related Work Reviewer requires method-family grouping and close-work comparison. |
| Methods reads like code flow | Methodology Reviewer requires problem formulation, overview, module logic, formulas, and inference/training flow. |
| Experiments lack explicit claims | Experiment Design Reviewer requires claim-tested statements before each experiment. |
| Failed ablations are explained away | Experiment Design Reviewer triggers failure diagnosis, optimization, reframe, redesign, or route kill. |
| Result prose protects weak evidence | Result and Claim Auditor requires direct ranks, deltas, affected metrics, and claim reduction. |
| Tables or figures look immature | Presentation and PDF Reviewer blocks submission-ready final integration until layout and visuals are repaired. |
| Meta-review averages away blockers | Meta-Reviewer must preserve hard blocks until repaired or explicitly overridden by the user. |

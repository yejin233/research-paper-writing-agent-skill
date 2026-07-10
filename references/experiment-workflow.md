# Experiment Workflow

Mandatory reference for experiment design, execution, route decisions, result
analysis, and experiment-to-prose handoff. Experiments are not complete when
numbers are reported. They are complete only when each result has claim-level
interpretation, mechanism-level explanation, and a bounded conclusion.

## Phase 2: Experiment Design

Goal: design experiments that directly test the paper's claims. Every
experiment must answer a specific reviewer-facing question and have a declared
consequence if it fails.

### Claim-to-Experiment Map

Before launching experiments, map each claim to the evidence that could support
or falsify it.

| Claim | Experiment | Expected evidence | Failure consequence |
| --- | --- | --- | --- |
| Core method claim | Main comparison | Rank, delta, primary metric, strongest baseline | optimize, weaken, redesign, or kill |
| Module necessity | Ablation | Removal or replacement changes the target behavior | remove, merge, or reframe the module |
| Mechanism claim | Diagnostic or controlled test | Intermediate behavior changes as predicted | revise mechanism or delete claim |
| Robustness claim | Sensitivity, seed, shift, or subgroup analysis | Stable trend within declared boundary | narrow boundary or remove robustness claim |

If an experiment does not map to a paper claim, a likely reviewer objection, a
boundary condition, or reproducibility, do not run it.

### Contribution Thickness Gate

Before spending experiment budget on a new route, complete:

```markdown
## Contribution Thickness Check

- Proposed contribution:
- One-sentence mechanism claim:
- Why the mechanism is necessary:
- Closest existing method that may already cover it:
- Strongest simple baseline or control:
- Cheapest route-killing test:
- Minimum practical effect size:
- Expected paper type if successful:
```

Default status for a new route is `yellow`, not `green`. It becomes `green`
only after the mechanism claim, closest-work boundary, simple control, budget,
primary metric, and kill criterion are explicit.

### Experiment License

Claim-affecting experiments must use `experiment_license.yaml` and pass:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-license.ps1 -ProjectRoot .
```

The license must include experiment ID, route ID, claim IDs, hypothesis,
primary metric, metric direction, datasets, baselines, simple controls, source
paths, expected outputs, budget, success criterion, partial-support policy, kill
criterion, failure action, and paper decision affected.

If failure has no consequence, the experiment is not licensed.

### Baselines and Controls

Include baselines because they test alternative explanations, not because they
fill tables.

Required baseline categories when relevant:

- naive baseline: simplest possible approach;
- strong baseline: best known or strongest available method;
- close baseline: method most similar to the proposed route;
- simple control: cheap explanation that could make the new mechanism
  unnecessary;
- ablation baseline: proposed method with one claimed factor removed;
- cost-matched baseline: same compute, labels, parameters, API calls, or wall
  time when cost matters.

Before tuning or scaling the proposed method, run the cheapest control that
could explain the claimed gain.

### Evaluation Protocol

Record:

- metrics and direction;
- aggregation across runs, datasets, tasks, or seeds;
- statistical tests or confidence intervals when appropriate;
- sample sizes and repeated runs;
- cost metrics such as GPU hours, latency, labels, memory, API calls, or tool
  calls;
- exploratory vs confirmatory status;
- frozen policy for thresholds, prompts, preprocessing, model selection, and
  dataset-specific exceptions.

If a design choice was made after seeing test results, mark the result as
exploratory unless a frozen-policy rerun is performed.

### Method Cleanliness

The method must look clean, unified, and inevitable from the paper's core idea.
Stop adding components if the implementation grows faster than contribution
clarity.

Checklist:

- one-sentence mechanism claim is clear;
- every component follows from the same principle, objective, or failure
  analysis;
- no dataset-specific patches, thresholds, prompts, or tool sets are used unless
  the paper's claim explicitly concerns the adaptation rule;
- components that only help one result are treated as ablation candidates, not
  main-method pillars;
- the same declared method runs across all claimed datasets or tasks.

If a reviewer could describe the method as patchwork or a bag of tricks,
simplify before running more experiments.

## Phase 3: Execution and Route Decision

Run only licensed experiments. A Runner reports commands, configuration, result
paths, failures, and logs. It must not write "this demonstrates" conclusions.
An Analyst may summarize trends. A Result Auditor and Experiment Analysis
Auditor must independently check whether the result supports the claim.

### Execution Log

Maintain an experiment journal with:

- command and commit or version;
- config and frozen-policy status;
- trusted result paths;
- start and end time;
- failed runs and recovery steps;
- whether the run is exploratory or confirmatory.

Use incremental saving and keep generation, evaluation, and visualization
separate.

### Failure Handling

A failed or mixed result is an optimization signal before it is a writing
limitation.

When a primary metric, core ablation, or simple control contradicts the claim:

1. verify source files and recompute values;
2. identify the failure type: bug, weak mechanism, unfair protocol, missing
   baseline, unstable metric, insufficient budget, or false claim;
3. propose the cheapest repair or diagnostic;
4. run the licensed repair test when plausible;
5. otherwise weaken, redesign, reframe, or kill the route.

Do not write defensive prose to preserve a claim contradicted by an ablation or
simple control.

## Phase 4: Result Analysis and Expansion

Before any result claim enters the manuscript, update:

- `result_audit.md`;
- `result_ledger.jsonl`;
- `claim_evidence_map.md`;
- `experiment_analysis_audit.md`.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-result-audit.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
```

### Result Audit

The Result Auditor verifies values, ranks, deltas, averages, best markers, table
labels, source paths, and claim support. A result can be:

- `supported`;
- `partial`;
- `unsupported`;
- `contradicted`;
- `context`.

Unsupported or contradicted claim entries must not appear as supported
manuscript claims.

### Experiment Analysis Depth Gate

Every experiment that appears in the paper body or supports a claim must have an
analysis unit:

```markdown
## Experiment Analysis Unit: [experiment_id]

- Experiment:
- Claim tested:
- Reviewer question answered:
- Primary observation:
- Strongest baseline comparison:
- Mechanism interpretation:
- Alternative explanation:
- Evidence against alternative explanation:
- Boundary condition:
- Failure or weak case:
- Claim implication:
- Required prose:
```

Required interpretation levels:

1. claim-level: what claim this result can and cannot support;
2. comparison-level: strongest baseline, rank, delta, and metric direction;
3. mechanism-level: why the result is consistent with the proposed mechanism;
4. alternative-explanation level: what simpler explanation could account for
   the result and what evidence rules it out or leaves it open;
5. boundary-level: where the result applies and where it does not.

If any level is missing, do not write an Experiments paragraph. Repair the
analysis first.

### Ablation Kill Rule

If removing or replacing a claimed module does not hurt the primary metric or
target behavior, do not claim the module is effective or necessary.

If a simple replacement matches the full method, simplify the method or reframe
the contribution. If the core ablation contradicts the mechanism, stop expansion
and trigger route reframe or kill review.

### Expansion Planning

Only expand after the main result is claim-sufficient:

- it reaches the declared effect size or success criterion;
- it beats or matches relevant strong baselines under the declared budget;
- it supports the core claim as written;
- it is stable enough for the venue standard;
- it can be explained by the proposed mechanism rather than a simple control or
  test-set patch.

Expansion experiments must answer reviewer questions: ablation, simple-control
test, sensitivity, scaling, subgroup analysis, robustness, mechanism
diagnostic, visualization, qualitative examples, cost, or failure cases.

### Experiment Log for Writing Handoff

Before drafting Experiments, create `experiment_log.md`:

```markdown
# Experiment Log

## Contribution
[one-sentence paper claim]

## Experiments Run

### Experiment 1: [name]
- Claim tested:
- Setup:
- Key result:
- Result files:
- Figures generated:
- Surprising findings:

## Failed Experiments
- What was tried:
- Why it failed:
- What it changes about claims:

## Open Questions
- What the paper still needs to address:
```

The experiment log bridges raw files to prose. Without it, the writing agent is
likely to infer a story from scattered JSON or CSV files.

## Stop Conditions

Stop and repair the experiment phase when:

- no experiment license exists;
- primary metric or kill criterion is missing;
- strongest baseline or simple control is absent without justification;
- result values cannot be traced to source files;
- ablations contradict a claimed module;
- analysis units are missing or shallow;
- failure diagnosis was skipped after weak, mixed, or negative results;
- an expansion experiment is decorative rather than claim-serving;
- prose has started before `experiment_analysis_audit.md` exists.

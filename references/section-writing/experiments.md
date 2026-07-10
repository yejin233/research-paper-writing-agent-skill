# Experiments Writing Workflow

Mandatory reference before drafting or rewriting Experiments, Results,
ablations, analysis, tables, or figure-result prose. The section contract must
record this path before prose is integrated.

## Purpose

The Experiments section verifies the paper's claims. It is not an inventory of
all runs. Each subsection must answer a reviewer-facing question, report direct
evidence, interpret the evidence through the proposed mechanism, address a
plausible alternative explanation, and end with a bounded claim.

## Required Artifacts Before Drafting

Do not draft Experiments or result-bearing prose until these exist:

- `experiment_license.yaml`;
- `experiment_log.md`;
- `result_audit.md`;
- `result_ledger.jsonl`;
- `claim_evidence_map.md`;
- `experiment_analysis_audit.md`;
- Experiments entry in `section_contracts.md` that records this reference path.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot . -Sections Experiments -RequireResults
powershell -ExecutionPolicy Bypass -File .\scripts\check-result-audit.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
```

If any check fails, repair the artifact. Do not write prose first.

## Default Section Structure

1. **Experimental Setup**: datasets, baselines, metrics, protocol, and
   implementation details. This subsection reports conditions only; it does not
   analyze results.
2. **Main Results**: direct comparison against strongest and closest baselines,
   with rank, delta, primary metric, and bounded conclusion.
3. **Ablation Study**: removal, replacement, or incremental tests of claimed
   components.
4. **Further Analysis**: only analyses that answer a claim or likely reviewer
   concern, such as sensitivity, robustness, efficiency, scaling, subgroup
   behavior, failure cases, or mechanism diagnostics.
5. **Visualization or Case Study**: auxiliary evidence that explains behavior;
   never a replacement for quantitative results.

When space is limited, keep setup, main results, core ablation, and the single
most important further analysis in the body. Move extra sweeps and supplementary
statistics to the appendix.

## Experiment Analysis Unit

Every body paragraph that interprets a result must be traceable to an
Experiment Analysis Unit:

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

The writing paragraph should follow:

1. state the reviewer question;
2. report the primary observation with metric, rank, delta, and table or figure;
3. compare with the strongest or closest baseline;
4. explain why the pattern matches the proposed mechanism;
5. name the strongest alternative explanation and the evidence for or against
   it;
6. state the boundary and exact claim implication.

Do not use the pattern "Table X shows that our method is effective" without the
comparison, mechanism, alternative explanation, and boundary.

## Setup Rules

- Datasets: report task type, scale, dimensionality, train/test split,
  anomaly/class ratio if relevant, and evaluation unit.
- Baselines: explain what method family each baseline represents and why it is
  fair. Include classic methods, recent strong methods, close methods, and
  necessary simple controls.
- Metrics and protocol: define metric direction, thresholding, repetitions,
  statistics, and evaluation unit.
- Implementation details: centralize reproducibility settings such as optimizer,
  search ranges, seeds, compute, and hardware. Keep engineering narrative out of
  the main result analysis.
- Do not put result analysis or defensive fairness prose in Setup.

## Main Result Rules

Use the pattern:

```text
reviewer question -> direct observation -> strongest-baseline comparison ->
mechanism interpretation -> alternative explanation -> bounded conclusion
```

Prioritize:

- best and second-best counts when tables are ranked;
- deltas to strongest and closest baselines;
- metric direction and primary metric;
- datasets or conditions where the method does not win;
- whether the trend is stable across metrics, seeds, or datasets.

Do not write "outperforms all baselines" unless every reported dataset and
metric supports it. Do not write "consistently superior" unless the result is
truly consistent.

## Ablation Rules

Each ablation must state:

- what changes;
- which claim is tested;
- which metric or behavior is affected;
- whether the effect is consistent;
- how far the conclusion can go.

Apply the Ablation Kill Rule before writing prose. If removing a module does not
reduce the primary metric or target behavior, do not claim that module is
effective, indispensable, or necessary. If a simple replacement is not worse,
simplify or reframe the claimed design.

## Further Analysis Rules

Further Analysis is not an experiment dumping ground. Include only analyses that
answer a core claim or likely reviewer concern.

- Sensitivity analysis should report ranges and trends, mark the default value,
  and avoid over-interpreting a single peak.
- Efficiency analysis must compare against relevant baselines under stated
  measurement settings.
- Robustness analysis must define the shift, perturbation, split, seed, or
  subgroup being tested.
- Case studies and visualizations must state selection criteria and explanatory
  purpose.
- Failure cases must state what fails and what claim boundary changes.

## Table and Figure Prose

Tables and figures must have:

- clear dataset grouping;
- metric direction;
- consistent decimals;
- method categories;
- proposed method placed consistently;
- best and second-best markers only when ranking is intended;
- captions that state what evidence the figure or table provides.

The prose must not leak code filenames, log paths, raw config names, temporary
variables, script names, plugin traces, or generated-file wording.

## Defensive Language Ban

Do not use defensive result language such as:

- "although this does not undermine";
- "despite the degradation";
- "still acceptable";
- "slight degradation is reasonable";
- "does not affect effectiveness";
- "remains competitive" when the primary metric does not support it;
- "fully demonstrates", "strongly proves", or "validates" without direct
  quantitative support.

Replace defensive wording with direct evidence: rank, delta, affected metric,
support level, and boundary condition. If evidence is weak, delete the claim or
return to optimization.

## Section Contract Requirements

The Experiments contract must include:

- claims tested;
- required tables and figures;
- primary metric and metric direction;
- required baselines and simple controls;
- required ablations;
- required Experiment Analysis Units;
- forbidden claims and defensive phrases;
- failure or weak-case reporting rule;
- appendix split for extra results.

If a planned paragraph has no Experiment Analysis Unit, do not write that
paragraph.

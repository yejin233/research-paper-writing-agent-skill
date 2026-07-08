# Hard Gates

The skill uses gates as blocking constraints. If a gate artifact is missing, the workflow stops and creates or repairs the artifact before continuing.

## Major Gates

- Manuscript Intent Gate
- Project Identity Gate
- Phase Gate
- Pre-registered Experiment License
- Failed-Result Optimization Gate
- Ablation Kill Rule
- Result Auditor Verdict
- Defensive Writing Zero-Tolerance Gate
- Writing Conformance Gate
- Workflow Supervision Audit
- Optional External GPT Reviewer checkpoints

## Method Paper Rule

If the frozen paper type is `method_paper`, the autonomous workflow must not silently convert the manuscript into a boundary study, negative-result paper, benchmark, survey, or position paper. Weak evidence can trigger optimization, claim deletion, redesign, reframe_required, or kill, but not silent paper-type conversion.

## Failed Results

Failed or mixed results are first optimization signals. Before writing failure prose, the workflow must diagnose root cause, propose repair candidates, and run the cheapest licensed repair test when repair is plausible.

## Defensive Writing

Defensive prose blocks final integration. Replace protective language with direct ranks, deltas, affected metrics, and bounded claims. If evidence is weak, delete the claim or return to optimization.


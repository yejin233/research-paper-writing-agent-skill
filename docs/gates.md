# Hard Gates

The skill uses gates as blocking constraints. If a gate artifact is missing, the workflow stops and creates or repairs the artifact before continuing.

## Startup Hygiene

The installed skill may drift behind the latest GitHub version. This is not a
blocking gate, but it should be checked at the first call of a long-running
workflow when the skill root is available:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1
```

If the status is `warn`, recommend updating the installed skill before a
long-running autonomous workflow. If the status is `unavailable`, continue and
note that the latest published version could not be verified.

## Runtime Protocol Anchor

Long-running workflows must maintain `paper/protocol_state.md`. Before any gated action, the Coordinator checks current phase, allowed next actions, blocked actions, external audit route, required artifacts, gate status, last supervision, and drift risk. If the intended action is not explicitly allowed, or if the first-call external audit route is unanswered, the next action is protocol repair.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
```

## Major Gates

- Manuscript Intent Gate
- Runtime Protocol Anchor
- Remote Audit Window Intake
- Project Identity Gate
- Phase Gate
- Pre-registered Experiment License
- Experiment License Schema Check
- Experiment Analysis Depth Gate
- Failed-Result Optimization Gate
- Ablation Kill Rule
- Result Auditor Verdict
- Result Ledger Recalculation Check
- Defensive Writing Zero-Tolerance Gate
- Writing Conformance Gate
- Fail-Closed Writing Entry Gate
- Manuscript Prose Scanner
- Role Boundary Write Barrier
- Workflow Supervision Audit
- Optional External GPT Reviewer checkpoints

## Method Paper Rule

If the frozen paper type is `method_paper`, the autonomous workflow must not silently convert the manuscript into a boundary study, negative-result paper, benchmark, survey, or position paper. Weak evidence can trigger optimization, claim deletion, redesign, reframe_required, or kill, but not silent paper-type conversion.

## Failed Results

Failed or mixed results are first optimization signals. Before writing failure prose, the workflow must diagnose root cause, propose repair candidates, and run the cheapest licensed repair test when repair is plausible.

## Experiment License Schema

Claim-affecting experiments must use `experiment_license.yaml`, not only a
free-form Markdown note. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-license.ps1 -ProjectRoot .
```

The checker requires primary metric, metric direction, claim IDs, source paths,
budget, success criterion, kill criterion, failure action, and simple controls.

## Experiment Analysis

Reported numbers are not enough for Experiments writing. Before drafting result
interpretation, create `experiment_analysis_audit.md` and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-experiment-analysis.ps1 -ProjectRoot .
```

The checker requires one Experiment Analysis Unit per interpreted result, with
claim tested, reviewer question, primary observation, strongest-baseline
comparison, mechanism interpretation, alternative explanation, evidence against
that explanation, boundary condition, weak case, claim implication, and required
prose.

## Result Ledger

`result_audit.md` is a human verdict. `result_ledger.jsonl` is the source-backed
ledger used for machine checks. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-result-audit.ps1 -ProjectRoot .
```

The checker traces result IDs to source CSV rows, recomputes reported values,
checks ranks and best markers, and blocks unsupported or contradicted claims.

## Defensive Writing

Defensive prose blocks final integration. Replace protective language with direct ranks, deltas, affected metrics, and bounded claims. If evidence is weak, delete the claim or return to optimization.

## Writing Entry

Writing is fail-closed. Before drafting, rewriting, polishing, or integrating manuscript prose, the workflow must have frozen paper intent, claim-evidence mapping, section contracts, and trusted evidence paths. Experiments/Results and result-bearing Abstract/Introduction/Conclusion sentences additionally require `result_audit.md`.

At writing-stage setup, copy the skill-provided checkers into the paper project's
`scripts/` directory. Then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
powershell -ExecutionPolicy Bypass -File .\scripts\check-writing-gate.ps1 -ProjectRoot .
```

If the checker fails, the next action is to repair artifacts, not to write prose.

## Manuscript Prose And Role Boundary

Before final integration, scan the produced `.tex` files and enforce the
Coordinator write barrier:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-manuscript-prose.ps1 -ProjectRoot .
powershell -ExecutionPolicy Bypass -File .\scripts\check-role-boundaries.ps1 -ProjectRoot .
```

The prose scanner catches internal route names, leaked configuration text,
defensive phrases, overclaiming phrases, and forbidden paper-type drift. The
role-boundary checker blocks protected manuscript edits unless a Coordinator
integration trace exists.

# Hard Gates

The skill uses gates as blocking constraints. If a gate artifact is missing, the workflow stops and creates or repairs the artifact before continuing.

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
- Failed-Result Optimization Gate
- Ablation Kill Rule
- Result Auditor Verdict
- Defensive Writing Zero-Tolerance Gate
- Writing Conformance Gate
- Fail-Closed Writing Entry Gate
- Workflow Supervision Audit
- Optional External GPT Reviewer checkpoints

## Method Paper Rule

If the frozen paper type is `method_paper`, the autonomous workflow must not silently convert the manuscript into a boundary study, negative-result paper, benchmark, survey, or position paper. Weak evidence can trigger optimization, claim deletion, redesign, reframe_required, or kill, but not silent paper-type conversion.

## Failed Results

Failed or mixed results are first optimization signals. Before writing failure prose, the workflow must diagnose root cause, propose repair candidates, and run the cheapest licensed repair test when repair is plausible.

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

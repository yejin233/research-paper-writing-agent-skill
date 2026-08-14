# Research Workflow Liveness Design

## Problem

The current workflow is fail-closed for both scientific exploration and
publication claims. In long-running autonomous research this allows governance
work to recurse: a review creates a blocker, the repair requires another
review, recovery repeats protocol setup, and no experiment produces evidence
that resolves the uncertainty.

The repair must preserve evidence integrity while guaranteeing progress toward
scientific results.

## Goals

1. Permit bounded exploratory experiments after safety and provenance checks.
2. Keep publication claims, route promotion, and manuscript integration behind
   the existing strict evidence gates.
3. Detect and stop review-only loops before they consume an open-ended budget.
4. Resume from an executable checkpoint after interruption or compaction.
5. Treat scientific, engineering, and governance progress as separate states.
6. Preserve the rule that only complete-dataset evidence may kill or promote a
   route, while allowing smaller runs for debugging and cost estimation.

## Non-Goals

- Weakening label-leakage, workspace, provenance, result-audit, or manuscript
  claim protections.
- Letting smoke tests kill or promote a scientific route.
- Replacing the existing phase model or rewriting all gate scripts.
- Making external reviewers authoritative over local evidence.

## State Model

Protocol state gains a liveness section with these fields:

- `science progress`: latest result-bearing experiment artifact or `none`;
- `engineering progress`: latest implementation or verification artifact;
- `governance progress`: latest gate or review artifact;
- `consecutive governance-only batches`: non-negative integer;
- `active executor`: command/job identifier or `none`;
- `next executable command`: concrete command or `none` with a blocker;
- `task identity`: stable task identifier;
- `workspace identity`: canonical trusted root;
- `resume status`: fresh / resumable / identity-mismatch / externally-blocked.

Engineering tests and governance documents never update `science progress`.

## Two Gate Classes

### Exploration Gate

An exploratory run is allowed when all of the following hold:

- task and workspace identities match;
- inputs and outputs stay inside the authorized boundary;
- test labels cannot influence training, selection, routing, or scoring;
- the command, resource budget, output path, and stop condition are frozen;
- the run cannot create manuscript claims or route promotion by itself.

Novelty proof, final reviewer approval, complete multi-seed coverage, result
audit, and manuscript contracts are not exploration prerequisites.

### Promotion and Publication Gate

Route kill/promotion, result claims, manuscript prose, and final integration
retain the strict existing requirements: complete-dataset decision units,
licensed metrics and controls, result audit, claim-evidence mapping, workflow
supervision, and the relevant writing/review gates.

## Liveness Rules

1. At most two consecutive tool-use batches may produce governance artifacts
   without either running an experiment, implementing an executable test, or
   recording a genuine external blocker.
2. Before a third governance-only batch, the coordinator must execute the
   cheapest allowed falsification action or stop and report the blocker.
3. A reviewer may block exploration only for safety, provenance, leakage,
   destructive-operation, or non-executable-contract failures.
4. Scientific risks must be converted to an executable test with a failure
   criterion and budget. If no such test is possible, record the risk without
   recursively requesting another review.
5. A candidate receives at most one pre-experiment design review. Re-review is
   allowed only after the first result or after a concrete safety defect repair.
6. Review-of-review and supervisor-of-supervisor loops are forbidden.
7. When subagents are used, at least one available execution slot must remain
   for implementation or experiment work.

## Complete-Dataset Semantics

Small runs may validate code paths, estimate resource use, expose numerical
failure, and test whether an implementation can reach the licensed decision
unit. They may not kill, promote, tune, or support a paper claim.

Only the registered complete-dataset unit may produce a route decision. For
multi-entity datasets, selected entities may be used for debugging but never
for route selection.

## Recovery

After interruption, compaction, or service failure, the coordinator first
checks task identity, workspace identity, active jobs, last result artifact,
and `next executable command`.

- If identities match and the checkpoint is valid, resume the command or the
  next allowed action without rebuilding completed gates.
- If identities mismatch, stop before any write and request correction.
- If a job is active, monitor it instead of reopening design review.
- Repeated service failures do not create new scientific blockers.

## Checker Changes

`check-research-liveness.ps1` will validate the required liveness fields and
reject these states:

- more than two governance-only batches with no executor or external blocker;
- an experiment action with missing safety/provenance prerequisites;
- promotion based on a smoke or partial dataset;
- resumable state with no next executable command;
- task/workspace identity mismatch marked as runnable;
- all available subagent roles assigned to governance while execution is due.

`check-protocol-state.ps1` will distinguish `exploration` from `experiment`
promotion and writing actions. `check-workflow-supervision.ps1` will call the
liveness checker without turning advisory scientific concerns into exploration
blockers.

## Tests

The regression suite will cover:

1. exploration passes with safety fields but without publication review;
2. manuscript/result claims remain blocked in that same state;
3. the third governance-only batch fails when no executor or blocker exists;
4. a concrete external blocker permits a paused state;
5. partial-dataset results cannot kill or promote a route;
6. complete-dataset audited results can advance normally;
7. a valid checkpoint resumes without repeating completed reviews;
8. task or workspace identity mismatch blocks before writes;
9. review recursion and all-reviewer subagent allocation fail liveness checks;
10. existing writing, result-audit, role-boundary, and supervision tests remain
    unchanged and passing.

## Compatibility

Existing protocol files without liveness fields will fail with a targeted
migration message rather than an ambiguous gate error. Existing strict actions
(`writing`, result claims, route promotion, and final integration) retain their
current behavior. No manuscript templates or section-writing rules change.

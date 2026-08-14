# Research Workflow Liveness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an exploration-safe, publication-strict liveness layer that prevents review-only loops and resumes interrupted experiments from a concrete checkpoint.

**Architecture:** A new `check-research-liveness.ps1` owns liveness-state parsing and anti-stall rules. `check-protocol-state.ps1` adds a narrow `exploration` action and delegates its liveness validation, while `check-workflow-supervision.ps1` includes liveness in aggregate checks. Skill prose and examples define the same two-gate semantics; focused PowerShell fixtures prove the intended pass/fail behavior before implementation.

**Tech Stack:** Markdown skill instructions, PowerShell 5.1-compatible gate scripts, PowerShell regression tests.

---

### Task 1: Add Failing Liveness Regression Tests

**Files:**
- Create: `tests/check-research-liveness.ps1`
- Modify: `tests/check-gates.ps1`

- [ ] **Step 1: Create liveness fixtures and assertions**

Create a helper that writes protocol state containing `Research liveness` fields, then assert these cases:

```powershell
Assert-Passes -Name "bounded exploration" -Script {
  & $LivenessChecker -ProjectRoot $root -Action exploration
}

Assert-Blocks -Name "third governance-only batch" -Pattern "governance-only" -Script {
  & $LivenessChecker -ProjectRoot $root -Action exploration
}

Assert-Blocks -Name "partial promotion" -Pattern "complete-dataset" -Script {
  & $LivenessChecker -ProjectRoot $root -Action promotion
}

Assert-Blocks -Name "identity mismatch" -Pattern "identity mismatch" -Script {
  & $LivenessChecker -ProjectRoot $root -Action exploration
}
```

Cover a genuine external blocker, valid resume checkpoint, review recursion, and all-governance subagent allocation as separate assertions.

- [ ] **Step 2: Extend the protocol gate test**

Add a fixture where `exploration` is allowed, the exploration safety gate is `pass`, workflow supervision is not passed, and publication gates are not passed. Assert:

```powershell
& $ProtocolChecker -ProjectRoot $ExploreRoot -Action exploration
Assert-Blocks -Name "exploration cannot write claims" -Pattern "not explicitly allowed|explicitly blocked" -Script {
  & $ProtocolChecker -ProjectRoot $ExploreRoot -Action result-claim
}
```

- [ ] **Step 3: Run tests and verify RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-research-liveness.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-gates.ps1
```

Expected: the first command fails because `scripts/check-research-liveness.ps1` does not exist; the second fails because `exploration` is not a valid protocol action.

### Task 2: Implement the Liveness Checker

**Files:**
- Create: `scripts/check-research-liveness.ps1`
- Test: `tests/check-research-liveness.ps1`

- [ ] **Step 1: Implement protocol discovery and field parsing**

Use the same protocol search paths as `check-protocol-state.ps1`. Require this section and fields:

```markdown
## Research liveness

- task identity: task-123
- workspace identity: C:\trusted\project
- science progress: none
- engineering progress: tests/test_method.py
- governance progress: paper/handoffs/design_review.md
- consecutive governance-only batches: 1
- active executor: none
- next executable command: python run_smoke.py
- external blocker: none
- resume status: resumable
- decision unit: complete-dataset
- current evidence scope: smoke-only
- subagent allocation: execution=1, governance=1
- review depth: 1
```

- [ ] **Step 2: Implement anti-stall rules**

For `exploration`, reject identity mismatch, unresolved placeholders, unsafe resume state, governance count greater than two without an executor or external blocker, review depth greater than one before first results, and allocation with zero execution slots when execution is due.

For `promotion`, additionally require `decision unit: complete-dataset`, `current evidence scope: complete-dataset`, and non-`none` science progress.

- [ ] **Step 3: Run focused test and verify GREEN**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-research-liveness.ps1
```

Expected: `Research liveness checks completed.` with exit code 0.

### Task 3: Integrate Exploration Into Existing Gates

**Files:**
- Modify: `scripts/check-protocol-state.ps1`
- Modify: `scripts/check-workflow-supervision.ps1`
- Test: `tests/check-gates.ps1`

- [ ] **Step 1: Add protocol actions**

Extend the action set with `exploration` and `promotion`. For `exploration`, require only:

```powershell
Require-GatePass -GateStatusBody $GateStatus -Label "exploration safety"
& (Join-Path $PSScriptRoot "check-research-liveness.ps1") -ProjectRoot $Root -Action exploration | Out-Null
```

Do not require a passed Workflow Supervisor decision for exploration. Keep existing requirements for `experiment`, `result-claim`, `writing`, phase transition, and final integration. `promotion` requires workflow supervision, experiment license, and liveness promotion validation.

- [ ] **Step 2: Add aggregate liveness checking**

In `check-workflow-supervision.ps1`, invoke the new checker when a protocol state contains a `Research liveness` section. Use `Action general` so aggregate supervision validates state shape without changing the requested scientific action.

- [ ] **Step 3: Run protocol and liveness tests**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-gates.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-research-liveness.ps1
```

Expected: both scripts exit 0.

### Task 4: Update Runtime Instructions and Examples

**Files:**
- Modify: `SKILL.md`
- Modify: `references/experiment-workflow.md`
- Modify: `references/review-workflow.md`
- Modify: `examples/protocol_state.example.md`
- Modify: `docs/gates.md`
- Modify: `docs/workflow.md`

- [ ] **Step 1: Add the two-gate rule to SKILL.md**

Add a concise `Research Liveness and Two-Gate Autonomy` section near the runtime protocol anchor. State that exploration safety does not require novelty proof, final review, result audit, or complete-dataset evidence; those remain mandatory for promotion, claims, and writing.

Replace the unconditional every-three-batches supervision refresh with: update protocol state every three batches, but after two governance-only batches the next batch must execute, implement an executable falsification test, or record a real external blocker.

- [ ] **Step 2: Define experiment and review boundaries**

In `references/experiment-workflow.md`, distinguish debug/smoke evidence from complete-dataset route decisions and require every scientific blocker to map to a bounded executable test.

In `references/review-workflow.md`, limit pre-result review depth to one, forbid review-of-review, and make external review advisory for exploration.

- [ ] **Step 3: Update example state and operational docs**

Add the complete `Research liveness` section to `examples/protocol_state.example.md`. Document the exploration/promotion gate matrix in `docs/gates.md` and interruption recovery sequence in `docs/workflow.md`.

- [ ] **Step 4: Run reference and gate checks**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check-reference-routes.ps1 -ProjectRoot .
```

Expected: both commands exit 0.

### Task 5: Document and Verify the Release

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add concise release notes**

Document the new exploration action, liveness state, promotion boundary, and migration requirement. Do not duplicate the detailed workflow reference.

- [ ] **Step 2: Run the full repository verification**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\check-research-liveness.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-gates.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-open-source.ps1
powershell -ExecutionPolicy Bypass -File .\tests\check-skill-update.ps1
git diff --check
```

Expected: every test exits 0 and `git diff --check` reports no whitespace errors.

- [ ] **Step 3: Audit requirements against the approved specification**

Confirm that exploration can proceed without publication review, claims remain strict, governance loops are bounded, partial data cannot decide routes, recovery identities are checked, and existing uncommitted changes remain preserved.

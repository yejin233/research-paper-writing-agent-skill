Scope: this reference governs managed research only. Apply the SKILL.md mode router first; language-only edits do not require these state files, scripts, or gates. Reuse current verified context rather than rereading unchanged documents mechanically.

## Research Liveness and Two-Gate Autonomy

Use two gate classes. The **Exploration Gate** protects workspace identity,
provenance, label boundaries, resource budget, output paths, and stop
conditions. It permits bounded debug, smoke, and falsification runs without a
novelty proof, final reviewer approval, result audit, or complete-dataset
evidence. Run it with `-Action exploration`.

The **Promotion and Publication Gate** remains strict. Only registered
complete-dataset evidence may kill or promote a route. Result claims,
manuscript prose, phase transitions, and final integration still require their
existing supervision and evidence gates. Smoke or selected-entity results may
debug an implementation but may not tune, kill, promote, or support a paper
claim.

Maintain `## Research liveness` in `paper/protocol_state.md` and run
`scripts/check-research-liveness.ps1`. Track science, engineering, and
governance progress separately; tests and handoffs do not count as science
progress. Before results, allow at most one pre-experiment review layer and
forbid review-of-review. A reviewer may block exploration only for safety,
provenance, leakage, destructive-operation, or non-executable-contract defects.
Convert other scientific concerns into a bounded experiment with a failure
criterion, or record them as advisory risks.

After interruption or compaction, verify task identity, workspace identity,
active jobs, the last result artifact, and the next executable command. Resume
valid work instead of rebuilding completed gates. An identity mismatch blocks
all writes. When sub-agents are used before results, retain an execution slot;
do not allocate every slot to reviewers or supervisors.

**Installed Skill Update Check**:
At the first call of a paper workflow, when running from the installed skill
root or a checkout that contains `skill-version.json`, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1
```

This is a non-blocking hygiene check, not a scientific gate. If the result
status is `warn`, tell the user that a newer GitHub skill version exists and
recommend updating before long-running autonomous research workflows. If the
status is `unavailable`, continue the workflow and note that the latest version
could not be verified. Do not block paper work solely because the update check
is behind or unavailable.

If the user explicitly asks whether the installed skill matches the latest
GitHub branch, run the detailed mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-skill-update.ps1 -Detailed
```

Optionally write the result to `skill_update_status.md` or
`paper/handoffs/skill_update_status.md` with `-StatusPath`.

End-to-end pipeline for producing publication-ready ML/AI research papers targeting **NeurIPS, ICML, ICLR, ACL, AAAI, and COLM**. This skill covers the full research lifecycle: experiment design, execution, monitoring, analysis, paper writing, review, revision, and submission.

This is **not a linear pipeline** 鈥?it is an iterative loop. Results trigger new experiments. Reviews trigger new analysis. The coordinating agent must handle these feedback loops while using sub-agents only at high-risk boundaries where isolated search, skepticism, or verification improves quality.

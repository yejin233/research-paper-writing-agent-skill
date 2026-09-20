---
name: research-paper-writing-agent
description: "Use when writing, revising, analyzing, or preparing ML/AI research papers, especially long-running automated research workflows where manuscript constraints, evidence gates, result audits, reviewer simulation, or protocol-drift prevention matter for NeurIPS, ICML, ICLR, ACL, AAAI, COLM, or similar venues."
license: MIT
---

# Research Paper Writing Agent

Select the smallest mode that fulfills the request. Reuse existing author preferences and permissions.

## Mode router

| Task | Behavior |
|---|---|
| Language-only polishing, translation, or formatting | Edit directly from supplied text. Preserve facts, claims, formulas, numbers, citations, and uncertainty. Read the relevant section guide only if needed. Do not initialize protocol files, copy checkers, request an external-review window, or run experiment gates. |
| Drafting or changing scientific claims | Check the specific supporting evidence and flag gaps. Do not invent evidence. Use the target section guide. An existing project-managed gate remains binding; otherwise use a concise task-local evidence check instead of installing the full framework. |
| End-to-end autonomous research or an existing managed research project | Load runtime protocol, liveness, and phase routing; then only the current stage's detailed rules. Preserve the project's evidence, budget, leakage, and promotion gates. |
| External review | Default to internal review. Enable external review only with explicit destination/content authorization. Reuse prior consent; an optional external channel must not delay internal work. |

## Shared boundaries

- No fabricated results, citations, or claims. Keep paper type, protocol, trusted workspace, and evidence scope consistent.
- Do not convert smoke or selected-entity checks into publication evidence. Keep exploration and promotion distinct.
- Continue authorized work without repeat approvals. Ask when a real missing requirement, permission, credential, or resource prevents progress.
- In managed state, `first-call question: not-requested` records the internal default without pretending the user answered. `remote-gpt` requires affirmative authorization.
- The stage files below describe the managed research mode. They do not impose its artifact setup on language-only tasks. Existing project rules still apply.
- Paths to scripts/examples in stage prose are relative to the skill root or the explicit project root, not the stage file's directory.

## Stage references

| Current task | Read only when needed |
|---|---|
| Workflow overview | [Workflow overview](references/stages/00-workflow-overview.md) |
| Runtime Protocol Anchor | [Runtime Protocol Anchor](references/stages/01-runtime-protocol-anchor.md) |
| Research Liveness and Two-Gate Autonomy | [Research Liveness and Two-Gate Autonomy](references/stages/02-research-liveness-and-two-gate-autonomy.md) |
| When To Use This Skill | [When To Use This Skill](references/stages/03-when-to-use-this-skill.md) |
| Core Philosophy | [Core Philosophy](references/stages/04-core-philosophy.md) |
| Protocol Phase Routing | [Protocol Phase Routing](references/stages/05-protocol-phase-routing.md) |
| Reference Documents | [Reference Documents](references/stages/06-reference-documents.md) |

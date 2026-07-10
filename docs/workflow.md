# Workflow Overview

This skill treats research-paper writing as a gated research workflow rather than a linear drafting task.

## Core Flow

1. Project identity and manuscript intent.
2. Installed skill freshness check.
3. Literature review and close-work mapping.
4. Skeptic / Route Killer review.
5. Experiment license with success and kill criteria.
6. Execution and factual result collection.
7. Result audit and claim-evidence mapping.
8. Experiment analysis depth audit before result prose.
9. Failed-result optimization if evidence is weak or contradictory.
10. Section contracts before drafting.
11. Planned-vs-produced writing audit after drafting.
12. Defensive-writing audit.
13. Workflow supervision.
14. Reviewer / Meta-Reviewer panel.
15. Final manuscript integration.

## Key Principle

Sub-agents expand search, create opposition, verify facts, and propose edits. The Research Coordinator owns the paper's main claim, terminology, evidence chain, and final manuscript integration. In multi-agent runs, sub-agents write handoffs or patch proposals; protected manuscript edits require a Coordinator integration trace and must pass `scripts/check-role-boundaries.ps1`.

## Completion Rule

A compiled PDF is not enough. The workflow is complete only when the relevant gates pass, no supervisor blocker remains, the result ledger traces reported numbers to source files, the manuscript prose scanner passes, and the manuscript claims are supported by the evidence chain.

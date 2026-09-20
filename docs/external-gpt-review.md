# External GPT Review

External GPT review is optional. It is an additional quality-control channel for users who have a controllable GPT review page available.

## Optional remote audit intake

Default to internal review without asking. Record `first-call question: not-requested` in managed protocol state. Reuse prior explicit authorization. If external review is requested and the destination or content authorization is missing, ask only for that information. Use `remote-gpt` only after affirmative consent; otherwise continue `internal-only`.

Do not record credentials, cookies, passwords, tokens, or browser storage.

## Review Checkpoints

- Startup / intent
- Literature / route
- Experiment design
- Failed or mixed results
- Section drafting
- Final integration

## Standard Prompt

Use the prompt embedded in `SKILL.md` under `External GPT Reviewer Role`.

The external GPT must evaluate quality and return:

- `Decision: pass / concern / block`
- `Overall quality score: 1-10`
- main quality problems
- unsupported or overstrong claims
- novelty and related-work risks
- methodology problems
- experiment-design or evidence problems
- writing and structure problems
- defensive or vague language
- complete actionable suggestions
- must-fix items before the next phase
- whether Workflow Supervisor should block

## Authority Boundary

External GPT output is advisory. It cannot directly edit the manuscript, override raw evidence, or replace Workflow Supervisor. The Coordinator preserves the review as a handoff; the Workflow Supervisor decides whether it creates a local blocker.

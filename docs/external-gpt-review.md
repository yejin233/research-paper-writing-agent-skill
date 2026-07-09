# External GPT Review

External GPT review is optional. It is an additional quality-control channel for users who have a controllable GPT review page available.

## First-Call Remote Audit Window Intake

At the first call of this skill for a paper workflow, ask:

```text
Do you have a controllable remote GPT review window that Codex may use as an
external audit window for this paper workflow?
```

If yes, record operational details in `external_gpt_reviewer.md` and set
`paper/protocol_state.md` -> `External audit route.mode` to `remote-gpt`.

If no, no usable opening method is provided, or the user does not answer, set
`External audit route.mode` to `internal-only` and continue with the internal
audit route.

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

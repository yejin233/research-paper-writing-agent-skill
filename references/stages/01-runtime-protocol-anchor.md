Scope: this reference governs managed research only. Apply the SKILL.md mode router first; language-only edits do not require these state files, scripts, or gates. Reuse current verified context rather than rereading unchanged documents mechanically.

## Runtime Protocol Anchor

This skill is a state-controlled workflow, not a prose guideline.

Before any non-trivial action, the Coordinator must identify:

1. current phase;
2. current allowed next actions;
3. required gate artifacts;
4. blocked actions;
5. external audit route (`remote-gpt` or `internal-only`);
6. whether the intended action is allowed.

If the intended action is not explicitly allowed by the current protocol state,
stop and repair the protocol state instead.

Refresh `paper/protocol_state.md`:

- at workflow startup;
- when the first-call remote audit window intake is answered;
- before writing or modifying manuscript prose;
- before running experiments that may affect claims;
- before integrating results into claims;
- before declaring a phase complete;
- after every 3 tool-use batches in a long-running task. After two consecutive
  governance-only batches, the next batch must execute an allowed experiment,
  implement an executable falsification test, or record a genuine external
  blocker. Do not start a third governance-only batch.

No manuscript prose may be written unless the writing gate has passed in the
current protocol state. No result claim may be written unless `result_audit.md`
and `result_ledger.jsonl` exist and the result-audit checker can trace reported
values to trusted source files. No phase may advance unless the latest Workflow
Supervision Audit is `pass`. If unsure, choose `block`, not `pass`.

Before a gated action, run the protocol-state checker when available:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-protocol-state.ps1 -ProjectRoot . -Action writing
```

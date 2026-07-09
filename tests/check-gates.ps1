$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$TempRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests"

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $TempRoot "paper") | Out-Null

Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $TempRoot "paper\protocol_state.md")

& (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $TempRoot -Action writing | Out-Null

& (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $TempRoot -Action result-claim | Out-Null

$BlockedRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests-blocked"
Remove-Item -LiteralPath $BlockedRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $BlockedRoot "paper") | Out-Null

$BlockedStatePath = Join-Path $BlockedRoot "paper\protocol_state.md"
@'
# Protocol State

## Current phase

- phase: Phase 5 - Evidence-grounded drafting

## Frozen identity

- paper type: method_paper
- thesis: The method addresses the approved modeling gap with the frozen mechanism.
- core method claim: Claim C1 from `claim_evidence_map.md`.
- forbidden conversions: boundary_study, benchmark, survey, position, negative_result unless the user explicitly approves.

## Allowed next actions

- gate-repair
- workflow-supervision

## Blocked actions

- writing
- paper-type-conversion
- unsupported-claim-writing

## Required artifacts before next action

- paper_claims.md
- claim_evidence_map.md
- section_contracts.md

## Gate status

- manuscript intent: pass
- claim-evidence map: pass
- section contracts: pass
- result audit: pass
- writing gate: pass
- experiment license: pass
- defensive writing: pass
- workflow supervision: pass

## Last supervision

- decision: pass
- unresolved blockers: none

## Drift risk

- risk: high
- reason: Unauthorized writing action should be blocked.
'@ | Set-Content -LiteralPath $BlockedStatePath

$blocked = $false
try {
  & (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $BlockedRoot -Action writing | Out-Null
} catch {
  if ($_.Exception.Message -match "not explicitly allowed|explicitly blocked") {
    $blocked = $true
  } else {
    throw
  }
}

if (-not $blocked) {
  throw "Expected protocol-state checker to block unauthorized writing action."
}

$WritingRoot = Join-Path $env:TEMP "research-paper-writing-agent-writing-gate-tests"
Remove-Item -LiteralPath $WritingRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $WritingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $WritingRoot "paper_claims.md") -Value "# Paper Claims`n`n- Claim C1: The method addresses a specific modeling gap with a frozen paper-facing mechanism, and this claim is bounded by the evidence map before manuscript drafting.`n"
Set-Content -LiteralPath (Join-Path $WritingRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Table 1 metric delta | results/table1.csv |`n"
Copy-Item -LiteralPath (Join-Path $Root "examples\section_contracts.example.md") -Destination (Join-Path $WritingRoot "section_contracts.md")
Set-Content -LiteralPath (Join-Path $WritingRoot "result_audit.md") -Value "# Result Audit`n`nMetric, result, rank, delta, claim support, and evidence boundary are recorded here.`n"

& (Join-Path $Root "scripts\check-writing-gate.ps1") -ProjectRoot $WritingRoot -RequireResults | Out-Null

Write-Output "Gate checks completed."

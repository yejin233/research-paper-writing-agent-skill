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

## External audit route

- first-call question: answered-no
- mode: internal-only
- remote window opening method: none
- internal audit fallback: Workflow Supervisor, Reviewer, Result Auditor, Figure/Table Auditor

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

$UnansweredRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests-unanswered-external-audit"
Remove-Item -LiteralPath $UnansweredRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $UnansweredRoot "paper") | Out-Null
Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $UnansweredRoot "paper\protocol_state.md")
$UnansweredStatePath = Join-Path $UnansweredRoot "paper\protocol_state.md"
$UnansweredState = Get-Content -Raw -LiteralPath $UnansweredStatePath
$UnansweredState = $UnansweredState.Replace("- first-call question: answered-no", "- first-call question: unanswered")
Set-Content -LiteralPath $UnansweredStatePath -Value $UnansweredState

$externalAuditBlocked = $false
try {
  & (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $UnansweredRoot -Action writing | Out-Null
} catch {
  if ($_.Exception.Message -match "first-call question must be answered") {
    $externalAuditBlocked = $true
  } else {
    throw
  }
}

if (-not $externalAuditBlocked) {
  throw "Expected protocol-state checker to block workflow before remote audit intake is answered."
}

$BadRemoteRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests-bad-remote-audit"
Remove-Item -LiteralPath $BadRemoteRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $BadRemoteRoot "paper") | Out-Null
Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $BadRemoteRoot "paper\protocol_state.md")
$BadRemoteStatePath = Join-Path $BadRemoteRoot "paper\protocol_state.md"
$BadRemoteState = Get-Content -Raw -LiteralPath $BadRemoteStatePath
$BadRemoteState = $BadRemoteState.Replace("- first-call question: answered-no", "- first-call question: answered-yes")
$BadRemoteState = $BadRemoteState.Replace("- mode: internal-only", "- mode: remote-gpt")
Set-Content -LiteralPath $BadRemoteStatePath -Value $BadRemoteState

$badRemoteBlocked = $false
try {
  & (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $BadRemoteRoot -Action writing | Out-Null
} catch {
  if ($_.Exception.Message -match "opening method is not usable") {
    $badRemoteBlocked = $true
  } else {
    throw
  }
}

if (-not $badRemoteBlocked) {
  throw "Expected protocol-state checker to block remote-gpt mode without a usable opening method."
}

$WritingRoot = Join-Path $env:TEMP "research-paper-writing-agent-writing-gate-tests"
Remove-Item -LiteralPath $WritingRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $WritingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $WritingRoot "paper_claims.md") -Value "# Paper Claims`n`n- Claim C1: The method addresses a specific modeling gap with a frozen paper-facing mechanism, and this claim is bounded by the evidence map before manuscript drafting.`n"
Set-Content -LiteralPath (Join-Path $WritingRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Table 1 metric delta | results/table1.csv |`n"
Copy-Item -LiteralPath (Join-Path $Root "examples\section_contracts.example.md") -Destination (Join-Path $WritingRoot "section_contracts.md")
Set-Content -LiteralPath (Join-Path $WritingRoot "result_audit.md") -Value "# Result Audit`n`nMetric, result, rank, delta, claim support, and evidence boundary are recorded here.`n"

& (Join-Path $Root "scripts\check-writing-gate.ps1") -ProjectRoot $WritingRoot -RequireResults | Out-Null

$MissingReferenceRoot = Join-Path $env:TEMP "research-paper-writing-agent-writing-gate-missing-reference"
Remove-Item -LiteralPath $MissingReferenceRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $MissingReferenceRoot | Out-Null
Set-Content -LiteralPath (Join-Path $MissingReferenceRoot "paper_claims.md") -Value "# Paper Claims`n`n- Claim C1: The method addresses a specific modeling gap with a frozen paper-facing mechanism.`n"
Set-Content -LiteralPath (Join-Path $MissingReferenceRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Literature gap and method design | literature_matrix.md |`n"
$BadContracts = Get-Content -Raw -LiteralPath (Join-Path $Root "examples\section_contracts.example.md")
$BadContracts = $BadContracts.Replace('`references/section-writing/introduction.md`', '`references/section-writing/general.md`')
Set-Content -LiteralPath (Join-Path $MissingReferenceRoot "section_contracts.md") -Value $BadContracts

$referenceBlocked = $false
try {
  & (Join-Path $Root "scripts\check-writing-gate.ps1") -ProjectRoot $MissingReferenceRoot -Sections Introduction | Out-Null
} catch {
  if ($_.Exception.Message -match "required reference path") {
    $referenceBlocked = $true
  } else {
    throw
  }
}

if (-not $referenceBlocked) {
  throw "Expected writing gate to block Introduction without its routed reference."
}

Write-Output "Gate checks completed."

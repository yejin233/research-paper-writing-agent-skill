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
Set-Content -LiteralPath (Join-Path $WritingRoot "result_ledger.jsonl") -Value '{"result_id":"R1","source_path":"results/table1.csv","reported_value":0.91,"metric":"F1","dataset":"demo","method":"ours","metric_direction":"higher_is_better","support_level":"supported","table_cell":"Table 1 / demo / F1"}'

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

$ExperimentRoot = Join-Path $env:TEMP "research-paper-writing-agent-experiment-license-tests"
Remove-Item -LiteralPath $ExperimentRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $ExperimentRoot "results") | Out-Null
@'
experiment_id: exp-main
route_id: route-method
claim_ids:
  - C1
hypothesis: The method improves the declared primary metric under the frozen claim.
primary_metric: F1
metric_direction: higher_is_better
datasets:
  - demo
baselines:
  - base
simple_controls:
  - random-control
source_paths:
  - results/main.csv
expected_outputs:
  - result_ledger.jsonl
budget: one smoke run
success_criterion: Ours ranks first on F1.
partial_support_policy: Mark partial if Ours ranks second within 1 percent.
kill_criterion: Kill or redesign if Ours is below the simple control.
failure_action: failure_diagnosis_then_repair_test
paper_decision_affected: Claim C1 remains method claim or is weakened.
'@ | Set-Content -LiteralPath (Join-Path $ExperimentRoot "experiment_license.yaml")
Set-Content -LiteralPath (Join-Path $ExperimentRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Licensed experiment exp-main | results/main.csv |`n"
Set-Content -LiteralPath (Join-Path $ExperimentRoot "results\main.csv") -Value "result_id,value`nR1,0.91`n"

& (Join-Path $Root "scripts\check-experiment-license.ps1") -ProjectRoot $ExperimentRoot | Out-Null

$BadExperimentRoot = Join-Path $env:TEMP "research-paper-writing-agent-experiment-license-bad"
Remove-Item -LiteralPath $BadExperimentRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $BadExperimentRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $ExperimentRoot "experiment_license.yaml") -Destination (Join-Path $BadExperimentRoot "experiment_license.yaml")
$BadLicense = Get-Content -Raw -LiteralPath (Join-Path $BadExperimentRoot "experiment_license.yaml")
$BadLicense = $BadLicense.Replace("primary_metric: F1", "primary_metric: ")
Set-Content -LiteralPath (Join-Path $BadExperimentRoot "experiment_license.yaml") -Value $BadLicense

$licenseBlocked = $false
try {
  & (Join-Path $Root "scripts\check-experiment-license.ps1") -ProjectRoot $BadExperimentRoot | Out-Null
} catch {
  if ($_.Exception.Message -match "primary_metric") {
    $licenseBlocked = $true
  } else {
    throw
  }
}

if (-not $licenseBlocked) {
  throw "Expected experiment-license checker to block a missing primary metric."
}

$ResultRoot = Join-Path $env:TEMP "research-paper-writing-agent-result-ledger-tests"
Remove-Item -LiteralPath $ResultRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $ResultRoot "results") | Out-Null
Set-Content -LiteralPath (Join-Path $ResultRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Result R1 | results/main.csv |`n"
Set-Content -LiteralPath (Join-Path $ResultRoot "result_audit.md") -Value "# Result Audit`n`n- Route status: support`n- Supported claims: C1`n- Number/table mismatches: none`n- Ranking/best-marker mismatches: none`n"
Set-Content -LiteralPath (Join-Path $ResultRoot "results\main.csv") -Value "result_id,value`nR1,0.91`nR2,0.82`n"
@'
{"result_id":"R1","source_path":"results/main.csv","reported_value":0.91,"metric":"F1","dataset":"demo","method":"ours","metric_direction":"higher_is_better","claim_ids":["C1"],"support_level":"supported","rank":1,"best_marker":true,"table_cell":"Table 1 / demo / F1"}
{"result_id":"R2","source_path":"results/main.csv","reported_value":0.82,"metric":"F1","dataset":"demo","method":"base","metric_direction":"higher_is_better","claim_ids":[],"support_level":"context","rank":2,"table_cell":"Table 1 / demo / F1"}
'@ | Set-Content -LiteralPath (Join-Path $ResultRoot "result_ledger.jsonl")

& (Join-Path $Root "scripts\check-result-audit.ps1") -ProjectRoot $ResultRoot | Out-Null

$BadResultRoot = Join-Path $env:TEMP "research-paper-writing-agent-result-ledger-bad"
Remove-Item -LiteralPath $BadResultRoot -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath $ResultRoot -Destination $BadResultRoot -Recurse
$BadLedger = Get-Content -Raw -LiteralPath (Join-Path $BadResultRoot "result_ledger.jsonl")
$BadLedger = $BadLedger.Replace('"reported_value":0.91', '"reported_value":0.95')
Set-Content -LiteralPath (Join-Path $BadResultRoot "result_ledger.jsonl") -Value $BadLedger

$resultBlocked = $false
try {
  & (Join-Path $Root "scripts\check-result-audit.ps1") -ProjectRoot $BadResultRoot | Out-Null
} catch {
  if ($_.Exception.Message -match "reported value mismatch") {
    $resultBlocked = $true
  } else {
    throw
  }
}

if (-not $resultBlocked) {
  throw "Expected result-audit checker to block a source/reported value mismatch."
}

$ManuscriptRoot = Join-Path $env:TEMP "research-paper-writing-agent-manuscript-prose-tests"
Remove-Item -LiteralPath $ManuscriptRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $ManuscriptRoot "paper") | Out-Null
Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $ManuscriptRoot "paper\protocol_state.md")
Set-Content -LiteralPath (Join-Path $ManuscriptRoot "paper\main.tex") -Value "\section{Introduction}`nThe promoted route uses window size 256 and step size 8. This boundary study remains competitive."

$proseBlocked = $false
try {
  & (Join-Path $Root "scripts\check-manuscript-prose.ps1") -ProjectRoot $ManuscriptRoot | Out-Null
} catch {
  if ($_.Exception.Message -match "forbidden manuscript prose") {
    $proseBlocked = $true
  } else {
    throw
  }
}

if (-not $proseBlocked) {
  throw "Expected manuscript-prose checker to block internal traces and defensive language."
}

$RoleRoot = Join-Path $env:TEMP "research-paper-writing-agent-role-boundary-tests"
Remove-Item -LiteralPath $RoleRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $RoleRoot | Out-Null
Set-Content -LiteralPath (Join-Path $RoleRoot "changed_files.txt") -Value "paper/main.tex`n"

$roleBlocked = $false
try {
  & (Join-Path $Root "scripts\check-role-boundaries.ps1") -ProjectRoot $RoleRoot -ChangedFilesPath (Join-Path $RoleRoot "changed_files.txt") | Out-Null
} catch {
  if ($_.Exception.Message -match "manuscript write barrier") {
    $roleBlocked = $true
  } else {
    throw
  }
}

if (-not $roleBlocked) {
  throw "Expected role-boundary checker to block manuscript edits without coordinator integration trace."
}

Write-Output "Gate checks completed."

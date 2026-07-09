$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$TempRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests"

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $TempRoot "paper") | Out-Null

Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $TempRoot "paper\protocol_state.md")

& powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $TempRoot -Action writing | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Expected protocol-state writing check to pass." }

& powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $TempRoot -Action result-claim | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Expected protocol-state result-claim check to pass." }

$BlockedRoot = Join-Path $env:TEMP "research-paper-writing-agent-gate-tests-blocked"
Remove-Item -LiteralPath $BlockedRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Join-Path $BlockedRoot "paper") | Out-Null
Copy-Item -LiteralPath (Join-Path $Root "examples\protocol_state.example.md") -Destination (Join-Path $BlockedRoot "paper\protocol_state.md")

$BlockedStatePath = Join-Path $BlockedRoot "paper\protocol_state.md"
(Get-Content -Raw -LiteralPath $BlockedStatePath) -replace "(?m)^- writing$", "- gate-repair" |
  Set-Content -LiteralPath $BlockedStatePath

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$blockedOutput = & powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts\check-protocol-state.ps1") -ProjectRoot $BlockedRoot -Action writing 2>&1
$blockedExit = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

if ($blockedExit -eq 0 -or (($blockedOutput | Out-String) -notmatch "not explicitly allowed")) {
  throw "Expected protocol-state checker to block unauthorized writing action."
}

$WritingRoot = Join-Path $env:TEMP "research-paper-writing-agent-writing-gate-tests"
Remove-Item -LiteralPath $WritingRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $WritingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $WritingRoot "paper_claims.md") -Value "# Paper Claims`n`n- Claim C1: The method addresses a specific modeling gap with a frozen paper-facing mechanism, and this claim is bounded by the evidence map before manuscript drafting.`n"
Set-Content -LiteralPath (Join-Path $WritingRoot "claim_evidence_map.md") -Value "# Claim Evidence Map`n`n| Claim | Evidence | Source |`n| --- | --- | --- |`n| C1 | Table 1 metric delta | results/table1.csv |`n"
Copy-Item -LiteralPath (Join-Path $Root "examples\section_contracts.example.md") -Destination (Join-Path $WritingRoot "section_contracts.md")
Set-Content -LiteralPath (Join-Path $WritingRoot "result_audit.md") -Value "# Result Audit`n`nMetric, result, rank, delta, claim support, and evidence boundary are recorded here.`n"

& powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts\check-writing-gate.ps1") -ProjectRoot $WritingRoot -RequireResults | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Expected writing gate check to pass." }

Write-Output "Gate checks completed."

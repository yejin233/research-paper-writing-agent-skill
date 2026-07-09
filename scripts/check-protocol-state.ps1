param(
  [string]$ProjectRoot = ".",
  [ValidateSet("general", "writing", "result-claim", "experiment", "phase-transition", "final-integration")]
  [string]$Action = "general"
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path

function Find-ProtocolState {
  $candidates = @(
    (Join-Path $Root "paper\protocol_state.md"),
    (Join-Path $Root "protocol_state.md"),
    (Join-Path $Root "handoffs\protocol_state.md"),
    (Join-Path $Root "paper\handoffs\protocol_state.md")
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  return $null
}

function Get-Section {
  param(
    [string]$Text,
    [string]$Heading
  )

  $pattern = "(?is)^##\s+$([regex]::Escape($Heading))\s*(.*?)(?=^##\s+|\z)"
  $match = [regex]::Match($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if (-not $match.Success) {
    throw "protocol_state.md missing section: $Heading"
  }

  $body = $match.Groups[1].Value.Trim()
  if ([string]::IsNullOrWhiteSpace($body)) {
    throw "protocol_state.md section is empty: $Heading"
  }

  return $body
}

function Require-NonPlaceholderLine {
  param(
    [string]$SectionBody,
    [string]$Label,
    [string]$SectionName
  )

  $pattern = "(?im)^\s*-\s*$([regex]::Escape($Label))\s*:\s*(.+?)\s*$"
  $match = [regex]::Match($SectionBody, $pattern)
  if (-not $match.Success) {
    throw "protocol_state.md section '$SectionName' missing field: $Label"
  }

  $value = $match.Groups[1].Value.Trim()
  if (
    [string]::IsNullOrWhiteSpace($value) -or
    $value -eq "TODO" -or
    $value -eq "TBD" -or
    $value -eq "pending" -or
    $value -eq "<fill>"
  ) {
    throw "protocol_state.md field '$Label' in '$SectionName' is not resolved."
  }

  return $value
}

function Require-ListItem {
  param(
    [string]$SectionBody,
    [string]$SectionName
  )

  if ($SectionBody -notmatch "(?im)^\s*-\s*\S+") {
    throw "protocol_state.md section '$SectionName' must contain at least one non-empty list item."
  }
}

function Get-GateStatus {
  param(
    [string]$GateStatusBody,
    [string]$Label
  )

  $pattern = "(?im)^\s*-\s*$([regex]::Escape($Label))\s*:\s*(.+?)\s*$"
  $match = [regex]::Match($GateStatusBody, $pattern)
  if (-not $match.Success) {
    throw "Gate status missing required label: $Label"
  }

  return $match.Groups[1].Value.Trim().ToLowerInvariant()
}

function Require-GatePass {
  param(
    [string]$GateStatusBody,
    [string]$Label
  )

  $status = Get-GateStatus -GateStatusBody $GateStatusBody -Label $Label
  if ($status -notin @("pass", "passed", "complete", "completed")) {
    throw "Gate '$Label' must be pass before action '$Action'. Current status: $status"
  }
}

$ProtocolPath = Find-ProtocolState
if (-not $ProtocolPath) {
  throw "Missing protocol state: expected paper/protocol_state.md or protocol_state.md"
}

$ProtocolText = Get-Content -Raw -LiteralPath $ProtocolPath

$CurrentPhase = Get-Section -Text $ProtocolText -Heading "Current phase"
$FrozenIdentity = Get-Section -Text $ProtocolText -Heading "Frozen identity"
$ExternalAuditRoute = Get-Section -Text $ProtocolText -Heading "External audit route"
$AllowedActions = Get-Section -Text $ProtocolText -Heading "Allowed next actions"
$BlockedActions = Get-Section -Text $ProtocolText -Heading "Blocked actions"
$RequiredArtifacts = Get-Section -Text $ProtocolText -Heading "Required artifacts before next action"
$GateStatus = Get-Section -Text $ProtocolText -Heading "Gate status"
$LastSupervision = Get-Section -Text $ProtocolText -Heading "Last supervision"
$DriftRisk = Get-Section -Text $ProtocolText -Heading "Drift risk"

Require-NonPlaceholderLine -SectionBody $CurrentPhase -Label "phase" -SectionName "Current phase" | Out-Null
Require-NonPlaceholderLine -SectionBody $FrozenIdentity -Label "paper type" -SectionName "Frozen identity" | Out-Null
Require-NonPlaceholderLine -SectionBody $FrozenIdentity -Label "thesis" -SectionName "Frozen identity" | Out-Null
Require-NonPlaceholderLine -SectionBody $FrozenIdentity -Label "core method claim" -SectionName "Frozen identity" | Out-Null
$FirstCallQuestion = Require-NonPlaceholderLine -SectionBody $ExternalAuditRoute -Label "first-call question" -SectionName "External audit route"
$ExternalAuditMode = Require-NonPlaceholderLine -SectionBody $ExternalAuditRoute -Label "mode" -SectionName "External audit route"
Require-ListItem -SectionBody $AllowedActions -SectionName "Allowed next actions"
Require-ListItem -SectionBody $BlockedActions -SectionName "Blocked actions"
Require-ListItem -SectionBody $RequiredArtifacts -SectionName "Required artifacts before next action"
Require-NonPlaceholderLine -SectionBody $LastSupervision -Label "decision" -SectionName "Last supervision" | Out-Null
Require-NonPlaceholderLine -SectionBody $DriftRisk -Label "risk" -SectionName "Drift risk" | Out-Null
Require-NonPlaceholderLine -SectionBody $DriftRisk -Label "reason" -SectionName "Drift risk" | Out-Null

$ExternalAuditMode = $ExternalAuditMode.ToLowerInvariant()
if ($FirstCallQuestion.ToLowerInvariant() -notin @("answered-yes", "answered-no", "declined", "unavailable")) {
  throw "External audit route first-call question must be answered before gated work. Use answered-yes or answered-no."
}

if ($ExternalAuditMode -notin @("remote-gpt", "internal-only")) {
  throw "External audit route mode must be remote-gpt or internal-only. Current mode: $ExternalAuditMode"
}

if ($ExternalAuditMode -eq "remote-gpt") {
  $OpeningMethod = Require-NonPlaceholderLine -SectionBody $ExternalAuditRoute -Label "remote window opening method" -SectionName "External audit route"
  if ($OpeningMethod.ToLowerInvariant() -in @("none", "n/a", "na", "unavailable", "internal-only")) {
    throw "External audit route mode is remote-gpt, but remote window opening method is not usable."
  }
}

if ($ExternalAuditMode -eq "internal-only") {
  Require-NonPlaceholderLine -SectionBody $ExternalAuditRoute -Label "internal audit fallback" -SectionName "External audit route" | Out-Null
}

$ActionToken = $Action.ToLowerInvariant()
if ($ActionToken -ne "general") {
  if ($AllowedActions.ToLowerInvariant() -notmatch "(?m)^\s*-\s*$([regex]::Escape($ActionToken))\s*$") {
    throw "Action '$ActionToken' is not explicitly allowed in protocol_state.md."
  }

  if ($BlockedActions.ToLowerInvariant() -match "(?m)^\s*-\s*$([regex]::Escape($ActionToken))\s*$") {
    throw "Action '$ActionToken' is explicitly blocked in protocol_state.md."
  }
}

$SupervisionDecision = Require-NonPlaceholderLine -SectionBody $LastSupervision -Label "decision" -SectionName "Last supervision"
if ($ActionToken -in @("writing", "result-claim", "experiment", "phase-transition", "final-integration")) {
  if ($SupervisionDecision.ToLowerInvariant() -ne "pass") {
    throw "Last Workflow Supervision decision must be pass before action '$ActionToken'. Current decision: $SupervisionDecision"
  }
  Require-GatePass -GateStatusBody $GateStatus -Label "workflow supervision"
}

switch ($ActionToken) {
  "writing" {
    Require-GatePass -GateStatusBody $GateStatus -Label "manuscript intent"
    Require-GatePass -GateStatusBody $GateStatus -Label "claim-evidence map"
    Require-GatePass -GateStatusBody $GateStatus -Label "section contracts"
    Require-GatePass -GateStatusBody $GateStatus -Label "writing gate"
  }
  "result-claim" {
    Require-GatePass -GateStatusBody $GateStatus -Label "claim-evidence map"
    Require-GatePass -GateStatusBody $GateStatus -Label "result audit"
    Require-GatePass -GateStatusBody $GateStatus -Label "result ledger"
    Require-GatePass -GateStatusBody $GateStatus -Label "writing gate"
  }
  "experiment" {
    Require-GatePass -GateStatusBody $GateStatus -Label "manuscript intent"
    Require-GatePass -GateStatusBody $GateStatus -Label "experiment license"
  }
  "phase-transition" {
    Require-GatePass -GateStatusBody $GateStatus -Label "workflow supervision"
  }
  "final-integration" {
    Require-GatePass -GateStatusBody $GateStatus -Label "manuscript intent"
    Require-GatePass -GateStatusBody $GateStatus -Label "claim-evidence map"
    Require-GatePass -GateStatusBody $GateStatus -Label "section contracts"
    Require-GatePass -GateStatusBody $GateStatus -Label "result audit"
    Require-GatePass -GateStatusBody $GateStatus -Label "result ledger"
    Require-GatePass -GateStatusBody $GateStatus -Label "writing gate"
    Require-GatePass -GateStatusBody $GateStatus -Label "manuscript prose"
    Require-GatePass -GateStatusBody $GateStatus -Label "defensive writing"
    Require-GatePass -GateStatusBody $GateStatus -Label "role boundaries"
  }
}

Write-Output "Protocol state check passed."
Write-Output "Project root: $Root"
Write-Output "Protocol state: $ProtocolPath"
Write-Output "Action: $ActionToken"

param(
  [string]$ProjectRoot = ".",
  [ValidateSet("general", "exploration", "promotion")]
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
    throw "protocol_state.md missing section: $Heading. Migrate from examples/protocol_state.example.md."
  }

  return $match.Groups[1].Value.Trim()
}

function Get-Field {
  param(
    [string]$SectionBody,
    [string]$Label
  )

  $pattern = "(?im)^\s*-\s*$([regex]::Escape($Label))\s*:\s*(.*?)\s*$"
  $match = [regex]::Match($SectionBody, $pattern)
  if (-not $match.Success) {
    throw "Research liveness missing required field: $Label"
  }

  $value = $match.Groups[1].Value.Trim()
  if ([string]::IsNullOrWhiteSpace($value) -or $value.ToLowerInvariant() -in @("todo", "tbd", "pending", "<fill>")) {
    throw "Research liveness field '$Label' is unresolved."
  }

  return $value
}

function Get-NonNegativeInteger {
  param(
    [string]$Value,
    [string]$Label
  )

  $parsed = 0
  if (-not [int]::TryParse($Value, [ref]$parsed) -or $parsed -lt 0) {
    throw "Research liveness field '$Label' must be a non-negative integer. Current value: $Value"
  }

  return $parsed
}

function Test-None {
  param([string]$Value)
  return $Value.ToLowerInvariant() -in @("none", "n/a", "na")
}

$ProtocolPath = Find-ProtocolState
if (-not $ProtocolPath) {
  throw "Missing protocol state: expected paper/protocol_state.md or protocol_state.md"
}

$ProtocolText = Get-Content -Raw -LiteralPath $ProtocolPath
$Liveness = Get-Section -Text $ProtocolText -Heading "Research liveness"

$TaskIdentity = Get-Field -SectionBody $Liveness -Label "task identity"
$WorkspaceIdentity = Get-Field -SectionBody $Liveness -Label "workspace identity"
$ScienceProgress = Get-Field -SectionBody $Liveness -Label "science progress"
$EngineeringProgress = Get-Field -SectionBody $Liveness -Label "engineering progress"
$GovernanceProgress = Get-Field -SectionBody $Liveness -Label "governance progress"
$GovernanceBatches = Get-NonNegativeInteger -Value (Get-Field -SectionBody $Liveness -Label "consecutive governance-only batches") -Label "consecutive governance-only batches"
$ActiveExecutor = Get-Field -SectionBody $Liveness -Label "active executor"
$NextCommand = Get-Field -SectionBody $Liveness -Label "next executable command"
$ExternalBlocker = Get-Field -SectionBody $Liveness -Label "external blocker"
$ResumeStatus = (Get-Field -SectionBody $Liveness -Label "resume status").ToLowerInvariant()
$DecisionUnit = (Get-Field -SectionBody $Liveness -Label "decision unit").ToLowerInvariant()
$EvidenceScope = (Get-Field -SectionBody $Liveness -Label "current evidence scope").ToLowerInvariant()
$Allocation = Get-Field -SectionBody $Liveness -Label "subagent allocation"
$ReviewDepth = Get-NonNegativeInteger -Value (Get-Field -SectionBody $Liveness -Label "review depth") -Label "review depth"

if ($ResumeStatus -notin @("fresh", "resumable", "identity-mismatch", "externally-blocked")) {
  throw "Research liveness resume status is invalid: $ResumeStatus"
}

if ($ResumeStatus -eq "identity-mismatch") {
  throw "Research liveness identity mismatch blocks all writes and execution."
}

if ($WorkspaceIdentity -ne ".") {
  try {
    $declaredWorkspace = [System.IO.Path]::GetFullPath($WorkspaceIdentity).TrimEnd('\', '/')
  } catch {
    throw "Research liveness workspace identity is invalid: $WorkspaceIdentity"
  }

  if (-not $declaredWorkspace.Equals($Root.TrimEnd('\', '/'), [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Research liveness workspace identity mismatch. Declared: $declaredWorkspace; actual: $Root"
  }
}

$hasExecutor = -not (Test-None -Value $ActiveExecutor)
$hasBlocker = -not (Test-None -Value $ExternalBlocker)
$hasScience = -not (Test-None -Value $ScienceProgress)
$hasNextCommand = -not (Test-None -Value $NextCommand)

if ($ResumeStatus -eq "externally-blocked" -and -not $hasBlocker) {
  throw "Research liveness externally-blocked state requires a concrete external blocker."
}

if ($ResumeStatus -eq "resumable" -and -not $hasExecutor -and -not $hasBlocker -and -not $hasNextCommand) {
  throw "Research liveness resumable state requires a next executable command."
}

if ($GovernanceBatches -gt 2 -and -not $hasExecutor -and -not $hasBlocker) {
  throw "Research liveness blocks a third governance-only batch without an active executor or external blocker."
}

if (-not $hasScience -and $ReviewDepth -gt 1) {
  throw "Research liveness forbids review-of-review before results; review depth must not exceed 1."
}

$allocationMatch = [regex]::Match($Allocation, "(?i)^\s*execution\s*=\s*(\d+)\s*,\s*governance\s*=\s*(\d+)\s*$")
if (-not $allocationMatch.Success) {
  throw "Research liveness subagent allocation must use 'execution=N, governance=N'."
}

$executionSlots = [int]$allocationMatch.Groups[1].Value
$governanceSlots = [int]$allocationMatch.Groups[2].Value
if (-not $hasScience -and -not $hasExecutor -and -not $hasBlocker -and $governanceSlots -gt 0 -and $executionSlots -eq 0) {
  throw "Research liveness requires at least one execution slot when governance subagents are active before results."
}

$ActionToken = $Action.ToLowerInvariant()
if ($ActionToken -eq "promotion") {
  if ($DecisionUnit -ne "complete-dataset" -or $EvidenceScope -ne "complete-dataset") {
    throw "Research liveness promotion requires a complete-dataset decision unit and complete-dataset evidence scope."
  }
  if (-not $hasScience) {
    throw "Research liveness promotion requires a result-bearing science progress artifact."
  }
}

Write-Output "Research liveness check passed."
Write-Output "Project root: $Root"
Write-Output "Protocol state: $ProtocolPath"
Write-Output "Action: $ActionToken"
Write-Output "Task identity: $TaskIdentity"
Write-Output "Engineering progress: $EngineeringProgress"
Write-Output "Governance progress: $GovernanceProgress"

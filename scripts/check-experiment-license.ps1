param(
  [string]$ProjectRoot = ".",
  [string]$LicensePath = ""
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path

function Find-Artifact {
  param([string[]]$Names)

  foreach ($name in $Names) {
    $candidates = @(
      (Join-Path $Root $name),
      (Join-Path $Root "paper\$name"),
      (Join-Path $Root "paper\handoffs\$name"),
      (Join-Path $Root "handoffs\$name")
    )

    foreach ($candidate in $candidates) {
      if (Test-Path -LiteralPath $candidate) {
        return (Resolve-Path -LiteralPath $candidate).Path
      }
    }
  }

  return $null
}

function Get-YamlBlock {
  param(
    [string]$Text,
    [string]$Field
  )

  $pattern = "(?ims)^\s*$([regex]::Escape($Field))\s*:\s*(.*?)(?=^\s*[A-Za-z0-9_-]+\s*:|\z)"
  $match = [regex]::Match($Text, $pattern)
  if (-not $match.Success) {
    throw "Experiment License missing required field: $Field"
  }

  return $match.Groups[1].Value.Trim()
}

function Test-Placeholder {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $true
  }

  $normalized = $Value.Trim().ToLowerInvariant()
  return $normalized -in @("todo", "tbd", "pending", "none", "n/a", "na", "<fill>", "[]")
}

function Require-ScalarField {
  param(
    [string]$Text,
    [string]$Field
  )

  $block = Get-YamlBlock -Text $Text -Field $Field
  if ($block -match "(?m)^\s*-") {
    throw "Experiment License field '$Field' must be a scalar value, not a list."
  }

  if (Test-Placeholder -Value $block) {
    throw "Experiment License field '$Field' is missing or unresolved."
  }

  return $block
}

function Get-ListValues {
  param(
    [string]$Text,
    [string]$Field
  )

  $block = Get-YamlBlock -Text $Text -Field $Field
  if (Test-Placeholder -Value $block) {
    throw "Experiment License list field '$Field' is missing or unresolved."
  }

  $values = @()
  foreach ($line in ($block -split "`r?`n")) {
    $trimmed = $line.Trim()
    if ($trimmed -match "^-+\s*(.+?)\s*$") {
      $values += $Matches[1].Trim()
    } elseif ($trimmed -and $trimmed -notmatch "^\s*#") {
      $values += ($trimmed -split ",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
  }

  $values = @($values | Where-Object { -not (Test-Placeholder -Value $_) })
  if ($values.Count -eq 0) {
    throw "Experiment License list field '$Field' must contain at least one concrete item."
  }

  return $values
}

if ([string]::IsNullOrWhiteSpace($LicensePath)) {
  $LicensePath = Find-Artifact -Names @("experiment_license.yaml", "experiment_license.yml", "experiment-license.yaml", "experiment-license.yml")
}

if (-not $LicensePath) {
  throw "Missing Experiment License: expected experiment_license.yaml or experiment_license.yml"
}

$LicensePath = (Resolve-Path -LiteralPath $LicensePath).Path
$LicenseText = Get-Content -Raw -LiteralPath $LicensePath

$RequiredScalars = @(
  "experiment_id",
  "route_id",
  "hypothesis",
  "primary_metric",
  "metric_direction",
  "budget",
  "success_criterion",
  "partial_support_policy",
  "kill_criterion",
  "failure_action",
  "paper_decision_affected"
)

foreach ($field in $RequiredScalars) {
  Require-ScalarField -Text $LicenseText -Field $field | Out-Null
}

$MetricDirection = (Require-ScalarField -Text $LicenseText -Field "metric_direction").ToLowerInvariant()
if ($MetricDirection -notin @("higher_is_better", "lower_is_better")) {
  throw "Experiment License metric_direction must be higher_is_better or lower_is_better."
}

$RequiredLists = @(
  "claim_ids",
  "datasets",
  "baselines",
  "simple_controls",
  "source_paths",
  "expected_outputs"
)

$ListValues = @{}
foreach ($field in $RequiredLists) {
  $ListValues[$field] = @(Get-ListValues -Text $LicenseText -Field $field)
}

$ClaimMapPath = Find-Artifact -Names @("claim_evidence_map.md")
if ($ClaimMapPath) {
  $ClaimMap = Get-Content -Raw -LiteralPath $ClaimMapPath
  foreach ($claimId in $ListValues["claim_ids"]) {
    if ($ClaimMap -notmatch [regex]::Escape($claimId)) {
      throw "Experiment License references claim '$claimId' but claim_evidence_map.md does not contain it."
    }
  }
}

foreach ($sourcePath in $ListValues["source_paths"]) {
  $candidate = $sourcePath
  if (-not [System.IO.Path]::IsPathRooted($candidate)) {
    $candidate = Join-Path $Root $candidate
  }

  if ($candidate -match "[\*\?]") {
    $matches = Get-ChildItem -Path $candidate -ErrorAction SilentlyContinue
    if (-not $matches) {
      throw "Experiment License source_paths entry does not match any file: $sourcePath"
    }
  } elseif (-not (Test-Path -LiteralPath $candidate)) {
    throw "Experiment License source_paths entry does not exist: $sourcePath"
  }
}

$KillCriterion = Require-ScalarField -Text $LicenseText -Field "kill_criterion"
if ($KillCriterion -notmatch "(?i)kill|redesign|reframe|stop|weaken|delete") {
  throw "Experiment License kill_criterion must name a concrete consequence such as kill, redesign, reframe, stop, weaken, or delete."
}

Write-Output "Experiment License check passed."
Write-Output "Project root: $Root"
Write-Output "License: $LicensePath"

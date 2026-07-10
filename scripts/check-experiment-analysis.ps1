param(
  [string]$ProjectRoot = ".",
  [string]$AnalysisPath = ""
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

function Test-Placeholder {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $true
  }

  $normalized = $Value.Trim().ToLowerInvariant()
  return $normalized -in @("todo", "tbd", "pending", "none", "n/a", "na", "<fill>", "[]", "-")
}

function Get-FieldValue {
  param(
    [string]$UnitText,
    [string]$FieldName,
    [string]$UnitName
  )

  $pattern = "(?im)^\s*-\s*$([regex]::Escape($FieldName))\s*:\s*(.+?)\s*$"
  $match = [regex]::Match($UnitText, $pattern)
  if (-not $match.Success) {
    throw "Experiment Analysis Unit '$UnitName' missing required field: $FieldName"
  }

  $value = $match.Groups[1].Value.Trim()
  if (Test-Placeholder -Value $value) {
    throw "Experiment Analysis Unit '$UnitName' has unresolved field: $FieldName"
  }

  return $value
}

if ([string]::IsNullOrWhiteSpace($AnalysisPath)) {
  $AnalysisPath = Find-Artifact -Names @(
    "experiment_analysis_audit.md",
    "experiment-analysis-audit.md",
    "experiment_analysis_units.md",
    "experiment-analysis-units.md"
  )
}

if (-not $AnalysisPath) {
  throw "Missing experiment analysis audit: expected experiment_analysis_audit.md or experiment_analysis_units.md"
}

$AnalysisPath = (Resolve-Path -LiteralPath $AnalysisPath).Path
$AnalysisText = Get-Content -Raw -LiteralPath $AnalysisPath

if ([string]::IsNullOrWhiteSpace($AnalysisText) -or $AnalysisText.Length -lt 200) {
  throw "experiment analysis audit is too small to contain claim-level and mechanism-level analysis."
}

$UnitMatches = [regex]::Matches(
  $AnalysisText,
  '(?ims)^#{2,3}\s*Experiment Analysis Unit\s*:?\s*(.*?)\s*$([\s\S]*?)(?=^#{2,3}\s*Experiment Analysis Unit\s*:|\z)'
)

if ($UnitMatches.Count -eq 0) {
  throw "experiment analysis audit must contain at least one 'Experiment Analysis Unit' heading."
}

$requiredFields = @(
  "Experiment",
  "Claim tested",
  "Reviewer question answered",
  "Primary observation",
  "Strongest baseline comparison",
  "Mechanism interpretation",
  "Alternative explanation",
  "Evidence against alternative explanation",
  "Boundary condition",
  "Failure or weak case",
  "Claim implication",
  "Required prose"
)

$unitIndex = 0
foreach ($match in $UnitMatches) {
  $unitIndex += 1
  $unitName = $match.Groups[1].Value.Trim()
  if ([string]::IsNullOrWhiteSpace($unitName)) {
    $unitName = "unit $unitIndex"
  }

  $unitText = $match.Groups[2].Value
  $fieldValues = @{}

  foreach ($field in $requiredFields) {
    $fieldValues[$field] = Get-FieldValue -UnitText $unitText -FieldName $field -UnitName $unitName
  }

  foreach ($field in @("Reviewer question answered", "Mechanism interpretation", "Alternative explanation", "Evidence against alternative explanation", "Boundary condition", "Required prose")) {
    if ($fieldValues[$field].Length -lt 20) {
      throw "Experiment Analysis Unit '$unitName' field '$field' is too shallow."
    }
  }

  $evidenceText = @(
    $fieldValues["Primary observation"],
    $fieldValues["Strongest baseline comparison"],
    $fieldValues["Evidence against alternative explanation"],
    $fieldValues["Required prose"]
  ) -join " "

  if ($evidenceText -notmatch "(?i)\d|rank|delta|metric|table|figure|dataset|baseline|control") {
    throw "Experiment Analysis Unit '$unitName' must include direct evidence such as a value, rank, delta, metric, table, figure, dataset, baseline, or control."
  }

  if ($fieldValues["Claim implication"] -match "(?i)\b(supports|proves|validates|demonstrates)\b" -and
      $fieldValues["Boundary condition"] -match "(?i)\b(always|universal|all datasets|all settings|all cases|generalizes to all)\b") {
    throw "Experiment Analysis Unit '$unitName' has an overbroad boundary condition for a supporting claim."
  }
}

Write-Output "Experiment analysis check passed."
Write-Output "Project root: $Root"
Write-Output "Experiment analysis audit: $AnalysisPath"
Write-Output "Experiment analysis units: $($UnitMatches.Count)"

param(
  [string]$ProjectRoot = ".",
  [string]$ChangedFilesPath = ""
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path

function Get-ChangedFiles {
  if (-not [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
    if (-not (Test-Path -LiteralPath $ChangedFilesPath)) {
      throw "Changed files list does not exist: $ChangedFilesPath"
    }

    return @(Get-Content -LiteralPath $ChangedFilesPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  }

  $gitDir = Join-Path $Root ".git"
  if (Test-Path -LiteralPath $gitDir) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $output = & git -C $Root -c core.autocrlf=false diff --name-only 2>$null
      if ($LASTEXITCODE -eq 0) {
        return @($output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
      }
    } finally {
      $ErrorActionPreference = $oldPreference
    }
  }

  return @()
}

function Find-CoordinatorTrace {
  $candidates = @(
    (Join-Path $Root "coordinator_integration.md"),
    (Join-Path $Root "revision_trace.md"),
    (Join-Path $Root "paper\coordinator_integration.md"),
    (Join-Path $Root "paper\revision_trace.md"),
    (Join-Path $Root "paper\handoffs\coordinator_integration.md"),
    (Join-Path $Root "handoffs\coordinator_integration.md")
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      $text = Get-Content -Raw -LiteralPath $candidate
      if ($text -match "(?i)Coordinator integration\s*:\s*(approved|yes|pass)" -or
          $text -match "(?i)Manuscript edits\s*:\s*(approved|yes|pass)") {
        return (Resolve-Path -LiteralPath $candidate).Path
      }
    }
  }

  return $null
}

$manifestCandidates = @(
  (Join-Path $Root "handoff_manifest.yaml"),
  (Join-Path $Root "handoff_manifest.yml"),
  (Join-Path $Root "paper\handoff_manifest.yaml"),
  (Join-Path $Root "paper\handoff_manifest.yml"),
  (Join-Path $Root "paper\handoffs\handoff_manifest.yaml"),
  (Join-Path $Root "paper\handoffs\handoff_manifest.yml")
)

foreach ($candidate in $manifestCandidates) {
  if (Test-Path -LiteralPath $candidate) {
    $manifestLines = Get-Content -LiteralPath $candidate
    $currentRole = ""
    foreach ($line in $manifestLines) {
      if ($line -match "(?i)^\s*-\s*role\s*:\s*(.+?)\s*$") {
        $currentRole = $Matches[1].Trim()
      }

      if ($line -match "(?i)direct[ _-]?manuscript[ _-]?edit\s*:\s*(yes|true|allowed)") {
        if ($currentRole -notmatch "(?i)^Research Coordinator$") {
          throw "Sub-agent handoff manifest allows direct manuscript edits for '$currentRole'; manuscript write barrier must stay closed."
        }
      }
    }
  }
}

$changedFiles = @(Get-ChangedFiles)
$normalized = @($changedFiles | ForEach-Object { ($_ -replace "\\", "/").Trim() } | Where-Object { $_ })

$protected = @()
foreach ($file in $normalized) {
  if ($file -match "^(paper/)?main\.tex$" -or
      $file -match "^paper/[^/]+\.tex$" -or
      $file -match "^(paper_)?claims\.md$" -or
      $file -match "^claim_evidence_map\.md$") {
    $protected += $file
  }
}

if ($protected.Count -gt 0) {
  $trace = Find-CoordinatorTrace
  if (-not $trace) {
    throw "manuscript write barrier blocked protected edits without coordinator integration trace: $($protected -join ', ')"
  }
}

Write-Output "Role boundary check passed."
Write-Output "Project root: $Root"
Write-Output "Protected changed files: $($protected.Count)"

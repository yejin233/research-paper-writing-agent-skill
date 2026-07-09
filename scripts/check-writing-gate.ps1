param(
  [string]$ProjectRoot = ".",
  [string[]]$Sections = @("Abstract", "Introduction", "Related Work", "Methods", "Experiments"),
  [switch]$RequireResults
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

function Require-Artifact {
  param(
    [string]$Label,
    [string[]]$Names,
    [int]$MinBytes = 80
  )

  $path = Find-Artifact -Names $Names
  if (-not $path) {
    throw "Missing required writing-gate artifact: $Label ($($Names -join ', '))"
  }

  $item = Get-Item -LiteralPath $path
  if ($item.Length -lt $MinBytes) {
    throw "Writing-gate artifact is too small or empty: $Label at $path"
  }

  return $path
}

$ClaimsPath = Require-Artifact -Label "paper claims or project memory" -Names @("paper_claims.md", "project_memory.md")
$EvidencePath = Require-Artifact -Label "claim evidence map" -Names @("claim_evidence_map.md")
$ContractsPath = Require-Artifact -Label "section contracts" -Names @("section_contracts.md", "section_contract.md")

$EvidenceText = Get-Content -Raw -LiteralPath $EvidencePath
if ($EvidenceText -notmatch "(?i)claim" -or $EvidenceText -notmatch "(?i)evidence|source|table|figure|result") {
  throw "claim_evidence_map.md must explicitly mention claims and evidence/source links."
}

$ContractText = Get-Content -Raw -LiteralPath $ContractsPath
$RequiredContractFields = @(
  "Reference path(s) read",
  "Purpose in the paper",
  "Required content moves",
  "Forbidden",
  "Required evidence",
  "Paragraph-level"
)

foreach ($field in $RequiredContractFields) {
  if ($ContractText -notmatch [regex]::Escape($field)) {
    throw "section contracts missing required field: $field"
  }
}

function Get-SectionAliases {
  param([string]$Section)

  switch ($Section.ToLowerInvariant()) {
    "methods" { return @("Methods", "Methodology") }
    "methodology" { return @("Methods", "Methodology") }
    "experiments" { return @("Experiments", "Experiments & Results", "Results") }
    "results" { return @("Experiments", "Experiments & Results", "Results") }
    default { return @($Section) }
  }
}

function Get-ContractSection {
  param(
    [string]$Text,
    [string]$Section
  )

  $aliases = Get-SectionAliases -Section $Section
  $escapedAliases = $aliases | ForEach-Object { [regex]::Escape($_) }
  $headingPattern = $escapedAliases -join "|"
  $pattern = "(?is)^##\s+(?:$headingPattern)\s*(.*?)(?=^##\s+|\z)"
  $match = [regex]::Match($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if (-not $match.Success) {
    throw "section contracts missing target section: $Section"
  }

  return $match.Groups[1].Value
}

function Get-ExpectedReference {
  param([string]$Section)

  switch ($Section.ToLowerInvariant()) {
    "abstract" { return "references/section-writing/general.md" }
    "title" { return "references/section-writing/general.md" }
    "figure 1" { return "references/section-writing/general.md" }
    "limitations" { return "references/section-writing/general.md" }
    "conclusion" { return "references/section-writing/general.md" }
    "discussion" { return "references/section-writing/general.md" }
    "appendix" { return "references/section-writing/general.md" }
    "introduction" { return "references/section-writing/introduction.md" }
    "related work" { return "references/section-writing/related-work.md" }
    "methods" { return "references/section-writing/methodology.md" }
    "methodology" { return "references/section-writing/methodology.md" }
    "experiments" { return "references/section-writing/experiments.md" }
    "results" { return "references/section-writing/experiments.md" }
    default { return $null }
  }
}

foreach ($section in $Sections) {
  $SectionBody = Get-ContractSection -Text $ContractText -Section $section
  $ExpectedReference = Get-ExpectedReference -Section $section
  if ($ExpectedReference) {
    $normalizedBody = $SectionBody -replace "\\", "/"
    if ($normalizedBody -notmatch [regex]::Escape($ExpectedReference)) {
      throw "section '$section' contract must record required reference path: $ExpectedReference"
    }
  }
}

if ($RequireResults) {
  $ResultAuditPath = Require-Artifact -Label "result audit" -Names @("result_audit.md")
  $ResultText = Get-Content -Raw -LiteralPath $ResultAuditPath
  if ($ResultText -notmatch "(?i)metric|result|rank|delta|claim|support") {
    throw "result_audit.md must contain metric/result evidence and claim support boundaries."
  }

  $ResultLedgerPath = Require-Artifact -Label "result ledger" -Names @("result_ledger.jsonl", "result-ledger.jsonl")
  $ResultLedgerText = Get-Content -Raw -LiteralPath $ResultLedgerPath
  if ($ResultLedgerText -notmatch "(?i)result_id" -or $ResultLedgerText -notmatch "(?i)source_path" -or $ResultLedgerText -notmatch "(?i)reported_value") {
    throw "result_ledger.jsonl must contain result_id, source_path, and reported_value entries."
  }
}

Write-Output "Writing gate check passed."
Write-Output "Project root: $Root"
Write-Output "Claims: $ClaimsPath"
Write-Output "Evidence map: $EvidencePath"
Write-Output "Section contracts: $ContractsPath"
if ($RequireResults) {
  Write-Output "Result audit: $ResultAuditPath"
  Write-Output "Result ledger: $ResultLedgerPath"
}

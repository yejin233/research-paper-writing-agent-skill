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

foreach ($section in $Sections) {
  if ($ContractText -notmatch [regex]::Escape($section)) {
    throw "section contracts missing target section: $section"
  }
}

if ($RequireResults) {
  $ResultAuditPath = Require-Artifact -Label "result audit" -Names @("result_audit.md")
  $ResultText = Get-Content -Raw -LiteralPath $ResultAuditPath
  if ($ResultText -notmatch "(?i)metric|result|rank|delta|claim|support") {
    throw "result_audit.md must contain metric/result evidence and claim support boundaries."
  }
}

Write-Output "Writing gate check passed."
Write-Output "Project root: $Root"
Write-Output "Claims: $ClaimsPath"
Write-Output "Evidence map: $EvidencePath"
Write-Output "Section contracts: $ContractsPath"
if ($RequireResults) {
  Write-Output "Result audit: $ResultAuditPath"
}

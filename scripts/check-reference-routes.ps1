param(
  [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path
$SkillPath = Join-Path $Root "SKILL.md"

if (-not (Test-Path -LiteralPath $SkillPath)) {
  throw "Missing SKILL.md at project root."
}

$Skill = Get-Content -Raw -LiteralPath $SkillPath

$RequiredReferences = @(
  "references/literature-workflow.md",
  "references/experiment-workflow.md",
  "references/section-writing/general.md",
  "references/section-writing/introduction.md",
  "references/section-writing/methodology.md",
  "references/section-writing/experiments.md",
  "references/section-writing/related-work.md",
  "references/review-workflow.md"
)

foreach ($rel in $RequiredReferences) {
  $fsPath = Join-Path $Root ($rel -replace "/", "\")
  if (-not (Test-Path -LiteralPath $fsPath)) {
    throw "Missing required routed reference: $rel"
  }

  if ($Skill -notmatch [regex]::Escape($rel)) {
    throw "SKILL.md does not route to required reference: $rel"
  }
}

$RequiredPhrases = @(
  "Reference files are mandatory just-in-time instructions",
  "Reference path(s) read",
  "Section Reference Gate",
  "Required Reference Routing"
)

foreach ($phrase in $RequiredPhrases) {
  if ($Skill -notmatch [regex]::Escape($phrase)) {
    throw "SKILL.md missing reference-gate phrase: $phrase"
  }
}

if ($Skill -match "paper/status\.md") {
  throw "SKILL.md still names legacy paper/status.md; use paper/protocol_state.md only."
}

if ($Skill -match "(?m)^## Phase [0-9]+:") {
  throw "SKILL.md still contains detailed top-level phase manuals; keep details in references."
}

Write-Output "Reference route check passed."
Write-Output "Project root: $Root"
foreach ($rel in $RequiredReferences) {
  Write-Output "Routed reference: $rel"
}

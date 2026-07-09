$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot

$Required = @(
  "SKILL.md",
  "skill-version.json",
  "README.md",
  "LICENSE",
  "examples/paper_intent.example.md",
  "examples/protocol_state.example.md",
  "examples/external_gpt_reviewer.example.md",
  "examples/experiment_license.example.yaml",
  "examples/result_ledger.example.jsonl",
  "examples/handoff_manifest.example.yaml",
  "examples/skill_update_status.example.md",
  "examples/result_audit.example.md",
  "examples/section_contracts.example.md",
  "examples/workflow_supervision_audit.example.md",
  "docs/workflow.md",
  "docs/gates.md",
  "docs/external-gpt-review.md",
  "tests/check-gates.ps1",
  "tests/check-skill-update.ps1",
  "scripts/check-skill-update.ps1",
  "scripts/check-experiment-license.ps1",
  "scripts/check-result-audit.ps1",
  "scripts/check-manuscript-prose.ps1",
  "scripts/check-role-boundaries.ps1",
  "scripts/check-workflow-supervision.ps1",
  "scripts/check-writing-gate.ps1",
  "scripts/check-protocol-state.ps1",
  "scripts/check-reference-routes.ps1",
  "references/literature-workflow.md",
  "references/experiment-workflow.md",
  "references/section-writing/general.md",
  "references/section-writing/introduction.md",
  "references/section-writing/methodology.md",
  "references/section-writing/experiments.md",
  "references/section-writing/related-work.md",
  "references/review-workflow.md"
)

foreach ($rel in $Required) {
  $path = Join-Path $Root $rel
  if (-not (Test-Path $path)) {
    throw "Missing required file: $rel"
  }
}

$Skill = Get-Content -Raw (Join-Path $Root "SKILL.md")
$RequiredAnchors = @(
  "name: research-paper-writing-agent",
  "External GPT Reviewer Role",
  "Remote Audit Window Intake",
  "Installed Skill Update Check",
  "Workflow Supervisor Role",
  "Runtime Protocol Anchor",
  "Failed-Result Optimization Gate",
  "Result Auditor Verdict",
  "Defensive Writing Zero-Tolerance Gate",
  "Writing Conformance Gate",
  "Fail-Closed Writing Entry Gate"
)

foreach ($needle in $RequiredAnchors) {
  if ($Skill -notlike "*$needle*") {
    throw "SKILL.md missing anchor: $needle"
  }
}

$SensitivePatterns = @(
  'C:/Users/lenovo',
  'C:\\Users\\lenovo',
  'OPENAI_API_KEY\s*=',
  'ANTHROPIC_API_KEY\s*=',
  'SECRET_KEY\s*=',
  'ACCESS_TOKEN\s*=',
  'PASSWORD\s*='
)

$ScanFiles = Get-ChildItem $Root -Recurse -File |
  Where-Object {
    $_.FullName -notmatch "\\.git\\" -and
    $_.FullName -notmatch "\\tests\\check-open-source\.ps1$"
  }

$Matches = foreach ($pattern in $SensitivePatterns) {
  $ScanFiles | Select-String -Pattern $pattern -CaseSensitive:$false -ErrorAction SilentlyContinue
}

if ($Matches) {
  Write-Warning "Potential sensitive/local strings found:"
  $Matches | ForEach-Object { Write-Warning "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
  throw "Open-source package check found potential sensitive/local strings."
}

& (Join-Path $Root "scripts\check-reference-routes.ps1") -ProjectRoot $Root | Out-Null

Write-Output "Open-source package check completed."

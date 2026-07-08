$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot

$Required = @(
  "SKILL.md",
  "README.md",
  "LICENSE",
  "examples/paper_intent.example.md",
  "examples/external_gpt_reviewer.example.md",
  "examples/result_audit.example.md",
  "examples/workflow_supervision_audit.example.md",
  "docs/workflow.md",
  "docs/gates.md",
  "docs/external-gpt-review.md"
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
  "Workflow Supervisor Role",
  "Failed-Result Optimization Gate",
  "Defensive Writing Zero-Tolerance Gate",
  "Writing Conformance Gate"
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

Write-Output "Open-source package check completed."

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Checker = Join-Path $Root "scripts\check-research-liveness.ps1"
$SupervisorChecker = Join-Path $Root "scripts\check-workflow-supervision.ps1"
$TempRoot = Join-Path $env:TEMP "research-paper-writing-agent-liveness-tests"

function New-LivenessFixture {
  param(
    [string]$Name,
    [hashtable]$Replacements = @{}
  )

  $fixtureRoot = Join-Path $TempRoot $Name
  New-Item -ItemType Directory -Force -Path (Join-Path $fixtureRoot "paper") | Out-Null

  $state = @'
# Protocol State

## Research liveness

- task identity: task-liveness-test
- workspace identity: .
- science progress: none
- engineering progress: tests/test_method.py
- governance progress: paper/handoffs/design_review.md
- consecutive governance-only batches: 1
- active executor: none
- next executable command: python run_smoke.py
- external blocker: none
- resume status: resumable
- decision unit: complete-dataset
- current evidence scope: smoke-only
- subagent allocation: execution=1, governance=1
- review depth: 1
'@

  foreach ($key in $Replacements.Keys) {
    $state = $state.Replace($key, $Replacements[$key])
  }

  Set-Content -LiteralPath (Join-Path $fixtureRoot "paper\protocol_state.md") -Value $state
  return $fixtureRoot
}

function Assert-Passes {
  param(
    [string]$Name,
    [scriptblock]$Script
  )

  try {
    & $Script | Out-Null
  } catch {
    throw "Expected '$Name' to pass, but it failed: $($_.Exception.Message)"
  }
}

function Assert-Blocks {
  param(
    [string]$Name,
    [string]$Pattern,
    [scriptblock]$Script
  )

  $blocked = $false
  try {
    & $Script | Out-Null
  } catch {
    if ($_.Exception.Message -match $Pattern) {
      $blocked = $true
    } else {
      throw "Expected '$Name' to match '$Pattern', but received: $($_.Exception.Message)"
    }
  }

  if (-not $blocked) {
    throw "Expected '$Name' to be blocked."
  }
}

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

$BoundedRoot = New-LivenessFixture -Name "bounded"
Assert-Passes -Name "bounded exploration" -Script {
  & $Checker -ProjectRoot $BoundedRoot -Action exploration
}

$LoopRoot = New-LivenessFixture -Name "governance-loop" -Replacements @{
  "- consecutive governance-only batches: 1" = "- consecutive governance-only batches: 3"
}
Assert-Blocks -Name "third governance-only batch" -Pattern "governance-only" -Script {
  & $Checker -ProjectRoot $LoopRoot -Action exploration
}

$BlockedRoot = New-LivenessFixture -Name "external-blocker" -Replacements @{
  "- consecutive governance-only batches: 1" = "- consecutive governance-only batches: 4"
  "- next executable command: python run_smoke.py" = "- next executable command: none"
  "- external blocker: none" = "- external blocker: remote GPU is unreachable after verified connection attempts"
  "- resume status: resumable" = "- resume status: externally-blocked"
}
Assert-Passes -Name "genuine external blocker" -Script {
  & $Checker -ProjectRoot $BlockedRoot -Action exploration
}

$PartialRoot = New-LivenessFixture -Name "partial-promotion" -Replacements @{
  "- science progress: none" = "- science progress: results/smoke_metrics.json"
}
Assert-Blocks -Name "partial promotion" -Pattern "complete-dataset" -Script {
  & $Checker -ProjectRoot $PartialRoot -Action promotion
}

$CompleteRoot = New-LivenessFixture -Name "complete-promotion" -Replacements @{
  "- science progress: none" = "- science progress: results/complete_metrics.json"
  "- current evidence scope: smoke-only" = "- current evidence scope: complete-dataset"
}
Assert-Passes -Name "complete-dataset promotion" -Script {
  & $Checker -ProjectRoot $CompleteRoot -Action promotion
}

$MismatchRoot = New-LivenessFixture -Name "identity-mismatch" -Replacements @{
  "- resume status: resumable" = "- resume status: identity-mismatch"
}
Assert-Blocks -Name "identity mismatch" -Pattern "identity mismatch" -Script {
  & $Checker -ProjectRoot $MismatchRoot -Action exploration
}

$ResumeRoot = New-LivenessFixture -Name "missing-resume-command" -Replacements @{
  "- next executable command: python run_smoke.py" = "- next executable command: none"
}
Assert-Blocks -Name "resumable state without command" -Pattern "next executable command" -Script {
  & $Checker -ProjectRoot $ResumeRoot -Action exploration
}

$ReviewLoopRoot = New-LivenessFixture -Name "review-recursion" -Replacements @{
  "- review depth: 1" = "- review depth: 2"
}
Assert-Blocks -Name "review recursion" -Pattern "review depth|review-of-review" -Script {
  & $Checker -ProjectRoot $ReviewLoopRoot -Action exploration
}

$AllocationRoot = New-LivenessFixture -Name "all-governance-allocation" -Replacements @{
  "- subagent allocation: execution=1, governance=1" = "- subagent allocation: execution=0, governance=3"
}
Assert-Blocks -Name "all-governance subagent allocation" -Pattern "execution slot" -Script {
  & $Checker -ProjectRoot $AllocationRoot -Action exploration
}

$AggregateRoot = Join-Path $TempRoot "aggregate-supervision"
New-Item -ItemType Directory -Force -Path (Join-Path $AggregateRoot "paper") | Out-Null
$aggregateState = Get-Content -Raw -LiteralPath (Join-Path $Root "examples\protocol_state.example.md")
Set-Content -LiteralPath (Join-Path $AggregateRoot "paper\protocol_state.md") -Value $aggregateState
Assert-Passes -Name "aggregate supervision with valid liveness" -Script {
  & $SupervisorChecker -ProjectRoot $AggregateRoot
}

$aggregateState = $aggregateState.Replace("- science progress: results/main_metrics.csv", "- science progress: none")
$aggregateState = $aggregateState.Replace("- review depth: 1", "- review depth: 2")
Set-Content -LiteralPath (Join-Path $AggregateRoot "paper\protocol_state.md") -Value $aggregateState
Assert-Blocks -Name "aggregate supervision propagates liveness block" -Pattern "research liveness" -Script {
  & $SupervisorChecker -ProjectRoot $AggregateRoot
}

$requiredDocumentation = @(
  @{ Path = "SKILL.md"; Pattern = "^## Research Liveness and Two-Gate Autonomy$" },
  @{ Path = "SKILL.md"; Pattern = "third governance-only batch" },
  @{ Path = "references\experiment-workflow.md"; Pattern = "^## Debug and Smoke Runs$" },
  @{ Path = "references\review-workflow.md"; Pattern = "^## Review Recursion Circuit Breaker$" },
  @{ Path = "examples\protocol_state.example.md"; Pattern = "^## Research liveness$" },
  @{ Path = "docs\gates.md"; Pattern = "^## Exploration Gate$" },
  @{ Path = "docs\workflow.md"; Pattern = "^## Resume Before Rebuilding$" }
)

foreach ($requirement in $requiredDocumentation) {
  $path = Join-Path $Root $requirement.Path
  $content = Get-Content -Raw -LiteralPath $path
  if ($content -notmatch "(?im)$($requirement.Pattern)") {
    throw "Missing research-liveness documentation anchor '$($requirement.Pattern)' in $($requirement.Path)."
  }
}

Write-Output "Research liveness checks completed."

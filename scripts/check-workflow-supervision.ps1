param(
  [string]$ProjectRoot = ".",
  [string[]]$Sections = @("Abstract", "Introduction", "Related Work", "Methods", "Experiments"),
  [switch]$RequireResults
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Failures = @()
$Passed = @()
$Skipped = @()

function Test-AnyPath {
  param([string[]]$RelativePaths)

  foreach ($rel in $RelativePaths) {
    if (Test-Path -LiteralPath (Join-Path $Root $rel)) {
      return $true
    }
  }

  return $false
}

function Invoke-Gate {
  param(
    [string]$Name,
    [string]$ScriptName,
    [hashtable]$GateParameters = @{},
    [switch]$Optional,
    [bool]$ShouldRun = $true
  )

  $scriptPath = Join-Path $ScriptDir $ScriptName
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    if ($Optional) {
      $script:Skipped += "$Name (missing script)"
      return
    }

    throw "Missing required workflow supervision script: $ScriptName"
  }

  if (-not $ShouldRun) {
    $script:Skipped += "$Name (not applicable)"
    return
  }

  try {
    & $scriptPath @GateParameters | Out-Null
    $script:Passed += $Name
  } catch {
    $script:Failures += "${Name}: $($_.Exception.Message)"
  }
}

Invoke-Gate -Name "protocol state" -ScriptName "check-protocol-state.ps1" -GateParameters @{ ProjectRoot = $Root; Action = "general" } -Optional -ShouldRun (Test-AnyPath -RelativePaths @("paper\protocol_state.md", "protocol_state.md"))

Invoke-Gate -Name "reference routes" -ScriptName "check-reference-routes.ps1" -GateParameters @{ ProjectRoot = $Root } -Optional -ShouldRun (Test-Path -LiteralPath (Join-Path $Root "SKILL.md"))

Invoke-Gate -Name "experiment license" -ScriptName "check-experiment-license.ps1" -GateParameters @{ ProjectRoot = $Root } -Optional -ShouldRun (Test-AnyPath -RelativePaths @("experiment_license.yaml", "experiment_license.yml", "paper\experiment_license.yaml", "paper\experiment_license.yml"))

Invoke-Gate -Name "result audit" -ScriptName "check-result-audit.ps1" -GateParameters @{ ProjectRoot = $Root } -Optional -ShouldRun (Test-AnyPath -RelativePaths @("result_ledger.jsonl", "paper\result_ledger.jsonl"))

$writingArgs = @{ ProjectRoot = $Root; Sections = $Sections }
if ($RequireResults) {
  $writingArgs["RequireResults"] = $true
}
Invoke-Gate -Name "writing gate" -ScriptName "check-writing-gate.ps1" -GateParameters $writingArgs -Optional -ShouldRun (Test-AnyPath -RelativePaths @("section_contracts.md", "section_contract.md", "paper\section_contracts.md", "paper\section_contract.md"))

$hasTex = $false
if (Test-Path -LiteralPath (Join-Path $Root "main.tex")) {
  $hasTex = $true
}
if (Test-Path -LiteralPath (Join-Path $Root "paper")) {
  $texFiles = @(Get-ChildItem -LiteralPath (Join-Path $Root "paper") -Filter "*.tex" -File -ErrorAction SilentlyContinue)
  if ($texFiles.Count -gt 0) {
    $hasTex = $true
  }
}
Invoke-Gate -Name "manuscript prose" -ScriptName "check-manuscript-prose.ps1" -GateParameters @{ ProjectRoot = $Root } -Optional -ShouldRun $hasTex

Invoke-Gate -Name "role boundaries" -ScriptName "check-role-boundaries.ps1" -GateParameters @{ ProjectRoot = $Root } -Optional -ShouldRun ((Test-Path -LiteralPath (Join-Path $Root ".git")) -or (Test-AnyPath -RelativePaths @("changed_files.txt", "paper\changed_files.txt", "handoff_manifest.yaml", "paper\handoff_manifest.yaml")))

if ($Failures.Count -gt 0) {
  Write-Error "Workflow supervision check failed:`n$($Failures -join "`n")"
  throw "workflow supervision failed"
}

Write-Output "Workflow supervision check passed."
Write-Output "Project root: $Root"
Write-Output "Passed gates: $($Passed -join ', ')"
Write-Output "Skipped gates: $($Skipped -join ', ')"

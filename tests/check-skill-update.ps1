$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$TempRoot = Join-Path $env:TEMP "research-paper-writing-agent-skill-update-tests"

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

$LocalRoot = Join-Path $TempRoot "local-skill"
$RemoteRoot = Join-Path $TempRoot "remote-skill"
New-Item -ItemType Directory -Force -Path $LocalRoot | Out-Null
New-Item -ItemType Directory -Force -Path $RemoteRoot | Out-Null

@'
{
  "skill_name": "research-paper-writing-agent",
  "repo_url": "https://github.com/example/research-paper-writing-agent-skill",
  "default_branch": "main",
  "manifest_path": "skill-version.json",
  "version": "0.1.6",
  "released_at": "2026-07-09"
}
'@ | Set-Content -LiteralPath (Join-Path $LocalRoot "skill-version.json")

@'
{
  "skill_name": "research-paper-writing-agent",
  "repo_url": "https://github.com/example/research-paper-writing-agent-skill",
  "default_branch": "main",
  "manifest_path": "skill-version.json",
  "version": "0.1.7",
  "released_at": "2026-07-10"
}
'@ | Set-Content -LiteralPath (Join-Path $RemoteRoot "skill-version.json")

$OutdatedOutput = & (Join-Path $Root "scripts\check-skill-update.ps1") -SkillRoot $LocalRoot -RemoteManifestPath (Join-Path $RemoteRoot "skill-version.json")
$OutdatedText = $OutdatedOutput -join "`n"
if ($OutdatedText -notmatch "Status:\s+warn") {
  throw "Expected update checker to warn when the installed skill version is behind GitHub."
}
if ($OutdatedText -notmatch "Recommendation:\s+update") {
  throw "Expected update checker to recommend updating when the installed skill is behind."
}

$UpToDateRoot = Join-Path $TempRoot "up-to-date-skill"
New-Item -ItemType Directory -Force -Path $UpToDateRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $RemoteRoot "skill-version.json") -Destination (Join-Path $UpToDateRoot "skill-version.json")

$UpToDateOutput = & (Join-Path $Root "scripts\check-skill-update.ps1") -SkillRoot $UpToDateRoot -RemoteManifestPath (Join-Path $RemoteRoot "skill-version.json")
$UpToDateText = $UpToDateOutput -join "`n"
if ($UpToDateText -notmatch "Status:\s+pass") {
  throw "Expected update checker to pass when the installed skill version matches GitHub."
}

$DetailedOutput = & (Join-Path $Root "scripts\check-skill-update.ps1") -SkillRoot $UpToDateRoot -RemoteManifestPath (Join-Path $RemoteRoot "skill-version.json") -Detailed -RemoteHeadCommit "abcdef1234567890"
$DetailedText = $DetailedOutput -join "`n"
if ($DetailedText -notmatch "Detailed commit check:\s+local commit unavailable") {
  throw "Expected detailed update check to report that local commit comparison is unavailable without a local git checkout."
}

$UnavailableOutput = & (Join-Path $Root "scripts\check-skill-update.ps1") -SkillRoot $UpToDateRoot -RemoteManifestPath (Join-Path $RemoteRoot "missing.json")
$UnavailableText = $UnavailableOutput -join "`n"
if ($UnavailableText -notmatch "Status:\s+unavailable") {
  throw "Expected update checker to report unavailable when the remote manifest cannot be read."
}

$MissingLocalRoot = Join-Path $TempRoot "missing-local-skill"
New-Item -ItemType Directory -Force -Path $MissingLocalRoot | Out-Null
$MissingLocalOutput = & (Join-Path $Root "scripts\check-skill-update.ps1") -SkillRoot $MissingLocalRoot -RemoteManifestPath (Join-Path $RemoteRoot "skill-version.json")
$MissingLocalText = $MissingLocalOutput -join "`n"
if ($MissingLocalText -notmatch "Status:\s+unknown-local-version") {
  throw "Expected update checker to report unknown-local-version when the local manifest is missing."
}

Write-Output "Skill update checks completed."

param(
  [string]$SkillRoot = "",
  [string]$LocalManifestPath = "",
  [string]$RemoteManifestPath = "",
  [string]$RemoteManifestUrl = "",
  [string]$RemoteHeadCommit = "",
  [string]$StatusPath = "",
  [switch]$Detailed,
  [int]$TimeoutSec = 15
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
  $SkillRoot = Split-Path -Parent $PSScriptRoot
}

if (Test-Path -LiteralPath $SkillRoot) {
  $SkillRoot = (Resolve-Path -LiteralPath $SkillRoot).Path
}

function New-StatusObject {
  return [ordered]@{
    Status = "unknown-local-version"
    LocalVersion = "unknown"
    LatestGitHubVersion = "unknown"
    LocalCommit = "unknown"
    LatestCommit = "n/a"
    RemoteManifestSource = "unknown"
    Recommendation = "update"
    RecommendationDetail = "Local skill manifest is missing or unreadable. Reinstall or update from GitHub."
    DetailedCommitCheck = "not requested"
  }
}

function Convert-ToVersion {
  param([string]$Text)

  $candidate = $Text.Trim()
  if ($candidate -match '^v') {
    $candidate = $candidate.Substring(1)
  }

  try {
    return [version]$candidate
  } catch {
    return $null
  }
}

function Get-JsonObjectFromPath {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path does not exist: $Path"
  }

  return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
}

function Get-JsonObjectFromUrl {
  param(
    [string]$Url,
    [int]$TimeoutSeconds
  )

  $response = Invoke-WebRequest -UseBasicParsing -Uri $Url -Headers @{ "User-Agent" = "Codex-Skill-Update-Checker" } -TimeoutSec $TimeoutSeconds
  return $response.Content | ConvertFrom-Json
}

function Get-RepoInfo {
  param([string]$RepoUrl)

  $normalized = $RepoUrl.Trim()
  $match = [regex]::Match($normalized, 'github\.com[:/](?<owner>[^/]+)/(?<repo>[^/.]+?)(?:\.git)?/?$')
  if (-not $match.Success) {
    return $null
  }

  return [ordered]@{
    Owner = $match.Groups["owner"].Value
    Repo = $match.Groups["repo"].Value
  }
}

function Get-RawManifestUrl {
  param([object]$Manifest)

  if (-not $Manifest.repo_url -or -not $Manifest.default_branch -or -not $Manifest.manifest_path) {
    return $null
  }

  $repoInfo = Get-RepoInfo -RepoUrl ([string]$Manifest.repo_url)
  if ($null -eq $repoInfo) {
    return $null
  }

  $manifestPath = ([string]$Manifest.manifest_path).TrimStart("/")
  return "https://raw.githubusercontent.com/$($repoInfo.Owner)/$($repoInfo.Repo)/$($Manifest.default_branch)/$manifestPath"
}

function Get-LocalCommit {
  param(
    [string]$Root,
    [object]$Manifest
  )

  if ($Manifest.PSObject.Properties.Name -contains "commit" -and -not [string]::IsNullOrWhiteSpace([string]$Manifest.commit)) {
    return [string]$Manifest.commit
  }

  if (Test-Path -LiteralPath (Join-Path $Root ".git")) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $commit = (& git -C $Root rev-parse HEAD 2>$null)
      if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($commit -join "").Trim())) {
        return ($commit -join "").Trim()
      }
    } finally {
      $ErrorActionPreference = $oldPreference
    }
  }

  return ""
}

function Get-RemoteHeadCommitValue {
  param(
    [object]$Manifest,
    [string]$ForcedCommit,
    [int]$TimeoutSeconds
  )

  if (-not [string]::IsNullOrWhiteSpace($ForcedCommit)) {
    return $ForcedCommit
  }

  $repoInfo = Get-RepoInfo -RepoUrl ([string]$Manifest.repo_url)
  if ($null -eq $repoInfo) {
    return ""
  }

  $branch = [string]$Manifest.default_branch
  if ([string]::IsNullOrWhiteSpace($branch)) {
    return ""
  }

  $url = "https://api.github.com/repos/$($repoInfo.Owner)/$($repoInfo.Repo)/commits/$branch"
  try {
    $json = Get-JsonObjectFromUrl -Url $url -TimeoutSeconds $TimeoutSeconds
    if ($json.sha) {
      return [string]$json.sha
    }
  } catch {
    return ""
  }

  return ""
}

function Write-StatusFile {
  param(
    [string]$Path,
    [hashtable]$Status
  )

  $directory = Split-Path -Parent $Path
  if (-not [string]::IsNullOrWhiteSpace($directory)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
  }

  @(
    "# Skill Update Check",
    "",
    "- Status: $($Status.Status)",
    "- Local version: $($Status.LocalVersion)",
    "- Latest GitHub version: $($Status.LatestGitHubVersion)",
    "- Local commit: $($Status.LocalCommit)",
    "- Latest commit: $($Status.LatestCommit)",
    "- Remote manifest source: $($Status.RemoteManifestSource)",
    "- Recommendation: $($Status.Recommendation)",
    "- Recommendation detail: $($Status.RecommendationDetail)",
    "- Detailed commit check: $($Status.DetailedCommitCheck)"
  ) | Set-Content -LiteralPath $Path
}

function Test-CommitMatch {
  param(
    [string]$Left,
    [string]$Right
  )

  if ([string]::IsNullOrWhiteSpace($Left) -or [string]::IsNullOrWhiteSpace($Right)) {
    return $false
  }

  $leftValue = $Left.Trim().ToLowerInvariant()
  $rightValue = $Right.Trim().ToLowerInvariant()

  return $leftValue -eq $rightValue -or $leftValue.StartsWith($rightValue) -or $rightValue.StartsWith($leftValue)
}

$status = New-StatusObject
$localManifestLoaded = $false

try {
  if ([string]::IsNullOrWhiteSpace($LocalManifestPath)) {
    $LocalManifestPath = Join-Path $SkillRoot "skill-version.json"
  } elseif (-not [System.IO.Path]::IsPathRooted($LocalManifestPath)) {
    $LocalManifestPath = Join-Path $SkillRoot $LocalManifestPath
  }

  $localManifest = Get-JsonObjectFromPath -Path $LocalManifestPath
  if (-not $localManifest.version) {
    throw "Local manifest missing version."
  }
  $localManifestLoaded = $true

  $status.LocalVersion = [string]$localManifest.version
  $status.LocalCommit = Get-LocalCommit -Root $SkillRoot -Manifest $localManifest
  if ([string]::IsNullOrWhiteSpace($status.LocalCommit)) {
    $status.LocalCommit = "unknown"
  }

  if (-not [string]::IsNullOrWhiteSpace($RemoteManifestPath)) {
    $status.RemoteManifestSource = $RemoteManifestPath
    $remoteManifest = Get-JsonObjectFromPath -Path $RemoteManifestPath
  } else {
    if ([string]::IsNullOrWhiteSpace($RemoteManifestUrl)) {
      $RemoteManifestUrl = Get-RawManifestUrl -Manifest $localManifest
    }

    if ([string]::IsNullOrWhiteSpace($RemoteManifestUrl)) {
      throw "Cannot derive remote manifest URL from local manifest."
    }

    $status.RemoteManifestSource = $RemoteManifestUrl
    $remoteManifest = Get-JsonObjectFromUrl -Url $RemoteManifestUrl -TimeoutSeconds $TimeoutSec
  }

  if (-not $remoteManifest.version) {
    throw "Remote manifest missing version."
  }

  $status.LatestGitHubVersion = [string]$remoteManifest.version
  $localVersion = Convert-ToVersion -Text ([string]$localManifest.version)
  $remoteVersion = Convert-ToVersion -Text ([string]$remoteManifest.version)

  if ($null -eq $localVersion -or $null -eq $remoteVersion) {
    $status.Status = "unavailable"
    $status.Recommendation = "check-manually"
    $status.RecommendationDetail = "One of the manifests uses a version format that could not be parsed."
  } elseif ($localVersion -lt $remoteVersion) {
    $status.Status = "warn"
    $status.Recommendation = "update"
    $status.RecommendationDetail = "A newer GitHub skill version is available. Update before long-running autonomous research workflows."
  } elseif ($localVersion -gt $remoteVersion) {
    $status.Status = "local-ahead"
    $status.Recommendation = "none"
    $status.RecommendationDetail = "The installed skill version is newer than the published GitHub manifest."
  } else {
    $status.Status = "pass"
    $status.Recommendation = "none"
    $status.RecommendationDetail = "The installed skill version matches the latest published GitHub version."
  }

  if ($Detailed) {
    $remoteHead = Get-RemoteHeadCommitValue -Manifest $remoteManifest -ForcedCommit $RemoteHeadCommit -TimeoutSeconds $TimeoutSec
    if (-not [string]::IsNullOrWhiteSpace($remoteHead)) {
      $status.LatestCommit = $remoteHead
    }

    if ($status.LocalCommit -eq "unknown") {
      $status.DetailedCommitCheck = "local commit unavailable"
    } elseif ([string]::IsNullOrWhiteSpace($remoteHead)) {
      $status.DetailedCommitCheck = "remote head unavailable"
    } elseif (Test-CommitMatch -Left $status.LocalCommit -Right $remoteHead) {
      $status.DetailedCommitCheck = "local commit matches remote head"
    } else {
      if ($status.Status -eq "pass") {
        $status.Status = "warn"
        $status.Recommendation = "update"
        $status.RecommendationDetail = "The published version matches, but the remote branch has a newer commit than the local skill checkout."
      }
      $status.DetailedCommitCheck = "same version but remote commit differs"
    }
  }
} catch {
  if (-not $localManifestLoaded) {
    $status.Recommendation = "update"
    $status.RecommendationDetail = "Local skill manifest is missing or unreadable. Reinstall or update from GitHub."
  } else {
    $status.Status = "unavailable"
    $status.Recommendation = "check-manually"
    $status.RecommendationDetail = "Could not verify the latest GitHub skill manifest: $($_.Exception.Message)"
  }
}

if (-not [string]::IsNullOrWhiteSpace($StatusPath)) {
  if (-not [System.IO.Path]::IsPathRooted($StatusPath)) {
    $StatusPath = Join-Path $SkillRoot $StatusPath
  }
  Write-StatusFile -Path $StatusPath -Status $status
}

Write-Output "# Skill Update Check"
Write-Output ""
Write-Output "- Status: $($status.Status)"
Write-Output "- Local version: $($status.LocalVersion)"
Write-Output "- Latest GitHub version: $($status.LatestGitHubVersion)"
Write-Output "- Local commit: $($status.LocalCommit)"
Write-Output "- Latest commit: $($status.LatestCommit)"
Write-Output "- Remote manifest source: $($status.RemoteManifestSource)"
Write-Output "- Recommendation: $($status.Recommendation)"
Write-Output "- Recommendation detail: $($status.RecommendationDetail)"
Write-Output "- Detailed commit check: $($status.DetailedCommitCheck)"

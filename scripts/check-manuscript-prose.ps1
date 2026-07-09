param(
  [string]$ProjectRoot = ".",
  [string[]]$ManuscriptPaths = @()
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $ProjectRoot).Path

function Find-ProtocolState {
  $candidates = @(
    (Join-Path $Root "paper\protocol_state.md"),
    (Join-Path $Root "protocol_state.md"),
    (Join-Path $Root "handoffs\protocol_state.md"),
    (Join-Path $Root "paper\handoffs\protocol_state.md")
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  return $null
}

function Get-FrozenPaperType {
  $protocol = Find-ProtocolState
  if (-not $protocol) {
    return ""
  }

  $text = Get-Content -Raw -LiteralPath $protocol
  $match = [regex]::Match($text, "(?im)^\s*-\s*paper type\s*:\s*(\S+)")
  if ($match.Success) {
    return $match.Groups[1].Value.Trim().ToLowerInvariant()
  }

  return ""
}

function Get-ManuscriptFiles {
  if ($ManuscriptPaths.Count -gt 0) {
    $resolved = @()
    foreach ($path in $ManuscriptPaths) {
      $candidate = $path
      if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path $Root $candidate
      }
      if (-not (Test-Path -LiteralPath $candidate)) {
        throw "Manuscript path does not exist: $path"
      }
      $resolved += (Resolve-Path -LiteralPath $candidate).Path
    }
    return $resolved
  }

  $files = @()
  foreach ($candidate in @((Join-Path $Root "paper\main.tex"), (Join-Path $Root "main.tex"))) {
    if (Test-Path -LiteralPath $candidate) {
      $files += (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  $paperDir = Join-Path $Root "paper"
  if (Test-Path -LiteralPath $paperDir) {
    $files += Get-ChildItem -LiteralPath $paperDir -Filter "*.tex" -File -ErrorAction SilentlyContinue |
      ForEach-Object { $_.FullName }
  }

  return @($files | Select-Object -Unique)
}

$Patterns = @(
  @{ Pattern = "(?i)\bpromoted route\b"; Reason = "internal route-selection trace" },
  @{ Pattern = "(?i)\bsame method route\b"; Reason = "internal route-selection trace" },
  @{ Pattern = "(?i)\bselected route\b"; Reason = "internal route-selection trace" },
  @{ Pattern = "(?i)routeqced|qcedtrajectory|trajectoryadaptiv"; Reason = "corrupted internal route identifier" },
  @{ Pattern = "(?i)\binternal draft\b"; Reason = "internal workflow trace" },
  @{ Pattern = "(?i)\bgenerated artifact\b"; Reason = "generated-artifact trace" },
  @{ Pattern = "(?i)\bscore_mode\b"; Reason = "implementation variable leaked into prose" },
  @{ Pattern = "(?i)\bwindow size\s*[=:]?\s*\d+"; Reason = "configuration detail leaked into prose" },
  @{ Pattern = "(?i)\bstep size\s*[=:]?\s*\d+"; Reason = "configuration detail leaked into prose" },
  @{ Pattern = "(?i)\bbatch size\s*[=:]?\s*\d+"; Reason = "configuration detail leaked into prose" },
  @{ Pattern = "(?i)\blearning rate\s*[=:]?\s*[0-9.]+"; Reason = "configuration detail leaked into prose" },
  @{ Pattern = "(?i)\brandom seed\s*[=:]?\s*\d+"; Reason = "configuration detail leaked into prose" },
  @{ Pattern = "(?i)although this does not undermine"; Reason = "defensive writing" },
  @{ Pattern = "(?i)despite (the )?(degradation|drop|failure|not achieving)"; Reason = "defensive writing" },
  @{ Pattern = "(?i)\bstill acceptable\b"; Reason = "defensive writing" },
  @{ Pattern = "(?i)does not affect effectiveness"; Reason = "defensive writing" },
  @{ Pattern = "(?i)\bremains competitive\b"; Reason = "defensive writing" },
  @{ Pattern = "(?i)\bfully demonstrates\b"; Reason = "overclaiming phrase" },
  @{ Pattern = "(?i)\bstrongly proves\b"; Reason = "overclaiming phrase" },
  @{ Pattern = "(?i)validates the superiority"; Reason = "overclaiming phrase" }
)

$frozenPaperType = Get-FrozenPaperType
if ($frozenPaperType -eq "method_paper") {
  $Patterns += @(
    @{ Pattern = "(?i)\bboundary study\b"; Reason = "forbidden method-paper conversion" },
    @{ Pattern = "(?i)\bnegative-result paper\b"; Reason = "forbidden method-paper conversion" },
    @{ Pattern = "(?i)\bbenchmark study\b"; Reason = "forbidden method-paper conversion" },
    @{ Pattern = "(?i)\bsurvey paper\b"; Reason = "forbidden method-paper conversion" },
    @{ Pattern = "(?i)\bposition paper\b"; Reason = "forbidden method-paper conversion" }
  )
}

$files = @(Get-ManuscriptFiles)
if ($files.Count -eq 0) {
  Write-Output "Manuscript prose check skipped: no manuscript .tex files found."
  exit 0
}

$violations = @()
foreach ($file in $files) {
  $lines = Get-Content -LiteralPath $file
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    foreach ($item in $Patterns) {
      if ($line -match $item.Pattern) {
        $relative = $file
        if ($relative.StartsWith($Root)) {
          $relative = $relative.Substring($Root.Length).TrimStart([char[]]@("\", "/"))
        }
        $violations += "${relative}:$($i + 1): $($item.Reason): $($line.Trim())"
      }
    }
  }
}

if ($violations.Count -gt 0) {
  Write-Error "Forbidden manuscript prose found:`n$($violations -join "`n")"
  throw "forbidden manuscript prose found"
}

Write-Output "Manuscript prose check passed."
Write-Output "Project root: $Root"
Write-Output "Files checked: $($files.Count)"

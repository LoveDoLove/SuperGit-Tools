param (
    [Parameter(Mandatory = $true)]
    [string]$RootFolder,

    [int]$MaxDepth = 5,

    [switch]$AutoConfirm,
    [switch]$IncludeDirty,
    [switch]$DryRun,
    [switch]$FetchOnly
)

$ErrorActionPreference = "Stop"
$env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
}

function Get-RepoStatus {
    param([string]$RepoPath)

    Push-Location $RepoPath
    try {
        $branch = (git rev-parse --abbrev-ref HEAD).Trim()
        $dirty = [bool](git status --porcelain)

        $upstream = (git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
        $hasUpstream = ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($upstream))
        $ahead = 0
        $behind = 0

        if ($hasUpstream) {
            $counts = (git rev-list --left-right --count "HEAD...@{u}").Trim()
            if ($counts) {
                $parts = $counts -split "\s+"
                if ($parts.Count -ge 2) {
                    $ahead = [int]$parts[0]
                    $behind = [int]$parts[1]
                }
            }
        }

        $state = "Clean"
        if (-not $hasUpstream) {
            $state = if ($dirty) { "DirtyNoUpstream" } else { "NoUpstream" }
        } elseif ($ahead -gt 0 -and $behind -gt 0) {
            $state = if ($dirty) { "DirtyDiverged" } else { "Diverged" }
        } elseif ($ahead -gt 0) {
            $state = if ($dirty) { "DirtyAhead" } else { "Ahead" }
        } elseif ($behind -gt 0) {
            $state = if ($dirty) { "DirtyBehind" } else { "Behind" }
        } elseif ($dirty) {
            $state = "Dirty"
        }

        return [PSCustomObject]@{
            RepoPath     = $RepoPath
            RepoName     = Split-Path $RepoPath -Leaf
            Branch       = $branch
            Dirty        = $dirty
            HasUpstream  = $hasUpstream
            Ahead        = $ahead
            Behind       = $behind
            State        = $state
        }
    }
    finally {
        Pop-Location
    }
}

function Confirm-Sync {
    param([string]$RepoName)
    $answer = Read-Host "Sync $RepoName? [y/N]"
    return $answer -imatch '^(y|yes)$'
}

if (-not (Test-Path $RootFolder)) {
    throw "Root folder not found: $RootFolder"
}

try {
    $null = git --version
}
catch {
    throw "Git is not installed or not available in PATH."
}

$rootName = Split-Path $RootFolder -Leaf
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$timeStamp = Get-Date -Format "HHmmss"
$logFile = Join-Path $PSScriptRoot "$dateStamp-$timeStamp-$rootName-v4.log"
"Log start: $(Get-Date -Format s)" | Out-File -FilePath $logFile -Encoding UTF8

Write-Section "SuperGit-Tools CLI v4"
Write-Host "Root: $RootFolder"
Write-Host "Log : $logFile"

Write-Host ""
Write-Host "[SCAN] Discovering repositories..." -ForegroundColor Yellow

$gitDirs = Get-ChildItem -Path $RootFolder -Directory -Filter ".git" -Recurse -Depth $MaxDepth -ErrorAction SilentlyContinue
$repoPaths = $gitDirs | ForEach-Object { Split-Path $_.FullName -Parent } | Sort-Object -Unique

if (-not $repoPaths -or $repoPaths.Count -eq 0) {
    Write-Host "No repositories found." -ForegroundColor DarkYellow
    "No repositories found." | Out-File -FilePath $logFile -Append -Encoding UTF8
    exit 0
}

Write-Host "[SCAN] Found $($repoPaths.Count) repositories." -ForegroundColor Green

$total = 0
$synced = 0
$skipped = 0
$failed = 0
$dirtySkipped = 0

foreach ($repoPath in $repoPaths) {
    $total++
    $status = Get-RepoStatus -RepoPath $repoPath
    $line = "[{0}] {1} | {2} | ahead:{3} behind:{4} | branch:{5}" -f $status.State, $status.RepoName, $status.RepoPath, $status.Ahead, $status.Behind, $status.Branch
    Write-Host ""
    Write-Host $line -ForegroundColor White
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8

    if ($status.Dirty -and -not $IncludeDirty) {
        Write-Host "  - Skipped (dirty working tree)." -ForegroundColor DarkYellow
        "  [SKIP] Dirty working tree" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $skipped++
        $dirtySkipped++
        continue
    }

    if (-not $AutoConfirm -and -not (Confirm-Sync -RepoName $status.RepoName)) {
        Write-Host "  - Skipped by user." -ForegroundColor DarkGray
        "  [SKIP] User declined" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $skipped++
        continue
    }

    if ($DryRun) {
        Write-Host "  - DryRun: would sync." -ForegroundColor Cyan
        "  [DRYRUN] Would sync" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $skipped++
        continue
    }

    Push-Location $repoPath
    try {
        "  [CMD] git fetch --all --prune --progress" | Out-File -FilePath $logFile -Append -Encoding UTF8
        git fetch --all --prune --progress | Tee-Object -FilePath $logFile -Append | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "git fetch failed with exit code $LASTEXITCODE"
        }

        if (-not $FetchOnly) {
            "  [CMD] git pull --ff-only --progress" | Out-File -FilePath $logFile -Append -Encoding UTF8
            git pull --ff-only --progress | Tee-Object -FilePath $logFile -Append | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "git pull failed with exit code $LASTEXITCODE"
            }
        }

        Write-Host "  - Synced." -ForegroundColor Green
        "  [OK] Synced" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $synced++
    }
    catch {
        Write-Host "  - Failed: $($_.Exception.Message)" -ForegroundColor Red
        "  [FAIL] $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $failed++
    }
    finally {
        Pop-Location
    }
}

Write-Section "Summary"
Write-Host "Total repos      : $total"
Write-Host "Synced           : $synced" -ForegroundColor Green
Write-Host "Skipped          : $skipped" -ForegroundColor DarkYellow
Write-Host "  Dirty skipped  : $dirtySkipped" -ForegroundColor DarkYellow
Write-Host "Failed           : $failed" -ForegroundColor Red
Write-Host "Log file         : $logFile"

"Summary total=$total synced=$synced skipped=$skipped dirtySkipped=$dirtySkipped failed=$failed" | Out-File -FilePath $logFile -Append -Encoding UTF8

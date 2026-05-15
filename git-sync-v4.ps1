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

. (Join-Path $PSScriptRoot "git-sync-core-v4.ps1")

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
}

function Confirm-Sync {
    param([string]$RepoName)
    $answer = Read-Host "Sync $RepoName? [y/N]"
    return $answer -imatch '^(y|yes)$'
}

if (-not (Test-SgtGitAvailable)) {
    throw "Git is not installed or not available in PATH."
}

$repoPaths = @(Get-SgtRepoPaths -RootFolder $RootFolder -MaxDepth $MaxDepth)

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
    $status = Get-SgtRepoStatus -RepoPath $repoPath
    $line = "[{0}] {1} | {2} | ahead:{3} behind:{4} | branch:{5}" -f $status.State, $status.RepoName, $status.RepoPath, $status.Ahead, $status.Behind, $status.Branch
    Write-Host ""
    Write-Host $line -ForegroundColor White
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8

    if (-not $AutoConfirm -and -not (Confirm-Sync -RepoName $status.RepoName)) {
        Write-Host "  - Skipped by user." -ForegroundColor DarkGray
        "  [SKIP] User declined" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $skipped++
        continue
    }

    try {
        $result = Invoke-SgtRepoSync -RepoPath $repoPath -IncludeDirty:$IncludeDirty -DryRun:$DryRun -FetchOnly:$FetchOnly
        switch ($result.Status) {
            "SkippedDirty" {
                Write-Host "  - Skipped (dirty working tree)." -ForegroundColor DarkYellow
                "  [SKIP] Dirty working tree" | Out-File -FilePath $logFile -Append -Encoding UTF8
                $skipped++
                $dirtySkipped++
            }
            "DryRun" {
                Write-Host "  - DryRun: would sync." -ForegroundColor Cyan
                "  [DRYRUN] Would sync" | Out-File -FilePath $logFile -Append -Encoding UTF8
                $skipped++
            }
            "Fetched" {
                Write-Host "  - Fetched." -ForegroundColor Green
                "  [OK] Fetched" | Out-File -FilePath $logFile -Append -Encoding UTF8
                foreach ($lineOut in $result.FetchOutput) {
                    "$lineOut" | Out-File -FilePath $logFile -Append -Encoding UTF8
                }
                $synced++
            }
            default {
                Write-Host "  - Synced." -ForegroundColor Green
                "  [OK] Synced" | Out-File -FilePath $logFile -Append -Encoding UTF8
                foreach ($lineOut in $result.FetchOutput) {
                    "$lineOut" | Out-File -FilePath $logFile -Append -Encoding UTF8
                }
                foreach ($lineOut in $result.PullOutput) {
                    "$lineOut" | Out-File -FilePath $logFile -Append -Encoding UTF8
                }
                $synced++
            }
        }
    }
    catch {
        Write-Host "  - Failed: $($_.Exception.Message)" -ForegroundColor Red
        "  [FAIL] $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding UTF8
        $failed++
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

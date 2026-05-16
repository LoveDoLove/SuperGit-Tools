Set-StrictMode -Version 2

function Test-SgtGitAvailable {
    try {
        $null = git --version
        return $true
    }
    catch {
        return $false
    }
}

function Get-SgtRepoPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootFolder,

        [int]$MaxDepth = 5
    )

    if (-not (Test-Path -LiteralPath $RootFolder)) {
        throw "Root folder not found: $RootFolder"
    }

    if ($MaxDepth -lt 1) {
        $MaxDepth = 1
    }

    $repoPaths = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath (Join-Path $RootFolder ".git")) {
        [void]$repoPaths.Add($RootFolder)
    }

    $gitDirs = Get-ChildItem -Path $RootFolder -Directory -Filter ".git" -Recurse -Depth $MaxDepth -Force -ErrorAction SilentlyContinue
    foreach ($gitDir in $gitDirs) {
        [void]$repoPaths.Add((Split-Path $gitDir.FullName -Parent))
    }

    return @($repoPaths | Sort-Object -Unique)
}

function Get-SgtRepoDetail {
    param(
        [string]$State,
        [int]$Ahead,
        [int]$Behind,
        [bool]$HasUpstream
    )

    if (-not $HasUpstream) {
        if ($State -eq "DirtyNoUpstream") {
            return "Dirty working tree, no upstream"
        }
        return "No upstream configured"
    }

    switch ($State) {
        "Clean" { return "Up to date" }
        "Dirty" { return "Uncommitted changes" }
        "Ahead" { return "Ahead $Ahead commits" }
        "Behind" { return "Behind $Behind commits" }
        "Diverged" { return "Ahead $Ahead / behind $Behind" }
        "DirtyAhead" { return "Dirty, ahead $Ahead commits" }
        "DirtyBehind" { return "Dirty, behind $Behind commits" }
        "DirtyDiverged" { return "Dirty, ahead $Ahead / behind $Behind" }
        default { return $State }
    }
}

function Get-SgtRepoStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoPath
    )

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
        }
        elseif ($ahead -gt 0 -and $behind -gt 0) {
            $state = if ($dirty) { "DirtyDiverged" } else { "Diverged" }
        }
        elseif ($ahead -gt 0) {
            $state = if ($dirty) { "DirtyAhead" } else { "Ahead" }
        }
        elseif ($behind -gt 0) {
            $state = if ($dirty) { "DirtyBehind" } else { "Behind" }
        }
        elseif ($dirty) {
            $state = "Dirty"
        }

        return [PSCustomObject]@{
            RepoPath    = $RepoPath
            RepoName    = Split-Path $RepoPath -Leaf
            Branch      = $branch
            Dirty       = $dirty
            HasUpstream = $hasUpstream
            Ahead       = $ahead
            Behind      = $behind
            State       = $state
            Detail      = Get-SgtRepoDetail -State $state -Ahead $ahead -Behind $behind -HasUpstream $hasUpstream
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-SgtRepoSync {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,

        [switch]$IncludeDirty,
        [switch]$DryRun,
        [switch]$FetchOnly
    )

    $before = Get-SgtRepoStatus -RepoPath $RepoPath

    if ($before.Dirty -and -not $IncludeDirty) {
        return [PSCustomObject]@{
            RepoPath = $RepoPath
            RepoName = $before.RepoName
            Status   = "SkippedDirty"
            Detail   = "Skipped dirty working tree"
            Success  = $true
            Changed  = $false
            Before   = $before
            After    = $before
        }
    }

    if ($DryRun) {
        return [PSCustomObject]@{
            RepoPath = $RepoPath
            RepoName = $before.RepoName
            Status   = "DryRun"
            Detail   = "Dry run only"
            Success  = $true
            Changed  = $false
            Before   = $before
            After    = $before
        }
    }

    Push-Location $RepoPath
    try {
        $fetchOutput = @(git fetch --all --prune --progress 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "git fetch failed with exit code $LASTEXITCODE"
        }

        $pullOutput = @()
        if (-not $FetchOnly) {
            $pullOutput = @(git pull --ff-only --progress 2>&1)
            if ($LASTEXITCODE -ne 0) {
                throw "git pull failed with exit code $LASTEXITCODE"
            }
        }
    }
    finally {
        Pop-Location
    }

    $after = Get-SgtRepoStatus -RepoPath $RepoPath
    $resultState = if ($FetchOnly) { "Fetched" } else { "Synced" }
    $resultDetail = if ($FetchOnly) { "Fetch completed" } else { "Sync completed" }

    return [PSCustomObject]@{
        RepoPath    = $RepoPath
        RepoName    = $before.RepoName
        Status      = $resultState
        Detail      = $resultDetail
        Success     = $true
        Changed     = $true
        Before      = $before
        After       = $after
        FetchOutput = $fetchOutput
        PullOutput  = $pullOutput
    }
}

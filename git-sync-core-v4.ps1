Set-StrictMode -Version 2

function Get-SgtBackendCommand {
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        return @("uv", "run", "--project", $PSScriptRoot, "python", "-m", "supergit_backend.cli")
    }

    $uvCandidatePaths = @(
        (Join-Path $HOME ".local/bin/uv"),
        (Join-Path $HOME ".cargo/bin/uv"),
        (Join-Path $HOME "AppData/Local/Programs/uv/uv.exe")
    )

    foreach ($uvPath in $uvCandidatePaths) {
        if (Test-Path -LiteralPath $uvPath) {
            return @($uvPath, "run", "--project", $PSScriptRoot, "python", "-m", "supergit_backend.cli")
        }
    }

    throw "uv is not available in PATH."
}

function Invoke-SgtBackend {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $commandParts = Get-SgtBackendCommand
    $exe = $commandParts[0]
    $baseArgs = @($commandParts | Select-Object -Skip 1)

    $output = & $exe @baseArgs @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = if ($output) { ($output -join [Environment]::NewLine) } else { "Backend execution failed." }
        throw $message
    }

    $jsonText = ($output -join "`n").Trim()
    if ([string]::IsNullOrWhiteSpace($jsonText)) {
        throw "Backend returned empty response."
    }

    return ($jsonText | ConvertFrom-Json -Depth 20)
}

function Test-SgtGitAvailable {
    $result = Invoke-SgtBackend -Arguments @("git-available")
    return [bool]$result.Available
}

function Get-SgtRepoPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootFolder,

        [int]$MaxDepth = 5
    )

    $result = Invoke-SgtBackend -Arguments @("repo-paths", "--root-folder", $RootFolder, "--max-depth", "$MaxDepth")
    return @($result.Paths)
}

function Get-SgtRepoStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoPath
    )

    return Invoke-SgtBackend -Arguments @("repo-status", "--repo-path", $RepoPath)
}

function Invoke-SgtRepoSync {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,

        [switch]$IncludeDirty,
        [switch]$DryRun,
        [switch]$FetchOnly
    )

    $args = @("repo-sync", "--repo-path", $RepoPath)
    if ($IncludeDirty) {
        $args += "--include-dirty"
    }
    if ($DryRun) {
        $args += "--dry-run"
    }
    if ($FetchOnly) {
        $args += "--fetch-only"
    }

    return Invoke-SgtBackend -Arguments $args
}

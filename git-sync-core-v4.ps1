<#
.SYNOPSIS
    SuperGit-Tools Core Module v4.0
    Backend communication and git operations wrapper

.DESCRIPTION
    Handles all git operations through async Python backend
    Provides queue-based result collection for non-blocking GUI updates

.NOTES
    Author: SuperGit-Tools
    Requires: PowerShell 5.1+, Python 3.8+, uv package manager
    Version: 4.0
#>

Set-StrictMode -Version 2

# =============================================================================
# CONFIGURATION
# =============================================================================

$Script:BackendPath = Join-Path $PSScriptRoot "src/supergit_backend"
$Script:PythonExe = "python"

# Result queues for async communication
$Script:BackendResultQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:BackendProcesses = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()

# =============================================================================
# BACKEND INITIALIZATION
# =============================================================================

<#
.SYNOPSIS
    Initialize Python backend for first use
#>
function Initialize-Backend {
    try {
        # Check if Python is available
        $pythonVersion = & $Script:PythonExe --version 2>&1
        Write-Verbose "Python available: $pythonVersion"
        
        # Install package in development mode if needed
        if (-not (Test-Path $Script:BackendPath)) {
            Write-Error "Backend source not found at $Script:BackendPath"
            return $false
        }
        
        return $true
    }
    catch {
        Write-Error "Failed to initialize backend: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Invoke backend command and collect results
#>
function Invoke-Backend {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Args = @{}
    )
    
    try {
        $request = @{
            command = $Command
            args = $Args
        } | ConvertTo-Json -Depth 10 -ErrorAction Stop
        
        $process = New-Object System.Diagnostics.ProcessStartInfo
        $process.FileName = $Script:PythonExe
        $process.Arguments = "-m supergit_backend.cli"
        $process.UseShellExecute = $false
        $process.RedirectStandardInput = $true
        $process.RedirectStandardOutput = $true
        $process.RedirectStandardError = $true
        $process.CreateNoWindow = $true
        
        $proc = [System.Diagnostics.Process]::Start($process)
        
        # Send request
        $proc.StandardInput.WriteLine($request)
        $proc.StandardInput.Close()
        
        # Wait for response
        $output = $proc.StandardOutput.ReadToEnd()
        $error = $proc.StandardError.ReadToEnd()
        
        $proc.WaitForExit(30000) | Out-Null
        
        if ($proc.ExitCode -ne 0) {
            throw "Backend exited with code $($proc.ExitCode): $error"
        }
        
        # Parse and return result
        if ($output) {
            $result = ConvertFrom-Json -InputObject $output
            return $result
        }
        
        return @{}
    }
    catch {
        Write-Error "Backend invocation failed: $_"
        return @{ error = $_.Exception.Message }
    }
}

# =============================================================================
# GIT OPERATIONS (Backend Wrapper Functions)
# =============================================================================

<#
.SYNOPSIS
    Check if Git is available
#>
function Test-GitAvailable {
    $result = Invoke-Backend -Command "check-git"
    return $result.available -eq $true
}

<#
.SYNOPSIS
    Discover repositories in a path
#>
function Get-Repositories {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    $result = Invoke-Backend -Command "discover" -Args @{ path = $Path }
    return $result.repos
}

<#
.SYNOPSIS
    Get status of repositories
#>
function Get-RepositoriesStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Paths
    )
    
    $result = Invoke-Backend -Command "status" -Args @{ paths = $Paths }
    return $result.results
}

<#
.SYNOPSIS
    Get status of a single repository
#>
function Get-RepositoryStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    $result = Invoke-Backend -Command "status-single" -Args @{ path = $Path }
    return $result
}

<#
.SYNOPSIS
    Sync repositories
#>
function Sync-Repositories {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Paths,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("fetch", "pull", "both")]
        [string]$Operation = "both"
    )
    
    $result = Invoke-Backend -Command "sync" -Args @{ 
        paths = $Paths
        operation = $Operation
    }
    return $result.results
}

<#
.SYNOPSIS
    Sync a single repository
#>
function Sync-Repository {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("fetch", "pull", "both")]
        [string]$Operation = "both"
    )
    
    $result = Invoke-Backend -Command "sync-single" -Args @{ 
        path = $Path
        operation = $Operation
    }
    return $result
}

# =============================================================================
# EXPORT
# =============================================================================

Export-ModuleMember -Function @(
    "Initialize-Backend",
    "Invoke-Backend",
    "Test-GitAvailable",
    "Get-Repositories",
    "Get-RepositoriesStatus",
    "Get-RepositoryStatus",
    "Sync-Repositories",
    "Sync-Repository"
)

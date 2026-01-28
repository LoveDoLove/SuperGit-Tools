param (
    [Parameter(Mandatory=$true)]
    [string]$ParentFolder
)

# Fix for "Fake" PowerShell errors: Tell Git to send stderr to stdout
$env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"

# 1. Setup paths and filename (yyyy-MM-dd-xxx.log)
$FolderName = Split-Path $ParentFolder -Leaf
$DateStamp = Get-Date -Format "yyyy-MM-dd"
$LogFile = Join-Path $PSScriptRoot "$DateStamp-$FolderName.log"

# Counters for summary
$TotalFound = 0
$TotalSynced = 0
$TotalSkipped = 0
$TotalFailed = 0

# 2. Header
$Header = @"
======================================================
  Git Sync Tool: $FolderName
  Log: $DateStamp-$FolderName.log
======================================================
"@
Write-Host $Header -ForegroundColor Cyan
"Log Start: $(Get-Date)" | Out-File $LogFile

# 3. Main Loop
$SubFolders = Get-ChildItem -Path $ParentFolder -Directory

foreach ($Folder in $SubFolders) {
    $GitPath = Join-Path $Folder.FullName ".git"
    
    if (Test-Path $GitPath) {
        $TotalFound++
        Write-Host "`n[FOUND] $($Folder.Name)" -ForegroundColor Yellow
        
        $Confirm = Read-Host "Confirm sync for $($Folder.Name)? [y/n]"
        
        if ($Confirm -eq 'y') {
            Write-Host "   - Syncing..." -ForegroundColor Gray
            " `n[$((Get-Date).ToLongTimeString())] REPOSITORY: $($Folder.Name)" | Out-File $LogFile -Append
            
            Push-Location $Folder.FullName
            try {
                # Fetch
                " [COMMAND] git fetch --all --progress" | Out-File $LogFile -Append
                git fetch --all --progress | Tee-Object -FilePath $LogFile -Append
                
                # Pull
                " [COMMAND] git pull --progress" | Out-File $LogFile -Append
                git pull --progress | Tee-Object -FilePath $LogFile -Append
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   - Done." -ForegroundColor Green
                    " [RESULT] SUCCESS" | Out-File $LogFile -Append
                    $TotalSynced++
                } else {
                    Write-Host "   - Git returned an exit code: $LASTEXITCODE" -ForegroundColor Red
                    " [RESULT] EXIT CODE $LASTEXITCODE" | Out-File $LogFile -Append
                    $TotalFailed++
                }
            }
            catch {
                Write-Host "   - Script Error. Check logs." -ForegroundColor Red
                " [RESULT] SCRIPT ERROR: $($_.Exception.Message)" | Out-File $LogFile -Append
                $TotalFailed++
            }
            finally {
                Pop-Location
                "------------------------------------------------------" | Out-File $LogFile -Append
            }
        } else {
            Write-Host "   - Skipped." -ForegroundColor DarkGray
            "[$((Get-Date).ToLongTimeString())] SKIPPED: $($Folder.Name)" | Out-File $LogFile -Append
            $TotalSkipped++
        }
    }
}

# 4. Summary Display
$Summary = @"

======================================================
  SYNC SUMMARY
======================================================
  Total Repos Found: $TotalFound
  Successfully Synced: $TotalSynced
  Skipped by User: $TotalSkipped
  Failed/Errors: $TotalFailed
======================================================
Log saved to: $LogFile
"@
Write-Host $Summary -ForegroundColor Cyan
$Summary | Out-File $LogFile -Append
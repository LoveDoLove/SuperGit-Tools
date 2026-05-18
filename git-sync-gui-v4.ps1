<#
.SYNOPSIS
    SuperGit-Tools GUI v4 - Advanced Git Repository Synchronization Tool (v4 Backend Integration)

.DESCRIPTION
    A comprehensive WPF-based GUI for managing and synchronizing multiple Git repositories.
    Features: Async-first architecture, Python backend integration, real-time repo status,
    batch sync operations, persistent settings, logging, and responsive "Friendly Horizon" UI.

.NOTES
    Version: 4.0.0
    Prerequisites: PowerShell 5.1+, Git (in PATH), Python backend via git-sync-core-v4.ps1
    Author: SuperGit-Tools Team
    Last Updated: 2025
#>

param(
    [string]$RootFolder = $env:USERPROFILE,
    [switch]$Portable = $false,
    [switch]$Debug = $false
)

$ErrorActionPreference = "Continue"
$WarningPreference = "SilentlyContinue"

# ============================================================================
# SECTION 1: Core Configuration and Imports
# ============================================================================

$Script:ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:Version = "4.0.0"
$Script:AppName = "SuperGit-Tools GUI v4"

# Dot-source the v4 backend module
$BackendPath = Join-Path $Script:ScriptRoot "git-sync-core-v4.ps1"
if (-not (Test-Path $BackendPath)) {
    [System.Windows.MessageBox]::Show(
        "Backend module not found: $BackendPath`nPlease ensure git-sync-core-v4.ps1 is in the same directory.",
        "Missing Backend",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    exit 1
}

. $BackendPath

# Load required assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Xml")

# ============================================================================
# SECTION 2: Color Palette and Theme ("Friendly Horizon" Light)
# ============================================================================

$Script:Colors = @{
    # Window and background colors
    WindowBackground = "#FFFFFF"
    SecondaryBackground = "#F5F5F5"
    SidebarBackground = "#F0F0F0"
    ControlBackground = "#E8E8E8"
    
    # Text colors
    PrimaryText = "#1A1A1A"
    SecondaryText = "#616161"
    MutedText = "#9E9E9E"
    
    # Accent colors
    AccentPrimary = "#0078D4"
    AccentSecondary = "#50E6FF"
    AccentSuccess = "#27AE60"
    AccentWarning = "#F39C12"
    AccentDanger = "#E74C3C"
    
    # Repository status colors
    StatusClean = "#27AE60"
    StatusDirty = "#F39C12"
    StatusAhead = "#3498DB"
    StatusBehind = "#9B59B6"
    StatusDiverged = "#E74C3C"
    StatusError = "#C0392B"
}

# ============================================================================
# SECTION 3: Settings Management
# ============================================================================

function Get-Settings {
    $SettingsPath = if ($Portable) {
        Join-Path $Script:ScriptRoot "settings.json"
    } else {
        $AppDataPath = Join-Path $env:APPDATA "SuperGit-Tools"
        if (-not (Test-Path $AppDataPath)) { New-Item -ItemType Directory $AppDataPath -Force | Out-Null }
        Join-Path $AppDataPath "settings.json"
    }
    
    $DefaultSettings = @{
        RecentFolders = @()
        LastFolder = ""
        SyncInterval = 300
        MaxParallel = [Math]::Min(4, [Environment]::ProcessorCount)
        LogToFile = $true
        AutoRefresh = $true
        WindowWidth = 1000
        WindowHeight = 700
    }
    
    if (Test-Path $SettingsPath) {
        try {
            $Loaded = Get-Content $SettingsPath -Raw | ConvertFrom-Json -AsHashtable
            $DefaultSettings.Keys | Where-Object { $_ -in $Loaded.Keys } | ForEach-Object {
                $DefaultSettings[$_] = $Loaded[$_]
            }
        } catch { }
    }
    
    $Script:Settings = $DefaultSettings
    return $Script:Settings
}

function Set-Settings {
    $SettingsPath = if ($Portable) {
        Join-Path $Script:ScriptRoot "settings.json"
    } else {
        Join-Path $env:APPDATA "SuperGit-Tools" "settings.json"
    }
    
    $Script:Settings | ConvertTo-Json | Set-Content $SettingsPath -Force
}

function Add-RecentFolder {
    param(
        [Parameter(Mandatory=$true)][string]$FolderPath
    )
    
    $Script:Settings.RecentFolders = @($FolderPath) + @($Script:Settings.RecentFolders | Where-Object { $_ -ne $FolderPath })
    $Script:Settings.RecentFolders = $Script:Settings.RecentFolders | Select-Object -First 10
    $Script:Settings.LastFolder = $FolderPath
    Set-Settings
}

# ============================================================================
# SECTION 4: XAML UI Definition ("Friendly Horizon" Light Theme)
# ============================================================================

$Script:XamlTemplate = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="SuperGit-Tools GUI v4"
    Width="1000" Height="700"
    Background="#FFFFFF"
    Foreground="#1A1A1A"
    WindowStartupLocation="CenterScreen"
    Name="MainWindow">
    
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#0078D4"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Margin" Value="4"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#E8E8E8"/>
            <Setter Property="Foreground" Value="#1A1A1A"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#E0E0E0"/>
        </Style>
        <Style TargetType="DataGrid">
            <Setter Property="Background" Value="#F5F5F5"/>
            <Setter Property="Foreground" Value="#1A1A1A"/>
            <Setter Property="BorderBrush" Value="#E0E0E0"/>
        </Style>
    </Window.Resources>
    
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="300"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Left Sidebar: Folder Selection -->
        <StackPanel Grid.Column="0" Grid.Row="0" Grid.RowSpan="2" Background="#F0F0F0" Margin="0" Padding="12">
            <TextBlock Text="Root Folder" FontSize="14" FontWeight="Bold" Margin="0,0,0,8" Foreground="#1A1A1A"/>
            <TextBox Name="RootFolderInput" Text="" Height="32" Margin="0,0,0,8"/>
            <Button Name="BrowseRootFolder" Content="Browse..." Height="32" Margin="0,0,0,12"/>
            <Button Name="ScanRepositories" Content="Scan Repositories" Height="32" Margin="0,0,0,12"/>
            
            <TextBlock Text="Recent Folders" FontSize="12" FontWeight="Bold" Margin="0,12,0,8" Foreground="#616161"/>
            <ListBox Name="RecentFoldersList" Height="120" Margin="0,0,0,12" Background="#E8E8E8"/>
            
            <TextBlock Text="Actions" FontSize="12" FontWeight="Bold" Margin="0,12,0,8" Foreground="#616161"/>
            <Button Name="SyncAllButton" Content="Sync All" Height="32" Margin="0,0,0,6"/>
            <Button Name="RefreshStatusButton" Content="Refresh Status" Height="32" Margin="0,0,0,6"/>
            <Button Name="OpenSettingsButton" Content="Settings" Height="32" Margin="0,0,0,6"/>
            <Button Name="ExportLogButton" Content="Export Log" Height="32"/>
        </StackPanel>
        
        <!-- Main Content Area -->
        <Grid Grid.Column="1" Grid.Row="0" Grid.RowSpan="2" Margin="12">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="200"/>
            </Grid.RowDefinitions>
            
            <!-- Status Bar -->
            <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,12">
                <TextBlock Name="StatusText" Text="Ready" FontSize="12" Foreground="#616161" VerticalAlignment="Center"/>
                <ProgressBar Name="OperationProgress" Width="200" Height="6" Margin="12,0,0,0" Visibility="Collapsed"/>
            </StackPanel>
            
            <!-- Repository List -->
            <DataGrid Grid.Row="1" Name="RepositoryGrid" AutoGenerateColumns="False" CanUserAddRows="False">
                <DataGrid.Columns>
                    <DataGridTextColumn Header="Repository" Binding="{Binding Name}" Width="200"/>
                    <DataGridTextColumn Header="Path" Binding="{Binding Path}" Width="*"/>
                    <DataGridTextColumn Header="Status" Binding="{Binding Status}" Width="100"/>
                    <DataGridTextColumn Header="Branch" Binding="{Binding Branch}" Width="100"/>
                </DataGrid.Columns>
            </DataGrid>
            
            <!-- Log Output -->
            <TextBox Grid.Row="2" Name="LogOutput" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                     Background="#E8E8E8" Foreground="#1A1A1A"
                     Padding="8" Margin="0,12,0,0" FontFamily="Consolas" FontSize="10"/>
        </Grid>
        
        <!-- Status Bar (Bottom) -->
        <StatusBar Grid.Column="0" Grid.ColumnSpan="2" Grid.Row="2" Background="#F5F5F5" Padding="12,8">
            <TextBlock Name="RepositoryCountText" Text="Repositories: 0" Foreground="#616161"/>
            <Separator Margin="12,0"/>
            <TextBlock Name="SyncStatusText" Text="Last sync: Never" Foreground="#616161"/>
        </StatusBar>
    </Grid>
</Window>
"@

# ============================================================================
# SECTION 5: Async Infrastructure (RunspacePool, Queues, Timers)
# ============================================================================

$Script:LogQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[string]
$Script:StatusQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[object]
$Script:SyncQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[object]
$Script:ScanQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[object]

function Initialize-AsyncInfrastructure {
    # Create RunspacePool for parallel operations
    $RunspaceInitScript = {
        param($BackendPath)
        . $BackendPath
    }
    
    $Script:RunspacePool = [RunspaceFactory]::CreateRunspacePool(
        1,
        [Math]::Min($Script:Settings.MaxParallel, [Environment]::ProcessorCount * 2)
    )
    $Script:RunspacePool.Open()
    
    # Initialize each runspace with backend - collect handles for parallel initialization
    $Handles = @()
    for ($i = 0; $i -lt $Script:RunspacePool.GetMaxRunspaces(); $i++) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $Script:RunspacePool
        $ps.AddScript($RunspaceInitScript).AddArgument($BackendPath) | Out-Null
        $Handles += @{ PowerShell = $ps; Handle = $ps.BeginInvoke() }
    }
    
    # Wait for all initializations to complete
    foreach ($Item in $Handles) {
        try {
            $Item.Handle.AsyncWaitHandle.WaitOne() | Out-Null
            $Item.PowerShell.EndInvoke($Item.Handle) | Out-Null
            $Item.PowerShell.Dispose()
        } catch { }
    }
    
    # Create DispatcherTimer for queue processing
    $Script:QueueTimer = New-Object System.Windows.Threading.DispatcherTimer
    $Script:QueueTimer.Interval = [TimeSpan]::FromMilliseconds(50)
    $Script:QueueTimer.Add_Tick({
        Process-AllQueues
    })
}

function Process-AllQueues {
    # Process log queue
    $logEntry = $null
    while ($Script:LogQueue.TryDequeue([ref]$logEntry)) {
        $Script:Window.FindName("LogOutput").AppendText($logEntry + "`n")
        $Script:Window.FindName("LogOutput").ScrollToEnd()
    }
    
    # Process status queue
    $statusItem = $null
    while ($Script:StatusQueue.TryDequeue([ref]$statusItem)) {
        Update-RepositoryStatus $statusItem
    }
    
    # Process sync queue
    $syncItem = $null
    while ($Script:SyncQueue.TryDequeue([ref]$syncItem)) {
        Complete-SyncOperation $syncItem
    }
    
    # Process scan queue
    $scanItem = $null
    while ($Script:ScanQueue.TryDequeue([ref]$scanItem)) {
        Complete-ScanOperation $scanItem
    }
}

# ============================================================================
# SECTION 6: Logging and Statistics
# ============================================================================

function Get-SafeLogPath {
    param(
        [string]$BasePath = $null
    )
    
    if (-not $BasePath) {
        $BasePath = $Script:Settings.LastFolder
    }
    if (-not $BasePath) {
        $BasePath = $env:USERPROFILE
    }
    
    $ParentPath = Split-Path $BasePath
    if (-not $ParentPath -or $ParentPath -eq $BasePath) {
        $ParentPath = $BasePath
        $FolderName = [System.IO.Path]::GetFileName($BasePath)
    } else {
        $FolderName = Split-Path $BasePath -Leaf
    }
    
    return Join-Path $ParentPath "$(Get-Date -Format 'yyyy-MM-dd')-$FolderName.log"
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    $Script:LogQueue.Enqueue($LogEntry)
    
    if ($Script:Settings.LogToFile) {
        $LogPath = Get-SafeLogPath
        Add-Content $LogPath $LogEntry -ErrorAction SilentlyContinue
    }
}

function Update-Statistics {
    $Grid = $Script:Window.FindName("RepositoryGrid")
    $Count = $Grid.Items.Count
    $Script:Window.FindName("RepositoryCountText").Text = "Repositories: $Count"
    
    $DirtyCount = ($Grid.Items | Where-Object { $_.Status -eq "Dirty" }).Count
    if ($DirtyCount -gt 0) {
        $Script:Window.FindName("SyncStatusText").Text = "Synced: $(Get-Date -Format 'HH:mm:ss') | Dirty: $DirtyCount"
    }
}

# ============================================================================
# SECTION 7: Backend Operations (Using v4 Python Backend)
# ============================================================================

function Submit-StatusJob {
    param(
        [Parameter(Mandatory=$true)][string]$RepositoryPath,
        [Parameter(Mandatory=$true)][object]$Repository
    )
    
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $Script:RunspacePool
    
    $ps.AddScript({
        param($RepoPath, $Repository)
        
        try {
            $Status = Get-RepositoryStatus -Path $RepoPath
            @{
                Path = $RepoPath
                Status = $Status
                Repository = $Repository
            }
        } catch {
            @{
                Path = $RepoPath
                Status = "Error: $_"
                Repository = $Repository
            }
        }
    }).AddArgument($RepositoryPath).AddArgument($Repository) | Out-Null
    
    $ps.BeginInvoke() | Out-Null
}

function Update-RepositoryStatus {
    param([object]$StatusResult)
    
    if ($null -eq $StatusResult) { return }
    
    $Grid = $Script:Window.FindName("RepositoryGrid")
    $Item = $Grid.Items | Where-Object { $_.Path -eq $StatusResult.Path }
    
    if ($Item) {
        $Item.Status = $StatusResult.Status
        $Grid.Items.Refresh()
    }
    
    Write-Log "Updated status for $($StatusResult.Path): $($StatusResult.Status)"
}

function Submit-SyncJob {
    param(
        [Parameter(Mandatory=$true)][string[]]$RepositoryPaths
    )
    
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $Script:RunspacePool
    
    $ps.AddScript({
        param($RepoPaths)
        
        try {
            $Results = @()
            foreach ($Path in $RepoPaths) {
                $Result = Sync-Repository -Path $Path
                $Results += @{
                    Path = $Path
                    Result = $Result
                    Success = $true
                }
            }
            $Results
        } catch {
            @{
                Path = "Batch"
                Result = $_
                Success = $false
            }
        }
    }).AddArgument(@($RepositoryPaths)) | Out-Null
    
    $ps.BeginInvoke() | Out-Null
}

function Complete-SyncOperation {
    param([object]$SyncResult)
    
    if ($SyncResult.Success) {
        Write-Log "Synced $($SyncResult.Path): $($SyncResult.Result)"
    } else {
        Write-Log "Sync failed: $($SyncResult.Result)" -Level "ERROR"
    }
    
    Update-Statistics
}

# ============================================================================
# SECTION 8: Repository Scanning Operations
# ============================================================================

function Scan-Repositories {
    param(
        [Parameter(Mandatory=$true)][string]$RootPath
    )
    
    Write-Log "Starting repository scan: $RootPath"
    $Script:Window.FindName("StatusText").Text = "Scanning..."
    $Script:Window.FindName("OperationProgress").Visibility = "Visible"
    
    if (-not (Test-Path $RootPath)) {
        Write-Log "Root path does not exist: $RootPath" -Level "ERROR"
        return
    }
    
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $Script:RunspacePool
    
    $ps.AddScript({
        param($Root)
        
        $Repositories = @()
        
        # Scan for .git directories
        $Directories = Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue
        
        foreach ($Dir in $Directories) {
            if (Test-Path (Join-Path $Dir.FullName ".git")) {
                $Repositories += @{
                    Name = $Dir.Name
                    Path = $Dir.FullName
                    Status = "Unknown"
                    Branch = "N/A"
                }
            }
        }
        
        $Repositories
    }).AddArgument($RootPath) | Out-Null
    
    $ps.BeginInvoke() | Out-Null
}

function Complete-ScanOperation {
    param([object[]]$Repositories)
    
    $Grid = $Script:Window.FindName("RepositoryGrid")
    $Grid.ItemsSource = $Repositories
    
    Write-Log "Scan complete: Found $($Repositories.Count) repositories"
    
    $Script:Window.FindName("StatusText").Text = "Ready"
    $Script:Window.FindName("OperationProgress").Visibility = "Collapsed"
    
    Update-Statistics
    
    # Submit status jobs for each repository
    foreach ($Repo in $Repositories) {
        Submit-StatusJob -RepositoryPath $Repo.Path -Repository $Repo
    }
}

# ============================================================================
# SECTION 9: Sync Operations (Batch and Single)
# ============================================================================

function Invoke-SyncAll {
    $Grid = $Script:Window.FindName("RepositoryGrid")
    $RepositoryPaths = $Grid.Items.Path
    
    Write-Log "Starting batch sync: $($RepositoryPaths.Count) repositories"
    $Script:Window.FindName("StatusText").Text = "Syncing all repositories..."
    $Script:Window.FindName("OperationProgress").Visibility = "Visible"
    
    Submit-SyncJob -RepositoryPaths $RepositoryPaths
}

function Invoke-SyncRepository {
    param(
        [Parameter(Mandatory=$true)][string]$RepositoryPath
    )
    
    Write-Log "Starting sync: $RepositoryPath"
    Submit-SyncJob -RepositoryPaths @($RepositoryPath)
}

# ============================================================================
# SECTION 10: XAML Loading and UI State Initialization
# ============================================================================

function Initialize-UI {
    $XamlReader = New-Object System.Xml.XmlNodeReader([XML]$Script:XamlTemplate)
    $Script:Window = [Windows.Markup.XamlReader]::Load($XamlReader)
    
    # Set window size from settings
    $Script:Window.Width = $Script:Settings.WindowWidth
    $Script:Window.Height = $Script:Settings.WindowHeight
    
    # Bind initial data
    Update-RecentFoldersList
}

function Update-RecentFoldersList {
    if ($null -eq $Script:Window) { return }
    $ListBox = $Script:Window.FindName("RecentFoldersList")
    if ($null -ne $ListBox) {
        $ListBox.ItemsSource = $Script:Settings.RecentFolders
    }
}

# ============================================================================
# SECTION 11: Context Menu (Repository Actions)
# ============================================================================

function Add-RepositoryContextMenu {
    $Grid = $Script:Window.FindName("RepositoryGrid")
    
    $ContextMenu = New-Object System.Windows.Controls.ContextMenu
    
    # Sync This Repository
    $SyncItem = New-Object System.Windows.Controls.MenuItem
    $SyncItem.Header = "Sync This Repository"
    $SyncItem.Add_Click({
        $SelectedItem = $Grid.SelectedItem
        if ($SelectedItem) {
            Invoke-SyncRepository -RepositoryPath $SelectedItem.Path
            Write-Log "Queued sync for: $($SelectedItem.Name)"
        }
    })
    $ContextMenu.Items.Add($SyncItem) | Out-Null
    
    # Open in Explorer
    $ExplorerItem = New-Object System.Windows.Controls.MenuItem
    $ExplorerItem.Header = "Open in Explorer"
    $ExplorerItem.Add_Click({
        $SelectedItem = $Grid.SelectedItem
        if ($SelectedItem) {
            Invoke-Item -Path $SelectedItem.Path
        }
    })
    $ContextMenu.Items.Add($ExplorerItem) | Out-Null
    
    # Open in PowerShell
    $PSItem = New-Object System.Windows.Controls.MenuItem
    $PSItem.Header = "Open PowerShell Here"
    $PSItem.Add_Click({
        $SelectedItem = $Grid.SelectedItem
        if ($SelectedItem) {
            Start-Process PowerShell -ArgumentList "-NoExit", "-Command", "Set-Location '$($SelectedItem.Path)'"
        }
    })
    $ContextMenu.Items.Add($PSItem) | Out-Null
    
    $Grid.ContextMenu = $ContextMenu
}

# ============================================================================
# SECTION 12: Event Handlers - Buttons and UI Controls
# ============================================================================

function Register-EventHandlers {
    $Window = $Script:Window
    
    # Browse Root Folder
    $Window.FindName("BrowseRootFolder").Add_Click({
        $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $Dialog.SelectedPath = $Window.FindName("RootFolderInput").Text
        
        if ($Dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Window.FindName("RootFolderInput").Text = $Dialog.SelectedPath
            $Script:RootFolder = $Dialog.SelectedPath
            Add-RecentFolder -FolderPath $Dialog.SelectedPath
            Update-RecentFoldersList
        }
    })
    
    # Scan Repositories
    $Window.FindName("ScanRepositories").Add_Click({
        $RootPath = $Window.FindName("RootFolderInput").Text
        if (Test-Path $RootPath) {
            Scan-Repositories -RootPath $RootPath
        } else {
            Write-Log "Invalid root path: $RootPath" -Level "ERROR"
        }
    })
    
    # Sync All
    $Window.FindName("SyncAllButton").Add_Click({
        Invoke-SyncAll
    })
    
    # Refresh Status
    $Window.FindName("RefreshStatusButton").Add_Click({
        $Grid = $Window.FindName("RepositoryGrid")
        foreach ($Item in $Grid.Items) {
            Submit-StatusJob -RepositoryPath $Item.Path -Repository $Item
        }
        Write-Log "Status refresh queued"
    })
    
    # Settings (placeholder)
    $Window.FindName("OpenSettingsButton").Add_Click({
        Write-Log "Settings dialog not yet implemented" -Level "INFO"
    })
    
    # Export Log
    $Window.FindName("ExportLogButton").Add_Click({
        $SaveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $SaveDialog.Filter = "Text files|*.txt"
        $SaveDialog.DefaultExt = "txt"
        
        if ($SaveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $LogText = $Window.FindName("LogOutput").Text
            Set-Content -Path $SaveDialog.FileName -Value $LogText
            Write-Log "Log exported to $($SaveDialog.FileName)"
        }
    })
    
    # Recent Folders ListBox
    $Window.FindName("RecentFoldersList").Add_MouseDoubleClick({
        $SelectedFolder = $Window.FindName("RecentFoldersList").SelectedItem
        if ($SelectedFolder) {
            $Window.FindName("RootFolderInput").Text = $SelectedFolder
            $Script:RootFolder = $SelectedFolder
            Scan-Repositories -RootPath $SelectedFolder
        }
    })
    
    # Window Closing
    $Window.Add_Closing({
        $Script:Settings.WindowWidth = $Window.Width
        $Script:Settings.WindowHeight = $Window.Height
        Set-Settings
        $Script:QueueTimer.Stop()
    })
}

# ============================================================================
# SECTION 13: Repository Grid Setup
# ============================================================================

function Setup-RepositoryGrid {
    $Grid = $Script:Window.FindName("RepositoryGrid")
    $Grid.ItemsSource = New-Object System.Collections.ObjectModel.ObservableCollection[object]
    
    # Add context menu
    Add-RepositoryContextMenu
}

# ============================================================================
# SECTION 14: Initialization Sequence
# ============================================================================

function Initialize-Application {
    # Load settings
    Get-Settings
    
    # Check Git availability
    $GitPath = Get-Command git -ErrorAction SilentlyContinue
    if (-not $GitPath) {
        [System.Windows.MessageBox]::Show(
            "Git is not installed or not found in PATH.`nPlease install Git and try again.",
            "Git Not Found",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
        exit 1
    }
    
    # Initialize async infrastructure
    Initialize-AsyncInfrastructure
    
    # Initialize UI
    Initialize-UI
    Setup-RepositoryGrid
    Register-EventHandlers
    
    # Restore last folder
    if ($Script:Settings.LastFolder -and (Test-Path $Script:Settings.LastFolder)) {
        $Script:Window.FindName("RootFolderInput").Text = $Script:Settings.LastFolder
        $Script:RootFolder = $Script:Settings.LastFolder
    }
    
    Write-Log "$($Script:AppName) started"
    
    # Start queue processing timer
    $Script:QueueTimer.Start()
}

# ============================================================================
# SECTION 15: Error Handling and Diagnostics
# ============================================================================

$ErrorActionPreference = "Continue"

trap {
    Write-Log "Unhandled error: $_" -Level "ERROR"
}

# ============================================================================
# SECTION 16: Application Entry Point
# ============================================================================

try {
    Initialize-Application
    
    # Show window
    $null = $Script:Window.ShowDialog()
    
} catch {
    Write-Host "Fatal error: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# SECTION 17: Cleanup and Exit
# ============================================================================

if ($Script:RunspacePool) {
    $Script:RunspacePool.Close()
    $Script:RunspacePool.Dispose()
}

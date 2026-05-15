#requires -Version 5.1

<#
.SYNOPSIS
    SuperGit-Tools GUI v4 - Friendly Horizon rewrite.

.DESCRIPTION
    A simpler GUI rewrite aligned with the safer v4 sync flow:
    recursive discovery, clearer repo states, ff-only sync, and live logs.
#>

$ErrorActionPreference = "Stop"
$env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

try {
    $null = git --version
}
catch {
    [System.Windows.MessageBox]::Show(
        "Git is not installed or not available in PATH.",
        "Git Not Found",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    exit
}

$Script:AppName = "SuperGit Tools"
$Script:AppVersion = "4.0"
$Script:SettingsDir = Join-Path $env:APPDATA "SuperGit-Tools"
$Script:SettingsFile = Join-Path $Script:SettingsDir "settings-v4.json"
$Script:Settings = @{
    MaxDepth           = 5
    RecentFolders      = @()
    RecentFoldersCount = 5
}

function Load-Settings {
    if (-not (Test-Path $Script:SettingsFile)) {
        return
    }

    try {
        $json = Get-Content $Script:SettingsFile -Raw | ConvertFrom-Json
        if ($null -ne $json.MaxDepth) { $Script:Settings.MaxDepth = [int]$json.MaxDepth }
        if ($null -ne $json.RecentFoldersCount) { $Script:Settings.RecentFoldersCount = [int]$json.RecentFoldersCount }
        if ($null -ne $json.RecentFolders) { $Script:Settings.RecentFolders = @($json.RecentFolders) }
    }
    catch {
    }
}

function Save-Settings {
    try {
        if (-not (Test-Path $Script:SettingsDir)) {
            New-Item -ItemType Directory -Path $Script:SettingsDir -Force | Out-Null
        }

        $Script:Settings | ConvertTo-Json | Out-File -FilePath $Script:SettingsFile -Encoding UTF8
    }
    catch {
    }
}

function Add-RecentFolder {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    $folders = [System.Collections.ArrayList]@($Script:Settings.RecentFolders)
    [void]$folders.Remove($Path)
    [void]$folders.Insert(0, $Path)

    while ($folders.Count -gt $Script:Settings.RecentFoldersCount) {
        $folders.RemoveAt($folders.Count - 1)
    }

    $Script:Settings.RecentFolders = @($folders)
    Save-Settings
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SuperGit Tools v4"
        Height="760"
        Width="1280"
        MinHeight="640"
        MinWidth="1024"
        WindowStartupLocation="CenterScreen"
        Background="#F5F7FA">
    <Window.Resources>
        <SolidColorBrush x:Key="WindowBrush" Color="#F5F7FA" />
        <SolidColorBrush x:Key="PanelBrush" Color="#FFFFFF" />
        <SolidColorBrush x:Key="SidebarBrush" Color="#EEF3F8" />
        <SolidColorBrush x:Key="BorderBrush" Color="#D7E1EA" />
        <SolidColorBrush x:Key="AccentBrush" Color="#2F80ED" />
        <SolidColorBrush x:Key="AccentDarkBrush" Color="#1C5FB8" />
        <SolidColorBrush x:Key="TextBrush" Color="#1C2733" />
        <SolidColorBrush x:Key="MutedBrush" Color="#688096" />
        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource AccentBrush}" />
            <Setter Property="Foreground" Value="White" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Padding" Value="14,8" />
            <Setter Property="Margin" Value="0,0,10,0" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}" />
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Opacity" Value="0.45" />
                </Trigger>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{StaticResource AccentDarkBrush}" />
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Padding" Value="10,6" />
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="Background" Value="White" />
            <Setter Property="Foreground" Value="{StaticResource TextBrush}" />
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="Background" Value="White" />
            <Setter Property="Foreground" Value="{StaticResource TextBrush}" />
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="{StaticResource TextBrush}" />
            <Setter Property="Margin" Value="0,0,18,0" />
            <Setter Property="VerticalAlignment" Value="Center" />
        </Style>
    </Window.Resources>

    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="180" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="{StaticResource PanelBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="20" Margin="0,0,0,14">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>
                <StackPanel>
                    <TextBlock Text="SuperGit Tools" FontSize="24" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" />
                    <TextBlock Text="Friendly Horizon v4 GUI rewrite" FontSize="13" Foreground="{StaticResource MutedBrush}" Margin="0,4,0,0" />
                </StackPanel>
                <Border Grid.Column="1" Background="#EAF2FF" CornerRadius="999" Padding="12,6" VerticalAlignment="Center">
                    <TextBlock Name="TxtLastRun" Text="Ready" Foreground="{StaticResource AccentDarkBrush}" FontWeight="SemiBold" />
                </Border>
            </Grid>
        </Border>

        <Border Grid.Row="1" Background="{StaticResource PanelBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="20" Margin="0,0,0,14">
            <StackPanel>
                <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="180" />
                        <ColumnDefinition Width="Auto" />
                    </Grid.ColumnDefinitions>
                    <TextBox Name="TxtRootFolder" Height="36" VerticalContentAlignment="Center" />
                    <ComboBox Name="CmbRecentFolders" Grid.Column="1" Height="36" Margin="12,0,12,0" />
                    <Button Name="BtnBrowse" Grid.Column="2" Content="Browse Folder" MinWidth="130" Margin="0" />
                </Grid>

                <WrapPanel Margin="0,0,0,14">
                    <TextBlock Text="Max Depth" Foreground="{StaticResource MutedBrush}" VerticalAlignment="Center" Margin="0,0,8,0" />
                    <TextBox Name="TxtMaxDepth" Width="60" Height="32" Margin="0,0,18,0" Text="5" />
                    <CheckBox Name="ChkIncludeDirty" Content="Include Dirty Repos" />
                    <CheckBox Name="ChkDryRun" Content="Dry Run" />
                    <CheckBox Name="ChkFetchOnly" Content="Fetch Only" />
                </WrapPanel>

                <WrapPanel>
                    <Button Name="BtnScan" Content="Scan Repositories" MinWidth="150" />
                    <Button Name="BtnRefresh" Content="Refresh Status" MinWidth="130" Background="#5B7083" />
                    <Button Name="BtnSyncSelected" Content="Sync Selected" MinWidth="120" Background="#2A9D8F" />
                    <Button Name="BtnSyncAll" Content="Sync All" MinWidth="100" />
                    <Button Name="BtnOpenRepo" Content="Open in Explorer" MinWidth="130" Background="#7C5CFC" />
                    <Button Name="BtnCopyPath" Content="Copy Path" MinWidth="100" Background="#64748B" Margin="0" />
                </WrapPanel>
            </StackPanel>
        </Border>

        <Grid Grid.Row="2" Margin="0,0,0,14">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220" />
                <ColumnDefinition Width="*" />
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Background="{StaticResource SidebarBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="18" Margin="0,0,14,0">
                <StackPanel>
                    <TextBlock Text="Summary" FontSize="16" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Margin="0,0,0,12" />
                    <TextBlock Text="Total Repositories" Foreground="{StaticResource MutedBrush}" />
                    <TextBlock Name="TxtTotalRepos" Text="0" FontSize="24" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Margin="0,2,0,10" />
                    <TextBlock Text="Dirty" Foreground="{StaticResource MutedBrush}" />
                    <TextBlock Name="TxtDirtyRepos" Text="0" FontSize="20" FontWeight="SemiBold" Foreground="#D97706" Margin="0,2,0,10" />
                    <TextBlock Text="Failed / Error" Foreground="{StaticResource MutedBrush}" />
                    <TextBlock Name="TxtFailedRepos" Text="0" FontSize="20" FontWeight="SemiBold" Foreground="#DC2626" Margin="0,2,0,10" />
                    <TextBlock Text="Selection" Foreground="{StaticResource MutedBrush}" />
                    <TextBlock Name="TxtSelectionInfo" Text="0 selected" FontSize="14" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Margin="0,2,0,16" />

                    <Separator Margin="0,4,0,14" />

                    <TextBlock Text="Notes" FontSize="16" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Margin="0,0,0,10" />
                    <TextBlock Text="• Scan discovers repos recursively" Foreground="{StaticResource MutedBrush}" Margin="0,0,0,6" TextWrapping="Wrap" />
                    <TextBlock Text="• Sync uses git fetch --all --prune and git pull --ff-only" Foreground="{StaticResource MutedBrush}" Margin="0,0,0,6" TextWrapping="Wrap" />
                    <TextBlock Text="• Dirty repos are skipped unless Include Dirty Repos is checked" Foreground="{StaticResource MutedBrush}" TextWrapping="Wrap" />
                </StackPanel>
            </Border>

            <Border Grid.Column="1" Background="{StaticResource PanelBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="14">
                <DataGrid Name="RepoGrid"
                          AutoGenerateColumns="False"
                          IsReadOnly="True"
                          HeadersVisibility="Column"
                          GridLinesVisibility="Horizontal"
                          CanUserAddRows="False"
                          CanUserDeleteRows="False"
                          SelectionMode="Extended"
                          SelectionUnit="FullRow"
                          BorderThickness="0"
                          Background="Transparent"
                          RowBackground="White"
                          AlternatingRowBackground="#F8FBFF">
                    <DataGrid.Columns>
                        <DataGridTemplateColumn Header="" Width="36">
                            <DataGridTemplateColumn.CellTemplate>
                                <DataTemplate>
                                    <Ellipse Width="12" Height="12" Fill="{Binding StatusBrush}" VerticalAlignment="Center" HorizontalAlignment="Center" />
                                </DataTemplate>
                            </DataGridTemplateColumn.CellTemplate>
                        </DataGridTemplateColumn>
                        <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="160" />
                        <DataGridTextColumn Header="Branch" Binding="{Binding Branch}" Width="120" />
                        <DataGridTextColumn Header="Status" Binding="{Binding Status}" Width="120" />
                        <DataGridTextColumn Header="Ahead" Binding="{Binding Ahead}" Width="70" />
                        <DataGridTextColumn Header="Behind" Binding="{Binding Behind}" Width="70" />
                        <DataGridTextColumn Header="Detail" Binding="{Binding Detail}" Width="220" />
                        <DataGridTextColumn Header="Path" Binding="{Binding Path}" Width="*" />
                    </DataGrid.Columns>
                </DataGrid>
            </Border>
        </Grid>

        <Border Grid.Row="3" Background="{StaticResource PanelBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="14" Margin="0,0,0,14">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="*" />
                </Grid.RowDefinitions>
                <TextBlock Text="Activity Log" FontSize="16" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Margin="0,0,0,10" />
                <ScrollViewer Name="LogScroll" Grid.Row="1" VerticalScrollBarVisibility="Auto">
                    <TextBox Name="LogTextBox"
                             IsReadOnly="True"
                             TextWrapping="Wrap"
                             AcceptsReturn="True"
                             VerticalScrollBarVisibility="Hidden"
                             HorizontalScrollBarVisibility="Disabled"
                             Background="#0F172A"
                             Foreground="#D6E4F0"
                             FontFamily="Consolas"
                             BorderThickness="0" />
                </ScrollViewer>
            </Grid>
        </Border>

        <Border Grid.Row="4" Background="#1D4ED8" CornerRadius="10" Padding="14,10">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="220" />
                </Grid.ColumnDefinitions>
                <TextBlock Name="TxtStatus" Text="Ready" Foreground="White" FontWeight="SemiBold" VerticalAlignment="Center" />
                <ProgressBar Name="ProgressMain" Grid.Column="1" Height="14" Minimum="0" Maximum="100" Value="0" Margin="12,0,0,0" />
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

$controlNames = @(
    "TxtLastRun", "TxtRootFolder", "CmbRecentFolders", "BtnBrowse", "TxtMaxDepth",
    "ChkIncludeDirty", "ChkDryRun", "ChkFetchOnly", "BtnScan", "BtnRefresh",
    "BtnSyncSelected", "BtnSyncAll", "BtnOpenRepo", "BtnCopyPath", "TxtTotalRepos",
    "TxtDirtyRepos", "TxtFailedRepos", "TxtSelectionInfo", "RepoGrid", "LogScroll",
    "LogTextBox", "TxtStatus", "ProgressMain"
)
foreach ($controlName in $controlNames) {
    Set-Variable -Name $controlName -Value $Window.FindName($controlName) -Scope Script
}

$Script:RepoItems = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
$Script:RepoGrid.ItemsSource = $Script:RepoItems
$Script:Queue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:Worker = $null
$Script:WorkerHandle = $null
$Script:CurrentLogFile = $null

function Get-StateBrush {
    param([string]$State)

    switch -Wildcard ($State) {
        "Clean"         { return "#22C55E" }
        "Synced"        { return "#22C55E" }
        "Fetched"       { return "#0EA5E9" }
        "Ahead"         { return "#3B82F6" }
        "Behind"        { return "#F59E0B" }
        "Diverged"      { return "#A855F7" }
        "Dirty*"        { return "#FBBF24" }
        "Skipped*"      { return "#94A3B8" }
        "DryRun"        { return "#38BDF8" }
        "NoUpstream"    { return "#8B5CF6" }
        "Failed"        { return "#EF4444" }
        "Error"         { return "#EF4444" }
        default         { return "#64748B" }
    }
}

function Set-Status {
    param([string]$Message)
    $Script:TxtStatus.Text = $Message
}

function New-LogFilePath {
    param(
        [string]$Mode,
        [string]$RootFolder
    )

    $rootName = if ([string]::IsNullOrWhiteSpace($RootFolder)) { "workspace" } else { Split-Path $RootFolder -Leaf }
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $timeStamp = Get-Date -Format "HHmmss"
    return Join-Path $PSScriptRoot "$dateStamp-$timeStamp-$rootName-gui-v4-$Mode.log"
}

function Append-LogLine {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Timestamp = $(Get-Date -Format "HH:mm:ss")
    )

    $line = "[$Timestamp][$Level] $Message"
    $Script:LogTextBox.AppendText("$line`r`n")
    $Script:LogScroll.ScrollToEnd()

    if ($Script:CurrentLogFile) {
        $line | Out-File -FilePath $Script:CurrentLogFile -Append -Encoding UTF8
    }
}

function Find-RepoItem {
    param([string]$Path)
    return $Script:RepoItems | Where-Object { $_.Path -eq $Path } | Select-Object -First 1
}

function Upsert-RepoItem {
    param($Record)

    $item = Find-RepoItem -Path $Record.Path
    if ($null -eq $item) {
        $item = [PSCustomObject]@{
            Name        = $Record.Name
            Branch      = $Record.Branch
            Status      = $Record.Status
            Ahead       = $Record.Ahead
            Behind      = $Record.Behind
            Detail      = $Record.Detail
            Path        = $Record.Path
            StatusBrush = (Get-StateBrush -State $Record.Status)
            IsDirty     = $Record.IsDirty
        }
        $Script:RepoItems.Add($item)
        return
    }

    $item.Name = $Record.Name
    $item.Branch = $Record.Branch
    $item.Status = $Record.Status
    $item.Ahead = $Record.Ahead
    $item.Behind = $Record.Behind
    $item.Detail = $Record.Detail
    $item.StatusBrush = Get-StateBrush -State $Record.Status
    $item.IsDirty = $Record.IsDirty
}

function Update-Summary {
    $total = $Script:RepoItems.Count
    $dirty = ($Script:RepoItems | Where-Object { $_.IsDirty }).Count
    $failed = ($Script:RepoItems | Where-Object { $_.Status -in @("Failed", "Error") }).Count
    $selected = @($Script:RepoGrid.SelectedItems).Count

    $Script:TxtTotalRepos.Text = $total.ToString()
    $Script:TxtDirtyRepos.Text = $dirty.ToString()
    $Script:TxtFailedRepos.Text = $failed.ToString()
    $Script:TxtSelectionInfo.Text = "$selected selected"

    $hasRepos = ($total -gt 0)
    $hasSelection = ($selected -gt 0)
    $isBusy = ($null -ne $Script:WorkerHandle -and -not $Script:WorkerHandle.IsCompleted)

    $Script:BtnScan.IsEnabled = -not $isBusy
    $Script:BtnRefresh.IsEnabled = $hasRepos -and -not $isBusy
    $Script:BtnSyncAll.IsEnabled = $hasRepos -and -not $isBusy
    $Script:BtnSyncSelected.IsEnabled = $hasSelection -and -not $isBusy
    $Script:BtnOpenRepo.IsEnabled = ($hasSelection -eq $true)
    $Script:BtnCopyPath.IsEnabled = ($hasSelection -eq $true)
}

function Refresh-RecentFolders {
    $Script:CmbRecentFolders.Items.Clear()
    [void]$Script:CmbRecentFolders.Items.Add("(Recent folders)")
    foreach ($folder in $Script:Settings.RecentFolders) {
        [void]$Script:CmbRecentFolders.Items.Add($folder)
    }
    $Script:CmbRecentFolders.SelectedIndex = 0
}

function Get-SelectedRootFolder {
    return $Script:TxtRootFolder.Text.Trim()
}

function Get-MaxDepthValue {
    try {
        $value = [int]$Script:TxtMaxDepth.Text
        if ($value -lt 1) { return 1 }
        return $value
    }
    catch {
        return 5
    }
}

function Start-Worker {
    param(
        [string]$Mode,
        [scriptblock]$ScriptBlock,
        [object[]]$Arguments
    )

    if ($null -ne $Script:WorkerHandle -and -not $Script:WorkerHandle.IsCompleted) {
        [System.Windows.MessageBox]::Show(
            "Another operation is still running.",
            "$Script:AppName v$Script:AppVersion",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        ) | Out-Null
        return $false
    }

    $Script:Queue.Clear()
    $Script:ProgressMain.Value = 0
    $Script:CurrentLogFile = New-LogFilePath -Mode $Mode -RootFolder (Get-SelectedRootFolder)
    $Script:LogTextBox.Clear()
    Append-LogLine -Message "Starting $Mode operation."
    $Script:TxtLastRun.Text = "$Mode running"

    $powershell = [PowerShell]::Create()
    [void]$powershell.AddScript($ScriptBlock)
    foreach ($argument in $Arguments) {
        [void]$powershell.AddArgument($argument)
    }

    $Script:Worker = $powershell
    $Script:WorkerHandle = $powershell.BeginInvoke()
    Update-Summary
    return $true
}

function Process-Queue {
    $needsRefresh = $false
    $processed = 0

    while ($Script:Queue.Count -gt 0 -and $processed -lt 200) {
        $processed++
        $entry = $Script:Queue.Dequeue()

        switch ($entry.Type) {
            "Log" {
                Append-LogLine -Message $entry.Message -Level $entry.Level -Timestamp $entry.Timestamp
            }
            "Repo" {
                Upsert-RepoItem -Record $entry.Record
                $needsRefresh = $true
            }
            "Progress" {
                if ($null -ne $entry.Value) {
                    $Script:ProgressMain.Value = [double]$entry.Value
                }
                if ($entry.Message) {
                    Set-Status -Message $entry.Message
                }
            }
            "Done" {
                $Script:ProgressMain.Value = 100
                $Script:TxtLastRun.Text = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Set-Status -Message $entry.Message
                Append-LogLine -Message $entry.Message -Level "INFO"
            }
            "Error" {
                Set-Status -Message $entry.Message
                Append-LogLine -Message $entry.Message -Level "ERROR"
            }
        }
    }

    if ($needsRefresh) {
        $Script:RepoGrid.Items.Refresh()
        Update-Summary
    }

    if ($null -ne $Script:WorkerHandle -and $Script:WorkerHandle.IsCompleted) {
        try {
            $Script:Worker.EndInvoke($Script:WorkerHandle) | Out-Null
        }
        catch {
            Append-LogLine -Message $_.Exception.Message -Level "ERROR"
            Set-Status -Message "Operation failed."
        }
        finally {
            $Script:Worker.Dispose()
            $Script:Worker = $null
            $Script:WorkerHandle = $null
            Update-Summary
        }
    }
}

function Start-Scan {
    $rootFolder = Get-SelectedRootFolder
    if ([string]::IsNullOrWhiteSpace($rootFolder) -or -not (Test-Path $rootFolder)) {
        [System.Windows.MessageBox]::Show(
            "Please select a valid root folder first.",
            "$Script:AppName v$Script:AppVersion",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
        return
    }

    $maxDepth = Get-MaxDepthValue
    $Script:Settings.MaxDepth = $maxDepth
    Add-RecentFolder -Path $rootFolder
    Refresh-RecentFolders

    $Script:RepoItems.Clear()
    Update-Summary

    $scanScript = {
        param($rootFolder, $maxDepth, $queue)

        $ErrorActionPreference = "Stop"
        $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"

        function Write-QueueLog {
            param($Message, $Level = "INFO")
            $queue.Enqueue([PSCustomObject]@{
                    Type      = "Log"
                    Timestamp = (Get-Date -Format "HH:mm:ss")
                    Level     = $Level
                    Message   = $Message
                })
        }

        function Get-RepoDetail {
            param($State, $Ahead, $Behind, $Dirty, $HasUpstream)

            if (-not $HasUpstream) { return "No upstream configured" }
            if ($State -eq "Clean") { return "Up to date" }
            if ($State -eq "Dirty") { return "Uncommitted changes" }
            if ($State -eq "Ahead") { return "Ahead $Ahead commits" }
            if ($State -eq "Behind") { return "Behind $Behind commits" }
            if ($State -eq "Diverged") { return "Ahead $Ahead / Behind $Behind" }
            if ($State -like "Dirty*") { return "Dirty, ahead $Ahead / behind $Behind" }
            return $State
        }

        function Get-RepoStatus {
            param($RepoPath)

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
                    Name      = Split-Path $RepoPath -Leaf
                    Branch    = $branch
                    Status    = $state
                    Ahead     = $ahead
                    Behind    = $behind
                    Detail    = Get-RepoDetail -State $state -Ahead $ahead -Behind $behind -Dirty $dirty -HasUpstream $hasUpstream
                    Path      = $RepoPath
                    IsDirty   = $dirty
                }
            }
            finally {
                Pop-Location
            }
        }

        Write-QueueLog -Message "Scanning $rootFolder"
        $gitDirs = Get-ChildItem -Path $rootFolder -Directory -Filter ".git" -Recurse -Depth $maxDepth -ErrorAction SilentlyContinue
        $repoPaths = @($gitDirs | ForEach-Object { Split-Path $_.FullName -Parent } | Sort-Object -Unique)
        $total = $repoPaths.Count

        if ($total -eq 0) {
            $queue.Enqueue([PSCustomObject]@{
                    Type    = "Done"
                    Message = "Scan complete. No repositories found."
                })
            return
        }

        $index = 0
        foreach ($repoPath in $repoPaths) {
            $index++
            $queue.Enqueue([PSCustomObject]@{
                    Type    = "Progress"
                    Value   = [math]::Round(($index / $total) * 100, 0)
                    Message = "Scanning [$index/$total] $(Split-Path $repoPath -Leaf)"
                })

            try {
                $record = Get-RepoStatus -RepoPath $repoPath
                $queue.Enqueue([PSCustomObject]@{
                        Type   = "Repo"
                        Record = $record
                    })
                Write-QueueLog -Message "Found $($record.Name) [$($record.Status)]"
            }
            catch {
                Write-QueueLog -Message "Failed to scan ${repoPath}: $($_.Exception.Message)" -Level "ERROR"
            }
        }

        $queue.Enqueue([PSCustomObject]@{
                Type    = "Done"
                Message = "Scan complete. Found $total repositories."
            })
    }

    [void](Start-Worker -Mode "scan" -ScriptBlock $scanScript -Arguments @($rootFolder, $maxDepth, $Script:Queue))
}

function Start-Refresh {
    if ($Script:RepoItems.Count -eq 0) {
        return
    }

    $repoPaths = @($Script:RepoItems | ForEach-Object { $_.Path })

    $refreshScript = {
        param($repoPaths, $queue)

        $ErrorActionPreference = "Stop"

        function Write-QueueLog {
            param($Message, $Level = "INFO")
            $queue.Enqueue([PSCustomObject]@{
                    Type      = "Log"
                    Timestamp = (Get-Date -Format "HH:mm:ss")
                    Level     = $Level
                    Message   = $Message
                })
        }

        function Get-RepoDetail {
            param($State, $Ahead, $Behind, $Dirty, $HasUpstream)

            if (-not $HasUpstream) { return "No upstream configured" }
            if ($State -eq "Clean") { return "Up to date" }
            if ($State -eq "Dirty") { return "Uncommitted changes" }
            if ($State -eq "Ahead") { return "Ahead $Ahead commits" }
            if ($State -eq "Behind") { return "Behind $Behind commits" }
            if ($State -eq "Diverged") { return "Ahead $Ahead / Behind $Behind" }
            if ($State -like "Dirty*") { return "Dirty, ahead $Ahead / behind $Behind" }
            return $State
        }

        function Get-RepoStatus {
            param($RepoPath)

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
                    Name      = Split-Path $RepoPath -Leaf
                    Branch    = $branch
                    Status    = $state
                    Ahead     = $ahead
                    Behind    = $behind
                    Detail    = Get-RepoDetail -State $state -Ahead $ahead -Behind $behind -Dirty $dirty -HasUpstream $hasUpstream
                    Path      = $RepoPath
                    IsDirty   = $dirty
                }
            }
            finally {
                Pop-Location
            }
        }

        $total = $repoPaths.Count
        $index = 0
        foreach ($repoPath in $repoPaths) {
            $index++
            $queue.Enqueue([PSCustomObject]@{
                    Type    = "Progress"
                    Value   = [math]::Round(($index / $total) * 100, 0)
                    Message = "Refreshing [$index/$total] $(Split-Path $repoPath -Leaf)"
                })

            try {
                $record = Get-RepoStatus -RepoPath $repoPath
                $queue.Enqueue([PSCustomObject]@{
                        Type   = "Repo"
                        Record = $record
                    })
                Write-QueueLog -Message "Refreshed $($record.Name) [$($record.Status)]"
            }
            catch {
                Write-QueueLog -Message "Failed to refresh ${repoPath}: $($_.Exception.Message)" -Level "ERROR"
            }
        }

        $queue.Enqueue([PSCustomObject]@{
                Type    = "Done"
                Message = "Refresh complete."
            })
    }

    [void](Start-Worker -Mode "refresh" -ScriptBlock $refreshScript -Arguments @($repoPaths, $Script:Queue))
}

function Start-Sync {
    param([switch]$SelectedOnly)

    $repoPaths = if ($SelectedOnly) {
        @($Script:RepoGrid.SelectedItems | ForEach-Object { $_.Path })
    }
    else {
        @($Script:RepoItems | ForEach-Object { $_.Path })
    }

    if ($repoPaths.Count -eq 0) {
        return
    }

    $countLabel = if ($SelectedOnly) { "selected repositories" } else { "repositories" }
    $confirm = [System.Windows.MessageBox]::Show(
        "Start sync for $($repoPaths.Count) $countLabel?",
        "$Script:AppName v$Script:AppVersion",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question
    )

    if ($confirm -ne [System.Windows.MessageBoxResult]::Yes) {
        return
    }

    $includeDirty = [bool]$Script:ChkIncludeDirty.IsChecked
    $dryRun = [bool]$Script:ChkDryRun.IsChecked
    $fetchOnly = [bool]$Script:ChkFetchOnly.IsChecked

    $syncScript = {
        param($repoPaths, $includeDirty, $dryRun, $fetchOnly, $queue)

        $ErrorActionPreference = "Stop"
        $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"

        function Write-QueueLog {
            param($Message, $Level = "INFO")
            $queue.Enqueue([PSCustomObject]@{
                    Type      = "Log"
                    Timestamp = (Get-Date -Format "HH:mm:ss")
                    Level     = $Level
                    Message   = $Message
                })
        }

        function New-RepoRecord {
            param($RepoPath, $Branch, $State, $Ahead, $Behind, $Detail, $IsDirty)
            return [PSCustomObject]@{
                Name    = Split-Path $RepoPath -Leaf
                Branch  = $Branch
                Status  = $State
                Ahead   = $Ahead
                Behind  = $Behind
                Detail  = $Detail
                Path    = $RepoPath
                IsDirty = $IsDirty
            }
        }

        function Get-RepoStatus {
            param($RepoPath)

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
                    RepoPath  = $RepoPath
                    Branch    = $branch
                    State     = $state
                    Ahead     = $ahead
                    Behind    = $behind
                    IsDirty   = $dirty
                }
            }
            finally {
                Pop-Location
            }
        }

        $total = $repoPaths.Count
        $index = 0
        foreach ($repoPath in $repoPaths) {
            $index++
            $repoName = Split-Path $repoPath -Leaf
            $queue.Enqueue([PSCustomObject]@{
                    Type    = "Progress"
                    Value   = [math]::Round(($index / $total) * 100, 0)
                    Message = "Syncing [$index/$total] $repoName"
                })

            try {
                $before = Get-RepoStatus -RepoPath $repoPath

                if ($before.IsDirty -and -not $includeDirty) {
                    Write-QueueLog -Message "Skipped dirty repo: $repoName" -Level "WARN"
                    $queue.Enqueue([PSCustomObject]@{
                            Type   = "Repo"
                            Record = (New-RepoRecord -RepoPath $repoPath -Branch $before.Branch -State "SkippedDirty" -Ahead $before.Ahead -Behind $before.Behind -Detail "Skipped dirty working tree" -IsDirty $before.IsDirty)
                        })
                    continue
                }

                if ($dryRun) {
                    Write-QueueLog -Message "Dry run only: $repoName"
                    $queue.Enqueue([PSCustomObject]@{
                            Type   = "Repo"
                            Record = (New-RepoRecord -RepoPath $repoPath -Branch $before.Branch -State "DryRun" -Ahead $before.Ahead -Behind $before.Behind -Detail "Dry run only" -IsDirty $before.IsDirty)
                        })
                    continue
                }

                Push-Location $repoPath
                try {
                    Write-QueueLog -Message "[CMD] git fetch --all --prune --progress ($repoName)"
                    git fetch --all --prune --progress 2>&1 | ForEach-Object { Write-QueueLog -Message $_ }
                    if ($LASTEXITCODE -ne 0) {
                        throw "git fetch failed with exit code $LASTEXITCODE"
                    }

                    if (-not $fetchOnly) {
                        Write-QueueLog -Message "[CMD] git pull --ff-only --progress ($repoName)"
                        git pull --ff-only --progress 2>&1 | ForEach-Object { Write-QueueLog -Message $_ }
                        if ($LASTEXITCODE -ne 0) {
                            throw "git pull failed with exit code $LASTEXITCODE"
                        }
                    }
                }
                finally {
                    Pop-Location
                }

                $after = Get-RepoStatus -RepoPath $repoPath
                $finalState = if ($fetchOnly) { "Fetched" } else { "Synced" }
                $finalDetail = if ($fetchOnly) { "Fetch completed" } else { "Sync completed" }
                Write-QueueLog -Message "${finalState}: $repoName"
                $queue.Enqueue([PSCustomObject]@{
                        Type   = "Repo"
                        Record = (New-RepoRecord -RepoPath $repoPath -Branch $after.Branch -State $finalState -Ahead $after.Ahead -Behind $after.Behind -Detail $finalDetail -IsDirty $after.IsDirty)
                    })
            }
            catch {
                Write-QueueLog -Message "Failed: $repoName - $($_.Exception.Message)" -Level "ERROR"
                $queue.Enqueue([PSCustomObject]@{
                        Type   = "Repo"
                        Record = (New-RepoRecord -RepoPath $repoPath -Branch "unknown" -State "Failed" -Ahead 0 -Behind 0 -Detail $_.Exception.Message -IsDirty $false)
                    })
            }
        }

        $queue.Enqueue([PSCustomObject]@{
                Type    = "Done"
                Message = "Sync complete."
            })
    }

    [void](Start-Worker -Mode "sync" -ScriptBlock $syncScript -Arguments @($repoPaths, $includeDirty, $dryRun, $fetchOnly, $Script:Queue))
}

function Open-SelectedRepository {
    $selected = @($Script:RepoGrid.SelectedItems) | Select-Object -First 1
    if ($selected -and (Test-Path $selected.Path)) {
        Start-Process "explorer.exe" $selected.Path
    }
}

function Copy-SelectedRepositoryPath {
    $selected = @($Script:RepoGrid.SelectedItems) | Select-Object -First 1
    if ($selected) {
        Set-Clipboard -Value $selected.Path
        Set-Status -Message "Path copied."
    }
}

Load-Settings
$Script:TxtMaxDepth.Text = $Script:Settings.MaxDepth.ToString()
Refresh-RecentFolders
Update-Summary

$Script:Timer = New-Object System.Windows.Threading.DispatcherTimer
$Script:Timer.Interval = [TimeSpan]::FromMilliseconds(120)
$Script:Timer.Add_Tick({ Process-Queue })
$Script:Timer.Start()

$Script:BtnBrowse.Add_Click({
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select root folder containing Git repositories"
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:TxtRootFolder.Text = $dialog.SelectedPath
        }
    })

$Script:CmbRecentFolders.Add_SelectionChanged({
        if ($Script:CmbRecentFolders.SelectedIndex -gt 0) {
            $Script:TxtRootFolder.Text = [string]$Script:CmbRecentFolders.SelectedItem
        }
    })

$Script:BtnScan.Add_Click({ Start-Scan })
$Script:BtnRefresh.Add_Click({ Start-Refresh })
$Script:BtnSyncSelected.Add_Click({ Start-Sync -SelectedOnly })
$Script:BtnSyncAll.Add_Click({ Start-Sync })
$Script:BtnOpenRepo.Add_Click({ Open-SelectedRepository })
$Script:BtnCopyPath.Add_Click({ Copy-SelectedRepositoryPath })
$Script:RepoGrid.Add_SelectionChanged({ Update-Summary })

$Window.Add_Closing({
        Save-Settings
        if ($Script:Timer) {
            $Script:Timer.Stop()
        }
        if ($Script:Worker) {
            $Script:Worker.Dispose()
        }
    })

Set-Status -Message "Ready."
$Script:TxtLastRun.Text = "Ready"
Append-LogLine -Message "Application started."
$Window.ShowDialog() | Out-Null

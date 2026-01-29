<#
.SYNOPSIS
    SuperGit-Tools GUI - "Friendly Horizon" Edition
    A modern, dark-themed GUI for syncing Git repositories.

.DESCRIPTION
    This script launches a WPF application to manage and sync multiple git repositories.
    It adheres to the "Friendly Horizon" design philosophy:
    - Chromeless window with custom title bar.
    - Dark mode aesthetics (#1E1E1E).
    - Responsive async operations.

.NOTES
    Author: Antigravity for SuperGit-Tools
    Requires: PowerShell 5.1+
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# -----------------------------------------------------------------------------
# XAML INTERFACE (Friendly Horizon Design)
# -----------------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SuperGit Tools" Height="600" Width="900"
        WindowStyle="None" ResizeMode="CanResizeWithGrip" AllowsTransparency="True"
        Background="Transparent">

    <Window.Resources>
        <!-- Colors & Brushes -->
        <SolidColorBrush x:Key="WindowBackground" Color="#1E1E1E"/>
        <SolidColorBrush x:Key="SidebarBackground" Color="#252526"/>
        <SolidColorBrush x:Key="ControlBackground" Color="#333337"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#CCCCCC"/>
        <SolidColorBrush x:Key="AccentColor" Color="#007ACC"/>
        <SolidColorBrush x:Key="SuccessColor" Color="#4CAF50"/>
        <SolidColorBrush x:Key="WarningColor" Color="#FFC107"/>
        <SolidColorBrush x:Key="ErrorColor" Color="#FF5252"/>
        <SolidColorBrush x:Key="HoverOverlay" Color="#3FFFFFFF"/>

        <!-- Button Style -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource ControlBackground}"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#3E3E42"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#007ACC"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Custom Scrollbar (Minimalist) -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#444444"/>
        </Style>

    </Window.Resources>

    <Border Background="{StaticResource WindowBackground}" CornerRadius="8" BorderThickness="1" BorderBrush="#333333">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="40"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="30"/>
            </Grid.RowDefinitions>

            <!-- 1. Custom Title Bar -->
            <Grid Grid.Row="0" Background="Transparent" Name="TitleBarArea">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="15,0,0,0">
                    <TextBlock Text="🚀 SuperGit Tools" Foreground="{StaticResource TextPrimary}" FontWeight="SemiBold" FontSize="14"/>
                    <TextBlock Text=" | Friendly Horizon" Foreground="{StaticResource TextSecondary}" Margin="10,0,0,0" FontSize="12" VerticalAlignment="Center"/>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,10,0">
                    <Button Name="MinimizeButton" Content="_" Width="40" Background="Transparent"/>
                    <Button Name="CloseButton" Content="X" Width="40" Background="Transparent" Foreground="#FF5252" FontWeight="Bold"/>
                </StackPanel>
            </Grid>

            <!-- 2. Main Content Area -->
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="220"/> <!-- Sidebar -->
                    <ColumnDefinition Width="*"/>   <!-- Main List -->
                </Grid.ColumnDefinitions>

                <!-- Sidebar Controls -->
                <Border Grid.Column="0" Background="{StaticResource SidebarBackground}" Padding="15">
                    <StackPanel>
                        <Label Content="ACTIONS" Foreground="#888888" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                        
                        <Button Name="BtnSelectFolder" Content="📂 Select Folder" Height="35" HorizontalContentAlignment="Left"/>
                        <Button Name="BtnScan" Content="🔍 Scan Subfolders" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                        <Button Name="BtnSyncAll" Content="⚡ Sync All" Height="35" HorizontalContentAlignment="Left" Background="#007ACC"/>

                        <Separator Background="#333333" Margin="0,15"/>

                        <Label Content="STATS" Foreground="#888888" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                        <StackPanel Orientation="Horizontal" Margin="5">
                            <TextBlock Text="Found:" Foreground="{StaticResource TextSecondary}" Width="60"/>
                            <TextBlock Name="TxtCountFound" Text="0" Foreground="White" FontWeight="Bold"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="5">
                            <TextBlock Text="Success:" Foreground="{StaticResource TextSecondary}" Width="60"/>
                            <TextBlock Name="TxtCountSuccess" Text="0" Foreground="{StaticResource SuccessColor}" FontWeight="Bold"/>
                        </StackPanel>
                    </StackPanel>
                </Border>

                <!-- Repo List -->
                <DockPanel Grid.Column="1" Margin="20">
                    <StackPanel DockPanel.Dock="Top" Margin="0,0,0,10">
                        <TextBlock Text="Repositories" FontSize="20" FontWeight="Light" Foreground="White"/>
                        <TextBlock Name="TxtCurrentPath" Text="No folder selected" Foreground="#666666" FontStyle="Italic"/>
                    </StackPanel>

                    <!-- Header for List -->
                    <Grid DockPanel.Dock="Top" Background="#2D2D30" Height="30">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="100"/>
                            <ColumnDefinition Width="100"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock Text="Repo Name" Foreground="#AAAAAA" VerticalAlignment="Center" Margin="10,0"/>
                        <TextBlock Grid.Column="1" Text="Status" Foreground="#AAAAAA" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                        <TextBlock Grid.Column="2" Text="Action" Foreground="#AAAAAA" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                    </Grid>

                    <!-- The List Box -->
                    <ListBox Name="RepoList" Background="Transparent" BorderThickness="0" ScrollViewer.HorizontalScrollBarVisibility="Disabled">
                        <ListBox.ItemContainerStyle>
                            <Style TargetType="ListBoxItem">
                                <Setter Property="Background" Value="Transparent"/>
                                <Setter Property="Padding" Value="5"/>
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="ListBoxItem">
                                            <Border Name="ItemBorder" BorderThickness="0,0,0,1" BorderBrush="#333333" Background="{TemplateBinding Background}" CornerRadius="2">
                                                <ContentPresenter/>
                                            </Border>
                                            <ControlTemplate.Triggers>
                                                <Trigger Property="IsMouseOver" Value="True">
                                                    <Setter TargetName="ItemBorder" Property="Background" Value="#2D2D30"/>
                                                </Trigger>
                                            </ControlTemplate.Triggers>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                            </Style>
                        </ListBox.ItemContainerStyle>
                        <ListBox.ItemTemplate>
                            <DataTemplate>
                                <Grid Height="40">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="100"/>
                                        <ColumnDefinition Width="100"/>
                                    </Grid.ColumnDefinitions>
                                    
                                    <!-- Name -->
                                    <StackPanel VerticalAlignment="Center" Margin="5,0">
                                        <TextBlock Text="{Binding Name}" Foreground="White" FontWeight="SemiBold" FontSize="13"/>
                                        <TextBlock Text="{Binding Path}" Foreground="#666666" FontSize="10"/>
                                    </StackPanel>

                                    <!-- Status -->
                                    <Border Grid.Column="1" Background="{Binding StatusColor}" CornerRadius="10" 
                                            Height="20" Width="80" VerticalAlignment="Center" HorizontalAlignment="Center">
                                        <TextBlock Text="{Binding Status}" Foreground="White" FontSize="10" 
                                                   HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    
                                    <!-- Sync Button Placeholder (In actual implementation, we might use commands) -->
                                    <!-- For simple listbox binding, specific button logic is tricky in pure PS XAML without code-behind events per item. 
                                         We'll rely on selecting an item or 'Sync All' for version 1. -->
                                    <TextBlock Grid.Column="2" Text="Ready" Foreground="#444444" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                                </Grid>
                            </DataTemplate>
                        </ListBox.ItemTemplate>
                    </ListBox>
                </DockPanel>
            </Grid>

            <!-- 3. Footer / Status Bar -->
            <Border Grid.Row="2" Background="#007ACC" CornerRadius="0,0,8,8">
                <Grid>
                    <TextBlock Name="StatusText" Text="Ready" Foreground="White" VerticalAlignment="Center" Margin="15,0"/>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

# -----------------------------------------------------------------------------
# POWERSHELL LOGIC
# -----------------------------------------------------------------------------

# Helper to load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    Write-Error "Failed to load XAML: $_"
    exit
}

# Connect standard controls
$controls = @(
    "TitleBarArea", "MinimizeButton", "CloseButton", 
    "BtnSelectFolder", "BtnScan", "BtnSyncAll", 
    "TxtCountFound", "TxtCountSuccess", "TxtCurrentPath", "RepoList", "StatusText"
)
foreach ($id in $controls) {
    Set-Variable -Name $id -Value $window.FindName($id) -Scope Script
}

# --------------------------------------------------
# Window Events (Chrome-less dragging)
# --------------------------------------------------
$TitleBarArea.Add_MouseLeftButtonDown({
        param($sender, $e)
        $window.DragMove()
    })

$MinimizeButton.Add_Click({
        $window.WindowState = "Minimized"
    })

$CloseButton.Add_Click({
        $window.Close()
    })

# --------------------------------------------------
# Application State
# --------------------------------------------------
$Script:SelectedFolder = ""
$Script:Repos = [System.Collections.ObjectModel.ObservableCollection[System.Object]]::new()
$RepoList.ItemsSource = $Script:Repos

# --------------------------------------------------
# Functions
# --------------------------------------------------
Function Update-Status($msg) {
    if ($StatusText) { $StatusText.Text = $msg }
    # Force UI refresh for smooth feel
    [System.Windows.Forms.Application]::DoEvents() 
}

Function Scan-Repositories {
    if ([string]::IsNullOrWhiteSpace($Script:SelectedFolder)) {
        Update-Status "Please select a folder first!"
        return
    }

    $Script:Repos.Clear()
    $TxtCountFound.Text = "0"
    Update-Status "Scanning for .git folders..."

    # Use a runspace or simple job to avoid freezing? 
    # For simplicity v1: direct execution with DoEvents
    
    $subfolders = Get-ChildItem -Path $Script:SelectedFolder -Directory
    
    foreach ($folder in $subfolders) {
        $gitPath = Join-Path $folder.FullName ".git"
        if (Test-Path $gitPath) {
            $displayName = $folder.Name
            
            # Simple object for binding
            $repoObj = [PSCustomObject]@{
                Name        = $displayName
                Path        = $folder.FullName
                Status      = "Found"
                StatusColor = "#444444" # Gray
            }
            $Script:Repos.Add($repoObj)
            $TxtCountFound.Text = $Script:Repos.Count.ToString()
            [System.Windows.Forms.Application]::DoEvents()
        }
    }
    Update-Status "Scan Complete. Found $($Script:Repos.Count) repositories."
}

# --------------------------------------------------
# Async Sync Logic
# --------------------------------------------------
$Script:SyncTimer = $null
$Script:SyncRunspace = $null
$Script:SyncQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())

Function Sync-Repositories {
    $count = $Script:Repos.Count
    if ($count -eq 0) { return }

    # Disable UI
    $BtnSyncAll.IsEnabled = $false
    $BtnScan.IsEnabled = $false
    Update-Status "Starting background sync..."

    # Reset Stats
    $Script:Repos | ForEach-Object { 
        $_.Status = "Pending..." 
        $_.StatusColor = "#444444" 
    }
    $RepoList.Items.Refresh()

    # Prepare Data for Background Thread (ObservableCollection is not safe to pass directly)
    $repoPaths = $Script:Repos | Select-Object -ExpandProperty Path
    
    # Clear Queue
    $Script:SyncQueue.Clear()

    # 1. Create ScriptBlock for Background Worker
    $syncBlock = {
        param($paths, $queue)
        
        $total = $paths.Count
        $i = 0

        foreach ($path in $paths) {
            $i++
            
            # Notify Start
            $queue.Enqueue(@{ Type = "Progress"; Path = $path; Index = $i; Total = $total })
            
            # Do Work
            $status = "Failed"
            $color = "#FF5252"
            
            if (Test-Path $path) {
                try {
                    Push-Location $path
                    $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
                    
                    # Run Git
                    git fetch --all 2>&1 | Out-Null
                    git pull 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        $status = "Synced"
                        $color = "#4CAF50" # Green
                    }
                    else {
                        $status = "Error"
                        $color = "#FF5252" # Red
                    }
                }
                catch {
                    $status = "Ex: $_"
                }
                finally {
                    Pop-Location
                }
            }
            
            # Notify Result
            $queue.Enqueue(@{ Type = "Result"; Path = $path; Status = $status; Color = $color })
        }
    }

    # 2. Start Runspace
    $Script:SyncRunspace = [PowerShell]::Create().AddScript($syncBlock).AddArgument($repoPaths).AddArgument($Script:SyncQueue)
    $Script:SyncRunspace.BeginInvoke()

    # 3. Start UI Timer to poll results
    if ($null -eq $Script:SyncTimer) {
        $Script:SyncTimer = New-Object System.Windows.Threading.DispatcherTimer
        $Script:SyncTimer.Interval = [TimeSpan]::FromMilliseconds(100)
        $Script:SyncTimer.Add_Tick({
                Process-SyncQueue
            })
    }
    $Script:SyncTimer.Start()
}

Function Process-SyncQueue {
    # Process all available messages
    while ($Script:SyncQueue.Count -gt 0) {
        $msg = $Script:SyncQueue.Dequeue()
        
        # Find local repo object
        $repo = $Script:Repos | Where-Object { $_.Path -eq $msg.Path } | Select-Object -First 1
        
        if ($msg.Type -eq "Progress") {
            if ($repo) {
                $repo.Status = "Syncing..."
                $repo.StatusColor = "#007ACC"
            }
            Update-Status "Syncing [$($msg.Index)/$($msg.Total)]: $($msg.Path | Split-Path -Leaf)"
            $RepoList.Items.Refresh()
        }
        elseif ($msg.Type -eq "Result") {
            if ($repo) {
                $repo.Status = $msg.Status
                $repo.StatusColor = $msg.Color
                
                # Update Success Count safely
                if ($msg.Status -eq "Synced") {
                    $curr = [int]$TxtCountSuccess.Text
                    $TxtCountSuccess.Text = ($curr + 1).ToString()
                }
            }
            $RepoList.Items.Refresh()
        }
    }

    # Check if finished
    if ($Script:SyncRunspace -and $Script:SyncRunspace.InvocationStateInfo.State -ne "Running") {
        $Script:SyncTimer.Stop()
        $Script:SyncRunspace.Dispose()
        $Script:SyncRunspace = $null
        
        $BtnSyncAll.IsEnabled = $true
        $BtnScan.IsEnabled = $true
        Update-Status "Sync Completed!"
        $RepoList.Items.Refresh()
    }
}

# --------------------------------------------------
# Event Handlers
# --------------------------------------------------
$BtnSelectFolder.Add_Click({
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select Parent Folder containing Git Repos"
    
        if ($dialog.ShowDialog() -eq "OK") {
            $Script:SelectedFolder = $dialog.SelectedPath
            $TxtCurrentPath.Text = $Script:SelectedFolder
            Update-Status "Folder Selected: $($Script:SelectedFolder)"
        }
    })

$BtnScan.Add_Click({
        Scan-Repositories
    })

$BtnSyncAll.Add_Click({
        Sync-Repositories
    })

# --------------------------------------------------
# Launch
# --------------------------------------------------
Update-Status "Welcome to Friendly Horizon"
$window.ShowDialog() | Out-Null

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
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#1E1E1E" Offset="0.0"/>
            <GradientStop Color="#252526" Offset="1.0"/>
        </LinearGradientBrush>
        
        <SolidColorBrush x:Key="SidebarBackground" Color="#202020"/>
        <SolidColorBrush x:Key="ControlBackground" Color="#333337"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#AAAAAA"/>
        
        <!-- Action Button Gradient -->
        <LinearGradientBrush x:Key="AccentGradient" StartPoint="0,0" EndPoint="1,0">
            <GradientStop Color="#007ACC" Offset="0.0"/>
            <GradientStop Color="#005A9E" Offset="1.0"/>
        </LinearGradientBrush>

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

        <!-- Custom Scrollbar -->
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
                <RowDefinition Height="35"/>
            </Grid.RowDefinitions>

            <!-- 1. Custom Title Bar -->
            <Grid Grid.Row="0" Background="Transparent" Name="TitleBarArea">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="15,0,0,0">
                    <TextBlock Text="SuperGit Tools" Foreground="{StaticResource TextPrimary}" FontWeight="SemiBold" FontSize="14"/>
                    <TextBlock Text=" | Friendly Horizon" Foreground="{StaticResource TextSecondary}" Margin="10,0,0,0" FontSize="12" VerticalAlignment="Center"/>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,10,0">
                    <Button Name="MinimizeButton" Content="_" Width="40" Background="Transparent" Foreground="#CCCCCC"/>
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
                        <Label Content="ACTIONS" Foreground="#666666" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                        
                        <Button Name="BtnSelectFolder" Content="Select Folder" Height="35" HorizontalContentAlignment="Left"/>
                        <Button Name="BtnScan" Content="Scan Subfolders" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                        <Button Name="BtnSyncAll" Content="Sync All" Height="35" HorizontalContentAlignment="Left" Background="{StaticResource AccentGradient}"/>

                        <Separator Background="#333333" Margin="0,15"/>

                        <Label Content="STATS" Foreground="#666666" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                        <StackPanel Orientation="Horizontal" Margin="5">
                            <TextBlock Text="Found:" Foreground="{StaticResource TextSecondary}" Width="60"/>
                            <TextBlock Name="TxtCountFound" Text="0" Foreground="White" FontWeight="Bold"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="5">
                            <TextBlock Text="Success:" Foreground="{StaticResource TextSecondary}" Width="60"/>
                            <TextBlock Name="TxtCountSuccess" Text="0" Foreground="#4CAF50" FontWeight="Bold"/>
                        </StackPanel>
                    </StackPanel>
                </Border>

                <!-- Repo List (Card Layout) -->
                <DockPanel Grid.Column="1" Margin="20,10,20,10">
                    <StackPanel DockPanel.Dock="Top" Margin="0,0,0,10">
                        <TextBlock Text="Repositories" FontSize="20" FontWeight="Light" Foreground="White"/>
                        <TextBlock Name="TxtCurrentPath" Text="No folder selected" Foreground="#666666" FontStyle="Italic" TextTrimming="CharacterEllipsis"/>
                    </StackPanel>

                    <ListBox Name="RepoList" Background="Transparent" BorderThickness="0" ScrollViewer.HorizontalScrollBarVisibility="Disabled">
                        <ListBox.ItemContainerStyle>
                            <Style TargetType="ListBoxItem">
                                <Setter Property="Background" Value="Transparent"/>
                                <Setter Property="Padding" Value="0"/>
                                <Setter Property="Margin" Value="0,0,0,8"/> <!-- Spacing between cards -->
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="ListBoxItem">
                                            <ContentPresenter/>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                            </Style>
                        </ListBox.ItemContainerStyle>
                        <ListBox.ItemTemplate>
                            <DataTemplate>
                                <Border Background="#2D2D30" CornerRadius="6" Padding="10" BorderBrush="#3E3E42" BorderThickness="1">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        
                                        <!-- Left Info -->
                                        <StackPanel VerticalAlignment="Center">
                                            <TextBlock Text="{Binding Name}" Foreground="White" FontWeight="SemiBold" FontSize="13"/>
                                            <TextBlock Text="{Binding Path}" Foreground="#888888" FontSize="10" TextTrimming="CharacterEllipsis"/>
                                        </StackPanel>

                                        <!-- Right Status -->
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <TextBlock Text="{Binding Status}" Foreground="#AAAAAA" FontSize="11" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                            <Ellipse Width="12" Height="12" Fill="{Binding StatusColor}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </DataTemplate>
                        </ListBox.ItemTemplate>
                    </ListBox>
                </DockPanel>
            </Grid>

            <!-- 3. Footer / Status Bar -->
            <Border Grid.Row="2" Background="#007ACC" CornerRadius="0,0,8,8">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <TextBlock Name="StatusText" Text="Ready" Foreground="White" VerticalAlignment="Center" Margin="15,0" FontWeight="SemiBold"/>
                    
                    <!-- Progress Bar -->
                    <ProgressBar Name="SyncProgressBar" Grid.Column="1" Height="6" Margin="10,0" Background="#33000000" Foreground="White" BorderThickness="0" Value="0" Maximum="100"/>
                    
                    <Button Name="BtnToggleLog" Grid.Column="2" Content="Show Log" Background="Transparent" Foreground="White" Margin="0,0,10,0" FontWeight="Bold"/>
                </Grid>
            </Border>

            <!-- 4. Log Overlay -->
            <Border Name="LogOverlay" Grid.Row="0" Grid.RowSpan="2" Background="#F21E1E1E" Margin="20,50,20,10" Visibility="Collapsed" BorderBrush="#333333" BorderThickness="1" CornerRadius="6">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Border Background="#2D2D30" Padding="10,8" CornerRadius="6,6,0,0">
                        <Grid>
                            <TextBlock Text="Activity Log" Foreground="White" FontWeight="Bold"/>
                            <Button Name="BtnCloseLog" Content="X" HorizontalAlignment="Right" Background="Transparent" Foreground="#FF5252" Width="30" Padding="0"/>
                        </Grid>
                    </Border>
                    <ScrollViewer Name="LogScroll" Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="#1E1E1E">
                        <TextBox Name="LogTextBox" Background="Transparent" Foreground="#00FF00" FontFamily="Consolas" BorderThickness="0" IsReadOnly="True" TextWrapping="Wrap" Padding="10"/>
                    </ScrollViewer>
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
    "TxtCountFound", "TxtCountSuccess", "TxtCurrentPath", "RepoList", "StatusText",
    "BtnToggleLog", "LogOverlay", "BtnCloseLog", "LogTextBox", "LogScroll", "SyncProgressBar"
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
    $SyncProgressBar.Value = 0
    Update-Status "Starting background sync..."

    # Reset Stats
    $Script:Repos | ForEach-Object { 
        $_.Status = "Pending..." 
        $_.StatusColor = "#444444" 
    }
    $RepoList.Items.Refresh()

    # Prepare Data for Background Thread (ObservableCollection is not safe to pass directly)
    $repoPaths = $Script:Repos | Select-Object -ExpandProperty Path
    
    # SETUP LOGGING
    $parentName = Split-Path $Script:SelectedFolder -Leaf
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $logFile = Join-Path $Script:SelectedFolder "$dateStamp-$parentName.log"
    
    # Clear Queue & Log Box
    $Script:SyncQueue.Clear()
    $LogTextBox.Text = "--- Log Started: $(Get-Date) ---`r`n"
    if ($LogOverlay.Visibility -eq "Collapsed") { $LogOverlay.Visibility = "Visible" }

    # 1. Create ScriptBlock for Background Worker
    $syncBlock = {
        param($paths, $queue, $logFile)
        
        # Helper logging function
        function Log-Msg ($msg) {
            # To File
            $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            "[$time] $msg" | Out-File $logFile -Append -Encoding UTF8
            # To UI
            $queue.Enqueue(@{ Type = "Log"; Msg = "[$time] $msg" })
        }

        # Header
        Log-Msg "======================================================"
        Log-Msg "STARTING SYNC JOB"
        Log-Msg "======================================================"

        $total = $paths.Count
        $i = 0

        foreach ($path in $paths) {
            $i++
            
            # Notify Start
            $queue.Enqueue(@{ Type = "Progress"; Path = $path; Index = $i; Total = $total })
            Log-Msg "[$i/$total] PROCESSING: $path"
            
            # Do Work
            $status = "Failed"
            $color = "#FF5252"
            
            if (Test-Path $path) {
                try {
                    Push-Location $path
                    $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
                    
                    Log-Msg "   [CMD] git fetch --all"
                    $fetch = git fetch --all 2>&1 
                    if ($fetch) { foreach ($l in $fetch) { Log-Msg "      $l" } }

                    Log-Msg "   [CMD] git pull"
                    $pull = git pull 2>&1
                    if ($pull) { foreach ($l in $pull) { Log-Msg "      $l" } }
                    
                    if ($LASTEXITCODE -eq 0) {
                        $status = "Synced"
                        $color = "#4CAF50" # Green
                        Log-Msg "   [RES] SUCCESS"
                    }
                    else {
                        $status = "Error"
                        $color = "#FF5252" # Red
                        Log-Msg "   [RES] GIT EXIT CODE $LASTEXITCODE"
                    }
                }
                catch {
                    $status = "Ex: $_"
                    Log-Msg "   [ERR] EXCEPTION: $_"
                }
                finally {
                    Pop-Location
                }
            }
            else {
                Log-Msg "   [ERR] PATH NOT FOUND"
            }
            
            # Notify Result
            $queue.Enqueue(@{ Type = "Result"; Path = $path; Status = $status; Color = $color })
        }
        Log-Msg "======================================================"
        Log-Msg "SYNC JOB COMPLETED"
        Log-Msg "======================================================"
    }

    # 2. Start Runspace
    $Script:SyncRunspace = [PowerShell]::Create().AddScript($syncBlock).AddArgument($repoPaths).AddArgument($Script:SyncQueue).AddArgument($logFile)
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
            # Update Progress Bar
            $percent = [math]::Round(($msg.Index / $msg.Total) * 100)
            $SyncProgressBar.Value = $percent

            Update-Status "Syncing [$($msg.Index)/$($msg.Total)]: $($msg.Path | Split-Path -Leaf)"
            $RepoList.Items.Refresh()
        }
        elseif ($msg.Type -eq "Log") {
            $LogTextBox.AppendText($msg.Msg + "`r`n")
            $LogScroll.ScrollToEnd()
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
        $SyncProgressBar.Value = 100
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

$BtnToggleLog.Add_Click({
        if ($LogOverlay.Visibility -eq "Visible") {
            $LogOverlay.Visibility = "Collapsed"
            $BtnToggleLog.Content = "Show Log"
        }
        else {
            $LogOverlay.Visibility = "Visible"
            $BtnToggleLog.Content = "Hide Log"
        }
    })

$BtnCloseLog.Add_Click({
        $LogOverlay.Visibility = "Collapsed"
        $BtnToggleLog.Content = "Show Log"
    })

# --------------------------------------------------
# Launch
# --------------------------------------------------
Update-Status "Welcome to Friendly Horizon"
$window.ShowDialog() | Out-Null

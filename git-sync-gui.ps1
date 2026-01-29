<#
.SYNOPSIS
    SuperGit-Tools GUI - "Friendly Horizon" Edition v2.0
    A modern, feature-rich GUI for syncing Git repositories.

.DESCRIPTION
    This script launches a WPF application to manage and sync multiple git repositories.
    Enhanced with advanced status tracking, filtering, individual repo actions, and more.
    
    Features:
    - Git status detection (clean, dirty, ahead, behind, diverged)
    - Search and filter repositories
    - Individual repository actions (context menu)
    - Enhanced visual design with animations
    - Keyboard shortcuts
    - Detailed repository information
    - Export logs functionality

.NOTES
    Author: Antigravity for SuperGit-Tools
    Requires: PowerShell 5.1+, Git installed
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Check if Git is installed
try {
    $null = git --version
}
catch {
    [System.Windows.MessageBox]::Show("Git is not installed or not in PATH. Please install Git and try again.", "Git Not Found", "OK", "Error")
    exit
}

# -----------------------------------------------------------------------------
# XAML INTERFACE (Enhanced Friendly Horizon Design)
# -----------------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SuperGit Tools v2.0" Height="700" Width="1100"
        WindowStyle="None" ResizeMode="CanResizeWithGrip" AllowsTransparency="True"
        Background="Transparent">

    <Window.Resources>
        <!-- Colors & Brushes (Light Theme) -->
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#FFFFFF" Offset="0.0"/>
            <GradientStop Color="#F5F5F5" Offset="1.0"/>
        </LinearGradientBrush>
        
        <SolidColorBrush x:Key="SidebarBackground" Color="#F0F0F0"/>
        <SolidColorBrush x:Key="ControlBackground" Color="#E8E8E8"/>
        <SolidColorBrush x:Key="CardBackground" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#1A1A1A"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#616161"/>
        <SolidColorBrush x:Key="TextMuted" Color="#9E9E9E"/>
        
        <!-- Action Button Gradient -->
        <LinearGradientBrush x:Key="AccentGradient" StartPoint="0,0" EndPoint="1,0">
            <GradientStop Color="#0078D4" Offset="0.0"/>
            <GradientStop Color="#005A9E" Offset="1.0"/>
        </LinearGradientBrush>

        <!-- Button Style with Hover Animation -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource ControlBackground}"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#D0D0D0"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0078D4"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- TextBox Style -->
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="{StaticResource ControlBackground}"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#CCCCCC"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>

        <!-- ScrollBar Style -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#BDBDBD"/>
        </Style>

    </Window.Resources>

    <Border Background="{StaticResource WindowBackground}" CornerRadius="8" BorderThickness="1" BorderBrush="#D0D0D0">
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
                    <TextBlock Text=" v2.0 | Friendly Horizon" Foreground="{StaticResource TextSecondary}" Margin="10,0,0,0" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,10,0">
                    <Button Name="MinimizeButton" Content="_" Width="40" Background="Transparent" Foreground="#666666"/>
                    <Button Name="CloseButton" Content="X" Width="40" Background="Transparent" Foreground="#FF5252" FontWeight="Bold"/>
                </StackPanel>
            </Grid>

            <!-- 2. Main Content Area -->
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="240"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Sidebar Controls -->
                <Border Grid.Column="0" Background="{StaticResource SidebarBackground}" Padding="15">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <Label Content="ACTIONS" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            
                            <Button Name="BtnSelectFolder" Content="Select Folder" Height="35" HorizontalContentAlignment="Left"/>
                            <Button Name="BtnScan" Content="Scan Repositories" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                            <Button Name="BtnRefresh" Content="Refresh Status" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                            <Button Name="BtnSyncAll" Content="Sync All" Height="35" HorizontalContentAlignment="Left" Background="{StaticResource AccentGradient}"/>

                            <Separator Background="#D0D0D0" Margin="0,15"/>

                            <Label Content="FILTER" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <TextBox Name="TxtSearch" Height="32" Margin="5"/>
                            <TextBlock Name="TxtSearchHelper" Text="Search repos..." Foreground="#9E9E9E" FontSize="11" Margin="10,2,0,0" FontStyle="Italic"/>
                            
                            <ComboBox Name="CmbStatusFilter" Height="32" Margin="5,10,5,5" Background="{StaticResource ControlBackground}" Foreground="{StaticResource TextPrimary}" BorderBrush="#CCCCCC">
                                <ComboBoxItem Content="All Status" IsSelected="True"/>
                                <ComboBoxItem Content="Clean"/>
                                <ComboBoxItem Content="Dirty"/>
                                <ComboBoxItem Content="Ahead"/>
                                <ComboBoxItem Content="Behind"/>
                                <ComboBoxItem Content="Diverged"/>
                                <ComboBoxItem Content="Error"/>
                            </ComboBox>

                            <Separator Background="#D0D0D0" Margin="0,15"/>

                            <Label Content="STATS" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <StackPanel Orientation="Horizontal" Margin="5">
                                <TextBlock Text="Found:" Foreground="{StaticResource TextSecondary}" Width="65"/>
                                <TextBlock Name="TxtCountFound" Text="0" Foreground="{StaticResource TextPrimary}" FontWeight="Bold"/>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="5">
                                <TextBlock Text="Success:" Foreground="{StaticResource TextSecondary}" Width="65"/>
                                <TextBlock Name="TxtCountSuccess" Text="0" Foreground="#4CAF50" FontWeight="Bold"/>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="5">
                                <TextBlock Text="Failed:" Foreground="{StaticResource TextSecondary}" Width="65"/>
                                <TextBlock Name="TxtCountFailed" Text="0" Foreground="#FF5252" FontWeight="Bold"/>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="5">
                                <TextBlock Text="Dirty:" Foreground="{StaticResource TextSecondary}" Width="65"/>
                                <TextBlock Name="TxtCountDirty" Text="0" Foreground="#FFC107" FontWeight="Bold"/>
                            </StackPanel>

                            <Separator Background="#D0D0D0" Margin="0,15"/>

                            <Label Content="OPTIONS" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <Button Name="BtnExportLogs" Content="Export Logs" Height="32" HorizontalContentAlignment="Left"/>
                            <Button Name="BtnSettings" Content="Settings" Height="32" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <!-- Repo List Area -->
                <DockPanel Grid.Column="1" Margin="20,10,20,10">
                    <StackPanel DockPanel.Dock="Top" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel>
                                <TextBlock Text="Repositories" FontSize="20" FontWeight="Light" Foreground="{StaticResource TextPrimary}"/>
                                <TextBlock Name="TxtCurrentPath" Text="No folder selected" Foreground="{StaticResource TextMuted}" FontStyle="Italic" TextTrimming="CharacterEllipsis"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
                                <ComboBox Name="CmbSortBy" Width="140" Height="28" Margin="10,0" Background="{StaticResource ControlBackground}" Foreground="{StaticResource TextPrimary}" BorderBrush="#CCCCCC">
                                    <ComboBoxItem Content="Sort: Name" IsSelected="True"/>
                                    <ComboBoxItem Content="Sort: Status"/>
                                    <ComboBoxItem Content="Sort: Branch"/>
                                </ComboBox>
                            </StackPanel>
                        </Grid>
                    </StackPanel>

                    <!-- Repository Cards List -->
                    <ListBox Name="RepoList" Background="Transparent" BorderThickness="0" ScrollViewer.HorizontalScrollBarVisibility="Disabled"
                             VirtualizingStackPanel.IsVirtualizing="True" VirtualizingStackPanel.VirtualizationMode="Recycling">
                        <ListBox.ItemContainerStyle>
                            <Style TargetType="ListBoxItem">
                                <Setter Property="Background" Value="Transparent"/>
                                <Setter Property="Padding" Value="0"/>
                                <Setter Property="Margin" Value="0,0,0,8"/>
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
                                <Border Background="{StaticResource CardBackground}" CornerRadius="6" Padding="12" 
                                        BorderBrush="#E0E0E0" BorderThickness="1" Name="CardBorder">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        
                                        <!-- Left Info -->
                                        <StackPanel VerticalAlignment="Center">
                                            <StackPanel Orientation="Horizontal">
                                                <TextBlock Text="{Binding Name}" Foreground="{StaticResource TextPrimary}" FontWeight="SemiBold" FontSize="14"/>
                                                <TextBlock Text="{Binding Branch}" Foreground="#1976D2" FontSize="11" Margin="10,0,0,0" VerticalAlignment="Center" FontStyle="Italic"/>
                                            </StackPanel>
                                            <TextBlock Text="{Binding Path}" Foreground="{StaticResource TextMuted}" FontSize="10" TextTrimming="CharacterEllipsis" Margin="0,2,0,0"/>
                                            <TextBlock Text="{Binding DetailedStatus}" Foreground="{StaticResource TextSecondary}" FontSize="10" Margin="0,2,0,0"/>
                                        </StackPanel>

                                        <!-- Right Status -->
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <TextBlock Text="{Binding Status}" Foreground="{StaticResource TextSecondary}" FontSize="11" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                            <Ellipse Width="14" Height="14" Fill="{Binding StatusColor}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                                <DataTemplate.Triggers>
                                    <DataTrigger Binding="{Binding IsMouseOver, RelativeSource={RelativeSource AncestorType=ListBoxItem}}" Value="True">
                                        <Setter TargetName="CardBorder" Property="Background" Value="#F8F8F8"/>
                                        <Setter TargetName="CardBorder" Property="BorderBrush" Value="#BDBDBD"/>
                                    </DataTrigger>
                                </DataTemplate.Triggers>
                            </DataTemplate>
                        </ListBox.ItemTemplate>
                    </ListBox>
                </DockPanel>
            </Grid>

            <!-- 3. Footer / Status Bar -->
            <Border Grid.Row="2" Background="#0078D4" CornerRadius="0,0,8,8">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <TextBlock Name="StatusText" Text="Ready" Foreground="White" VerticalAlignment="Center" Margin="15,0" FontWeight="SemiBold" FontSize="11"/>
                    
                    <!-- Progress Bar -->
                    <ProgressBar Name="SyncProgressBar" Grid.Column="1" Height="6" Margin="10,0" Background="#33FFFFFF" Foreground="White" BorderThickness="0" Value="0" Maximum="100"/>
                    
                    <Button Name="BtnToggleLog" Grid.Column="2" Content="Show Log" Background="Transparent" Foreground="White" Margin="0,0,10,0" FontWeight="Bold"/>
                </Grid>
            </Border>

            <!-- 4. Log Overlay -->
            <Border Name="LogOverlay" Grid.Row="0" Grid.RowSpan="2" Background="#F2FFFFFF" Margin="20,50,20,10" Visibility="Collapsed" BorderBrush="#CCCCCC" BorderThickness="1" CornerRadius="6">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Border Background="#F0F0F0" Padding="12,8" CornerRadius="6,6,0,0">
                        <Grid>
                            <StackPanel Orientation="Horizontal">
                                <TextBlock Text="Activity Log" Foreground="{StaticResource TextPrimary}" FontWeight="Bold"/>
                                <Button Name="BtnClearLog" Content="Clear" Margin="15,0,0,0" Height="24" Padding="10,2" Background="{StaticResource ControlBackground}"/>
                            </StackPanel>
                            <Button Name="BtnCloseLog" Content="X" HorizontalAlignment="Right" Background="Transparent" Foreground="#FF5252" Width="30" Padding="0"/>
                        </Grid>
                    </Border>
                    <ScrollViewer Name="LogScroll" Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="#FAFAFA">
                        <TextBox Name="LogTextBox" Background="Transparent" Foreground="#2E7D32" FontFamily="Consolas" BorderThickness="0" IsReadOnly="True" TextWrapping="Wrap" Padding="10" FontSize="11"/>
                    </ScrollViewer>
                </Grid>
            </Border>

            <!-- 5. Context Menu (will be added programmatically) -->
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
    "BtnSelectFolder", "BtnScan", "BtnRefresh", "BtnSyncAll", 
    "TxtCountFound", "TxtCountSuccess", "TxtCountFailed", "TxtCountDirty",
    "TxtCurrentPath", "RepoList", "StatusText",
    "BtnToggleLog", "LogOverlay", "BtnCloseLog", "BtnClearLog", "LogTextBox", "LogScroll", "SyncProgressBar",
    "TxtSearch", "TxtSearchHelper", "CmbStatusFilter", "CmbSortBy", 
    "BtnExportLogs", "BtnSettings"
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
$Script:AllRepos = [System.Collections.ObjectModel.ObservableCollection[System.Object]]::new()
$Script:FilteredRepos = [System.Collections.ObjectModel.ObservableCollection[System.Object]]::new()
$RepoList.ItemsSource = $Script:FilteredRepos

# --------------------------------------------------
# Context Menu Setup
# --------------------------------------------------
$Script:RepoContextMenu = New-Object System.Windows.Controls.ContextMenu

$menuItemSync = New-Object System.Windows.Controls.MenuItem
$menuItemSync.Header = "Sync This Repository"
$menuItemSync.Add_Click({
        $selectedRepo = $RepoList.SelectedItem
        if ($selectedRepo) {
            Sync-SingleRepository $selectedRepo
        }
    })

$menuItemRefresh = New-Object System.Windows.Controls.MenuItem
$menuItemRefresh.Header = "Refresh Status"
$menuItemRefresh.Add_Click({
        $selectedRepo = $RepoList.SelectedItem
        if ($selectedRepo) {
            Update-RepoStatus $selectedRepo
        }
    })

$menuItemExplorer = New-Object System.Windows.Controls.MenuItem
$menuItemExplorer.Header = "Open in Explorer"
$menuItemExplorer.Add_Click({
        $selectedRepo = $RepoList.SelectedItem
        if ($selectedRepo -and (Test-Path $selectedRepo.Path)) {
            Start-Process "explorer.exe" $selectedRepo.Path
        }
    })

$menuItemCopy = New-Object System.Windows.Controls.MenuItem
$menuItemCopy.Header = "Copy Path"
$menuItemCopy.Add_Click({
        $selectedRepo = $RepoList.SelectedItem
        if ($selectedRepo) {
            Set-Clipboard $selectedRepo.Path
            Update-Status "Path copied to clipboard"
        }
    })

$Script:RepoContextMenu.Items.Add($menuItemSync)
$Script:RepoContextMenu.Items.Add($menuItemRefresh)
$Script:RepoContextMenu.Items.Add((New-Object System.Windows.Controls.Separator))
$Script:RepoContextMenu.Items.Add($menuItemExplorer)
$Script:RepoContextMenu.Items.Add($menuItemCopy)

$RepoList.ContextMenu = $Script:RepoContextMenu

# --------------------------------------------------
# Keyboard Shortcuts
# --------------------------------------------------
$window.Add_KeyDown({
        param($sender, $e)
        
        if ($e.Key -eq "F" -and $e.KeyboardDevice.Modifiers -eq "Control") {
            $TxtSearch.Focus()
            $e.Handled = $true
        }
        elseif ($e.Key -eq "R" -and $e.KeyboardDevice.Modifiers -eq "Control") {
            Refresh-AllRepoStatus
            $e.Handled = $true
        }
        elseif ($e.Key -eq "S" -and $e.KeyboardDevice.Modifiers -eq "Control") {
            if ($BtnSyncAll.IsEnabled) {
                Sync-Repositories
            }
            $e.Handled = $true
        }
        elseif ($e.Key -eq "F5") {
            Refresh-AllRepoStatus
            $e.Handled = $true
        }
    })

# --------------------------------------------------
# Functions
# --------------------------------------------------
Function Update-Status($msg) {
    if ($StatusText) { $StatusText.Text = $msg }
    [System.Windows.Forms.Application]::DoEvents()
}

Function Log-Message($msg, $toFile = $true) {
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $logLine = "[$timestamp] $msg"
    
    $LogTextBox.AppendText($logLine + "`r`n")
    $LogScroll.ScrollToEnd()
    
    if ($toFile -and $Script:CurrentLogFile) {
        $logLine | Out-File $Script:CurrentLogFile -Append -Encoding UTF8
    }
}

Function Get-GitStatus($repoPath) {
    try {
        Push-Location $repoPath
        $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
        
        # Get branch and tracking info
        $status = git status --porcelain -b 2>&1
        
        $result = @{
            Branch         = "unknown"
            IsDirty        = $false
            Ahead          = 0
            Behind         = 0
            Status         = "Clean"
            StatusColor    = "#4CAF50"
            DetailedStatus = ""
        }
        
        if ($status) {
            $branchLine = $status[0]
            
            # Parse branch
            if ($branchLine -match '## (.+?)\.\.\.') {
                $result.Branch = $matches[1]
            }
            elseif ($branchLine -match '## (.+)$') {
                $result.Branch = $matches[1]
            }
            
            # Parse ahead/behind
            if ($branchLine -match '\[ahead (\d+)\]') {
                $result.Ahead = [int]$matches[1]
            }
            if ($branchLine -match '\[behind (\d+)\]') {
                $result.Behind = [int]$matches[1]
            }
            if ($branchLine -match '\[ahead (\d+), behind (\d+)\]') {
                $result.Ahead = [int]$matches[1]
                $result.Behind = [int]$matches[2]
            }
            
            # Check for dirty status
            if ($status.Count -gt 1) {
                $result.IsDirty = $true
            }
            
            # Determine overall status
            if ($result.IsDirty) {
                $result.Status = "Dirty"
                $result.StatusColor = "#FFC107"
                $result.DetailedStatus = "Uncommitted changes"
            }
            elseif ($result.Ahead -gt 0 -and $result.Behind -gt 0) {
                $result.Status = "Diverged"
                $result.StatusColor = "#9C27B0"
                $result.DetailedStatus = "Ahead $($result.Ahead), Behind $($result.Behind)"
            }
            elseif ($result.Ahead -gt 0) {
                $result.Status = "Ahead"
                $result.StatusColor = "#2196F3"
                $result.DetailedStatus = "Ahead by $($result.Ahead) commit$(if($result.Ahead -ne 1){'s'})"
            }
            elseif ($result.Behind -gt 0) {
                $result.Status = "Behind"
                $result.StatusColor = "#FF9800"
                $result.DetailedStatus = "Behind by $($result.Behind) commit$(if($result.Behind -ne 1){'s'})"
            }
            else {
                $result.Status = "Clean"
                $result.StatusColor = "#4CAF50"
                $result.DetailedStatus = "Up to date"
            }
        }
        
        return $result
    }
    catch {
        return @{
            Branch         = "error"
            IsDirty        = $false
            Ahead          = 0
            Behind         = 0
            Status         = "Error"
            StatusColor    = "#FF5252"
            DetailedStatus = "Failed to get status"
        }
    }
    finally {
        Pop-Location
    }
}

Function Update-RepoStatus($repoObj) {
    $gitStatus = Get-GitStatus $repoObj.Path
    
    $repoObj.Branch = $gitStatus.Branch
    $repoObj.Status = $gitStatus.Status
    $repoObj.StatusColor = $gitStatus.StatusColor
    $repoObj.DetailedStatus = $gitStatus.DetailedStatus
    $repoObj.IsDirty = $gitStatus.IsDirty
    $repoObj.Ahead = $gitStatus.Ahead
    $repoObj.Behind = $gitStatus.Behind
    
    $RepoList.Items.Refresh()
    Update-Statistics
}

Function Scan-Repositories {
    if ([string]::IsNullOrWhiteSpace($Script:SelectedFolder)) {
        Update-Status "Please select a folder first!"
        return
    }

    $Script:AllRepos.Clear()
    $Script:FilteredRepos.Clear()
    $TxtCountFound.Text = "0"
    Update-Status "Scanning for .git folders..."

    $subfolders = Get-ChildItem -Path $Script:SelectedFolder -Directory
    
    $count = 0
    foreach ($folder in $subfolders) {
        $gitPath = Join-Path $folder.FullName ".git"
        if (Test-Path $gitPath) {
            $count++
            
            # Get git status
            $gitStatus = Get-GitStatus $folder.FullName
            
            $repoObj = [PSCustomObject]@{
                Name           = $folder.Name
                Path           = $folder.FullName
                Branch         = $gitStatus.Branch
                Status         = "Pending"
                StatusColor    = "#757575"
                DetailedStatus = ""
                IsDirty        = $false
                Ahead          = 0
                Behind         = 0
                LastSync       = $null
            }
            
            $Script:AllRepos.Add($repoObj)
            $Script:FilteredRepos.Add($repoObj)
            $TxtCountFound.Text = $count.ToString()
            [System.Windows.Forms.Application]::DoEvents()
        }
    }
    
    Update-Status "Scan Complete. Found $count repositories."
    Log-Message "Scan Complete: Found $count repositories"
    
    # Start background status check
    if ($count -gt 0) {
        Update-Status "Checking repository status..."
        Start-BackgroundStatusCheck
    }
}

Function Start-BackgroundStatusCheck {
    # Simple sequential check
    foreach ($repo in $Script:AllRepos) {
        Update-RepoStatus $repo
        [System.Windows.Forms.Application]::DoEvents()
    }
    Update-Status "Status check complete"
    Log-Message "Status check complete"
}

Function Refresh-AllRepoStatus {
    if ($Script:AllRepos.Count -eq 0) {
        return
    }
    
    Update-Status "Refreshing status for all repositories..."
    Log-Message "Refreshing repository status..."
    
    foreach ($repo in $Script:AllRepos) {
        Update-RepoStatus $repo
        [System.Windows.Forms.Application]::DoEvents()
    }
    
    Update-Status "Status refresh complete"
    Log-Message "Status refresh complete"
}

Function Update-Statistics {
    $successCount = ($Script:AllRepos | Where-Object { $_.Status -eq "Synced" -or $_.Status -eq "Clean" }).Count
    $failedCount = ($Script:AllRepos | Where-Object { $_.Status -eq "Error" -or $_.Status -eq "Failed" }).Count
    $dirtyCount = ($Script:AllRepos | Where-Object { $_.IsDirty }).Count
    
    $TxtCountFound.Text = $Script:AllRepos.Count.ToString()
    $TxtCountSuccess.Text = $successCount.ToString()
    $TxtCountFailed.Text = $failedCount.ToString()
    $TxtCountDirty.Text = $dirtyCount.ToString()
}

Function Apply-Filter {
    $searchText = $TxtSearch.Text.Trim().ToLower()
    $statusFilter = $CmbStatusFilter.SelectedItem.Content
    
    $Script:FilteredRepos.Clear()
    
    foreach ($repo in $Script:AllRepos) {
        $matchSearch = [string]::IsNullOrWhiteSpace($searchText) -or 
        $repo.Name.ToLower().Contains($searchText) -or 
        $repo.Path.ToLower().Contains($searchText) -or
        $repo.Branch.ToLower().Contains($searchText)
        
        $matchStatus = ($statusFilter -eq "All Status") -or ($repo.Status -eq $statusFilter)
        
        if ($matchSearch -and $matchStatus) {
            $Script:FilteredRepos.Add($repo)
        }
    }
}

Function Apply-Sort {
    $sortMode = $CmbSortBy.SelectedItem.Content
    
    $sorted = switch ($sortMode) {
        "Sort: Name" { $Script:AllRepos | Sort-Object Name }
        "Sort: Status" { $Script:AllRepos | Sort-Object Status }
        "Sort: Branch" { $Script:AllRepos | Sort-Object Branch }
        default { $Script:AllRepos }
    }
    
    $Script:AllRepos.Clear()
    foreach ($item in $sorted) {
        $Script:AllRepos.Add($item)
    }
    
    Apply-Filter
}

# --------------------------------------------------
# Async Sync Logic
# --------------------------------------------------
$Script:SyncTimer = $null
$Script:SyncRunspace = $null
$Script:SyncQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:CurrentLogFile = $null

Function Sync-SingleRepository($repoObj) {
    Update-Status "Syncing $($repoObj.Name)..."
    Log-Message "Starting sync for: $($repoObj.Name)"
    
    $repoObj.Status = "Syncing..."
    $repoObj.StatusColor = "#00BCD4"
    $RepoList.Items.Refresh()
    
    try {
        Push-Location $repoObj.Path
        $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
        
        Log-Message "  [CMD] git fetch --all"
        $fetch = git fetch --all 2>&1
        if ($fetch) { Log-Message "  $fetch" }
        
        Log-Message "  [CMD] git pull"
        $pull = git pull 2>&1
        if ($pull) { Log-Message "  $pull" }
        
        if ($LASTEXITCODE -eq 0) {
            $repoObj.Status = "Synced"
            $repoObj.StatusColor = "#4CAF50"
            $repoObj.LastSync = Get-Date
            Log-Message "  [RESULT] SUCCESS"
        }
        else {
            $repoObj.Status = "Error"
            $repoObj.StatusColor = "#FF5252"
            Log-Message "  [RESULT] Git exit code: $LASTEXITCODE"
        }
    }
    catch {
        $repoObj.Status = "Error"
        $repoObj.StatusColor = "#FF5252"
        Log-Message "  [ERROR] $_"
    }
    finally {
        Pop-Location
        $RepoList.Items.Refresh()
        Update-Statistics
        Update-Status "Ready"
        
        # Refresh status after sync
        Update-RepoStatus $repoObj
    }
}

Function Sync-Repositories {
    $count = $Script:AllRepos.Count
    if ($count -eq 0) { return }

    # Disable UI
    $BtnSyncAll.IsEnabled = $false
    $BtnScan.IsEnabled = $false
    $BtnRefresh.IsEnabled = $false
    $SyncProgressBar.Value = 0
    Update-Status "Starting sync operation..."

    # Reset Stats
    $Script:AllRepos | ForEach-Object { 
        $_.Status = "Pending..." 
        $_.StatusColor = "#757575" 
    }
    $RepoList.Items.Refresh()

    # Prepare Data for Background Thread
    $repoPaths = $Script:AllRepos | Select-Object -ExpandProperty Path
    
    # SETUP LOGGING
    $parentName = Split-Path $Script:SelectedFolder -Leaf
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $Script:CurrentLogFile = Join-Path $Script:SelectedFolder "$dateStamp-$parentName.log"
    
    # Clear Queue & Log Box
    $Script:SyncQueue.Clear()
    $LogTextBox.Text = "--- Sync Started: $(Get-Date) ---`r`n"
    if ($LogOverlay.Visibility -eq "Collapsed") { $LogOverlay.Visibility = "Visible" }

    # Create ScriptBlock for Background Worker
    $syncBlock = {
        param($paths, $queue, $logFile)
        
        function Log-Msg ($msg) {
            $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            "[$time] $msg" | Out-File $logFile -Append -Encoding UTF8
            $queue.Enqueue(@{ Type = "Log"; Msg = "[$time] $msg" })
        }

        Log-Msg "======================================================="
        Log-Msg "STARTING SYNC JOB"
        Log-Msg "======================================================="

        $total = $paths.Count
        $i = 0

        foreach ($path in $paths) {
            $i++
            
            $queue.Enqueue(@{ Type = "Progress"; Path = $path; Index = $i; Total = $total })
            Log-Msg "[$i/$total] PROCESSING: $path"
            
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
                        $color = "#4CAF50"
                        Log-Msg "   [RES] SUCCESS"
                    }
                    else {
                        $status = "Error"
                        $color = "#FF5252"
                        Log-Msg "   [RES] GIT EXIT CODE $LASTEXITCODE"
                    }
                }
                catch {
                    $status = "Error"
                    Log-Msg "   [ERR] EXCEPTION: $_"
                }
                finally {
                    Pop-Location
                }
            }
            else {
                Log-Msg "   [ERR] PATH NOT FOUND"
            }
            
            $queue.Enqueue(@{ Type = "Result"; Path = $path; Status = $status; Color = $color })
        }
        Log-Msg "======================================================="
        Log-Msg "SYNC JOB COMPLETED"
        Log-Msg "======================================================="
    }

    # Start Runspace
    $Script:SyncRunspace = [PowerShell]::Create().AddScript($syncBlock).AddArgument($repoPaths).AddArgument($Script:SyncQueue).AddArgument($Script:CurrentLogFile)
    $Script:SyncRunspace.BeginInvoke()

    # Start UI Timer to poll results
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
    while ($Script:SyncQueue.Count -gt 0) {
        $msg = $Script:SyncQueue.Dequeue()
        
        $repo = $Script:AllRepos | Where-Object { $_.Path -eq $msg.Path } | Select-Object -First 1
        
        if ($msg.Type -eq "Progress") {
            if ($repo) {
                $repo.Status = "Syncing..."
                $repo.StatusColor = "#00BCD4"
            }
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
                if ($msg.Status -eq "Synced") {
                    $repo.LastSync = Get-Date
                }
            }
            $RepoList.Items.Refresh()
            Update-Statistics
        }
    }

    # Check if finished
    if ($Script:SyncRunspace -and $Script:SyncRunspace.InvocationStateInfo.State -ne "Running") {
        $Script:SyncTimer.Stop()
        $Script:SyncRunspace.Dispose()
        $Script:SyncRunspace = $null
        
        $BtnSyncAll.IsEnabled = $true
        $BtnScan.IsEnabled = $true
        $BtnRefresh.IsEnabled = $true
        $SyncProgressBar.Value = 100
        Update-Status "Sync Completed!"
        $RepoList.Items.Refresh()
        
        # Refresh all statuses after sync
        Log-Message "Refreshing repository status after sync..."
        Start-BackgroundStatusCheck
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
            Log-Message "Selected folder: $($Script:SelectedFolder)"
        }
    })

$BtnScan.Add_Click({
        Scan-Repositories
    })

$BtnRefresh.Add_Click({
        Refresh-AllRepoStatus
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

$BtnClearLog.Add_Click({
        $LogTextBox.Clear()
    })

$TxtSearch.Add_TextChanged({
        Apply-Filter
    })

$TxtSearch.Add_GotFocus({
        $TxtSearchHelper.Visibility = "Collapsed"
    })

$TxtSearch.Add_LostFocus({
        if ([string]::IsNullOrWhiteSpace($TxtSearch.Text)) {
            $TxtSearchHelper.Visibility = "Visible"
        }
    })

$CmbStatusFilter.Add_SelectionChanged({
        Apply-Filter
    })

$CmbSortBy.Add_SelectionChanged({
        Apply-Sort
    })

$BtnExportLogs.Add_Click({
        if ($Script:CurrentLogFile -and (Test-Path $Script:CurrentLogFile)) {
            Start-Process "explorer.exe" "/select,`"$($Script:CurrentLogFile)`""
            Update-Status "Log file location opened"
        }
        else {
            [System.Windows.MessageBox]::Show("No log file available yet. Please run a sync operation first.", "Export Logs", "OK", "Information")
        }
    })

$BtnSettings.Add_Click({
        [System.Windows.MessageBox]::Show("Settings panel coming soon!", "Settings", "OK", "Information")
    })

# --------------------------------------------------
# Launch
# --------------------------------------------------
Update-Status "Ready - Welcome to SuperGit Tools v2.0"
Log-Message "Application started"
$window.ShowDialog() | Out-Null

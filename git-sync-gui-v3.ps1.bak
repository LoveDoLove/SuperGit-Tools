<#
.SYNOPSIS
    SuperGit-Tools GUI - "Friendly Horizon" Edition v3.0
    A modern, feature-rich GUI for syncing Git repositories.

.DESCRIPTION
    Complete rewrite with enhanced async architecture, settings persistence,
    and improved "Friendly Horizon" light theme design.

.NOTES
    Author: Antigravity for SuperGit-Tools
    Requires: PowerShell 5.1+, Git installed
#>

#region Configuration
# =============================================================================
$Script:AppVersion = "3.0"
$Script:AppName = "SuperGit Tools"

# Settings path
$Script:SettingsDir = Join-Path $env:APPDATA "SuperGit-Tools"
$Script:SettingsFile = Join-Path $Script:SettingsDir "settings.json"

# Default settings
$Script:DefaultSettings = @{
    MaxParallel        = 8
    LogRetentionDays   = 30
    RecentFoldersCount = 5
    RecentFolders      = @()
}

# Color Palette - Friendly Horizon Light Theme
$Script:Colors = @{
    WindowBg1       = "#FFFFFF"
    WindowBg2       = "#F5F5F5"
    Sidebar         = "#F0F0F0"
    Control         = "#E8E8E8"
    Card            = "#FFFFFF"
    CardBorder      = "#E0E0E0"
    CardHover       = "#F8F8F8"
    CardHoverBorder = "#BDBDBD"
    TextPrimary     = "#1A1A1A"
    TextSecondary   = "#616161"
    TextMuted       = "#9E9E9E"
    Accent          = "#0078D4"
    AccentDark      = "#005A9E"
    StatusClean     = "#4CAF50"
    StatusDirty     = "#FFC107"
    StatusAhead     = "#2196F3"
    StatusBehind    = "#FF9800"
    StatusDiverged  = "#9C27B0"
    StatusError     = "#FF5252"
    StatusSyncing   = "#00BCD4"
    StatusPending   = "#757575"
}
#endregion

#region Assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Check Git
try { $null = git --version }
catch {
    [System.Windows.MessageBox]::Show("Git is not installed or not in PATH.", "Git Not Found", "OK", "Error")
    exit
}
#endregion

#region XAML_UI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SuperGit Tools v3.0" Height="700" Width="1100"
        WindowStyle="None" ResizeMode="CanResizeWithGrip" AllowsTransparency="True"
        Background="Transparent">

    <Window.Resources>
        <!-- Brushes -->
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#FFFFFF" Offset="0.0"/>
            <GradientStop Color="#F5F5F5" Offset="1.0"/>
        </LinearGradientBrush>
        
        <SolidColorBrush x:Key="SidebarBg" Color="#F0F0F0"/>
        <SolidColorBrush x:Key="ControlBg" Color="#E8E8E8"/>
        <SolidColorBrush x:Key="CardBg" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#1A1A1A"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#616161"/>
        <SolidColorBrush x:Key="TextMuted" Color="#9E9E9E"/>
        <SolidColorBrush x:Key="AccentBrush" Color="#0078D4"/>
        
        <LinearGradientBrush x:Key="AccentGradient" StartPoint="0,0" EndPoint="1,0">
            <GradientStop Color="#0078D4" Offset="0.0"/>
            <GradientStop Color="#005A9E" Offset="1.0"/>
        </LinearGradientBrush>

        <!-- Button Style -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource ControlBg}"/>
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
                                <Setter Property="Foreground" Value="White"/>
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
            <Setter Property="Background" Value="{StaticResource ControlBg}"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#CCCCCC"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>

        <!-- ComboBox Style -->
        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="{StaticResource ControlBg}"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="#CCCCCC"/>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource WindowBackground}" CornerRadius="8" BorderThickness="1" BorderBrush="#D0D0D0">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="40"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="35"/>
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Grid Grid.Row="0" Background="Transparent" Name="TitleBarArea">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="15,0,0,0">
                    <Ellipse Width="12" Height="12" Fill="#0078D4" Margin="0,0,8,0"/>
                    <TextBlock Text="SuperGit Tools" Foreground="{StaticResource TextPrimary}" FontWeight="SemiBold" FontSize="14"/>
                    <TextBlock Text=" v3.0" Foreground="{StaticResource TextMuted}" FontSize="11" VerticalAlignment="Center"/>
                    <TextBlock Text=" | Friendly Horizon" Foreground="{StaticResource TextSecondary}" Margin="5,0,0,0" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,10,0">
                    <Button Name="MinimizeButton" Content="_" Width="40" Background="Transparent" Foreground="#666666"/>
                    <Button Name="CloseButton" Content="X" Width="40" Background="Transparent" Foreground="#FF5252" FontWeight="Bold"/>
                </StackPanel>
            </Grid>

            <!-- Main Content -->
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="240"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Sidebar -->
                <Border Grid.Column="0" Background="{StaticResource SidebarBg}" Padding="15">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <!-- Actions -->
                            <Label Content="ACTIONS" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <Button Name="BtnSelectFolder" Content="Select Folder" Height="35" HorizontalContentAlignment="Left"/>
                            <Button Name="BtnScan" Content="Scan Repositories" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                            <Button Name="BtnRefresh" Content="Refresh Status" Height="35" HorizontalContentAlignment="Left" Margin="5,0,5,5"/>
                            <Button Name="BtnSyncAll" Content="Sync All" Height="35" HorizontalContentAlignment="Left" Background="{StaticResource AccentGradient}" Foreground="White"/>

                            <Separator Background="#D0D0D0" Margin="0,15"/>

                            <!-- Recent Folders -->
                            <Label Content="RECENT" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <ListBox Name="RecentList" Background="Transparent" BorderThickness="0" MaxHeight="100" Margin="0,0,0,10">
                                <ListBox.ItemContainerStyle>
                                    <Style TargetType="ListBoxItem">
                                        <Setter Property="Padding" Value="5,3"/>
                                        <Setter Property="Cursor" Value="Hand"/>
                                        <Setter Property="Foreground" Value="#616161"/>
                                        <Setter Property="FontSize" Value="11"/>
                                    </Style>
                                </ListBox.ItemContainerStyle>
                            </ListBox>

                            <Separator Background="#D0D0D0" Margin="0,5"/>

                            <!-- Filter -->
                            <Label Content="FILTER" Foreground="#9E9E9E" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                            <Grid Margin="5,0,5,0">
                                <TextBox Name="TxtSearch" Height="32"/>
                                <TextBlock Name="TxtSearchHelper" Text="Search repos..." Foreground="#9E9E9E" FontSize="11" Margin="10,0,0,0" 
                                           FontStyle="Italic" VerticalAlignment="Center" IsHitTestVisible="False"/>
                            </Grid>
                            
                            <ComboBox Name="CmbStatusFilter" Height="32" Margin="5,10,5,5">
                                <ComboBoxItem Content="All Status" IsSelected="True"/>
                                <ComboBoxItem Content="Clean"/>
                                <ComboBoxItem Content="Dirty"/>
                                <ComboBoxItem Content="Ahead"/>
                                <ComboBoxItem Content="Behind"/>
                                <ComboBoxItem Content="Diverged"/>
                                <ComboBoxItem Content="Error"/>
                            </ComboBox>

                            <Separator Background="#D0D0D0" Margin="0,15"/>

                            <!-- Stats -->
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

                            <!-- Options -->
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
                                <ComboBox Name="CmbSortBy" Width="140" Height="28" Margin="10,0">
                                    <ComboBoxItem Content="Sort: Name" IsSelected="True"/>
                                    <ComboBoxItem Content="Sort: Status"/>
                                    <ComboBoxItem Content="Sort: Branch"/>
                                </ComboBox>
                            </StackPanel>
                        </Grid>
                    </StackPanel>

                    <!-- Repository List -->
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
                                <Border Background="{StaticResource CardBg}" CornerRadius="6" Padding="12" 
                                        BorderBrush="#E0E0E0" BorderThickness="1" Name="CardBorder">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        
                                        <StackPanel VerticalAlignment="Center">
                                            <StackPanel Orientation="Horizontal">
                                                <TextBlock Text="{Binding Name}" Foreground="{StaticResource TextPrimary}" FontWeight="SemiBold" FontSize="14"/>
                                                <TextBlock Text="{Binding Branch}" Foreground="#1976D2" FontSize="11" Margin="10,0,0,0" VerticalAlignment="Center" FontStyle="Italic"/>
                                            </StackPanel>
                                            <TextBlock Text="{Binding Path}" Foreground="{StaticResource TextMuted}" FontSize="10" TextTrimming="CharacterEllipsis" Margin="0,2,0,0"/>
                                            <TextBlock Text="{Binding DetailedStatus}" Foreground="{StaticResource TextSecondary}" FontSize="10" Margin="0,2,0,0"/>
                                        </StackPanel>

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

            <!-- Status Bar -->
            <Border Grid.Row="2" Background="#0078D4" CornerRadius="0,0,8,8">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <TextBlock Name="StatusText" Text="Ready" Foreground="White" VerticalAlignment="Center" Margin="15,0" FontWeight="SemiBold" FontSize="11"/>
                    <ProgressBar Name="SyncProgressBar" Grid.Column="1" Height="6" Margin="10,0" Background="#33FFFFFF" Foreground="White" BorderThickness="0" Value="0" Maximum="100"/>
                    <TextBlock Name="TxtElapsed" Grid.Column="2" Text="" Foreground="#CCFFFFFF" VerticalAlignment="Center" FontSize="10" Margin="10,0"/>
                    <Button Name="BtnToggleLog" Grid.Column="3" Content="Show Log" Background="Transparent" Foreground="White" Margin="0,0,10,0" FontWeight="Bold"/>
                </Grid>
            </Border>

            <!-- Log Overlay -->
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
                                <Button Name="BtnClearLog" Content="Clear" Margin="15,0,0,0" Height="24" Padding="10,2" Background="{StaticResource ControlBg}"/>
                            </StackPanel>
                            <Button Name="BtnCloseLog" Content="X" HorizontalAlignment="Right" Background="Transparent" Foreground="#FF5252" Width="30" Padding="0"/>
                        </Grid>
                    </Border>
                    <ScrollViewer Name="LogScroll" Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="#FAFAFA">
                        <TextBox Name="LogTextBox" Background="Transparent" Foreground="#2E7D32" FontFamily="Consolas" BorderThickness="0" IsReadOnly="True" TextWrapping="Wrap" Padding="10" FontSize="11"/>
                    </ScrollViewer>
                </Grid>
            </Border>

            <!-- Settings Overlay -->
            <Border Name="SettingsOverlay" Grid.Row="0" Grid.RowSpan="3" Background="#CC000000" Visibility="Collapsed">
                <Border Background="White" CornerRadius="8" Width="400" Height="300" VerticalAlignment="Center" HorizontalAlignment="Center">
                    <Grid Margin="20">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <TextBlock Text="Settings" FontSize="18" FontWeight="SemiBold" Foreground="{StaticResource TextPrimary}"/>
                        
                        <StackPanel Grid.Row="1" Margin="0,20,0,0">
                            <StackPanel Orientation="Horizontal" Margin="0,10">
                                <TextBlock Text="Max Parallel Operations:" Width="180" VerticalAlignment="Center"/>
                                <TextBox Name="TxtMaxParallel" Width="60" Text="8"/>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,10">
                                <TextBlock Text="Log Retention (days):" Width="180" VerticalAlignment="Center"/>
                                <TextBox Name="TxtLogRetention" Width="60" Text="30"/>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,10">
                                <TextBlock Text="Recent Folders Count:" Width="180" VerticalAlignment="Center"/>
                                <TextBox Name="TxtRecentCount" Width="60" Text="5"/>
                            </StackPanel>
                        </StackPanel>
                        
                        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button Name="BtnSettingsCancel" Content="Cancel" Width="80"/>
                            <Button Name="BtnSettingsSave" Content="Save" Width="80" Background="{StaticResource AccentGradient}" Foreground="White"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </Border>
        </Grid>
    </Border>
</Window>
"@
#endregion

#region Settings_Management
Function Load-Settings {
    if (Test-Path $Script:SettingsFile) {
        try {
            $json = Get-Content $Script:SettingsFile -Raw | ConvertFrom-Json
            $Script:Settings = @{
                MaxParallel        = if ($json.MaxParallel) { $json.MaxParallel } else { 8 }
                LogRetentionDays   = if ($json.LogRetentionDays) { $json.LogRetentionDays } else { 30 }
                RecentFoldersCount = if ($json.RecentFoldersCount) { $json.RecentFoldersCount } else { 5 }
                RecentFolders      = if ($json.RecentFolders) { @($json.RecentFolders) } else { @() }
            }
        }
        catch { $Script:Settings = $Script:DefaultSettings.Clone() }
    }
    else { $Script:Settings = $Script:DefaultSettings.Clone() }
}

Function Save-Settings {
    try {
        if (-not (Test-Path $Script:SettingsDir)) { New-Item -ItemType Directory -Path $Script:SettingsDir -Force | Out-Null }
        $Script:Settings | ConvertTo-Json | Out-File $Script:SettingsFile -Encoding UTF8
    }
    catch { }
}

Function Add-RecentFolder($path) {
    $list = [System.Collections.ArrayList]@($Script:Settings.RecentFolders)
    $list.Remove($path)
    $list.Insert(0, $path)
    while ($list.Count -gt $Script:Settings.RecentFoldersCount) { $list.RemoveAt($list.Count - 1) }
    $Script:Settings.RecentFolders = @($list)
    Save-Settings
}
#endregion

#region XAML_Loading
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try { $window = [Windows.Markup.XamlReader]::Load($reader) }
catch { Write-Error "Failed to load XAML: $_"; exit }

$controls = @(
    "TitleBarArea", "MinimizeButton", "CloseButton", "BtnSelectFolder", "BtnScan", "BtnRefresh", "BtnSyncAll",
    "TxtCountFound", "TxtCountSuccess", "TxtCountFailed", "TxtCountDirty", "TxtCurrentPath", "RepoList", "StatusText", "TxtElapsed",
    "BtnToggleLog", "LogOverlay", "BtnCloseLog", "BtnClearLog", "LogTextBox", "LogScroll", "SyncProgressBar",
    "TxtSearch", "TxtSearchHelper", "CmbStatusFilter", "CmbSortBy", "BtnExportLogs", "BtnSettings", "RecentList",
    "SettingsOverlay", "TxtMaxParallel", "TxtLogRetention", "TxtRecentCount", "BtnSettingsCancel", "BtnSettingsSave"
)
foreach ($id in $controls) { Set-Variable -Name $id -Value ($window.FindName($id)) -Scope Script }
#endregion

#region Application_State
$Script:SelectedFolder = ""
$Script:AllRepos = [System.Collections.ObjectModel.ObservableCollection[System.Object]]::new()
$Script:FilteredRepos = [System.Collections.ObjectModel.ObservableCollection[System.Object]]::new()
$RepoList.ItemsSource = $Script:FilteredRepos

$Script:LogQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:StatusQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:SyncQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())
$Script:ScanQueue = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())

$Script:RunspacePool = $null
$Script:SyncRunspace = $null
$Script:ScanRunspace = $null
$Script:StatusPool = [System.Collections.Generic.List[PSObject]]::new()
$Script:CurrentLogFile = $null
$Script:SyncStartTime = $null
$Script:MainTimer = $null

Load-Settings
#endregion

#region Async_Infrastructure
Function Initialize-RunspacePool {
    if ($Script:RunspacePool) { $Script:RunspacePool.Dispose() }
    $limit = [Math]::Min($Script:Settings.MaxParallel, [Environment]::ProcessorCount * 2)
    $Script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, $limit)
    $Script:RunspacePool.Open()
    $Script:StatusPool.Clear()
}

Function Start-MainTimer {
    if ($null -eq $Script:MainTimer) {
        $Script:MainTimer = New-Object System.Windows.Threading.DispatcherTimer
        $Script:MainTimer.Interval = [TimeSpan]::FromMilliseconds(50)
        $Script:MainTimer.Add_Tick({ Process-AllQueues })
    }
    $Script:MainTimer.Start()
}

Function Process-AllQueues {
    Process-LogQueue
    Process-ScanQueue
    Process-StatusQueue
    Process-SyncQueue
    Update-ElapsedTime
}

Function Process-LogQueue {
    $count = 0
    while ($Script:LogQueue.Count -gt 0 -and $count -lt 20) {
        $entry = $Script:LogQueue.Dequeue()
        $count++
        $line = "[$($entry.Time)][$($entry.Level)] $($entry.Message)`r`n"
        if ($LogTextBox) { $LogTextBox.AppendText($line); $LogScroll.ScrollToEnd() }
    }
}

Function Update-ElapsedTime {
    if ($Script:SyncStartTime -and $TxtElapsed) {
        $elapsed = (Get-Date) - $Script:SyncStartTime
        $TxtElapsed.Text = "{0:mm\:ss}" -f $elapsed
    }
}
#endregion

#region Logging_Functions
Function Write-Log($msg, $level = "INFO") {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $entry = @{ Time = $timestamp; Level = $level; Message = $msg }
    $Script:LogQueue.Enqueue($entry)
    if ($Script:CurrentLogFile) {
        try { "[$timestamp][$level] $msg" | Out-File $Script:CurrentLogFile -Append -Encoding UTF8 } catch { }
    }
}

Function Update-Status($msg) {
    if ($StatusText) { $StatusText.Text = $msg }
    [System.Windows.Forms.Application]::DoEvents()
}

Function Update-Statistics {
    try {
        $success = ($Script:AllRepos | Where-Object { $_.Status -eq "Synced" -or $_.Status -eq "Clean" }).Count
        $failed = ($Script:AllRepos | Where-Object { $_.Status -eq "Error" -or $_.Status -eq "Failed" }).Count
        $dirty = ($Script:AllRepos | Where-Object { $_.IsDirty }).Count
        if ($TxtCountFound) { $TxtCountFound.Text = $Script:AllRepos.Count.ToString() }
        if ($TxtCountSuccess) { $TxtCountSuccess.Text = $success.ToString() }
        if ($TxtCountFailed) { $TxtCountFailed.Text = $failed.ToString() }
        if ($TxtCountDirty) { $TxtCountDirty.Text = $dirty.ToString() }
    }
    catch { }
}

Function Update-RecentList {
    if ($RecentList) {
        $RecentList.Items.Clear()
        foreach ($folder in $Script:Settings.RecentFolders) {
            $name = Split-Path $folder -Leaf
            $item = New-Object System.Windows.Controls.ListBoxItem
            $item.Content = $name
            $item.ToolTip = $folder
            $item.Tag = $folder
            $RecentList.Items.Add($item)
        }
    }
}
#endregion

#region Git_Operations
Function Submit-StatusJob($repoPath) {
    $workerScript = {
        param($repoPath, $queue)
        $res = @{ Path = $repoPath; Branch = "unknown"; IsDirty = $false; Ahead = 0; Behind = 0; Status = "Clean"; StatusColor = "#4CAF50"; DetailedStatus = "Up to date" }
        try {
            Push-Location $repoPath
            $branch = git rev-parse --abbrev-ref HEAD 2>&1
            if ($LASTEXITCODE -eq 0 -and $branch) { $res.Branch = $branch.Trim() }
            $dirty = @(git status --porcelain 2>&1)
            if ($dirty.Count -gt 0 -and $dirty[0] -notmatch '^fatal:') { $res.IsDirty = $true }
            $upstream = git rev-parse --abbrev-ref "@{u}" 2>&1
            if ($LASTEXITCODE -eq 0) {
                $ahead = git rev-list --count "@{u}..HEAD" 2>&1; if ($LASTEXITCODE -eq 0) { $res.Ahead = [int]$ahead }
                $behind = git rev-list --count "HEAD..@{u}" 2>&1; if ($LASTEXITCODE -eq 0) { $res.Behind = [int]$behind }
            }
            if ($res.IsDirty) { $res.Status = "Dirty"; $res.StatusColor = "#FFC107"; $res.DetailedStatus = "Uncommitted changes" }
            elseif ($res.Ahead -gt 0 -and $res.Behind -gt 0) { $res.Status = "Diverged"; $res.StatusColor = "#9C27B0"; $res.DetailedStatus = "Ahead $($res.Ahead), Behind $($res.Behind)" }
            elseif ($res.Ahead -gt 0) { $res.Status = "Ahead"; $res.StatusColor = "#2196F3"; $res.DetailedStatus = "Ahead $($res.Ahead) commits" }
            elseif ($res.Behind -gt 0) { $res.Status = "Behind"; $res.StatusColor = "#FF9800"; $res.DetailedStatus = "Behind $($res.Behind) commits" }
        }
        catch { $res.Status = "Error"; $res.StatusColor = "#FF5252"; $res.DetailedStatus = "Check failed" }
        finally { Pop-Location }
        $queue.Enqueue($res)
    }
    if ($Script:RunspacePool -and $Script:RunspacePool.RunspacePoolStateInfo.State -eq "Opened") {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $Script:RunspacePool
        [void]$ps.AddScript($workerScript).AddArgument($repoPath).AddArgument($Script:StatusQueue)
        [void]$ps.BeginInvoke()
        $Script:StatusPool.Add($ps)
    }
}

Function Process-StatusQueue {
    $count = 0
    while ($Script:StatusQueue.Count -gt 0 -and $count -lt 20) {
        $res = $Script:StatusQueue.Dequeue(); $count++
        $repo = $Script:AllRepos | Where-Object { $_.Path -eq $res.Path } | Select-Object -First 1
        if ($repo) {
            $repo.Branch = $res.Branch; $repo.Status = $res.Status; $repo.StatusColor = $res.StatusColor
            $repo.DetailedStatus = $res.DetailedStatus; $repo.IsDirty = $res.IsDirty; $repo.Ahead = $res.Ahead; $repo.Behind = $res.Behind
            Write-Log "Status: $($repo.Name) [$($res.Branch)] - $($res.Status)"
        }
    }
    if ($count -gt 0) { $RepoList.Items.Refresh(); Update-Statistics }
    $running = $false
    foreach ($ps in $Script:StatusPool) { if ($ps.InvocationStateInfo.State -eq "Running") { $running = $true; break } }
    if (-not $running -and $Script:StatusQueue.Count -eq 0 -and $Script:StatusPool.Count -gt 0) {
        $Script:StatusPool.Clear(); Update-Status "Status check complete"; Write-Log "Status refresh complete"
    }
}

Function Start-BackgroundStatusCheck {
    if ($Script:AllRepos.Count -eq 0) { return }
    Update-Status "Checking repository status..."
    Initialize-RunspacePool
    Start-MainTimer
    $snapshot = @($Script:AllRepos | ForEach-Object { $_.Path })
    foreach ($path in $snapshot) { Submit-StatusJob $path }
}
#endregion

#region Scan_Operations
Function Scan-Repositories {
    if ([string]::IsNullOrWhiteSpace($Script:SelectedFolder)) { Update-Status "Please select a folder first!"; return }
    
    $Script:AllRepos.Clear()
    $Script:FilteredRepos.Clear()
    $TxtCountFound.Text = "0"
    $Script:ScanQueue.Clear()
    Update-Status "Scanning for repositories..."
    
    $scanBlock = {
        param($path, $queue)
        Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $gitPath = Join-Path $_.FullName ".git"
            if (Test-Path $gitPath) { $queue.Enqueue(@{ Name = $_.Name; Path = $_.FullName }) }
        }
    }
    
    $Script:ScanRunspace = [PowerShell]::Create().AddScript($scanBlock).AddArgument($Script:SelectedFolder).AddArgument($Script:ScanQueue)
    $Script:ScanRunspace.BeginInvoke()
    
    Initialize-RunspacePool
    Start-MainTimer
}

Function Process-ScanQueue {
    while ($Script:ScanQueue.Count -gt 0) {
        $item = $Script:ScanQueue.Dequeue()
        if ($item.Name) {
            $repoObj = [PSCustomObject]@{
                Name = $item.Name; Path = $item.Path; Branch = "..."; Status = "Pending"; StatusColor = "#757575"
                DetailedStatus = "Checking..."; IsDirty = $false; Ahead = 0; Behind = 0; LastSync = $null
            }
            $Script:AllRepos.Add($repoObj)
            $Script:FilteredRepos.Add($repoObj)
            $TxtCountFound.Text = $Script:AllRepos.Count.ToString()
            Write-Log "Found: $($item.Name)"
            Submit-StatusJob $item.Path
        }
    }
    [System.Windows.Forms.Application]::DoEvents()
    
    if ($Script:ScanRunspace -and $Script:ScanRunspace.InvocationStateInfo.State -ne "Running") {
        $Script:ScanRunspace.Dispose()
        $Script:ScanRunspace = $null
        Update-Status "Scan complete. Found $($Script:AllRepos.Count) repositories."
        Write-Log "Scan complete: $($Script:AllRepos.Count) repositories"
    }
}
#endregion

#region Sync_Operations
Function Sync-Repositories {
    $count = $Script:AllRepos.Count
    if ($count -eq 0) { return }
    
    $BtnSyncAll.IsEnabled = $false; $BtnScan.IsEnabled = $false; $BtnRefresh.IsEnabled = $false
    $SyncProgressBar.Value = 0
    $Script:SyncStartTime = Get-Date
    Update-Status "Starting sync..."
    
    $Script:AllRepos | ForEach-Object { $_.Status = "Pending..."; $_.StatusColor = "#757575" }
    $RepoList.Items.Refresh()
    
    # Setup logging
    $parentName = Split-Path $Script:SelectedFolder -Leaf
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $Script:CurrentLogFile = Join-Path $Script:SelectedFolder "$dateStamp-$parentName.log"
    
    $Script:SyncQueue.Clear()
    $LogTextBox.Text = "--- Sync Started: $(Get-Date) ---`r`n"
    if ($LogOverlay.Visibility -eq "Collapsed") { $LogOverlay.Visibility = "Visible" }
    
    $repoPaths = $Script:AllRepos | Select-Object -ExpandProperty Path
    
    $syncBlock = {
        param($paths, $queue, $logFile)
        function Log-Msg($msg) {
            $time = (Get-Date).ToString("HH:mm:ss")
            "[$time] $msg" | Out-File $logFile -Append -Encoding UTF8
            $queue.Enqueue(@{ Type = "Log"; Time = $time; Message = $msg })
        }
        Log-Msg "=== SYNC JOB STARTED ==="
        $total = $paths.Count; $i = 0
        foreach ($path in $paths) {
            $i++
            $queue.Enqueue(@{ Type = "Progress"; Path = $path; Index = $i; Total = $total })
            Log-Msg "[$i/$total] Processing: $(Split-Path $path -Leaf)"
            $status = "Failed"; $color = "#FF5252"
            if (Test-Path $path) {
                try {
                    Push-Location $path
                    $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
                    Log-Msg "  [CMD] git fetch --all"
                    $fetch = git fetch --all 2>&1; if ($fetch) { foreach ($l in $fetch) { Log-Msg "    $l" } }
                    Log-Msg "  [CMD] git pull"
                    $pull = git pull 2>&1; if ($pull) { foreach ($l in $pull) { Log-Msg "    $l" } }
                    if ($LASTEXITCODE -eq 0) { $status = "Synced"; $color = "#4CAF50"; Log-Msg "  [RES] SUCCESS" }
                    else { Log-Msg "  [RES] Exit code: $LASTEXITCODE" }
                }
                catch { Log-Msg "  [ERR] $_" }
                finally { Pop-Location }
            }
            else { Log-Msg "  [ERR] Path not found" }
            $queue.Enqueue(@{ Type = "Result"; Path = $path; Status = $status; Color = $color })
        }
        Log-Msg "=== SYNC JOB COMPLETED ==="
    }
    
    $Script:SyncRunspace = [PowerShell]::Create().AddScript($syncBlock).AddArgument($repoPaths).AddArgument($Script:SyncQueue).AddArgument($Script:CurrentLogFile)
    $Script:SyncRunspace.BeginInvoke()
    Start-MainTimer
}

Function Process-SyncQueue {
    while ($Script:SyncQueue.Count -gt 0) {
        $msg = $Script:SyncQueue.Dequeue()
        $repo = $Script:AllRepos | Where-Object { $_.Path -eq $msg.Path } | Select-Object -First 1
        
        if ($msg.Type -eq "Progress") {
            if ($repo) { $repo.Status = "Syncing..."; $repo.StatusColor = "#00BCD4" }
            $percent = [math]::Round(($msg.Index / $msg.Total) * 100)
            $SyncProgressBar.Value = $percent
            Update-Status "Syncing [$($msg.Index)/$($msg.Total)]: $(Split-Path $msg.Path -Leaf)"
            $RepoList.Items.Refresh()
        }
        elseif ($msg.Type -eq "Log") {
            $LogTextBox.AppendText("[$($msg.Time)] $($msg.Message)`r`n")
            $LogScroll.ScrollToEnd()
        }
        elseif ($msg.Type -eq "Result") {
            if ($repo) { $repo.Status = $msg.Status; $repo.StatusColor = $msg.Color; if ($msg.Status -eq "Synced") { $repo.LastSync = Get-Date } }
            $RepoList.Items.Refresh()
            Update-Statistics
        }
    }
    
    if ($Script:SyncRunspace -and $Script:SyncRunspace.InvocationStateInfo.State -ne "Running") {
        $Script:SyncRunspace.Dispose()
        $Script:SyncRunspace = $null
        $BtnSyncAll.IsEnabled = $true; $BtnScan.IsEnabled = $true; $BtnRefresh.IsEnabled = $true
        $SyncProgressBar.Value = 100
        $Script:SyncStartTime = $null
        Update-Status "Sync Complete!"
        Write-Log "Sync operation completed"
        Start-BackgroundStatusCheck
    }
}
#endregion

#region Filter_Sort
Function Apply-Filter {
    $searchText = $TxtSearch.Text.Trim().ToLower()
    $statusFilter = $CmbStatusFilter.SelectedItem.Content
    
    $Script:FilteredRepos.Clear()
    foreach ($repo in $Script:AllRepos) {
        $matchSearch = [string]::IsNullOrWhiteSpace($searchText) -or $repo.Name.ToLower().Contains($searchText) -or $repo.Path.ToLower().Contains($searchText)
        $matchStatus = ($statusFilter -eq "All Status") -or ($repo.Status -eq $statusFilter)
        if ($matchSearch -and $matchStatus) { $Script:FilteredRepos.Add($repo) }
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
    foreach ($item in $sorted) { $Script:AllRepos.Add($item) }
    Apply-Filter
}
#endregion

#region Context_Menu
$Script:RepoContextMenu = New-Object System.Windows.Controls.ContextMenu

$menuSync = New-Object System.Windows.Controls.MenuItem
$menuSync.Header = "Sync This Repository"
$menuSync.Add_Click({
        $selected = $RepoList.SelectedItem
        if ($selected) {
            $selected.Status = "Syncing..."; $selected.StatusColor = "#00BCD4"; $RepoList.Items.Refresh()
            Push-Location $selected.Path
            try {
                $env:GIT_REDIRECT_STDERR_TO_STDOUT = "1"
                Write-Log "Syncing: $($selected.Name)"
                git fetch --all 2>&1 | ForEach-Object { Write-Log "  $_" }
                git pull 2>&1 | ForEach-Object { Write-Log "  $_" }
                if ($LASTEXITCODE -eq 0) { $selected.Status = "Synced"; $selected.StatusColor = "#4CAF50"; Write-Log "  SUCCESS" }
                else { $selected.Status = "Error"; $selected.StatusColor = "#FF5252"; Write-Log "  Exit code: $LASTEXITCODE" }
            }
            catch { $selected.Status = "Error"; $selected.StatusColor = "#FF5252"; Write-Log "  Error: $_" }
            finally { Pop-Location; $RepoList.Items.Refresh(); Update-Statistics }
        }
    })

$menuRefresh = New-Object System.Windows.Controls.MenuItem
$menuRefresh.Header = "Refresh Status"
$menuRefresh.Add_Click({
        $selected = $RepoList.SelectedItem
        if ($selected) { Initialize-RunspacePool; Start-MainTimer; Submit-StatusJob $selected.Path }
    })

$menuExplorer = New-Object System.Windows.Controls.MenuItem
$menuExplorer.Header = "Open in Explorer"
$menuExplorer.Add_Click({ $selected = $RepoList.SelectedItem; if ($selected -and (Test-Path $selected.Path)) { Start-Process "explorer.exe" $selected.Path } })

$menuCopy = New-Object System.Windows.Controls.MenuItem
$menuCopy.Header = "Copy Path"
$menuCopy.Add_Click({ $selected = $RepoList.SelectedItem; if ($selected) { Set-Clipboard $selected.Path; Update-Status "Path copied" } })

$Script:RepoContextMenu.Items.Add($menuSync)
$Script:RepoContextMenu.Items.Add($menuRefresh)
$Script:RepoContextMenu.Items.Add((New-Object System.Windows.Controls.Separator))
$Script:RepoContextMenu.Items.Add($menuExplorer)
$Script:RepoContextMenu.Items.Add($menuCopy)
$RepoList.ContextMenu = $Script:RepoContextMenu
#endregion

#region Event_Handlers
# Window chrome
$TitleBarArea.Add_MouseLeftButtonDown({ param($s, $e) $window.DragMove() })
$MinimizeButton.Add_Click({ $window.WindowState = "Minimized" })
$CloseButton.Add_Click({ $window.Close() })

# Main actions
$BtnSelectFolder.Add_Click({
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select Parent Folder containing Git Repos"
        if ($dialog.ShowDialog() -eq "OK") {
            $Script:SelectedFolder = $dialog.SelectedPath
            $TxtCurrentPath.Text = $Script:SelectedFolder
            Update-Status "Folder Selected: $($Script:SelectedFolder)"
            Write-Log "Selected folder: $($Script:SelectedFolder)"
            Add-RecentFolder $Script:SelectedFolder
            Update-RecentList
        }
    })

$BtnScan.Add_Click({ Scan-Repositories })
$BtnRefresh.Add_Click({ Start-BackgroundStatusCheck })
$BtnSyncAll.Add_Click({ Sync-Repositories })

# Log controls
$BtnToggleLog.Add_Click({
        if ($LogOverlay.Visibility -eq "Visible") { $LogOverlay.Visibility = "Collapsed"; $BtnToggleLog.Content = "Show Log" }
        else { $LogOverlay.Visibility = "Visible"; $BtnToggleLog.Content = "Hide Log" }
    })
$BtnCloseLog.Add_Click({ $LogOverlay.Visibility = "Collapsed"; $BtnToggleLog.Content = "Show Log" })
$BtnClearLog.Add_Click({ $LogTextBox.Clear() })

# Filter/Sort
$TxtSearch.Add_TextChanged({ Apply-Filter })
$TxtSearch.Add_GotFocus({ $TxtSearchHelper.Visibility = "Collapsed" })
$TxtSearch.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($TxtSearch.Text)) { $TxtSearchHelper.Visibility = "Visible" } })
$CmbStatusFilter.Add_SelectionChanged({ Apply-Filter })
$CmbSortBy.Add_SelectionChanged({ Apply-Sort })

# Recent folders
$RecentList.Add_SelectionChanged({
        $sel = $RecentList.SelectedItem
        if ($sel -and $sel.Tag) {
            $Script:SelectedFolder = $sel.Tag
            $TxtCurrentPath.Text = $Script:SelectedFolder
            Update-Status "Folder Selected: $($Script:SelectedFolder)"
            Scan-Repositories
        }
    })

# Export & Settings
$BtnExportLogs.Add_Click({
        if ($Script:CurrentLogFile -and (Test-Path $Script:CurrentLogFile)) { Start-Process "explorer.exe" "/select,`"$($Script:CurrentLogFile)`"" }
        else { [System.Windows.MessageBox]::Show("No log file available yet.", "Export Logs", "OK", "Information") }
    })

$BtnSettings.Add_Click({
        $TxtMaxParallel.Text = $Script:Settings.MaxParallel.ToString()
        $TxtLogRetention.Text = $Script:Settings.LogRetentionDays.ToString()
        $TxtRecentCount.Text = $Script:Settings.RecentFoldersCount.ToString()
        $SettingsOverlay.Visibility = "Visible"
    })

$BtnSettingsCancel.Add_Click({ $SettingsOverlay.Visibility = "Collapsed" })
$BtnSettingsSave.Add_Click({
        try {
            $Script:Settings.MaxParallel = [int]$TxtMaxParallel.Text
            $Script:Settings.LogRetentionDays = [int]$TxtLogRetention.Text
            $Script:Settings.RecentFoldersCount = [int]$TxtRecentCount.Text
            Save-Settings
            Update-Status "Settings saved"
        }
        catch { Update-Status "Invalid settings value" }
        $SettingsOverlay.Visibility = "Collapsed"
    })

# Keyboard shortcuts
$window.Add_KeyDown({
        param($s, $e)
        if ($e.Key -eq "F" -and $e.KeyboardDevice.Modifiers -eq "Control") { $TxtSearch.Focus(); $e.Handled = $true }
        elseif (($e.Key -eq "R" -and $e.KeyboardDevice.Modifiers -eq "Control") -or $e.Key -eq "F5") { Start-BackgroundStatusCheck; $e.Handled = $true }
        elseif ($e.Key -eq "S" -and $e.KeyboardDevice.Modifiers -eq "Control") { if ($BtnSyncAll.IsEnabled) { Sync-Repositories }; $e.Handled = $true }
    })
#endregion

#region Main_Entry
Update-Status "Ready - Welcome to SuperGit Tools v3.0"
Write-Log "Application started"
Update-RecentList
$window.ShowDialog() | Out-Null
#endregion

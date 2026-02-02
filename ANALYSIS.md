# SuperGit-Tools Analysis

## 1. Project Overview

**App Name:** SuperGit-Tools
**Core Functionality:** Automated Git synchronization tools for managing multiple repositories.
**Target OS:** Windows (PowerShell)

## 2. File Structure Analysis

- **Root Directory:** `d:\Projects\CloudProjects\SuperGit-Tools`
- **Key Files:**
  - `git-sync.ps1`: CLI-based Git synchronization script (v1.0, 97 lines).
  - `git-sync-gui.ps1`: GUI-based synchronization tool (v3.0, ~950 lines, WPF/PowerShell).
  - `git-sync-gui.ps1.bak`: Backup of v2.0 GUI.
  - `.git`, `.github`: Version control and GitHub configuration.
- **Settings Location:** `%APPDATA%\SuperGit-Tools\settings.json`
- **Log Files:** `yyyy-MM-dd-<FolderName>.log` (created in parent folder)

## 3. Script Analysis: `git-sync.ps1`

### Functionality

- **Input:** Accepts a parent folder path (`$ParentFolder`).
- **Discovery:** Finds subdirectories containing a `.git` folder.
- **Action:**
  - Prompts user for confirmation for each found repository.
  - Executes `git fetch --all --progress` and `git pull --progress`.
- **Logging:**
  - Creates a daily log file: `yyyy-MM-dd-<ParentFolderName>.log`.
  - Captures stdout and stderr (redirected).
  - Logs success, skipped status, and failure/exit codes.

## 4. Script Analysis: `git-sync-gui.ps1` (v3.0)

### Architecture

Complete rewrite organized into 14 `#region` blocks:

| Region               | Purpose                                       |
| -------------------- | --------------------------------------------- |
| Configuration        | App version, color palette, settings paths    |
| Assemblies           | Load WPF, validate Git installation           |
| XAML_UI              | Complete enhanced XAML interface              |
| Settings_Management  | JSON load/save functions                      |
| XAML_Loading         | Parse XAML, bind control references           |
| Application_State    | Variables, queues, pools, timers              |
| Async_Infrastructure | RunspacePool, unified timer, queue processors |
| Logging_Functions    | Write-Log, Update-Status, Update-Statistics   |
| Git_Operations       | Submit-StatusJob, Process-StatusQueue         |
| Scan_Operations      | Scan-Repositories, Process-ScanQueue          |
| Sync_Operations      | Sync-Repositories, Process-SyncQueue          |
| Filter_Sort          | Apply-Filter, Apply-Sort                      |
| Context_Menu         | Right-click menu items                        |
| Event_Handlers       | All UI event bindings                         |
| Main_Entry           | Application launch                            |

### Core Features

- **Folder Selection:** `FolderBrowserDialog` to select root directory.
- **Auto-Scan:** Finds `.git` repositories and lists them asynchronously.
- **Git Status Detection:** Uses dedicated git commands for reliability:
  - `git rev-parse --abbrev-ref HEAD` for branch
  - `git status --porcelain` for dirty check
  - `git rev-list --count @{u}..HEAD` / `HEAD..@{u}` for ahead/behind
- **Search & Filter:** Real-time filtering by name, path, or branch with status dropdown.
- **Sorting:** Sort by name, status, or branch.
- **Individual Repository Actions:** Context menu with sync, refresh, open, copy.
- **Keyboard Shortcuts:** `Ctrl+F`, `Ctrl+R`/`F5`, `Ctrl+S`
- **Sync-All:** Async git fetch/pull with real-time progress.
- **Statistics Panel:** Found, Success, Failed, Dirty counts.
- **Settings Persistence:** JSON config at `%APPDATA%\SuperGit-Tools\settings.json`
- **Recent Folders:** Quick access sidebar with last 5 folders used.
- **Elapsed Time:** Displays sync duration in status bar.

### Logging

- **Real-Time Log:** Toggleable overlay with live command output.
- **File Log:** Mirrors real-time log to `yyyy-MM-dd-<ParentFolder>.log`.
- **Log Format:** `[HH:mm:ss][LEVEL] Message`
- **Log Export:** Quick access to log file location.

### Async Architecture

- **Unified Timer:** Single `DispatcherTimer` (50ms) polls all queues.
- **Four Synchronized Queues:**
  - `$Script:LogQueue` - Log messages
  - `$Script:StatusQueue` - Git status results
  - `$Script:SyncQueue` - Sync progress/results
  - `$Script:ScanQueue` - Discovered repositories
- **RunspacePool:** Configurable parallel operations (default 8, max `ProcessorCount * 2`).
- **Collection Safety:** Snapshot copies before enumeration.
- **Throttled Updates:** Max 20 queue items per timer tick.

## 5. Design System: Friendly Horizon v3.0 (Light Theme)

- **Concept:** User-centric, aesthetically pleasing light theme (clean, airy, professional).
- **Visuals:**
  - **Background:** Subtle gradient (`#FFFFFF` → `#F5F5F5`).
  - **Color Palette:**
    - Sidebar: `#F0F0F0`
    - Cards: `#FFFFFF` with Border `#E0E0E0`
    - Controls: `#E8E8E8`
    - Text: `#1A1A1A` (Primary), `#616161` (Secondary), `#9E9E9E` (Muted)
  - **Status Colors:**
    - Clean: `#4CAF50` (Green)
    - Dirty: `#FFC107` (Amber)
    - Ahead: `#2196F3` (Blue)
    - Behind: `#FF9800` (Orange)
    - Diverged: `#9C27B0` (Purple)
    - Error: `#FF5252` (Red)
    - Syncing: `#00BCD4` (Cyan)
    - Pending: `#757575` (Gray)
  - **Layout:** Card-based repository list with rounded corners, hover effects.
  - **Controls:** Custom styled buttons with hover (`#D0D0D0`) and press (`#0078D4`).
- **Typography:**
  - Repository name: 14px SemiBold
  - Branch info: 11px Italic
  - Path: 10px Regular
- **Constraints:** **NO EMOJIS** to prevent PowerShell encoding errors.

## 6. Settings Schema (v3.0)

```json
{
  "MaxParallel": 8,
  "LogRetentionDays": 30,
  "RecentFoldersCount": 5,
  "RecentFolders": ["D:\\path1", "D:\\path2"]
}
```

## 7. Status & Observations

- `git-sync.ps1` is fully functional (v1.0).
- `git-sync-gui.ps1` is **Complete Rewrite (v3.0)**:
  - **New Features:**
    - Settings persistence (JSON)
    - Recent folders quick access
    - Elapsed time display
    - Functional settings panel
  - **Architecture Improvements:**
    - Organized into 14 `#region` blocks
    - Unified timer system (single 50ms timer)
    - Centralized queue processing
    - Clean separation of concerns
  - **Technical:**
    - ~950 lines of well-organized code
    - Comprehensive async infrastructure
    - Full real-time logging coverage
    - Robust error handling

## 8. Version History

| Version | Changes                                                                                             |
| ------- | --------------------------------------------------------------------------------------------------- |
| v1.0    | Initial CLI tool (`git-sync.ps1`)                                                                   |
| v2.0    | GUI with WPF, async operations, status detection                                                    |
| v2.1    | RunspacePool for parallel status checking, streaming scan                                           |
| v3.0    | Complete rewrite with settings persistence, recent folders, unified timer, organized #region blocks |

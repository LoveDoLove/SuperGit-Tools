# PROMPT_GUIDE: SuperGit-Tools

## Project Context

- **App Name:** SuperGit-Tools
- **CLI Tool:** `git-sync.ps1` v1.0 (Automation focused, interactive CLI)
- **GUI Tool:** `git-sync-gui.ps1` v2.0 (Visual interface, "Friendly Horizon" design, WPF/XAML)

## Design Philosophy: "Friendly Horizon" v2.0

Any UI/UX development (especially for `git-sync-gui.ps1` or web dashboards) must adhere to these Modern UI principles:

1.  **Aesthetics:** High-end, premium feel following 2024/2025 dark mode best practices.
    - **Backgrounds:** Use soft grays (`#121212`, `#1C1C1C`, `#1E1E1E`) instead of pure black (`#000000`).
    - **Gradients:** Use subtle `LinearGradientBrush` for depth and visual interest.
    - **Color Palette:**
      - Sidebar: `#161616`
      - Cards: `#1E1E1E`
      - Controls: `#2A2A2E`
      - Text: Primary `#FFFFFF`, Secondary `#B0B0B0`, Muted `#707070`
    - **Status Colors:** Use distinct, accessible colors:
      - Clean: `#4CAF50` (green)
      - Dirty: `#FFC107` (amber)
      - Ahead: `#2196F3` (blue)
      - Behind: `#FF9800` (orange)
      - Diverged: `#9C27B0` (purple)
      - Error: `#FF5252` (red)
      - Syncing: `#00BCD4` (cyan)
      - Pending: `#757575` (gray)
    - **Controls:** Use **Card Layouts** for lists (Border with rounded corners, padding, hover effects).
    - **Indicators:** Use colored shapes (Ellipse) for status instead of text boxes.
2.  **Interaction:** Dynamic feedback (hover states on cards and buttons, smooth transitions). Code should not feel static.
3.  **Tone:** Friendly, helpful, and clear. Avoid cryptic error messages.
4.  **Content Policy:** **NO EMOJIS!** Do not use any emoji characters in the source code or UI strings (e.g., `🚀`, `📜`) as they cause encoding/parsing errors in PowerShell 5.1. Use standard text or iconography (using shapes/paths) instead.

## Prompting Rules for Future Development

### 1. Analysis First

- **Rule:** Always analyze the existing file structure and `ANALYSIS.md` before proposing changes.
- **Why:** To ensure new features integrate seamlessly with existing logging and error handling mechanisms.

### 2. Code Style & Consistency

- **PowerShell:**
  - Use `Join-Path` for cross-platform compatibility.
  - Implement `try/catch` blocks for all external command executions (like `git`).
  - Maintain the logging format: `[TIME] [COMMAND/RESULT] Message`.
- **GUI (WPF/Windows Forms in PS):**
  - **Framework:** Use **WPF (XAML)** over Windows Forms for better styling capabilities.
  - **Styling:** Adhere to "Friendly Horizon" Modern Standards:
    - **Window:** Chromeless (`WindowStyle="None"`, `AllowsTransparency="True"`).
    - **Theme:** Dark mode with Gradients.
    - **Layout:** Use `Grid` and `DockPanel` for structure. Use `DataTemplate` in `ListBox` for Card views.
    - **Feedback:** Use `ProgressBar` for long-running operations.
  - **Async:** Use **Runspaces** or `[System.Windows.Threading.Dispatcher]` to keep the UI responsive during Git operations.

### 3. Feature Requirements (Must-Have)

When updating or fixing the app, ensure these core features remain intact:

1.  **Auto-Discovery:** Ability to recursively find `.git` folders given a parent path.
2.  **Git Status Detection:** Automatically check and display repository status (branch, clean/dirty, ahead/behind).
3.  **Real-Time Logging:** All commands, progress, and status updates must be displayed in the GUI's "Show Log" window in real-time.
4.  **Persistent Logging:** Logs must be auto-written to a file with the format `yyyy-MM-dd-<ParentFolder>.log`. This file must mirror the Real-Time Log exactly.
5.  **Search and Filter:** Users must be able to search repositories by name, path, or branch, and filter by status.
6.  **Individual Actions:** Right-click context menu for per-repository actions (sync, refresh, open, copy).
7.  **Keyboard Shortcuts:** Power users should have keyboard shortcuts for common actions.
8.  **Async Operations:** All Git operations must run asynchronously to keep UI responsive.
9.  **Virtualization:** Large repository lists must use UI virtualization for performance.

### 4. UI/UX Best Practices (v2.0)

- **Avoid Pure Black:** Use `#121212` or similar soft grays for backgrounds to reduce eye strain.
- **Contrast Ratios:** Maintain WCAG-compliant contrast ratios for accessibility.
- **Hover Effects:** Provide visual feedback on interactive elements (cards, buttons).
- **Status Feedback:** Use distinct colors for different repository states.
- **Information Hierarchy:** Use font sizes and weights to establish clear hierarchy:
  - Repository name: 14px SemiBold
  - Branch info: 11px Italic
  - Path: 10px Regular
- **Error Handling:** Show detailed error messages with actionable suggestions.
- **Performance:** Throttle UI updates to maintain 30+ fps during operations.

## Quick Reference

- **Run CLI Sync:** `.\git-sync.ps1 -ParentFolder <path>`
- **Run GUI:** `.\git-sync-gui.ps1`
- **Log Location:** Same directory as parent folder, format `yyyy-MM-dd-<Folder>.log`
- **Keyboard Shortcuts (GUI):**
  - `Ctrl+F`: Focus search
  - `Ctrl+R` or `F5`: Refresh status
  - `Ctrl+S`: Sync all

## Future Considerations

- **Settings Persistence:** Implement JSON-based settings file for user preferences.
- **Recent Folders:** Add quick access to recently used parent folders.
- **Repository Details Panel:** Sliding panel with detailed repo information and recent commits.
- **Scheduled Sync:** Background auto-sync at configurable intervals.
- **Multi-threading Optimization:** Parallel status checking for large repository counts.
- **Advanced Git Features:**
  - Branch switching
  - Stash management
  - Conflict resolution helpers

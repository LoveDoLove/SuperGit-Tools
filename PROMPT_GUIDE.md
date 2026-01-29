# PROMPT_GUIDE: SuperGit-Tools

## Project Context

- **App Name:** SuperGit-Tools
- **CLI Tool:** `git-sync.ps1` (Automation focused, interactive CLI)
- **GUI Tool:** `git-sync-gui.ps1` (Visual interface, "Friendly Horizon" design, WPF/XAML)

## Design Philosophy: "Friendly Horizon"

Any UI/UX development (especially for `git-sync-gui.ps1` or web dashboards) must adhere to these Modern UI principles:

1.  **Aesthetics:** High-end, premium feel.
    - **Backgrounds:** Use `LinearGradientBrush` (Deep dark blue/gray: `#1E1E1E` to `#252526`) instead of flat solid colors.
    - **Controls:** Use **Card Layouts** for lists (Border with rounded corners, padding, slight border brush).
    - **Indicators:** Use colored shapes (Ellipse) for status instead of text boxes.
2.  **Interaction:** Dynamic feedback (hover states on cards and buttons). Code should not feel static.
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
2.  **Real-Time Logging:** All commands, progress, and status updates must be displayed in the GUI's "Show Log" window in real-time.
3.  **Persistent Logging:** Logs must be auto-written to a file with the format `yyyy-MM-dd-<ParentFolder>.log`. This file must mirror the Real-Time Log exactly.

## Quick Reference

- **Run Sync:** `.\git-sync.ps1 -ParentFolder <path>`
- **Run GUI:** `.\git-sync-gui.ps1`
- **Log Location:** Same directory as parent folder, format `yyyy-MM-dd-<Folder>.log`

## Future Considerations

- **`git-sync-gui.ps1` Enhancements:**
  - Visual indicators for repo status (clean, behind, ahead, dirty).
  - Enhancing the progress bar details.

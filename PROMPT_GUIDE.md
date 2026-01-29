# PROMPT_GUIDE: SuperGit-Tools

## Project Context

- **App Name:** SuperGit-Tools
- **CLI Tool:** `git-sync.ps1` (Automation focused, interactive CLI)
- **GUI Tool:** `git-sync-gui.ps1` (Visual interface, "Friendly Horizon" design, WPF/XAML)

## Design Philosophy: "Friendly Horizon"

Any UI/UX development (especially for `git-sync-gui.ps1` or web dashboards) must adhere to:

1.  **Aesthetics:** High-end, premium feel. Use glassmorphism, gradients, and dark mode by default.
2.  **Interaction:** Dynamic feedback (hover states, transitions). Code should not feel static.
3.  **Tone:** Friendly, helpful, and clear. Avoid cryptic error messages.

## Prompting Rules for Future Development

### 1. Analysis First

- **Rule:** Always analyze the existing file structure and `ANALYSIS.md` before proposing changes.
- **Why:** To ensure new features integrate seamlessly with existing logging and error handling mechanisms defined in `git-sync.ps1`.

### 2. Code Style & consistency

- **PowerShell:**
  - Use `Join-Path` for cross-platform compatibility.
  - Implement `try/catch` blocks for all external command executions (like `git`).
  - Maintain the logging format: `[TIME] [COMMAND/RESULT] Message`.
- **GUI (WPF/Windows Forms in PS):**
  - **Framework:** Use **WPF (XAML)** over Windows Forms for better styling capabilities.
  - **Styling:** Adhere to "Friendly Horizon":
    - **Window:** Chromeless (`WindowStyle="None"`, `AllowsTransparency="True"`).
    - **Theme:** Dark mode (`#1E1E1E` background, `#FFFFFF` text).
    - **Controls:** Custom styled buttons (no default gray). Hover effects are mandatory.
  - **Async:** Use **Runspaces** or `[System.Windows.Threading.Dispatcher]` to keep the UI responsive during Git operations.

### 3. Feature Requests

- **When requesting specific file changes:** Explicitly state the target file (`git-sync.ps1` vs `git-sync-gui.ps1`).
- **When reporting bugs:** Provide the log file content if available.

## Quick Reference

- **Run Sync:** `.\git-sync.ps1 -ParentFolder <path>`
- **Log Location:** Same directory as script, format `yyyy-MM-dd-<Folder>.log`

## Future Considerations

- **`git-sync-gui.ps1` Implementation:** When building this, prioritize:
  - Asynchronous execution (don't freeze UI during git fetch).
  - Real-time progress bars.
  - Visual indicators for repo status (clean, behind, ahead, dirty).

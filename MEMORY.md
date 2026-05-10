# MEMORY

## Project Goals
- Keep SuperGit-Tools practical and stable for multi-repository Git synchronization on Windows.
- Maintain both tools:
  - CLI: `git-sync.ps1` (no GUI)
  - GUI: `git-sync-gui.ps1` (Friendly Horizon Light Theme)

## Persistent Conventions
- Preserve Friendly Horizon light-theme visual language in GUI changes.
- Keep asynchronous behavior for Git operations in GUI to maintain responsiveness.
- Keep real-time and file-based logging behavior consistent.
- Avoid unnecessary architectural changes; prefer surgical modifications.

## Feature Baseline (GUI)
1. Auto-discovery of Git repositories
2. Real-time status detection (Clean/Dirty/Ahead/Behind/Diverged)
3. Friendly Horizon modern light UI
4. Async operations
5. Search and filter
6. Sort options
7. Settings persistence
8. Statistics panel
9. Context menu actions
10. Keyboard shortcuts
11. Sync-all workflow
12. Real-time log overlay
13. File-based dated logs

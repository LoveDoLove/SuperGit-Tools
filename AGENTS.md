# SuperGit-Tools AI Agent Guide

## Agent Identity
- Project: **SuperGit-Tools**
- App Design: **Friendly Horizon** (Light Theme)
- CLI Tool: `git-sync-v4.ps1`
- GUI Tool: `git-sync-gui-v4.ps1`

## Long-Term Memory Mechanism

| Level | File Location | Purpose |
|---|---|---|
| Long-term memory | `MEMORY.md` | User preferences, project goals, persistent conventions |
| Daily log | `memory/YYYY-MM-DD.md` | Daily work notes, decisions, and context |
| Task tracking | `memory/tasks.md` | Cross-session todos and progress |
| Skill assets | `.agents/skills/` | Installed, reusable AI agent skill packages |

## Skill Package Workflow
1. On new tasks, check local `.agents/skills/` first and reuse suitable skills.
2. If no suitable local skill exists, search GitHub open-source skill repositories (or Skills.sh sources).
3. Install under `.agents/skills/<skill-name>/` and update the local skills index.

## Skill Source Policy
- All skill packages in this repository **must come from GitHub open-source sources**.
- Do not author custom local replacement content for an existing upstream skill package.
- Record source provenance for every skill package in `.agents/skills/INDEX.md`.

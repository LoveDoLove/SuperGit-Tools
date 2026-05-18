# AI Long-Term Memory — SuperGit-Tools

## Project Overview

**SuperGit-Tools** is a comprehensive Git synchronization suite designed for Windows, combining PowerShell scripting with a Python backend for robust, automated Git repository management.

### Core Values
- **Precision**: Surgical code changes that fully address requirements
- **Compatibility**: Support Windows PowerShell 5.1+ and Git in PATH
- **Performance**: Async operations to keep UI responsive
- **Clarity**: Clear logging, status tracking, and user feedback

---

## Established Conventions & Patterns

### PowerShell Development

**Fact:** Under StrictMode v2 in GUI scripts, wrap filtered pipeline output with `@(...).Count` to avoid scalar objects lacking Count property.  
**Source:** `git-sync-gui-v4.ps1:420-421`, `git-sync-core-v4.ps1:1`  
**Applies To:** GUI scripts that use StrictMode v2  

**Fact:** `git-sync-core-v4.ps1` must parse backend JSON with `ConvertFrom-Json` fallback (no `-Depth` flag) for Windows PowerShell 5.1 compatibility.  
**Source:** `git-sync-core-v4.ps1:44-47, 50`  
**Applies To:** JSON parsing from Python backend  

**Fact:** v4 repository discovery uses `Get-ChildItem -Force` when scanning for nested `.git` directories.  
**Source:** `git-sync-core-v4.ps1:34`  
**Applies To:** All repo discovery operations  

**Fact:** SuperGit-Tools is designed for Windows with PowerShell 5.1+ and requires Git available in PATH.  
**Source:** `README.md:106-108`  
**Applies To:** All environment setup and feature development  

### Architecture & Integration

**Fact:** v4 CLI and GUI share common git logic via `git-sync-core-v4.ps1` for repo discovery, status evaluation, and sync primitives.  
**Source:** `git-sync-core-v4.ps1:13-80`, `git-sync-gui-v4.ps1:41-60`  
**Applies To:** New features should extend the core module rather than duplicating logic  

**Fact:** v4 core PowerShell functions execute a Python backend module `supergit_backend.cli` for git availability, discovery, status, and sync via JSON inter-process communication.  
**Source:** `git-sync-core-v4.ps1:80-120`, `src/supergit_backend/cli.py:1-150`  
**Applies To:** Git operations should leverage the Python backend, not direct git commands  

**Fact:** Project includes a uv-managed Python package backend (`supergit-tools-backend`) built with hatchling from `src/supergit_backend`; setup uses `uv sync`.  
**Source:** `pyproject.toml:1-11`, setup.bat, setup.sh  
**Applies To:** Python dependency management and backend development  

**Fact:** v4 GUI context menu operations use async RunspacePool instead of synchronous execution - this prevents UI freezing during git operations.  
**Source:** `git-sync-gui-v4.ps1:250-280` (SyncRepositoryAsync function)  
**Applies To:** All interactive user actions must use RunspacePool for non-blocking execution  

### Skill Package Standards

**Fact:** All skill packages in this repository must come from GitHub open-source sources and be tracked with provenance in `.agents/skills/INDEX.md`.  
**Source:** `AGENTS.md:23-26`, `.agents/skills/INDEX.md:1-3`, `.agents/skills/karpathy-guidelines/SOURCE.md:1`  
**Applies To:** Any new skills must be sourced from GitHub, never custom-written  

### Documentation Standards

**Fact:** Repository uses `AGENTS.md`, `MEMORY.md`, and `memory/*.md` files for AI long-term memory, daily logs, and task tracking.  
**Source:** `AGENTS.md:9, 11, 14-15`, `MEMORY.md:1`, `memory/tasks.md:1`  
**Applies To:** All AI agent work should document decisions and progress  

---

## Project Goals

### Short Term
- Maintain and improve v4 architecture stability
- Ensure PowerShell 5.1+ compatibility across all features
- Keep UI responsive with async operations

### Long Term
- Build comprehensive Git workflow automation
- Support advanced repository patterns (monorepos, submodules)
- Expand cross-platform support where feasible

---

## User Preferences & Guidelines

### Code Changes
- Prefer **surgical precision** over comprehensive rewrites
- Make **complete solutions** rather than minimal patches
- Validate changes don't break existing behavior or introduce vulnerabilities

### Tools & Automation
- Use ecosystem tools (npm, pip, uv) to automate changes
- Apply existing linters and tests before finalizing code
- Avoid creating helper scripts; use standard project tools

### Documentation
- Update docs when directly related to code changes
- Keep README examples current and practical
- Record important decisions in memory files

---

## Known Issues & Workarounds

*(None currently documented; add as they are discovered)*

---

## References

- **README.md**: Project overview, installation, usage examples
- **ANALYSIS.md**: Technical analysis and file structure breakdown
- **AGENTS.md**: AI agent identity and behavior guidelines
- **memory/tasks.md**: Current task queue and progress tracking
- **memory/YYYY-MM-DD.md**: Daily work logs and decision records

---

**Last Updated:** 2026-05-17  
**AI Agent Version:** 1.0

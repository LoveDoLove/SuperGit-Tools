from __future__ import annotations

import os
import subprocess
from pathlib import Path
from typing import Any, Dict, List

GIT_TIMEOUT_SECONDS = 180


def _run_git(repo_path: str, args: List[str]) -> subprocess.CompletedProcess:
    """Run a git command in the given repository and return the completed process."""
    return subprocess.run(
        ["git", *args],
        cwd=repo_path,
        capture_output=True,
        text=True,
        timeout=GIT_TIMEOUT_SECONDS,
    )


def test_git_available() -> bool:
    try:
        proc = subprocess.run(["git", "--version"], capture_output=True, text=True)
        return proc.returncode == 0
    except OSError:
        return False


def get_repo_paths(root_folder: str, max_depth: int = 5) -> List[str]:
    """Recursively discover repositories by locating `.git` directories up to max depth."""
    root = Path(root_folder)
    if not root.exists():
        raise RuntimeError(f"Root folder not found: {root_folder}")

    if max_depth < 1:
        max_depth = 1

    repo_paths = set()
    if (root / ".git").exists():
        repo_paths.add(str(root.resolve()))

    for current_root, dirs, _ in os.walk(root_folder, topdown=True):
        rel = os.path.relpath(current_root, root_folder)
        depth = 0 if rel == "." else rel.count(os.sep) + 1
        if depth > max_depth:
            dirs[:] = []
            continue

        if ".git" in dirs:
            repo_paths.add(str(Path(current_root).resolve()))

    return sorted(repo_paths)


def _repo_detail(state: str, ahead: int, behind: int, has_upstream: bool) -> str:
    if not has_upstream:
        if state == "DirtyNoUpstream":
            return "Dirty working tree, no upstream"
        return "No upstream configured"

    table = {
        "Clean": "Up to date",
        "Dirty": "Uncommitted changes",
        "Ahead": f"Ahead {ahead} commits",
        "Behind": f"Behind {behind} commits",
        "Diverged": f"Ahead {ahead} / behind {behind}",
        "DirtyAhead": f"Dirty, ahead {ahead} commits",
        "DirtyBehind": f"Dirty, behind {behind} commits",
        "DirtyDiverged": f"Dirty, ahead {ahead} / behind {behind}",
    }
    return table.get(state, state)


def get_repo_status(repo_path: str) -> Dict[str, Any]:
    """Return repository branch, dirty/upstream state, ahead/behind counts, and summary detail."""
    branch_proc = _run_git(repo_path, ["rev-parse", "--abbrev-ref", "HEAD"])
    if branch_proc.returncode != 0:
        raise RuntimeError(branch_proc.stderr.strip() or branch_proc.stdout.strip() or "Unable to resolve branch")
    branch = branch_proc.stdout.strip()

    dirty_proc = _run_git(repo_path, ["status", "--porcelain"])
    if dirty_proc.returncode != 0:
        raise RuntimeError(dirty_proc.stderr.strip() or "Unable to get repo status")
    dirty = bool(dirty_proc.stdout.strip())

    upstream_proc = _run_git(repo_path, ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"])
    has_upstream = upstream_proc.returncode == 0 and bool(upstream_proc.stdout.strip())
    ahead = 0
    behind = 0

    if has_upstream:
        counts_proc = _run_git(repo_path, ["rev-list", "--left-right", "--count", "HEAD...@{u}"])
        if counts_proc.returncode != 0:
            raise RuntimeError(counts_proc.stderr.strip() or "Unable to get ahead/behind count")
        parts = counts_proc.stdout.strip().split()
        if len(parts) >= 2:
            ahead = int(parts[0])
            behind = int(parts[1])

    state = "Clean"
    if not has_upstream:
        state = "DirtyNoUpstream" if dirty else "NoUpstream"
    elif ahead > 0 and behind > 0:
        state = "DirtyDiverged" if dirty else "Diverged"
    elif ahead > 0:
        state = "DirtyAhead" if dirty else "Ahead"
    elif behind > 0:
        state = "DirtyBehind" if dirty else "Behind"
    elif dirty:
        state = "Dirty"

    return {
        "RepoPath": repo_path,
        "RepoName": Path(repo_path).name,
        "Branch": branch,
        "Dirty": dirty,
        "HasUpstream": has_upstream,
        "Ahead": ahead,
        "Behind": behind,
        "State": state,
        "Detail": _repo_detail(state, ahead, behind, has_upstream),
    }


def invoke_repo_sync(repo_path: str, include_dirty: bool, dry_run: bool, fetch_only: bool) -> Dict[str, Any]:
    """Run fetch/pull sync logic for one repository and return before/after status plus command output."""
    before = get_repo_status(repo_path)

    if before["Dirty"] and not include_dirty:
        return {
            "RepoPath": repo_path,
            "RepoName": before["RepoName"],
            "Status": "SkippedDirty",
            "Detail": "Skipped dirty working tree",
            "Success": True,
            "Changed": False,
            "Before": before,
            "After": before,
            "FetchOutput": [],
            "PullOutput": [],
        }

    if dry_run:
        return {
            "RepoPath": repo_path,
            "RepoName": before["RepoName"],
            "Status": "DryRun",
            "Detail": "Dry run only",
            "Success": True,
            "Changed": False,
            "Before": before,
            "After": before,
            "FetchOutput": [],
            "PullOutput": [],
        }

    fetch_proc = _run_git(repo_path, ["fetch", "--all", "--prune", "--progress"])
    fetch_output_text = (fetch_proc.stdout or "") + (fetch_proc.stderr or "")
    fetch_output = [line for line in fetch_output_text.splitlines() if line]
    if fetch_proc.returncode != 0:
        detail = fetch_output[0] if fetch_output else "no output"
        raise RuntimeError(f"git fetch failed with exit code {fetch_proc.returncode}: {detail}")

    pull_output: List[str] = []
    if not fetch_only:
        pull_proc = _run_git(repo_path, ["pull", "--ff-only", "--progress"])
        pull_output_text = (pull_proc.stdout or "") + (pull_proc.stderr or "")
        pull_output = [line for line in pull_output_text.splitlines() if line]
        if pull_proc.returncode != 0:
            detail = pull_output[0] if pull_output else "no output"
            raise RuntimeError(f"git pull failed with exit code {pull_proc.returncode}: {detail}")

    after = get_repo_status(repo_path)
    result_state = "Fetched" if fetch_only else "Synced"
    result_detail = "Fetch completed" if fetch_only else "Sync completed"
    changed = (
        before["State"] != after["State"]
        or before["Ahead"] != after["Ahead"]
        or before["Behind"] != after["Behind"]
        or before["Dirty"] != after["Dirty"]
    )

    return {
        "RepoPath": repo_path,
        "RepoName": before["RepoName"],
        "Status": result_state,
        "Detail": result_detail,
        "Success": True,
        "Changed": changed,
        "Before": before,
        "After": after,
        "FetchOutput": fetch_output,
        "PullOutput": pull_output,
    }

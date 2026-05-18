"""SuperGit-Tools Backend - Git Operations Module"""
import subprocess
import os
import json
from pathlib import Path
from typing import Optional, List, Dict
from datetime import datetime
from .models import RepositoryInfo, SyncResult, RepoStatus


class GitOperations:
    """Async-compatible git operations wrapper"""

    @staticmethod
    def check_git_availability() -> bool:
        """Check if git is available in PATH"""
        try:
            subprocess.run(["git", "--version"], capture_output=True, check=True, timeout=5)
            return True
        except Exception:
            return False

    @staticmethod
    def discover_repositories(root_path: str) -> List[str]:
        """Discover git repositories in directory"""
        repos = []
        root = Path(root_path)
        
        if not root.exists() or not root.is_dir():
            return repos
        
        try:
            for item in root.iterdir():
                if item.is_dir() and (item / ".git").exists():
                    repos.append(str(item))
        except Exception:
            pass
        
        return repos

    @staticmethod
    def get_repository_status(repo_path: str) -> RepositoryInfo:
        """Get status of a repository"""
        repo_info = RepositoryInfo(
            path=repo_path,
            name=Path(repo_path).name
        )
        
        try:
            # Check if path exists
            if not Path(repo_path).exists():
                repo_info.status = RepoStatus.ERROR
                repo_info.error = "Path not found"
                repo_info.detailed_status = "Repository path does not exist"
                return repo_info

            # Get current branch
            try:
                branch = subprocess.run(
                    ["git", "rev-parse", "--abbrev-ref", "HEAD"],
                    cwd=repo_path,
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if branch.returncode == 0:
                    repo_info.branch = branch.stdout.strip()
            except Exception:
                pass

            # Check for uncommitted changes
            try:
                status = subprocess.run(
                    ["git", "status", "--porcelain"],
                    cwd=repo_path,
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if status.returncode == 0 and status.stdout.strip():
                    repo_info.is_dirty = True
                    repo_info.status = RepoStatus.DIRTY
                    repo_info.detailed_status = "Uncommitted changes"
                    return repo_info
            except Exception:
                pass

            # Check upstream tracking
            try:
                upstream = subprocess.run(
                    ["git", "rev-parse", "--abbrev-ref", "@{u}"],
                    cwd=repo_path,
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if upstream.returncode == 0:
                    # Get ahead/behind counts
                    try:
                        ahead = subprocess.run(
                            ["git", "rev-list", "--count", "@{u}..HEAD"],
                            cwd=repo_path,
                            capture_output=True,
                            text=True,
                            timeout=10
                        )
                        if ahead.returncode == 0:
                            repo_info.ahead = int(ahead.stdout.strip() or 0)
                    except Exception:
                        pass

                    try:
                        behind = subprocess.run(
                            ["git", "rev-list", "--count", "HEAD..@{u}"],
                            cwd=repo_path,
                            capture_output=True,
                            text=True,
                            timeout=10
                        )
                        if behind.returncode == 0:
                            repo_info.behind = int(behind.stdout.strip() or 0)
                    except Exception:
                        pass

                    # Determine status based on ahead/behind
                    if repo_info.ahead > 0 and repo_info.behind > 0:
                        repo_info.status = RepoStatus.DIVERGED
                        repo_info.detailed_status = f"Ahead {repo_info.ahead}, Behind {repo_info.behind}"
                    elif repo_info.ahead > 0:
                        repo_info.status = RepoStatus.AHEAD
                        repo_info.detailed_status = f"Ahead {repo_info.ahead} commit(s)"
                    elif repo_info.behind > 0:
                        repo_info.status = RepoStatus.BEHIND
                        repo_info.detailed_status = f"Behind {repo_info.behind} commit(s)"
                    else:
                        repo_info.status = RepoStatus.CLEAN
                        repo_info.detailed_status = "Up to date"
                else:
                    # No upstream tracking
                    repo_info.status = RepoStatus.CLEAN
                    repo_info.detailed_status = "No upstream tracking"
            except Exception:
                repo_info.status = RepoStatus.CLEAN
                repo_info.detailed_status = "Up to date"

        except Exception as e:
            repo_info.status = RepoStatus.ERROR
            repo_info.error = str(e)
            repo_info.detailed_status = f"Status check failed: {str(e)}"

        return repo_info

    @staticmethod
    def sync_repository(repo_path: str, operation: str = "both") -> SyncResult:
        """Sync a repository (fetch and/or pull)"""
        result = SyncResult(
            path=repo_path,
            success=False,
            status="Starting",
            timestamp=datetime.now().isoformat()
        )

        try:
            if not Path(repo_path).exists():
                result.error = "Repository path does not exist"
                result.status = "Failed"
                return result

            output_lines = []

            # Fetch
            if operation in ("fetch", "both"):
                try:
                    fetch_result = subprocess.run(
                        ["git", "fetch", "--all"],
                        cwd=repo_path,
                        capture_output=True,
                        text=True,
                        timeout=60,
                        env={**os.environ, "GIT_REDIRECT_STDERR_TO_STDOUT": "1"}
                    )
                    output_lines.append(f"[FETCH] Exit code: {fetch_result.returncode}")
                    if fetch_result.stdout:
                        output_lines.append(fetch_result.stdout)
                    if fetch_result.stderr:
                        output_lines.append(fetch_result.stderr)
                except subprocess.TimeoutExpired:
                    result.error = "Fetch timed out"
                    result.status = "Failed"
                    return result
                except Exception as e:
                    result.error = f"Fetch error: {str(e)}"
                    result.status = "Failed"
                    return result

            # Pull
            if operation in ("pull", "both"):
                try:
                    pull_result = subprocess.run(
                        ["git", "pull"],
                        cwd=repo_path,
                        capture_output=True,
                        text=True,
                        timeout=60,
                        env={**os.environ, "GIT_REDIRECT_STDERR_TO_STDOUT": "1"}
                    )
                    output_lines.append(f"[PULL] Exit code: {pull_result.returncode}")
                    if pull_result.stdout:
                        output_lines.append(pull_result.stdout)
                    if pull_result.stderr:
                        output_lines.append(pull_result.stderr)

                    if pull_result.returncode == 0:
                        result.success = True
                        result.status = "Synced"
                    else:
                        result.status = f"Exit code {pull_result.returncode}"
                except subprocess.TimeoutExpired:
                    result.error = "Pull timed out"
                    result.status = "Failed"
                    return result
                except Exception as e:
                    result.error = f"Pull error: {str(e)}"
                    result.status = "Failed"
                    return result

            result.output = "\n".join(output_lines)

        except Exception as e:
            result.error = str(e)
            result.status = "Failed"

        return result

    @staticmethod
    def batch_get_status(repo_paths: List[str]) -> List[Dict]:
        """Get status for multiple repositories"""
        results = []
        for path in repo_paths:
            info = GitOperations.get_repository_status(path)
            results.append({
                'path': info.path,
                'name': info.name,
                'branch': info.branch,
                'status': info.status,
                'is_dirty': info.is_dirty,
                'ahead': info.ahead,
                'behind': info.behind,
                'detailed_status': info.detailed_status,
                'error': info.error
            })
        return results

    @staticmethod
    def batch_sync(repo_paths: List[str], operation: str = "both") -> List[Dict]:
        """Sync multiple repositories"""
        results = []
        for path in repo_paths:
            result = GitOperations.sync_repository(path, operation)
            results.append({
                'path': result.path,
                'success': result.success,
                'status': result.status,
                'error': result.error,
                'output': result.output,
                'timestamp': result.timestamp
            })
        return results

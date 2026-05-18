"""SuperGit-Tools Backend - CLI Interface"""
import json
import sys
from typing import Any, Dict
from .git_ops import GitOperations


def format_output(data: Any) -> str:
    """Format output as JSON"""
    return json.dumps(data, indent=None)


def handle_check_git(args: Dict) -> Dict:
    """Check git availability"""
    available = GitOperations.check_git_availability()
    return {"available": available, "message": "Git is available" if available else "Git not found"}


def handle_discover(args: Dict) -> Dict:
    """Discover repositories"""
    path = args.get("path", ".")
    repos = GitOperations.discover_repositories(path)
    return {"repos": repos, "count": len(repos)}


def handle_status(args: Dict) -> Dict:
    """Get status of repositories"""
    paths = args.get("paths", [])
    if not paths:
        return {"error": "No paths provided"}
    
    results = GitOperations.batch_get_status(paths)
    return {"results": results, "count": len(results)}


def handle_sync(args: Dict) -> Dict:
    """Sync repositories"""
    paths = args.get("paths", [])
    operation = args.get("operation", "both")
    
    if not paths:
        return {"error": "No paths provided"}
    
    results = GitOperations.batch_sync(paths, operation)
    return {"results": results, "count": len(results)}


def handle_single_status(args: Dict) -> Dict:
    """Get status of a single repository"""
    path = args.get("path")
    if not path:
        return {"error": "No path provided"}
    
    info = GitOperations.get_repository_status(path)
    return {
        'path': info.path,
        'name': info.name,
        'branch': info.branch,
        'status': info.status,
        'is_dirty': info.is_dirty,
        'ahead': info.ahead,
        'behind': info.behind,
        'detailed_status': info.detailed_status,
        'error': info.error
    }


def handle_single_sync(args: Dict) -> Dict:
    """Sync a single repository"""
    path = args.get("path")
    operation = args.get("operation", "both")
    
    if not path:
        return {"error": "No path provided"}
    
    result = GitOperations.sync_repository(path, operation)
    return {
        'path': result.path,
        'success': result.success,
        'status': result.status,
        'error': result.error,
        'output': result.output,
        'timestamp': result.timestamp
    }


# Command dispatch table
COMMANDS = {
    "check-git": handle_check_git,
    "discover": handle_discover,
    "status": handle_status,
    "status-single": handle_single_status,
    "sync": handle_sync,
    "sync-single": handle_single_sync,
}


def main():
    """Main entry point for CLI"""
    try:
        # Read JSON input from stdin
        input_data = sys.stdin.read()
        if not input_data:
            print(format_output({"error": "No input provided"}))
            sys.exit(1)
        
        request = json.loads(input_data)
        command = request.get("command")
        args = request.get("args", {})
        
        if not command:
            print(format_output({"error": "No command specified"}))
            sys.exit(1)
        
        handler = COMMANDS.get(command)
        if not handler:
            print(format_output({"error": f"Unknown command: {command}"}))
            sys.exit(1)
        
        result = handler(args)
        print(format_output(result))
        
    except json.JSONDecodeError as e:
        print(format_output({"error": f"Invalid JSON: {str(e)}"}))
        sys.exit(1)
    except Exception as e:
        print(format_output({"error": f"Unexpected error: {str(e)}"}))
        sys.exit(1)


if __name__ == "__main__":
    main()

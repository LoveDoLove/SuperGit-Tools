from __future__ import annotations

import argparse
import json
import sys

from supergit_backend.core import get_repo_paths, get_repo_status, invoke_repo_sync, test_git_available


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="supergit-backend")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("git-available")

    repo_paths = sub.add_parser("repo-paths")
    repo_paths.add_argument("--root-folder", required=True)
    repo_paths.add_argument("--max-depth", type=int, default=5)

    status = sub.add_parser("repo-status")
    status.add_argument("--repo-path", required=True)

    sync = sub.add_parser("repo-sync")
    sync.add_argument("--repo-path", required=True)
    sync.add_argument("--include-dirty", action="store_true")
    sync.add_argument("--dry-run", action="store_true")
    sync.add_argument("--fetch-only", action="store_true")

    return parser


def main() -> int:
    args = _parser().parse_args()
    try:
        if args.command == "git-available":
            payload = {"Available": test_git_available()}
        elif args.command == "repo-paths":
            payload = {"Paths": get_repo_paths(args.root_folder, args.max_depth)}
        elif args.command == "repo-status":
            payload = get_repo_status(args.repo_path)
        else:
            payload = invoke_repo_sync(
                repo_path=args.repo_path,
                include_dirty=args.include_dirty,
                dry_run=args.dry_run,
                fetch_only=args.fetch_only,
            )
    except Exception as exc:  # noqa: BLE001
        print(str(exc), file=sys.stderr)
        return 1

    print(json.dumps(payload, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

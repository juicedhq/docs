#!/usr/bin/env python3
"""WorktreeCreate hook adapter.

Reads the Claude Code hook JSON payload from stdin, derives the worktree name and
the parent directory the worktree should land in, then execs the bash CLI script
`../cli/worktree-create`. Copied from the app repo's create-worktree skill.

Behaviour:
  - name  = payload.worktree_name, else payload.name, else "" (the CLI's usage
            guard then fires).
  - parent dir = dirname(payload.worktree_path) when a path is proposed,
                 else "$CLAUDE_PROJECT_DIR/.claude/worktrees".
exec (not capture) preserves the CLI's stdout contract: provisioning goes to
stderr and the LAST STDOUT LINE is the absolute worktree path the harness reads.
"""

import json
import os
import sys


def build_argv(payload, project_dir, cli_dir):
    name = payload.get("worktree_name") or payload.get("name") or ""
    proposed = payload.get("worktree_path") or ""
    parent = os.path.dirname(proposed) if proposed else os.path.join(project_dir, ".claude", "worktrees")
    return [os.path.join(cli_dir, "worktree-create"), name, "--dir", parent]


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        payload = {}

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
    cli_dir = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "cli"))
    argv = build_argv(payload, project_dir, cli_dir)

    try:
        os.execv(argv[0], argv)
    except OSError as exc:
        print(f"worktree-create-hook: cannot exec {argv[0]}: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

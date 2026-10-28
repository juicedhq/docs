#!/usr/bin/env python3
"""WorktreeRemove hook adapter.

Reads the Claude Code hook JSON payload from stdin, derives the worktree name,
then execs `../cli/worktree-remove <name> --eject`. Replaces the former
inline-bash+jq hook command string.

Behaviour:
  - name = payload.worktree_name, else payload.name, else basename of
           payload.worktree_path, else basename of payload.path.
  - always passes --eject so the native exit never blocks (auto-WIP a dirty tree,
    always tear down, keep the branch unless it has landed or is fully pushed).
"""

import json
import os
import sys


def build_argv(payload, cli_dir):
    name = payload.get("worktree_name") or payload.get("name") or ""
    if not name:
        path = payload.get("worktree_path") or payload.get("path") or ""
        name = os.path.basename(path)
    return [os.path.join(cli_dir, "worktree-remove"), name, "--eject"]


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        payload = {}

    cli_dir = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "cli"))
    argv = build_argv(payload, cli_dir)

    try:
        os.execv(argv[0], argv)
    except OSError as exc:
        print(f"worktree-remove-hook: cannot exec {argv[0]}: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
SessionStart guard for git-worktree sessions.

When a session that was working inside a git worktree is resumed (or compacted),
Claude Code re-roots it back to the MAIN checkout instead of the worktree — the
worktree<->session binding is not restored. A hook can't re-root the session
itself (only the EnterWorktree tool can), but it CAN detect the mismatch and
inject a must-do-first instruction so re-entry isn't left to fragile recall.

Wired as a `SessionStart` hook in the project's `.claude/settings.json`, which
runs it from `.claude/skills/create-worktree/scripts/hooks/`.

Behaviour (fails open — never blocks or errors session start):
  - Acts only when the session is currently in the MAIN checkout
    (git-dir == git-common-dir); if already in a worktree, stays silent.
  - Scans the resumed transcript for the most recent `Entered worktree at
    <PATH>` (the EnterWorktree tool result) NOT followed by a later
    `ExitWorktree` tool call — the transcript is the state, so it picks the
    worktree THIS session was actually in, even with several worktrees present.
  - Verifies that worktree still exists, then prints a directive to stdout
    (SessionStart stdout is injected into the session context).
"""

import json
import os
import re
import subprocess
import sys


def _git(cwd, *args):
    return subprocess.run(
        ["git", "-C", cwd, *args],
        capture_output=True, text=True, timeout=10,
    ).stdout.strip()


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        return

    cwd = payload.get("cwd") or os.getcwd()
    transcript = payload.get("transcript_path")
    if not transcript or not os.path.isfile(transcript):
        return

    # Already inside a worktree? (git-dir differs from the common .git dir.) -> no-op.
    git_dir = _git(cwd, "rev-parse", "--absolute-git-dir")
    common_dir = _git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if not git_dir or not common_dir or git_dir != common_dir:
        return  # in a worktree, or git failed -> say nothing

    try:
        text = open(transcript, "r", encoding="utf-8", errors="ignore").read()
    except Exception:
        return

    enters = list(re.finditer(r"Entered worktree at (\S+) on branch (\S+)", text))
    if not enters:
        return
    last_enter = enters[-1]

    exits = [m.start() for m in re.finditer(r'"name"\s*:\s*"ExitWorktree"', text)]
    if exits and max(exits) > last_enter.start():
        return  # the worktree was intentionally exited after the last enter

    path, branch = last_enter.group(1), last_enter.group(2).rstrip(".")

    if not os.path.isdir(path):
        return
    if path not in _git(cwd, "worktree", "list", "--porcelain"):
        return

    print(
        "⚠ WORKTREE RESUME GUARD\n"
        f"This session was working in the git worktree:\n"
        f"  path:   {path}\n"
        f"  branch: {branch}\n"
        f"but it resumed in the MAIN checkout ({cwd}). The worktree's branch and "
        f"commits are intact — the session just isn't pointed at it.\n\n"
        f"BEFORE any git commit, any file edit for that work, or any cwd-dependent "
        f"command (mint dev, git, /self-review), call the "
        f"EnterWorktree tool with path=\"{path}\" to re-root the session. "
        f"Verify with `git branch --show-current` afterwards."
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # fail open: a guard must never break session start
    sys.exit(0)

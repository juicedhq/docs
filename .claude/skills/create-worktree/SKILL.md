---
name: create-worktree
description: Use when starting a new ticket, docs change, spike, or review that should not touch the main checkout, before creating branches or editing pages. Sets up a git worktree on its own docs/ branch, copies the local Claude config, and gives it its own mint dev port behind a Herd proxy (https://juiced-docs-<name>.test) so several branches can be previewed side by side.
compatibility: Designed for Claude Code on macOS with Laravel Herd. Requires git, rsync, python3 for the hooks, and the Mintlify CLI (mint) for previews. herd and gh are optional (no proxy without herd; squash-merge detection on teardown needs gh). Network access is needed for git fetch.
---

# Create Worktree

## Overview

A docs worktree is a separate checkout of this repo on its own branch, so a ticket's work never moves the main checkout off whatever it's on. Each one gets:

- a branch, `docs/<name>` (`jui-1369-v1-lead-api` → `docs/jui-1369-v1-lead-api`), matching the repo's branch history; the ticket key in it makes Linear link the PR;
- the main checkout's untracked `.claude/` config (local settings and permissions);
- a deterministic `mint dev` port and a Herd proxy, `https://juiced-docs-<name>.test`, so its preview runs next to the main one at `https://juiced-docs.test`.

`.claude/skills/create-worktree/scripts/cli/worktree-create` does all of it. This skill's job is deriving the name, running it the right way for your harness, and reporting what's ready. It's adapted from the app repo's `create-worktree` skill, minus everything the docs don't have (databases, Redis, `.env`, Composer and npm installs).

Worktrees live in `.claude/worktrees/<name>` inside the main checkout. That keeps them clear of the app repo's `jui-NNNN` worktrees in the shared parent directory, `.gitignore` keeps them out of git, and `.mintignore` already excludes `.claude/`, so the main checkout's `mint dev` and `mint broken-links` never scan them.

**Scope: environment setup, plus exactly two writes to the Linear ticket.** Move it to In Progress and claim it when it's unassigned (step 2). Nothing else on the ticket, and never from the shell scripts: humans and non-Claude agents use them without Linear access.

## When NOT to use

- Continuing work inside an existing worktree
- Reading or reviewing pages without changing them
- The user explicitly wants to work in the main checkout

## Flow

### 1. Pre-flight

Run `git status` in the current checkout. Surface uncommitted changes or untracked files the user might care about, and confirm before proceeding. (A worktree starts from `origin/main`, so uncommitted edits in the main checkout don't come along.)

Check you're not already inside a worktree: compare `git rev-parse --git-dir` with `git rev-parse --git-common-dir`. If they differ, you're in one already. Stop; don't nest.

### 2. Gather

Ask one question: "Is there a Linear ticket for this work (e.g. JUI-1369)? If not, give me a short slug (e.g. nav-cleanup)."

- Ticket → the name is the ticket ID lowercased plus a short slug of its title: `JUI-1369` "Publish the v1 lead API reference…" → `jui-1369-v1-lead-api`. The bare `jui-1369` also works.
- No ticket → `jui-<slug>`: `jui-nav-cleanup`.

**With a `JUI-` ticket, claim it before creating anything.** Fetch the issue with the Linear MCP tools (`mcp__linear-juiced__*` here; the server name can differ per install), then apply both rules. They're independent, so one being a no-op doesn't skip the other.

- **Status → In Progress, but only from Backlog or Todo.** Every other status is at or past In Progress, so writing it would walk the ticket backwards over someone else's update. Leave it and report the status it's in.
- **Assignee → yourself, but only when unassigned.** Never replace an existing assignee. Report who owns it and carry on.

This is best-effort. If Linear errors or is unreachable, warn and continue: the worktree is the deliverable, and the ticket update is bookkeeping. Slug worktrees have no ticket, so skip all of this silently.

### 3. Confirm

Show the worktree name, branch (`docs/<name>`), path and preview URL, and confirm before creating anything. Pass a second argument to the script to use a different branch name; the native tool can't, since its hook only receives a name.

### 4. Create

**Claude Code:** the hooks ship in this repo's `.claude/settings.json` (`WorktreeCreate`, `WorktreeRemove`, and a `SessionStart` re-entry guard), so the native worktree tool provisions through the script. Hooks load at session start, so if `.claude/settings.json` doesn't have them in this session (for example on a branch from before they were added), don't use the native tool: it would create a bare worktree on a branch named after the worktree, with no proxy. Run the script from the main checkout root instead, then switch into it with `EnterWorktree` (`path`):

```bash
.claude/skills/create-worktree/scripts/cli/worktree-create <name>
```

With the hooks active, use the native tool (`EnterWorktree`) with the worktree name. It routes through the `WorktreeCreate` hook, re-roots your session into the worktree, and attaches native lifecycle (exit prompts, cleanup).

How the hooks behave:

- `WorktreeCreate`/`WorktreeRemove` run the Python adapters in `scripts/hooks/`, which parse the payload (`worktree_name`/`name`/`worktree_path`) and dispatch to the matching `scripts/cli/` script. The file-existence guard in each command fails open when the skill isn't on the current branch. When the payload proposes a path, its parent directory is honored; otherwise worktrees land in `.claude/worktrees/`.
- `WorktreeRemove` passes `--eject` so the native exit never blocks: it auto-saves a dirty tree as a WIP commit, always tears the worktree and proxy down, and deletes the branch unless it still holds commits that exist nowhere else.
- `SessionStart` runs `worktree-reentry-guard.py`. On resume or compaction Claude Code re-roots a worktree session back to the main checkout; the guard reads the transcript for the worktree this session was in and injects a directive to re-enter via `EnterWorktree` before any commit or cwd-dependent command. It fails open.

**Other agents / humans:** run the script from the repo root, then `cd` into the path it prints. `--dir <parent>` overrides the location, `--base <ref>` the starting point for a new branch (default `origin/main`), and `--no-proxy` skips Herd.

If the branch already exists locally it's checked out as is; if it exists only on `origin`, it's tracked from there. A branch that's checked out somewhere else (including the main checkout) can't be added to a second worktree, so the script refuses; switch the main checkout to `main` first.

### 5. Report

Tell the user what's ready:

- **Path** (absolute) and **branch**
- **Preview**: `cd <path> && mint dev --port <port> --no-open`, served at `https://juiced-docs-<name>.test` (the script prints both). The `preview-docs` skill works in a worktree with this port and URL in place of 3333 and `https://juiced-docs.test`.
- **Ticket** (only when there was one): what step 2 changed, each rule either done or explicitly left alone. "JUI-1369 → In Progress, assigned to you"; "JUI-1369 was already In Review, left alone; already assigned to Sam." Say so if a Linear call failed.
- **Teardown**: when the work is merged or abandoned (below).

**Critical:** every subsequent command, file edit and spawned agent must use the **worktree path** as its working directory, not the main checkout. This carries for the rest of the session.

## Teardown

Cleanup is automatic only for worktrees created through Claude Code's hook; script-created ones rely on this command. `.claude/skills/create-worktree/scripts/cli/worktree-list` shows every worktree with its branch, port, proxy and whether its `mint dev` is running.

**An agent (or any non-interactive caller) MUST pass a flag**: `worktree-remove <name> --eject` (or `--yes`). The bare command opens a `[y/N]` prompt every time; a caller with no terminal can't answer it, so it prints `Aborted.` and exits 1, even on a clean, merged worktree. `--yes` just answers the prompt (the safety guards stay); `--eject` answers it *and* never blocks, auto-saving a dirty tree as a WIP commit.

Two independent things can stop the command: the **confirmation prompt** (cleared only by `--yes`/`--eject`) and the **safety guards** that refuse on uncommitted or unpushed work (bypassed by `--force`, or absorbed by `--eject`'s WIP save). Teardown removes the Herd proxy, stops a `mint dev` running in the worktree, removes the worktree, and deletes the branch unless it holds commits that exist nowhere else: not on a remote, and not carried into `main` by a merged PR (`--force` deletes regardless). A branch with an open PR is therefore deleted locally; `git fetch` brings it straight back.

Recognising a squash merge needs `gh`, since the rewrite leaves the branch's commits unreachable from `main` and GitHub deletes the remote branch on merge. Without `gh`, teardown falls back to plain reachability and keeps landed branches, which fails toward keeping work.

**Resources whose worktree vanished some other way** (a hand-run `git worktree remove`, an `rm -rf`, a create that failed part-way, an `ExitWorktree` whose teardown didn't fire) aren't reachable by name. `worktree-prune` sweeps them: orphaned Herd proxies, leftover directories and prunable registrations. `--dry-run` reports without touching anything; `--yes` skips the confirmation. It only auto-discovers ticket-shaped names (`jui-1369`, `jui-1369-v1-lead-api`), because a proxy's name is its only evidence of ownership; remove slug worktrees by name. Run it from the main checkout, not from inside a worktree.

## Subagent guidance (Claude Code)

Request `isolation: worktree` for subagents only when they edit pages in parallel with other work. Each isolated subagent gets a full worktree (and a proxy). Read-only agents, like the `self-review` reviewers, need no isolation.

## Common Mistakes

- **Operating on the main checkout after creating the worktree.** Subsequent tool calls, especially spawned agents, must use the worktree path as cwd.
- **Starting `mint dev` on the default port in a worktree.** Port 3000 or 3333 collides with the main checkout's preview. Use the worktree's port from the script output or `worktree-list`.
- **Expecting `mint dev` to pick up `openapi.json` edits.** It hot-reloads MDX but not the spec; restart it after editing `api-reference/openapi.json`.
- **Using the native worktree tool without the hooks loaded.** That creates a bare worktree on a branch without the `docs/` prefix and no proxy. Fall back to the script for the rest of the session.
- **Forgetting teardown for script-created worktrees.** Nothing sweeps them automatically. `worktree-remove <name> --eject` cleans up the worktree, branch and proxy.
- **Reading `ExitWorktree`'s `discard_changes: true` as data loss.** With the `--eject` hook wired, the flag doesn't discard: the hook auto-saves the dirty tree as a `WIP: auto-saved on eject` commit on the kept branch first.
- **Trusting `ExitWorktree` to tear everything down.** Its hook can silently not run (for example after compaction) while still reporting `removed`. For reliable teardown, run `worktree-remove <name> --eject` from the main checkout root, then check `git worktree list`. If only a proxy or directory remains, use `worktree-prune --dry-run`.

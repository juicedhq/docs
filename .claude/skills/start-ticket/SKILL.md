---
name: start-ticket
description: Use ONLY when the user runs /start-ticket <ticket-ref> or explicitly asks to take a Linear ticket (JUI-NNNN key or linear.app URL) end to end in the docs. Chains investigate-ticket → branch → grill-me (only when scope is genuinely undecided) → writing → self-review → preview-docs. Not for read-only investigation (use investigate-ticket).
---

# Start Ticket

One command that takes a Linear ticket from "unread" to "written, self-reviewed, and checked in the local preview on its own branch". It orchestrates the other skills in a fixed order and adds only the glue.

Arguments: $ARGUMENTS — a Linear issue key (`JUI-1340`) or a `linear.app` issue URL.

The stage numbers organise *your* work. Don't show "Stage N" labels to the user.

## Ground rules

- **Load each skill when its stage starts** (`Skill` tool) and follow it as written, except where a section below overrides it.
- **Invoking this flow is the user's explicit request for every stage**, including `self-review`. Do not re-prompt for any stage.
- **The app checkout is read-only.** Verify claims against `origin/main` of `../juiced` or `../juiced-tickets` (see `investigate-ticket`); never switch its branch, stash, or edit it.
- **Follow `CLAUDE.md`** in this repo for every page: sections, frontmatter, voice, badges, icons, changelog rules, and the writing standards (no em dashes, escaped `\$`, minimal colons, relative links, alt text).
- **Hard stops** (report and end the turn): the ticket cannot be fetched; the investigation finds the work invalid or blocked as a whole; the user declines the one pre-flight question in Stage 2.

## Stage 1 — Investigate

**Name the session first.** As soon as the ticket is fetched, output a ready-to-paste `/rename [JUI-NNNN] Ticket title` line.

Invoke `investigate-ticket` with `$ARGUMENTS` and produce its full analysis.

**Override:** skip its "Next Steps" menu. Close with a one-line **Decision** naming which Stage 3 path applies and why, plus the branch name.

## Stage 2 — Branch

Branch name: `docs/jui-NNNN-<short-slug>` (e.g. `docs/jui-1340-v3-69-0-release`), matching the repo's history. The ticket key in the branch is what makes Linear auto-link the PR.

1. `git status`. If there are uncommitted changes, ask once whether to carry, stash or stop; a "stop" is a hard stop.
2. `git fetch origin && git switch -c <branch> origin/main` (or `git switch <branch>` if it already exists).
3. Linear bookkeeping, best-effort (a Linear failure never blocks the work): move the ticket to In Progress if it is earlier in the workflow, and assign it to the current user if unassigned.

## Stage 3 — Grill or write

**Grill when any of these hold:**

- The investigation lists open questions that change what the docs say (is it shipped? who sees it? is it flag-gated?).
- It's unclear whether this is a new page or an update, or which section owns it, and the `CLAUDE.md` litmus test doesn't settle it.
- The app PRs and the code disagree, or the ticket asks the docs to promise behavior the code doesn't deliver.

**Write directly when** the change set is known: a release changelog with merged PRs, a page update with located drift, or a new page whose feature is shipped and fully readable in the code.

### If grilling

Invoke `grill-me`, seeded with the analysis and the open branches. Answer from the code whatever the code can answer. Finish with a short **Agreed Scope** (pages, facts each page states, what is left out and why). That scope is the claims source for `self-review`.

### Writing (both paths)

- **Before screenshots.** If a rendered page will change (layout, navigation, components, images), start the preview (`preview-docs`) and capture the affected pages before editing, light and dark, to `.screenshots/<branch>/` with names ending in `-before`.
- Match nearby pages before introducing a pattern. Prefer the smallest change that makes the docs correct.
- Every product fact you write has an app `file:line` behind it. Keep a running list; Stage 4 audits it.
- Update `docs.json` whenever a page is added, removed or renamed. Renamed headings break anchors, so grep for `#<old-anchor>` links.
- Changelog entries follow the `CLAUDE.md` rules exactly (audience split, tags, no ticket IDs or PR links).
- New images go under `images/tenant/**` or `images/portal/**` as light/dark WebP pairs in a `<Frame>`, like the existing pages.

Run the gate and fix what it reports:

```bash
mint broken-links
```

`mint validate` currently fails on `main` because of the OpenAPI setup in `docs.json`; run it, but only treat errors it reports that `main` doesn't as yours.

Commit in logical commits with the `docs: ` subject prefix the history uses (e.g. `docs: document v3.69.0 release updates`). **Do not push and do not open a PR.**

## Stage 4 — Self-review

Invoke `self-review` on the branch.

**Overrides:**

- Dispatch reviewers as `general-purpose` agents without asking.
- Every reviewer is read-only in both repos: no edits, commits, stash or checkout.
- Claims source: the Agreed Scope if you grilled, otherwise the Probable Change plus a PR description you draft first, plus your fact → `file:line` list.

Fix the findings you agree with and commit. List anything you deliberately left alone and why.

**Second pass.** If the first run produced a finding you acted on, run `self-review` once more with the same claims source plus the first-pass findings and their resolutions. Stop after two runs.

## Stage 5 — Preview

Invoke `preview-docs` on the changed pages. Fix what it finds, commit, and capture the `-after` screenshots for any page that has a `-before`.

## Final report

One message:

- **Ticket**: key, title, final status/assignee.
- **Branch**: name, and the preview URL for each changed page.
- **What changed**: pages added/updated/removed, `docs.json` changes, changelog entries.
- **Verification**: gate results, and which facts were checked against which app files.
- **Review**: per pass, findings fixed and declined (with reasons).
- **Preview**: what was checked and any anomalies left.
- **Screenshots**: the before/after files, or N/A.
- **Not done**: push and PR. Suggest a PR title in the `[JUI-NNNN] Summary` form and remind the user the template's Screenshots section describes `--attach`.

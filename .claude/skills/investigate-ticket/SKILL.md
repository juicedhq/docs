---
name: investigate-ticket
description: Use when the user mentions a Linear issue key (the `JUI-` prefix, e.g. JUI-1340), pastes a `linear.app` URL, or asks to "investigate", "look at", or "discover" a ticket for the docs. Linear is the tracker; the ticket usually describes an app change or release that the docs must reflect.
---

# Investigate Ticket

You are a senior technical writer and engineer performing deep ticket investigation for the Juiced docs. Goal: fully understand a Linear ticket, find what it changes in the product, cross-reference that against the app code and the current docs, and produce an analysis the user can act on.

Arguments: $ARGUMENTS

The phase numbers below organize *your* work, not the user-facing output. Don't include "Phase N" labels in anything you show the user.

This is a **read-only investigation**: gather context, analyze, and present options. Don't edit pages, switch git branches, or post to the ticket unless the user explicitly picks an action in the final step.

## Prerequisites

**Linear MCP (required).** This skill needs the Linear MCP tools (`mcp__linear-juiced__*` on a typical install; the server name is whatever each developer registered it as). If no Linear tools are available, set it up and authenticate, then retry:

- `claude mcp add --transport http linear-juiced https://mcp.linear.app/mcp`
- Run `/mcp`, select **linear-juiced**, and complete the OAuth login in the browser.

If the tools are still unavailable after that, stop and tell the user.

**The app checkout (required for accuracy).** The docs describe the Juiced app, so every product claim is checked against its code. It is a sibling checkout of this repo: `../juiced` or `../juiced-tickets`, whichever exists. Read the code as it is on `origin/main` (or the release/PR branch the ticket names), not whatever branch that checkout happens to be on:

```bash
APP=$(for d in ../juiced ../juiced-tickets; do [ -d "$d/.git" ] && echo "$d" && break; done)
git -C "$APP" fetch origin --quiet
git -C "$APP" branch --show-current        # if not main, read with: git -C "$APP" show origin/main:<path>
```

Never switch branches, stash, or edit anything in the app checkout. If no app checkout exists, say so and mark every product claim in the analysis as unverified.

## Phase 1: Identify the Ticket

Parse `$ARGUMENTS` for a Linear issue key:

- A bare key matching `[A-Z][A-Z0-9]*-\d+` (case-insensitive; uppercase before use).
- A Linear URL like `https://linear.app/juiced-hq/issue/JUI-1340/<slug>`; extract the key.

If no key is found, ask: *"Which Linear ticket should I investigate? (e.g. `JUI-1340` or full URL)"*

## Phase 2: Gather All Ticket Context

### Step 2a: Map the available tools

Linear's MCP tool names change between releases, so map the available tools to the roles you need rather than assuming a fixed list: fetch one issue, list comments, list sub-issues, get a project, and post a comment (Phase 5 only). If a role has no matching tool, say so and continue.

### Step 2b: Get the issue

Fetch the issue by key. Capture title, description, state, labels, assignee, project, parent, and every comment. **Read the description AND every comment**; clarifications and scope cuts often live only in comments.

### Step 2c: Related issues, project and app PRs

- **Parent / sub-issues / project**: fetch them when they exist. A docs ticket is often one slice of a release project, and the requirements live on the project or the app-side tickets it references.
- **App-side tickets**: when the ticket points at other `JUI-` tickets (the features being documented), fetch those too. They say what was built.
- **App PRs and releases**: find the merged app work the ticket documents. Linear attachments usually link the GitHub PRs; otherwise search: `gh pr list -R juicedhq/juiced --state merged --search "JUI-NNNN"`, or for a release, `gh release view vX.Y.Z -R juicedhq/juiced`. Read the PR bodies and diffs (`gh pr diff <N> -R juicedhq/juiced`). The PR says what changed; the code on `origin/main` is what ships, so confirm against it.

### Step 2d: Links and attachments

Fetch Linear-hosted images and files when they are load-bearing (a spec, screenshots the wording depends on). Note external links (Figma, Google Docs). If a load-bearing attachment can't be read, say so and mark that part of the assessment blocked.

### Summary Checkpoint

Write a brief summary of what the ticket asks for, then **classify it**:

- **Release notes**: a changelog entry for a version or range, plus any page updates the release requires.
- **New page**: a feature or guide that doesn't exist yet.
- **Page update**: existing pages that drifted from the app or need a new section.
- **Docs fix**: wrong facts, broken links, rendering problems, style cleanup.
- **Tooling**: navigation, `custom.css`, snippets, OpenAPI, repo config.

## Phase 3: Investigate the App and the Docs

1. **What changed in the product.** From the app PRs and code, list each user-visible change: the panel it appears in (tenant panel `/manage` or customer portal `/app`), the page, the labels, statuses and settings the user sees, and who can see it (roles, plans, feature flags). React pages live in `resources/js/Pages/`; status badges take their tone from the enum's `getTone()`; icons come from the sidebars and command palette (see `CLAUDE.md`). Note anything gated behind a Pennant flag (`app/Features/`) that isn't on for everyone; the docs shouldn't promise it to everyone.
2. **Where it belongs in the docs.** Apply the `CLAUDE.md` litmus test (noun → `features/`, verb or goal → `guides/`, buyer-facing → `customer-portal/`, inputs/outputs → `api-reference/`, what's new → `changelog/`). Search the repo for existing coverage before proposing a new page: `grep -ril '<term>' --include='*.mdx' .`
3. **Drift.** For each existing page the change touches, check its claims against the app and record what is now wrong, missing, or still correct (file:line on both sides).
4. **Blast radius.** Other pages that link to, screenshot, or repeat the changed behavior; `docs.json` navigation; the changelog pages; `api-reference/openapi.json` when the API changed; images under `images/` that now show the old UI.

## Phase 4: Present the Analysis

### Ticket Summary

What the ticket asks for, in your own words.

### Validity Assessment

- Is the described product behavior actually shipped (merged to the app's `main`, or in the named release)? Docs for unmerged or flag-gated work need a decision.
- Contradictions between the ticket, the app PRs and the code.
- Missing information that blocks the work. List the questions to send back. If a load-bearing input was unreadable, mark that portion **blocked** and assess the rest.

### Probable Change

- **Pages to add or change**: exact paths, and the section within each page.
- **What each change says**: the facts, with the app file:line that proves each one.
- **Navigation**: `docs.json` entries to add, move or remove.
- **Changelog**: which page(s), the `<Update>` label/description/tags, and the audience split (tenant vs portal).
- **Screenshots**: pages whose images now show stale UI.
- **Left out on purpose**: flag-gated, internal-only or about-to-be-removed behavior, with the reason.

### Risk Assessment

What a reader could get wrong if the docs ship as proposed: over-promising gated features, describing a role's view as everyone's, stale screenshots, broken anchors from renamed headings.

## Phase 5: Offer Next Steps

Under a heading like `## Next Steps`, offer:

1. Open the ticket in a browser (print the Linear URL).
2. Add a clarifying comment to the ticket.
3. Stop here.

And, when present in the session:

- `start-ticket`: "Take JUI-NNNN end to end" (branch, write, self-review, preview check).
- `preview-docs`: "Preview the affected pages locally".

Ask the user to pick one, then hand off with the ticket key and a one-line summary so the next step doesn't re-fetch.

## Tone

Be direct and specific. Reference exact paths and line numbers in both repos. If you're uncertain, say so and say what would resolve it.

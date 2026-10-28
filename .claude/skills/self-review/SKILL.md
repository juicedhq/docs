---
name: self-review
description: Use ONLY when the user explicitly asks for a full self-review of the current docs branch (e.g. runs /self-review), or as the review stage of a start-ticket run the user invoked. Do NOT invoke proactively — it dispatches 5 review subagents and is slow and token-intensive.
---

# Self Review

> **Cost gate — do not run casually.** This skill dispatches **5 review subagents** over the full branch diff. Run it ONLY on an explicit request to self-review the branch (or `/self-review`). If you reached here proactively, **STOP and ask the user to confirm** first. The exception is `start-ticket`: invoking it is the explicit request for its review stage.

Multi-agent review of the current docs branch: a broad consensus pass, focused single-concern passes, and an accuracy audit against the app code, reconciled into prioritized, actionable findings.

## 1. Setup

- **Diff**: base is `origin/main` (or the PR base), head is `HEAD`. Every agent reviews `git diff origin/main...HEAD`. Tell each agent which decisions are known-intentional so they aren't re-flagged.
- **App checkout**: `../juiced` or `../juiced-tickets`, whichever exists, read at `origin/main` (`git -C <app> show origin/main:<path>` if the checkout is on another branch). Pass the path to every agent and tell them it is read-only.
- **Claims source**, in priority order: the PR description if a PR exists; the Agreed Scope or Probable Change from this session; the fact → app `file:line` list from writing. If none exist, draft the PR description first (using `.github/PULL_REQUEST_TEMPLATE.md`) and audit the draft.
- Dispatch every agent as `general-purpose`, named `review: <lens>`, read-only in both repos (no edits, commits, stash or checkout).

## 2. Two general review agents (consensus)

Dispatch **two independent general agents in parallel**. Each reviews broadly (accuracy, clarity, structure, style, rendering) and returns Strengths / Issues (severity + file:line) / Assessment.

Raised by both → likely real. Raised by one → verify against the page and the code yourself.

## 3. Two targeted agents (one concern each)

Dispatch in parallel. The bullets are starting points, not a checklist; each agent explores its whole concern.

- **Conventions and style**: every rule in this repo's `CLAUDE.md` and `AGENTS.md`. Frontmatter on every page with no duplicate H1; section placement by the noun/verb litmus test; second person; no em dashes anywhere (including alt text and descriptions); `\$` escaping when a paragraph has two amounts; minimal colons and numbered procedural headings; relative internal links; language tags on code fences; alt text; badges via `tone-badge` with the app's tone; icons via `HugeIcon` matching the app; at most one community pitch and none on portal or API pages; changelog rules (audience split, tags, no ticket IDs or PR links, `**Breaking:**`). Voice: fruit puns only where they don't cost clarity.
- **Structure and rendering**: `docs.json` includes every added page and drops every removed one; renamed headings or moved pages don't leave dangling links or anchors elsewhere in the repo; images exist at the referenced paths with light/dark pairs; MDX that will render wrong (unescaped `$`, `<` in prose, broken component props, imports not at the top); duplicated content that should link instead; prerequisites at the top of procedural pages.

## 4. Accuracy agent (adversarial, in parallel with the others)

Its ONLY job is checking what the docs say against what the app does. Give it the claims source and the app checkout path, and instruct it to:

1. **Extract every factual claim in the diff**: UI labels and button names, navigation paths, status names and badge tones, default values, limits, who can see or do what (roles, plans, flags), the order of steps, API fields and status values, webhook payloads, and every changelog bullet. Also the claims in the PR description or Agreed Scope.
2. **Also audit implicit claims**: a page that says "you can" implies every tenant can (is it flag- or plan-gated?); a step list implies the steps work in that order from that starting page; a screenshot caption asserts what the image shows.
3. **Verdict each claim** with the app `file:line` that proves it: `verified` / `wrong` / `partly true` / `not shipped` (only on a branch, or behind a flag that isn't on for everyone) / `couldn't verify`.
4. Output a **claims × verdict table** with a row for every claim. "Couldn't verify" is a verdict, not an omission. Quote the docs text exactly.

This is a separate agent because it works from a checklist with a clear completion condition, and docs errors are almost always facts that read plausibly but drifted from the code.

## 5. Synthesize

Merge into one prioritized report. Wrong or not-shipped claims are the highest severity: a reader acts on them. Then broken rendering and navigation, then convention violations, then polish. For each finding: severity, `file:line`, why it matters, and a concrete fix (the corrected wording where possible). Drop duplicates and known-intentional decisions. Include the full claims table.

## Common mistakes

- **Trusting the app PR description over the code.** PRs describe intent; `origin/main` is what ships.
- **Treating flag-gated behavior as general.** Check `app/Features/` and the gate the page uses.
- **Trusting reviewer citations without spot-checks.** Verify the load-bearing `file:line` references during synthesis.
- **Reviewing what `mint broken-links` already checks.** Spend agent depth on facts and readability.

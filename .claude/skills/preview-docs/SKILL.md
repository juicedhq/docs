---
name: preview-docs
description: Use when the user asks to preview, run, view or visually check the docs locally, or as the preview stage of start-ticket. Starts the Mintlify dev server behind Herd at https://juiced-docs.test and checks the changed pages in Claude in Chrome, light and dark, desktop and phone.
---

# Preview Docs

The docs run on Mintlify's dev server (`mint dev`). Herd proxies `https://juiced-docs.test` to it, so it has a stable HTTPS URL like the app.

## 1. Start the preview

```bash
command -v mint || npm i -g mint
herd proxies | grep -q juiced-docs || herd proxy juiced-docs 'http://[::1]:3333' --secure
lsof -iTCP:3333 -sTCP:LISTEN -P   # already running? reuse it
```

If nothing is listening, start it from the repo root in the background (it dies with the session):

```bash
mint dev --port 3333 --no-open
```

`mint dev` binds to `localhost` on IPv6 only, which is why the proxy points at `[::1]` rather than `127.0.0.1` (that gives a 502). It reloads on file changes. If the preview looks stale or broken, run `mint update` and restart it.

Confirm `curl -sk -o /dev/null -w '%{http_code}' https://juiced-docs.test/` prints `200`.

## 2. Which pages

`git diff --name-only origin/main...HEAD` → each changed `.mdx` maps to `https://juiced-docs.test/<path without .mdx>` (`features/webhooks.mdx` → `/features/webhooks`, `index.mdx` → `/`). Add pages that link to a renamed anchor, and the changelog pages when they changed. A `docs.json` change means checking the sidebar on a page in each affected group.

## 3. Check in the browser

Load the `claude-in-chrome` skill, then its tools in one ToolSearch (core set plus `resize_window`, `javascript_tool`, `read_console_messages`). `tabs_context_mcp` first, then a new tab.

For each page, at desktop (1280×800) and phone (390×844), in light and dark (the theme toggle in the header):

- The page renders: title and description from frontmatter, no raw MDX, no `$...$` math where prices were meant, components (Cards, Steps, Tabs, Frames, Updates) render as components.
- Images load, light images in light mode and dark in dark, with nothing clipped.
- Badges and icons render with the right colors in both themes.
- Links on the page go somewhere real (spot-check, `mint broken-links` covers the rest), and anchors land on the right heading.
- The page sits in the right place in the sidebar.
- No horizontal overflow (`document.documentElement.scrollWidth > innerWidth`), and no console errors from the page.

Save screenshots worth keeping to `.screenshots/<branch>/` (gitignored), named `<page>-<light|dark>-<before|after>.png`, and look at each one.

## 4. Report

Per page: URL, what was checked, pass or the anomaly. Fix anomalies in the source and recheck; list anything left with a reason.

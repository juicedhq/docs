### Ticket(s)

- https://linear.app/juiced-hq/issue/JUI-

### Summary

What changed in the docs and why. Name the app change, release or ticket it follows, and anything left out on purpose.

### Pages touched

List each new, rewritten, moved or removed page, and note `docs.json` navigation changes.

- 

### Types of changes

Put an `x` in all the boxes that apply:

- [ ] New page(s)
- [ ] Update to existing page(s)
- [ ] Changelog entry (`changelog/platform.mdx` and/or `changelog/customer-portal.mdx`)
- [ ] API reference / OpenAPI
- [ ] Navigation, styling or snippets (`docs.json`, `custom.css`, `snippets/`)
- [ ] Repo tooling (skills, templates, scripts)

### Screenshots (if appropriate)

For rendered changes (new pages, layout, navigation, badges, icons, images), show each "after" screenshot of the local preview with a short caption, and put its "before" directly below it in a collapsed `<details>` block (one block per screenshot; a new page with no before gets none). Inspect each image before adding it. If nothing rendered differently, put N/A.

<!--
gh 2.99.0+ attaches images and videos directly (check with `gh --version`, update with `brew upgrade gh`).
Reference each file here by its local path, then pass the same path to `gh pr create` or `gh pr edit`;
gh uploads it and swaps the reference for the uploaded image:

  ![After: webhooks event list](.screenshots/jui-1234/after.png)

  <details>
  <summary>Before</summary>

  ![Before: webhooks event list](.screenshots/jui-1234/before.png)

  </details>

  gh pr edit <N> --body-file body.md \
    --attach '.screenshots/jui-1234/after.png#After: webhooks event list' \
    --attach '.screenshots/jui-1234/before.png#Before: webhooks event list'

Keep the blank lines around the image inside <details>, or GitHub won't render it.
.screenshots/ is gitignored, so the images never enter the branch.
-->


### Pre-review checklist

Before asking for a review in this pull request, ensure the following are true:

- [ ] Ran `/self-review` and addressed any findings
- [ ] Every product claim was checked against the app code
- [ ] Checked the changed pages in the local preview (`mint dev`), light and dark
- [ ] `mint broken-links` passes
- [ ] New, renamed or removed pages are reflected in `docs.json`
- [ ] Follows `CLAUDE.md` writing rules (frontmatter, no em dashes, escaped `\$`, relative links, alt text, no ticket IDs or PR links in the changelog)

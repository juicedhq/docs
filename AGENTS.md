# Repository Guidelines

## Project Structure & Module Organization
This repository is a Mintlify documentation site. Content lives in `get-started/`, `features/`, `guides/`, `customer-portal/`, `api-reference/`, and `changelog/`. Configuration, navigation, theme settings, and OpenAPI wiring live in `docs.json`. Static assets live in `images/`, `logo/`, and root files such as `favicon.svg`.

Choose sections intentionally: `features/` explains what a thing is and how it works, while `guides/` walks users through accomplishing a goal. If the title is a noun phrase, it usually belongs in Features; if it is a verb phrase, it usually belongs in Guides.

## Build, Test, and Development Commands
Use the Mintlify CLI from the repository root, where `docs.json` is located.

- `npm i -g mint`: install the Mintlify CLI.
- `mint dev`: run the local docs preview at `http://localhost:3000`.
- `mint update`: refresh the CLI if preview or config behavior looks stale.
- `bash scripts/update-docs-from-pr.sh <pr_number> <github_token>`: automation for generating a docs update branch from an app PR; use only when you intend to run the repo’s scripted workflow.

## Coding Style & Naming Conventions
Write docs in MDX with YAML frontmatter. Every page should include `title` and `description`; do not add a duplicate H1 in the body. Match existing lowercase, hyphenated filenames such as `features/payments-and-deposits.mdx`. Write in second person, keep prerequisites near the top of procedural pages, use relative internal links, language-tagged code fences, and alt text on images.

Match nearby pages before introducing a new pattern. The preferred tone is conversational, approachable, and occasionally Juiced-themed; keep critical warnings, security guidance, and technical explanations straightforward.

## Testing Guidelines
There is no dedicated automated test suite in this repo today. Validate changes with `mint dev` by checking affected pages, navigation, links, code blocks, images, and API rendering from `api-reference/openapi.json`. Test code examples before publishing, and verify product accuracy against `../juiced-tickets` when behavior or terminology is in doubt.

## Commit & Pull Request Guidelines
Recent history favors concise, imperative subjects such as `docs: update documentation for PR #123`. Keep commits focused. Do not use `--no-verify`, and do not skip hooks. Create a branch when there is not already a clear branch for the work. PRs should explain what changed, why it changed, which pages were touched, and include screenshots when rendered output or navigation changed.

## Contributor Notes
Start with the smallest reasonable change. Avoid duplication unless it is intentional and useful. Include basic and advanced use cases where they help users succeed. Update `docs.json` whenever you add, remove, or rename a page. Use `STRUCTURE.md` and `CLAUDE.md` as the primary local references for section intent and writing standards.

If requirements are unclear, ask instead of guessing.

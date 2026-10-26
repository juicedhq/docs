# Mintlify documentation

## Working relationship
- You can push back on ideas-this can lead to better documentation. Cite sources and explain your reasoning when you do so
- ALWAYS ask for clarification rather than making assumptions
- NEVER lie, guess, or make up information

## Project context
- Format: MDX files with YAML frontmatter
- Config: docs.json for navigation, theme, settings
- Components: Mintlify components

## Documentation structure

### Sections
- **Get Started**: Onboarding guide that takes users from zero to their first dollar earned. Prominent, standalone, goal-oriented.
- **Features**: Explains what each part of the system is and how it works. Noun-oriented. Users come here to look something up.
- **Guides**: Walks users through multi-step processes to achieve specific outcomes. Verb-oriented. Users come here to do something. This is also where we educate users on business models and expand their ideas about what's possible with Juiced.
- **Customer Portal**: Documentation for customers who purchase leads through the `/app` portal. Task-oriented. All other sections are written for tenants who manage their operation through `/manage`.
- **API Reference**: Technical specification. Exact inputs, outputs, and behaviors for developers.
- **Changelog**: What's new or changed. Split by audience into two pages (see "Changelog entries" below).

### Deciding where content belongs
Use this litmus test:
- If the page title is a **noun or noun phrase** (Lead Routing, Buyer Management, Webhooks) → **Features**
- If the page title is a **verb phrase or goal** (Setting Up Ping-Post, Implementing Tiered Pricing) → **Guides**

### Section purposes
| Section | Question it answers |
|---------|---------------------|
| Get Started | "How do I get up and running?" |
| Features | "What is this thing and how does it work?" |
| Guides | "How do I accomplish X?" |
| Customer Portal | "How do I use this as a customer?" |
| API Reference | "What are the exact inputs/outputs?" |
| Changelog | "What's new or changed?" |

## Changelog entries
The changelog is split by audience into two pages, both listed in the Changelog tab:
- `changelog/platform.mdx` — changes tenants see in `/manage`
- `changelog/customer-portal.mdx` — changes customers see in `/app`

Rules for adding entries:
- Each release is an `<Update>` block, newest first. `label` is the release date ("July 23, 2026"), `description` is the version or range ("v3.38–v3.43"), and `tags` come from the fixed set: `New`, `Improvements`, `Fixes`, `Breaking changes`. Only apply tags that match the entry's content.
- Sort every change by the audience that sees it. A release may appear on both pages with only the relevant slice on each; tenant-only changes never appear on the portal page.
- Write the portal page in buyer voice ("your purchased leads") and link only to `/customer-portal/*` pages. Platform entries link to `/features/*`, `/guides/*`, and `/api-reference/*` pages.
- Link the first natural mention of any feature, guide, or concept that has its own docs page (root-relative paths).
- Never include GitHub PR links or internal ticket IDs (JUI-xxx). Write plain, reader-facing prose.
- Prefix breaking changes with `**Breaking:**` and tag the update `Breaking changes`.
- Group changes inside an update under `##` headings by product area when there are more than a few bullets.
- Keep `rss: true` in both pages' frontmatter; adding an `<Update>` or editing headings inside one publishes to that page's RSS feed.

## Content strategy
- Document just enough for user success - not too much, not too little
- Prioritize accuracy and usability of information
- Make content evergreen when possible
- Search for existing information before adding new content. Avoid duplication unless it is done for a strategic reason
- Check existing patterns for consistency
- Start by making the smallest reasonable changes

## Frontmatter requirements for pages
- title: Clear, descriptive page title (renders as the page's H1 heading)
- description: Concise summary for SEO/navigation (renders as subheading)
- Do NOT add a duplicate H1 heading in the page content—the frontmatter title handles this

## Voice and tone
- Default to conversational and approachable - write like you're helping a colleague
- Add wit and humor when it enhances understanding or makes dry topics more engaging
- Lean into the Juiced theme - fruit and juice metaphors, puns, and references are encouraged when they fit naturally
- Safe places for personality: introductions, transitions, examples, error messages, asides
- Keep it professional in: critical warnings, security topics, complex technical explanations
- If a joke requires re-reading the sentence to understand the actual instruction, cut the joke
- Self-deprecating humor > sarcasm or punching down
- When in doubt, prioritize clarity over cleverness

## Writing standards
- Second-person voice ("you")
- Prerequisites at start of procedural content
- Test all code examples before publishing
- Verify documentation accuracy against the actual codebase in ../juiced-tickets
- Match style and formatting of existing pages
- Include both basic and advanced use cases
- Language tags on all code blocks
- Alt text on all images
- No em dashes anywhere, including alt text, descriptions and the changelog. Rephrase with a comma, a period, or parentheses instead of swapping in another dash
- Escape dollar signs as `\$` in body text whenever a paragraph has more than one amount (`\$100 deposit charges \$101`). Mintlify renders text between two `$` signs as a math formula. Leave them alone in code, frontmatter and HTML attributes
- Keep colons to a minimum. Write bold-label list items as sentences (`**Label** does X.`), end list lead-ins with a period, and number procedural headings as `## 1. Do the thing`. Colons in code, URLs, times and the changelog's `**Breaking:**` prefix are fine

## App badges

When a page names a status or badge the app shows as a colored badge (lead statuses, bid statuses and positions, customer statuses, payment method statuses, log results, roles), render it with the shared badge styles in `custom.css` so the docs match the app in light and dark mode.

- Use `<span className="tone-badge tone-success">Assigned</span>`. Tones mirror the app's `ToneBadge` (`neutral`, `success`, `warning`, `caution`, `danger`, `info`, `sky`, `purple`, `lime`, `fuchsia`, `amber`).
- Take the tone from the app, never from the word. Status enums carry it (`getTone()` via `App\Enums\Traits\HasTone`), and some React pages map it locally, so the same label can differ by panel. Bid **Limited** is `sky` in the tenant panel and `info` in the customer portal.
- Only badge values the app actually renders as badges. Filter options, timeline events (dots) and notification names stay plain text.
- The customer portal's wallet chip has its own `wallet-chip` classes.

## Icons

The docs use Hugeicons, the same free icon set as the app, so every icon should be the one the app shows for that concept. Look it up in the app's `resources/js/components/tenant/tenant-app-sidebar.tsx`, `customer/customer-app-sidebar.tsx`, and `tenant/tenant-command-palette.tsx` (which also gives settings pages their icons). Only reach for a new icon when the app has none for the concept, and never reuse an app icon for a different concept.

- Card icons use the shared snippet. Import it once after the frontmatter with `import { HugeIcon } from '/snippets/hugeicon.jsx';` and write `<Card title="Bids" icon={<HugeIcon name="auction" card />}>`. The `card` prop sizes it like Mintlify's own icons and colors it with the docs accent in both themes. Never use a string `icon="..."` on a Card.
- Names are kebab-case versions of the package's export (`Wallet01Icon` becomes `wallet-01`). To add one, copy its `[tag, attributes]` array from `https://cdn.jsdelivr.net/npm/@hugeicons/core-free-icons@4.3.5/dist/esm/Wallet01Icon.js` into the registry in `snippets/hugeicon.jsx`, dropping the `key` attribute (the component sets keys and stroke width itself).
- Keep `snippets/hugeicon.jsx` a single export. Mintlify evaluates each snippet export on its own, so one export can't call another.
- Sidebar group icons in `docs.json` are SVG files in `/images/icons/` (download the icon's SVG from hugeicons.com, free set, stroke 1.5). Mintlify renders a file icon as a plain `<img>`, so `custom.css` masks it to follow the text color. When you add a new file, add its line to the "Hugeicons sidebar group icons" block in `custom.css` or it shows black in dark mode.

## Community pitches
- Where it fits naturally, point readers to our Skool communities. That Agency Group (https://www.skool.com/that-agency-group) is free and suits strategy questions like pricing, finding buyers and return policies. The Hybrid Agency Mastermind (https://www.skool.com/hybrid-agency-mastermind) is paid, hands-on coaching and implementation help on live calls
- Hub pages use the shared `<CommunityCards />` snippet (`/snippets/community-cards.mdx`). Guides and feature pages use a short `<Tip>` tailored to the page, usually just before "What happens next" or "Related pages"
- At most one pitch per page, and never on customer portal or API reference pages
- Relative paths for internal links

## Git workflow
- NEVER use --no-verify when committing
- Ask how to handle uncommitted changes before starting
- Create a new branch when no clear branch exists for changes
- Commit frequently throughout development
- NEVER skip or disable pre-commit hooks

## Do not
- Skip frontmatter on any MDX file
- Use absolute URLs for internal links
- Include untested code examples
- Make assumptions - always ask for clarification
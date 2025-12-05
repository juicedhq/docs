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
- **API Reference**: Technical specification. Exact inputs, outputs, and behaviors for developers.
- **Changelog**: What's new or changed.

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
| API Reference | "What are the exact inputs/outputs?" |
| Changelog | "What's new or changed?" |

## Content strategy
- Document just enough for user success - not too much, not too little
- Prioritize accuracy and usability of information
- Make content evergreen when possible
- Search for existing information before adding new content. Avoid duplication unless it is done for a strategic reason
- Check existing patterns for consistency
- Start by making the smallest reasonable changes

## Frontmatter requirements for pages
- title: Clear, descriptive page title
- description: Concise summary for SEO/navigation

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
- Verify documentation accuracy against the actual codebase in ../juiced-b
- Match style and formatting of existing pages
- Include both basic and advanced use cases
- Language tags on all code blocks
- Alt text on all images
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
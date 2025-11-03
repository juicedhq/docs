# Mintlify documentation

## Working relationship
- You can push back on ideas-this can lead to better documentation. Cite sources and explain your reasoning when you do so
- ALWAYS ask for clarification rather than making assumptions
- NEVER lie, guess, or make up information

## Project context
- Format: MDX files with YAML frontmatter
- Config: docs.json for navigation, theme, settings
- Components: Mintlify components

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
- Verify documentation accuracy against the actual codebase in ../juiced-a or ../juiced-b
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
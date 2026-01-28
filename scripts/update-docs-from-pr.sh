#!/bin/bash
set -e

# Usage: ./update-docs-from-pr.sh <pr_number> <github_token>
# Example: ./update-docs-from-pr.sh 123 ghp_xxxxx

REPO="juicedhq/juiced"
PR_NUMBER="$1"
GITHUB_TOKEN="$2"
DOCS_REPO="juicedhq/docs"

if [ -z "$PR_NUMBER" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "Usage: $0 <pr_number> <github_token>"
    exit 1
fi

DOCS_DIR="/home/forge/docs"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Fetching PR #$PR_NUMBER from $REPO..."

# Fetch PR details
curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER" > "$TEMP_DIR/pr.json"

# Fetch PR diff
curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3.diff" \
    "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER" > "$TEMP_DIR/pr.diff"

# Fetch changed files
curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER/files" > "$TEMP_DIR/files.json"

# Extract PR info
PR_TITLE=$(jq -r '.title' "$TEMP_DIR/pr.json")
PR_BODY=$(jq -r '.body // ""' "$TEMP_DIR/pr.json")
PR_AUTHOR=$(jq -r '.user.login' "$TEMP_DIR/pr.json")
PR_URL=$(jq -r '.html_url' "$TEMP_DIR/pr.json")
CHANGED_FILES=$(jq -r '.[].filename' "$TEMP_DIR/files.json" | head -50)

echo "PR: $PR_TITLE"
echo "Author: $PR_AUTHOR"
echo "Changed files: $(echo "$CHANGED_FILES" | wc -l)"

cd "$DOCS_DIR"

# Configure Git to use the token for authentication
# This sets the remote URL to include credentials for push operations
ORIGINAL_REMOTE=$(git remote get-url origin)
git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${DOCS_REPO}.git"

# Ensure we restore the original remote URL on exit (security: don't leave token in git config)
cleanup() {
    cd "$DOCS_DIR" 2>/dev/null && git remote set-url origin "$ORIGINAL_REMOTE" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Ensure we're on main and up to date
git checkout main
git pull origin main

# Create a new branch for the docs update
BRANCH_NAME="docs/pr-${PR_NUMBER}-$(date +%Y%m%d%H%M%S)"
git checkout -b "$BRANCH_NAME"

echo "Created branch: $BRANCH_NAME"

# Build the prompt for Claude Code
PROMPT=$(cat <<EOF
A pull request has been merged into the main codebase that may require documentation updates.

## PR Details
- **Title:** $PR_TITLE
- **Author:** $PR_AUTHOR
- **URL:** $PR_URL
- **PR Description:**
$PR_BODY

## Changed Files
$CHANGED_FILES

## Diff
$(cat "$TEMP_DIR/pr.diff" | head -500)

## Your Task
1. Read the CLAUDE.md file in this repo to understand documentation standards
2. Analyze the changes above to understand what was modified in the codebase
3. Review the existing documentation to understand current structure and patterns
4. Determine if any documentation needs to be:
   - Updated (existing pages that reference changed functionality)
   - Created (new features that need documentation)
   - Removed (deprecated features)
5. Make the necessary documentation changes following the standards in CLAUDE.md
6. If no documentation changes are needed, create a file at /tmp/no-docs-needed.txt explaining why

Focus on user-facing changes that would affect how someone uses the product.
Do NOT commit your changes - the script will handle that.
EOF
)

echo "Running Claude Code to analyze and update documentation..."

# Run Claude Code in non-interactive mode
/home/forge/.local/bin/claude -p "$PROMPT" --allowedTools "Read,Write,Edit,Glob,Grep"

# Check if Claude determined no docs were needed
if [ -f "/tmp/no-docs-needed.txt" ]; then
    echo "Claude determined no documentation changes were needed:"
    cat /tmp/no-docs-needed.txt
    rm /tmp/no-docs-needed.txt
    git checkout main
    git branch -D "$BRANCH_NAME"
    echo "Cleaned up branch. Exiting."
    exit 0
fi

# Check if there are any changes to commit
if git diff --quiet && git diff --staged --quiet; then
    echo "No changes were made to documentation."
    git checkout main
    git branch -D "$BRANCH_NAME"
    exit 0
fi

echo "Changes detected. Creating commit..."

# Stage all changes
git add -A

# Create commit
git commit -m "docs: update documentation for PR #$PR_NUMBER

Automated documentation update triggered by:
$PR_URL

$PR_TITLE"

# Push the branch
echo "Pushing branch to origin..."
git push -u origin "$BRANCH_NAME"

# Create PR via GitHub API
echo "Creating pull request..."

PR_BODY_ESCAPED=$(cat <<EOF
## Automated Documentation Update

This PR was automatically generated to update documentation based on changes from:
- **Source PR:** $PR_URL
- **Title:** $PR_TITLE
- **Author:** @$PR_AUTHOR

### Changes in source PR:
$PR_BODY

---
*This PR was created automatically by the documentation bot. Please review the changes before merging.*
EOF
)

# Create the PR
RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$DOCS_REPO/pulls" \
    -d @- <<PRDATA
{
    "title": "docs: $PR_TITLE",
    "body": $(echo "$PR_BODY_ESCAPED" | jq -Rs .),
    "head": "$BRANCH_NAME",
    "base": "main"
}
PRDATA
)

# Extract and display the PR URL
DOCS_PR_URL=$(echo "$RESPONSE" | jq -r '.html_url // empty')

if [ -n "$DOCS_PR_URL" ] && [ "$DOCS_PR_URL" != "null" ]; then
    echo "================================================"
    echo "Documentation PR created successfully!"
    echo "PR URL: $DOCS_PR_URL"
    echo "================================================"
else
    echo "Failed to create PR. Response:"
    echo "$RESPONSE" | jq .
    exit 1
fi
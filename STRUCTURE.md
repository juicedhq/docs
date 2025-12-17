# Documentation Structure

This file tracks the planned structure for Juiced documentation. Pages marked with a checkmark are live in production. Unmarked pages exist as placeholder files but are hidden from navigation until content is ready.

## Get Started

- [x] `get-started/quickstart.mdx` - Quickstart

## Features

- [x] `features/index.mdx` - Introduction

### Core Concepts

- [x] `features/leads.mdx` - Leads
- [ ] `features/lead-types.mdx` - Lead Types
- [ ] `features/segments.mdx` - Segments
- [ ] `features/sources.mdx` - Sources
- [ ] `features/customers.mdx` - Customers
- [ ] `features/ping-post.mdx` - Ping-Post

### Selling Leads

- [ ] `features/bidding.mdx` - Bidding
- [ ] `features/reverse-auctions.mdx` - Reverse Auctions
- [ ] `features/distribution.mdx` - Distribution

### Money & Limits

- [ ] `features/budgets-and-caps.mdx` - Budgets & Caps
- [ ] `features/transactions.mdx` - Transactions
- [ ] `features/payment-methods.mdx` - Payment Methods

### Quality & Validation

- [ ] `features/duplicate-detection.mdx` - Duplicate Detection
- [ ] `features/submissions.mdx` - Submissions
- [ ] `features/audits.mdx` - Audits

### Automation

- [ ] `features/workflows.mdx` - Workflows
- [ ] `features/notifications.mdx` - Notifications

### Account Management

- [ ] `features/users-and-roles.mdx` - Users & Roles
- [ ] `features/integrations.mdx` - Integrations

## Guides

- [x] `guides/index.mdx` - Introduction

*No guides written yet. Add guide pages here as they're created.*

## API Reference

- [ ] `api-reference/introduction.mdx` - Introduction
- [ ] `api-reference/endpoint/get.mdx` - GET endpoint
- [ ] `api-reference/endpoint/create.mdx` - CREATE endpoint
- [ ] `api-reference/endpoint/delete.mdx` - DELETE endpoint
- [ ] `api-reference/endpoint/webhook.mdx` - Webhook endpoint

*API reference pages need to be rewritten for Juiced (currently contain Mintlify starter template content).*

## Changelog

- [x] `changelog/index.mdx` - Changelog

---

## Adding a new page

1. Write the content in the appropriate `.mdx` file
2. Add the page path to `docs.json` under the correct group
3. Update this file to mark the page as complete

## Section guidelines

| Section | Question it answers | Title format |
|---------|---------------------|--------------|
| Get Started | "How do I get up and running?" | Goal-oriented |
| Features | "What is this thing and how does it work?" | Noun phrases |
| Guides | "How do I accomplish X?" | Verb phrases |
| API Reference | "What are the exact inputs/outputs?" | Endpoint names |
| Changelog | "What's new or changed?" | Date-based |

## Core Concepts vs Guides

Core Concepts pages explain the "what and why"—what a feature is and why it exists in the application. These are higher-level explanations that help users understand the mental model.

For some concepts, that's all the documentation needed. For others, a companion page in Guides may be necessary to cover the "how"—step-by-step implementation details and configuration walkthroughs.

Example:
- `features/ping-post.mdx` — What ping-post is and why you'd use it
- `guides/setting-up-ping-post.mdx` — How to configure ping-post for your operation

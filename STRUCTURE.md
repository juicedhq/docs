# Documentation Structure

This file tracks the planned structure for Juiced documentation. Pages marked with a checkmark are live in production. Unmarked pages exist as placeholder files but are hidden from navigation until content is ready.

## Get Started

- [x] `get-started/quickstart.mdx` - Quickstart

## Features

- [x] `features/index.mdx` - Introduction

### Ingesting & Classifying Leads

- [x] `features/leads.mdx` - Leads
- [x] `features/lead-types.mdx` - Lead Types
- [x] `features/segments.mdx` - Segments
- [x] `features/sources.mdx` - Sources

### Selling Leads

- [ ] `features/ping-post.mdx` - Ping-Post
- [x] `features/bidding.mdx` - Bidding
- [ ] `features/reverse-auctions.mdx` - Reverse Auctions
- [ ] `features/distribution.mdx` - Distribution
- [ ] `features/marketplace.mdx` - Marketplace

### People

- [ ] `features/customers.mdx` - Customers

### Money & Limits

- [ ] `features/budgets-and-caps.mdx` - Budgets & Caps
- [ ] `features/transactions.mdx` - Transactions
- [x] `features/payment-methods.mdx` - Payments & Deposits

### Quality & Validation

- [x] `features/duplicate-detection.mdx` - Duplicate Detection
- [ ] `features/submissions.mdx` - Submissions
- [x] `features/audits.mdx` - Audits
- [x] `features/returns.mdx` - Returns

### Events & Messaging

- [ ] `features/workflows.mdx` - Workflows
- [x] `features/notifications.mdx` - Notifications
- [x] `features/webhooks.mdx` - Webhooks

### Observability

- [ ] `features/location-analytics.mdx` - Location Analytics

### Account Management

- [ ] `features/company-profile.mdx` - Company Profile
- [x] `features/branding.mdx` - Branding
- [ ] `features/billing.mdx` - Billing
- [x] `features/integrations.mdx` - Integrations
- [ ] `features/users.mdx` - Users
- [ ] `features/roles.mdx` - Roles

## Guides

- [x] `guides/index.mdx` - Introduction

*No guides written yet. Add guide pages here as they're created.*

## Buyer Portal

- [ ] `buyer-portal/index.mdx` - Introduction
- [ ] `buyer-portal/getting-started.mdx` - Getting Started
- [ ] `buyer-portal/purchasing-leads.mdx` - Purchasing Leads
- [ ] `buyer-portal/managing-your-account.mdx` - Managing Your Account

*Documentation for buyers who purchase leads through the `/app` portal. All other sections are written for tenants who manage their operation through `/manage`.*

## API Reference

- [x] `api-reference/introduction.mdx` - Introduction
- [x] `api-reference/endpoint/ping.mdx` - POST /ping
- [x] `api-reference/endpoint/leads.mdx` - POST /leads

*API documentation is auto-generated from `api-reference/openapi.json`.*

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
| Buyer Portal | "How do I use this as a buyer?" | Task-oriented |
| API Reference | "What are the exact inputs/outputs?" | Endpoint names |
| Changelog | "What's new or changed?" | Date-based |

## Features vs Guides

Feature pages explain the "what and why"—what something is and why it exists in the application. These are organized by workflow (ingesting leads, selling leads, etc.) to help users understand how pieces fit together.

For some features, that's all the documentation needed. For others, a companion page in Guides may be necessary to cover the "how"—step-by-step implementation details and configuration walkthroughs.

Example:
- `features/ping-post.mdx` — What ping-post is and why you'd use it
- `guides/setting-up-ping-post.mdx` — How to configure ping-post for your operation

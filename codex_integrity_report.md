# Codex Integrity Report

## Scope
I reviewed the full docs repo for internal consistency and cross-checked the highest-risk product claims against `../juiced-tickets`, focusing on routes, Filament resources, enums, config, tests, and internal panel docs.

## Summary
- Structural issues found: 3
- Product-behavior mismatches found: 5
- Status: report updated after follow-up review; one stale finding was removed because the file no longer exists

## Findings

### High

1. `features/integrations.mdx` links to a non-existent public page.
   Docs: [features/integrations.mdx](/Users/nolan/Sites/Juiced/docs/features/integrations.mdx:18)
   The page links Twilio notifications to `/features/workflows`, but this repo has no `features/workflows.mdx`, and `docs.json` exposes no such page.
   Suggestion: replace the link with the actual public destination, likely `/features/webhooks` or `/features/notifications`, depending on intent.

2. `features/integrations.mdx` describes Real Estate API automation using the wrong distribution-stage model.
   Docs: [features/integrations.mdx](/Users/nolan/Sites/Juiced/docs/features/integrations.mdx:74)
   Code: [DistributionStageMethodEnum.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Enums/DistributionStageMethodEnum.php:17), [DistributionStageResource.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Filament/Tenant/Resources/DistributionStageResource.php:340)
   The docs say automatic enrichment uses an `ALTER_DATA` stage with a `real_estate_api` operation. The code defines `REAL_ESTATE_API` as its own stage method.
   Suggestion: rewrite this section to describe a dedicated `Real Estate API` distribution stage, not an `ALTER_DATA` operation.

### Medium

3. Customer webhook docs advertise unsupported HTTP methods.
   Docs: [customer-portal/notifications.mdx](/Users/nolan/Sites/Juiced/docs/customer-portal/notifications.mdx:27)
   Code: [ExchangeConfigurationForm.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Filament/Support/ExchangeConfigurationForm.php:136)
   The docs list `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`. The form only exposes `POST`, `PUT`, and `GET`.
   Suggestion: update the docs to match the actual selector options.

4. Customer billing docs promise a running balance that the UI does not display.
   Docs: [customer-portal/billing.mdx](/Users/nolan/Sites/Juiced/docs/customer-portal/billing.mdx:38)
   Code: [TransactionResource.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Filament/Customer/Resources/TransactionResource.php:73)
   The actual transactions table shows date, amount, event, and transaction ID, but no running balance column.
   Suggestion: remove “Running balance” from the transaction-list description and point readers to the persistent wallet-balance widget shown elsewhere in the customer panel.

5. Notification-template docs overstate channel availability.
   Docs: [features/notifications.mdx](/Users/nolan/Sites/Juiced/docs/features/notifications.mdx:10)
   Code: [NotificationTypeEnum.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Enums/NotificationTypeEnum.php:210)
   The docs say each notification can be delivered through email, SMS, and in-app. In code, some events are mail-only, including `Account Archived`, `Account Restored`, `Payment Failed`, and `Payment Successful`.
   Suggestion: change this section to say channel availability varies by event, and call out mail-only events.

6. Public API docs omit a live, deprecated endpoint.
   Docs: [api-reference/introduction.mdx](/Users/nolan/Sites/Juiced/docs/api-reference/introduction.mdx:65)
   Code: [api.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/routes/api.php:19), [MarketplaceController.php](/Users/nolan/Sites/Juiced/docs/../juiced-tickets/app/Http/Controllers/Api/MarketplaceController.php:11)
   The app still exposes `POST /api/marketplace`, forwarding to the leads endpoint while logging a deprecation warning. The public API docs list only `/ping` and `/leads`.
   Suggestion: either document `POST /marketplace` as deprecated for backward compatibility or remove the route from the app if it should no longer be supported.

### Low

7. `STRUCTURE.md` is stale and now contradicts the live docs set.
   Docs: [STRUCTURE.md](/Users/nolan/Sites/Juiced/docs/STRUCTURE.md:22)
   It still references non-existent pages like `features/reverse-auctions.mdx` and `features/workflows.mdx`, and it says “No guides written yet” despite live guide pages under `guides/`.
   Suggestion: either update `STRUCTURE.md` to match `docs.json` and the filesystem, or remove it if `docs.json` is now the canonical structure source.

8. The API endpoint MDX files do not follow the repo’s own frontmatter standard.
   Docs: [api-reference/endpoint/ping.mdx](/Users/nolan/Sites/Juiced/docs/api-reference/endpoint/ping.mdx:1), [api-reference/endpoint/leads.mdx](/Users/nolan/Sites/Juiced/docs/api-reference/endpoint/leads.mdx:1)
   `CLAUDE.md` requires both `title` and `description` on MDX pages, but these endpoint wrappers only declare `title` and `openapi`.
   Suggestion: add concise `description` frontmatter for consistency, even if Mintlify renders the body from OpenAPI.

## Notes
- I found no evidence that the plan/pricing table in `features/billing.mdx` is out of sync with `config/spark.php`; those values currently match.
- I also verified that public marketplace support, public marketplace visit tracking, and customer webhook test tooling described elsewhere in the docs are backed by code.
- `features/users-and-roles.mdx` no longer exists in the repo, so the earlier placeholder-page finding is no longer applicable.

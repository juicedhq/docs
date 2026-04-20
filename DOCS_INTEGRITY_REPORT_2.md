# Docs Integrity Report — Second Pass

**Date:** 2026-04-20
**Branch:** check-integrity
**Reviewer:** Claude (Opus 4.7)
**Source of truth:** `../juiced-tickets` (primary)
**Previous report:** [`DOCS_INTEGRITY_REPORT.md`](./DOCS_INTEGRITY_REPORT.md)

## Scope

Fresh end-to-end review of every `.mdx` page currently under `docs/`, the `docs.json` nav, and the `api-reference/openapi.json` spec — to confirm the first-pass fixes landed correctly and to surface anything missed or introduced since.

Total `.mdx` files reviewed: **46**.

## Severity legend

- 🟥 **Factual** — contradicts the codebase.
- 🟧 **Consistency** — doc-to-doc contradiction.
- 🟨 **Severe style / structural** — orphan page, broken reference, wrong section label, etc.
- 🟦 **Note** — observation; no action required.

---

## Headline findings

Three real issues surfaced that weren't caught in pass 1, plus a couple of minor ones. Everything else holds up against the current codebase.

### 🟥 1. Customer "Inactive" display status is narrower than the docs claim

Two pages claim customer-level cap or budget exhaustion causes the **Inactive** display status:

- **`features/customers.mdx:106`** — "Inactive | Funding, caps, or budget exhausted" (pre-existing — missed in pass 1).
- **`features/budgets-and-caps.mdx:69-74`** — the "Customer status impact" table maps Cap: Exhausted and Budget: Exhausted to **Inactive** (introduced this session).

Actual behavior — `app/Models/Customer.php::displayStatus()`:

```php
if ($this->operational_status === OperationalStatusEnum::ARCHIVED) return ARCHIVED;
if ($this->operational_status === OperationalStatusEnum::PAUSED)   return PAUSED;
if ($this->funding_status === FundingStatusEnum::EXHAUSTED)        return INACTIVE;
return ACTIVE;
```

Only **funding exhaustion** drives Inactive. `cap_status` and `budget_status` are stored on the customer but do **not** feed into `displayStatus`. Confirmed by the `displayInactive` scope in `Customer.php:336` which filters on `funding_status = EXHAUSTED` only.

**Recommended fix:** update both pages so "Inactive" is tied to funding exhaustion only. Note separately that cap and budget exhaustion make the customer's *bids* show as Capped / Exhausted without changing the customer's own display status.

### 🟥 2. Submissions are labeled "Posts" in the tenant nav

`features/submissions.mdx` (written this session) says:

> Submissions live under **Entries → Submissions** in the tenant panel.

The resource file actually sets:

```php
protected static ?string $navigationLabel = 'Posts';
protected static ?string $pluralLabel = 'Posts';
protected static ?string $label = 'Post';
```

So the nav entry is **Entries → Posts**, not **Entries → Submissions**. This is doubly confusing because "Post" already means the follow-up request in ping-post terminology.

**Recommended fix:** either (a) update the doc to say "Entries → Posts (submissions)" and explain the terminology overlap, or (b) change the Filament label to "Submissions" if that's the preferred user-facing term. A doc-only fix is safer.

### 🟨 3. Orphan Lorem ipsum stub still present

`features/users-and-roles.mdx` exists on disk, is a Lorem ipsum placeholder, and is **not** referenced in `docs.json`. It's distinct from `features/users.mdx` and `features/roles.mdx` (both in nav, both written).

Likely a leftover from an earlier consolidation attempt. Nothing links to it.

**Recommended fix:** delete the file.

### 🟨 4. Marketplace-enabled-by-default wording in quickstart

`get-started/quickstart.mdx` Step 7:

> If you've turned on the marketplace, a Marketplace stage is added automatically as a fallback.

`TenantSettings.enable_marketplace` default was changed from `false` to `true` in migration `2025_11_06_225623_update_tenant_settings_defaults.php`. So for any tenant created after that migration, marketplace is **on** by default — and therefore the Marketplace stage is seeded automatically.

**Recommended fix:** reword to "New tenants have the marketplace enabled by default, so your plan ships with both a Bidding stage and a Marketplace fallback out of the box. If you disable the marketplace, new tenants will only get the Bidding stage."

### 🟦 5. Distribution stages nav placement isn't explicit

`features/distribution.mdx` tells readers to find **Stages → New stage**, but `DistributionStageResource.php` doesn't set an explicit `navigationGroup` — so the resource lands wherever Filament defaults place ungrouped resources. Not a factual error, just worth confirming the label and position once in the running UI (the distribution **Logs** resource IS explicitly in the **Entries** group, so that half is fine).

---

## Per-page findings

Organized by section. Pages not listed had no findings.

### Root

- **`index.mdx`** — Landing links all resolve. ✓

### Get Started

- **`get-started/quickstart.mdx`** — Rewritten this session into an 11-step walkthrough. Covers account → subscription → Stripe → lead category → lead types → bidding settings → distribution plan → customer + wallet → bid → source → test lead. Internal links all resolve. One finding above (#4 — marketplace-on-by-default wording).

### Features: Ingesting & Classifying

- **`features/leads.mdx`** — Status table is now complete (Processing added in pass 1). Reprocessing reasoning and bulk actions match the `LeadResource` code. ✓
- **`features/lead-categories.mdx`** — Field types, ten default fields, `required_for_post/ping/deliverable/hidden_from_api_spec` casts all match. ✓
- **`features/lead-types.mdx`** — Operator table expanded with date-field aliases and set operators; labels match `ConditionOperatorEnum::getLabel()`. ✓
- **`features/sources.mdx`** — No new findings. Test-mode zip table and pricing types still accurate.

### Features: Selling Leads

- **`features/ping-post.mdx`** — No new findings.
- **`features/bidding.mdx`** — Display-status table is now complete. Underlying statuses (Operational / Funding / Cap / Budget) all match their enums.
- **`features/distribution.mdx`** (new this session) — Stage methods, attempt statuses, and timeline events all match enums. One finding (#5 — navigation group note).
- **`features/marketplace.mdx`** — New subsections added this session (floor movement with buy orders, auction lifecycle, 90-day pruning, import-created reverse auctions). `ReverseAuction::floor`/`true_ends_at` behavior, `prunable()` 90-day cutoff, and `LeadImporter`'s use of `ReverseAuctionService` all confirmed. ✓

### Features: People

- **`features/customers.mdx`** — See **headline finding #1**. Display-status mapping claim is wrong. Everything else (auto-recharge, return tiers, contacts, webhooks) matches the model.
- **`features/partners.mdx`** — No new findings.

### Features: Money & Limits

- **`features/budgets-and-caps.mdx`** (new this session) — See **headline finding #1**. Otherwise accurate. The claim about weekly reset on Monday 00:00 UTC is consistent with Carbon's Laravel default and the app has no timezone override.
- **`features/transactions.mdx`** (new this session) — All nine `TransactionEventEnum` values match. Hold-vs-charge distinction for buy orders is accurate. ✓
- **`features/payments-and-deposits.mdx`** — File renamed in pass 1; title and nav now align.

### Features: Quality & Validation

- **`features/duplicate-detection.mdx`** — "Fields" plural + composite-match explanation landed. ✓
- **`features/submissions.mdx`** (new this session) — See **headline finding #2** (nav label is "Posts"). Status enum, data/validation_errors storage, is_test flag all match. Relationship to source and lead is correct.
- **`features/audits.mdx`** — Broken anchor fix from pass 1 still holds (`#reprocessing-leads` resolves). ✓
- **`features/returns.mdx`** — No new findings. Dispute/Return terminology gap is known and accepted.

### Features: Events & Messaging

- **`features/notifications.mdx`** — Event labels corrected in pass 1 (Return Approved, Account Paused, etc.). ✓
- **`features/webhooks.mdx`** — `County Lead Type Stats Updated` removed in pass 1. Event list matches `Workflow::$supportedEvents`. ✓

### Features: Observability

- **`features/location-analytics.mdx`** — No new findings.

### Features: Account Management

- **`features/company-profile.mdx`** — No new findings.
- **`features/branding.mdx`** — No new findings.
- **`features/billing.mdx`** — All ten Spark plans match config (verified pass 1). ✓
- **`features/domains.mdx`** — Added to nav in pass 1. Reserved subdomain list accurate as a partial. ✓
- **`features/integrations.mdx`** — No new findings. All six integrations match `IntegrationTypeEnum`.
- **`features/users.mdx`** — No new findings. Four tenant roles match.
- **`features/roles.mdx`** — No new findings. Permission tables match the role enum.
- **`features/users-and-roles.mdx`** — See **headline finding #3**. Orphan Lorem ipsum stub; delete.

### Guides

- **`guides/index.mdx`** — "Campaigns" reference replaced in pass 1. ✓
- **`guides/adding-fields-to-a-lead-category.mdx`** — Defaults, four toggles, and permission naming match the model.
- **`guides/setting-up-a-source-and-its-attributes.mdx`** — Source creation flow, Distribution Stages conditional on the Pricing tab, and status-response default mapping all accurate.

### Customer Portal

- **`customer-portal/index.mdx`** — Bidding link fix from pass 1 holds. Terminology swap (dispute tiers → return tiers) landed. Dashboard row retained per user decision.
- **`customer-portal/leads.mdx`** — No new findings.
- **`customer-portal/bids.mdx`** — No new findings. Smart-pricing claim is consistent with `OfferService::adjustTopOfferToLowestPossibleStep`.
- **`customer-portal/marketplace.mdx`** — No new findings. Floor color coding consistent with feature page.
- **`customer-portal/notifications.mdx`** — HTTP methods match `ExchangeConfiguration::ALLOWED_HTTP_METHODS`. ✓
- **`customer-portal/billing.mdx`** — No new findings.
- **`customer-portal/bidding-limits.mdx`** — No new findings.
- **`customer-portal/company-profile.mdx`** — No new findings.

### API Reference

- **`api-reference/introduction.mdx`** — `X-Partner-Id` documented (added pass 1). ✓
- **`api-reference/endpoint/ping.mdx`** — OpenAPI-backed; spec includes the new `PartnerIdHeader` parameter. ✓
- **`api-reference/endpoint/leads.mdx`** — Same. ✓
- **`api-reference/openapi.json`** — `components.parameters.PartnerIdHeader` defined; both endpoints reference it. ✓

### Changelog

- **`changelog/index.mdx`** — Intentionally empty per user decision. ✓

---

## `docs.json` consistency

Walked every `pages` entry in `docs.json` and confirmed each resolves to a file that exists. No orphaned references. The only `.mdx` file on disk **not** referenced by `docs.json` is `features/users-and-roles.mdx` (see headline finding #3).

## Cross-page links

Sampled internal links across the rewritten pages and the new content. Verified targets for:

- `features/distribution.mdx` → `/features/integrations#real-estate-api`, `/features/submissions`, `/features/leads#reprocessing-leads`, `/features/billing#what-happens-at-100` — all resolve.
- `features/budgets-and-caps.mdx` → `/features/marketplace`, `/features/bidding#bid-statuses` — all resolve.
- `features/marketplace.mdx` → `/features/leads#importing-leads` — resolves.
- `get-started/quickstart.mdx` → links to 20 different feature/guide pages; all resolve.

No broken links detected.

---

## Summary

**New actionable items — all resolved:**

1. ✅ **Customer "Inactive" display-status** — `features/customers.mdx` now ties Inactive to wallet funding only, with an added note explaining that cap/budget exhaustion surfaces on bids rather than the customer. `features/budgets-and-caps.mdx`'s "Customer status impact" section rewritten to state that caps and budgets do not change customer display status.

   Re-verified before fixing: `Customer::calculateFundingStatus` (`CustomerService.php:177`) rolls up its bids' funding statuses; bid funding (`BidService.php:336`) only looks at wallet balance vs. bid amount. Caps and budgets are not inputs—directly or indirectly.

2. ✅ **Submissions nav label** — `features/submissions.mdx` now points readers to **Entries → Posts** and calls out the terminology overlap with ping-post's "post".

3. ✅ **Orphan stub deleted** — `features/users-and-roles.mdx` removed.

4. ✅ **Marketplace-on-by-default wording** — `get-started/quickstart.mdx` Step 7 updated to say the default distribution plan ships with both a Bidding stage and a Marketplace fallback, since `enable_marketplace` defaults to `true` for new tenants.

**Noted, not acting on:**

- 🟦 `DistributionStageResource` has no explicit `navigationGroup`; the doc's "Stages → New stage" reference depends on whatever Filament's default placement is. User will verify in the running UI.

**Pass-1 fixes verified still correct.** No further issues surfaced against the current codebase.

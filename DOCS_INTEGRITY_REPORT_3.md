# Docs Integrity Report — Third Pass

**Date:** 2026-04-20
**Branch:** check-integrity
**Reviewer:** Claude (Opus 4.7)
**Source of truth:** `../juiced-tickets` (primary)
**Previous reports:** [`DOCS_INTEGRITY_REPORT.md`](./DOCS_INTEGRITY_REPORT.md), [`DOCS_INTEGRITY_REPORT_2.md`](./DOCS_INTEGRITY_REPORT_2.md)

## Scope

Third end-to-end pass. This round deliberately drills into claims I accepted as "plausible, not directly verified" in earlier passes — Filament form options, labels that end users actually see, and behaviors gated by config I didn't open.

Total `.mdx` files reviewed: **45** (one less than pass 2 after deleting the orphan).

## Severity legend

- 🟥 **Factual** — contradicts the codebase.
- 🟧 **Consistency** — doc-to-doc contradiction.
- 🟨 **Severe style / structural** — wrong label, misleading wording, etc.
- 🟦 **Note** — observation; no action required.

---

## Headline findings

Three new issues surfaced — one factual and two label mismatches. Everything else held up.

### 🟥 1. Customer webhook HTTP methods — doc lists 5, UI offers 3

`customer-portal/notifications.mdx`:

> 3. Choose your HTTP method (GET, POST, PUT, PATCH, or DELETE)

Actual form options in `app/Filament/Support/ExchangeConfigurationForm.php:136-145`:

```php
Select::make('request_method')
    ->label('Method')
    ->options([
        'post' => 'POST',
        'put'  => 'PUT',
        'get'  => 'GET',
    ])
    ->default('post')
```

Only **POST / PUT / GET** are selectable in the UI. The server-side constant `ExchangeConfiguration::ALLOWED_HTTP_METHODS` does include `patch` and `delete`, but the form never exposes them — so customers can't pick those two options. My pass-1 verification looked at the constant, not the form.

Same shared form is used by the tenant-side webhook relation manager, so if `features/webhooks.mdx` ever grows to mention methods, the same list should apply.

**Recommended fix:** update the doc to "POST, PUT, or GET" (in that order to match the select defaulting to POST).

### 🟨 2. Distribution stages nav label is "Distribution Stages", not "Stages"

`features/distribution.mdx` refers to the sidebar entry as **Stages**:

> If the **Stages** and **Logs** entries don't appear in your tenant navigation…
> …add stages from **Stages → New stage**.

`DistributionStageResource.php` sets no explicit `modelLabel`, `pluralModelLabel`, or `navigationLabel`, so Filament defaults to **Distribution Stage** / **Distribution Stages** (derived from the class name). There's also no explicit `navigationGroup`, so it doesn't live under "Entries" with Logs.

`DistributionFlowResource.php` *does* set `navigationLabel = 'Logs'` and `navigationGroup = 'Entries'`, so the "Logs" half of the doc is correct.

**Recommended fix:** change "Stages" → "Distribution Stages" throughout the doc, and either (a) don't imply the two entries are near each other, or (b) set an explicit `navigationGroup` on `DistributionStageResource` so they sit together (code change, out of scope for docs).

### 🟨 3. Bidding settings — doc uses "Increment", UI shows "Step"

`features/lead-types.mdx` bidding-scope settings table:

| Setting | Description |
|---------|-------------|
| **Increment** | The amount by which bids increase … |

The Filament form in `ManageBiddingSettings.php:74` creates the field as `MoneyInput::make('step')` with no `->label()` override, so Filament's auto-humanized label is **Step**. The `features/bidding.mdx` page also uses "Bid increments" / "increment" throughout (correct as a user-facing *concept*), so the naming isn't consistent across docs either.

Additionally, the doc labels the minimum bid as "Minimum bid" while the form uses the callback `fn (Get $get): string => $get('is_fixed_price') ? 'Price' : 'Minimum'` — UI label is **Minimum** (or **Price** in fixed-price mode), no "bid" suffix. Minor.

**Recommended fix:** either rename the form field's label to "Increment" (code change, one line) or update the doc to say "Step". If keeping the conceptual "increment" language in prose, at minimum clarify that the UI field is labeled "Step".

---

## Additional verifications performed this pass

Claims I flagged in earlier reports as plausible-but-not-verified are now **confirmed**:

| Claim | Verified against |
|-------|------------------|
| API spec share link expires in 7 days | `ViewSource.php:36`, `EditSource.php:24` — `now()->addDays(7)` |
| Bearer token 24h expiry when rotated | `ManageSourceAuthentication.php:65` — `now()->addDay()` |
| Field title regex `^[a-zA-Z_][a-zA-Z0-9_-]*$` | `FieldsRelationManager.php:40`, `ManageSourceFields.php:51` — identical rules |
| "Default fields can't be removed" | `FieldsRelationManager.php` hides the delete action when `title_lock = true` |
| Default customer webhook payload shape | `WebhookTemplateService.php:386-396` matches `customer-portal/notifications.mdx` exactly |
| `customer.leads_count` is a real variable for batch notifications | `NotificationTemplateService.php:143` |
| Webhook format locked to JSON | `ExchangeConfigurationForm.php:237-245` — select disabled, only `json` option |
| `DistributionStageResource` properly gated when flag inactive | `DistributionStagePolicy.php:26` — policy's `before()` returns false for non-super users when the Pennant flag is off |
| Notifications pass-1 fixes (Return/Account labels, six email-only events) | Confirmed against `NotificationTypeEnum::getConfig()` — `channels` arrays for CUSTOMER_ARCHIVED, CUSTOMER_RESTORED, PAYMENT_FAILED, PAYMENT_SUCCESSFUL each contain only `['mail']` (the user-added email-only caveat is correct) |
| Audit condition form fields (Name, Description, Lead category) | `AuditConditionResource.php` — matches doc exactly |

## Second-pass fixes — confirmed landed

- ✓ `features/customers.mdx` display-status mapping updated to funding-only + note about caps/budgets surfacing on bids.
- ✓ `features/budgets-and-caps.mdx` "Customer status impact" section rewritten correctly.
- ✓ `features/submissions.mdx` now points to "Entries → Posts" and explains the ping-post terminology overlap.
- ✓ `features/users-and-roles.mdx` gone from disk and not referenced anywhere.
- ✓ `get-started/quickstart.mdx` Step 7 reworded to reflect marketplace-on-by-default.

## `docs.json` and link integrity

- Every `pages` entry resolves to an existing file. ✓
- No `.mdx` files on disk are unreferenced by `docs.json`. ✓ (The previous orphan `features/users-and-roles.mdx` is gone.)
- Re-sampled internal links from pages touched most recently (`features/customers.mdx`, `features/budgets-and-caps.mdx`, `features/submissions.mdx`, `get-started/quickstart.mdx`) — all anchors still resolve.

---

## Summary

**New actionable items — all resolved:**

1. ✅ **`customer-portal/notifications.mdx`** — no change needed. Current file already reads "(GET, POST, or PUT)" matching the form. My pass-3 report incorrectly quoted an older version of the line; the doc itself was already correct at the time of this pass.

2. ✅ **`features/distribution.mdx`** — feature-flag note updated so the nav reference reads "**Distribution Stages** resource and the **Logs** entry" instead of grouping them together as "Stages and Logs". Also updated `get-started/quickstart.mdx` Step 7 from "Stages → New stage" to "Distribution Stages → New stage".

3. ✅ **`features/lead-types.mdx`** — Bidding-settings table rewritten to match the actual UI labels: **Scope**, **Enabled**, **Fixed Price**, **Minimum** (relabels to **Price** when Fixed Price is on), **Maximum**, **Step**. Conceptual "increment" language in `features/bidding.mdx` and `customer-portal/bids.mdx` was left alone since those are prose/examples rather than UI-label references.

**No other issues surfaced.** Pass-1 and pass-2 fixes all hold up. The new pages written this session (distribution, budgets-and-caps, transactions, submissions), the marketplace additions, and the rewritten quickstart remain factually accurate.

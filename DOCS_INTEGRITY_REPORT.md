# Docs Integrity Report

**Date:** 2026-04-20
**Branch:** check-integrity
**Reviewer:** Claude (Opus 4.7)
**Source of truth:** `../juiced-tickets` (primary), supporting repos where relevant
**Last updated:** 2026-04-20 (mechanical fixes applied; see Status section below)

## Status

### ✅ Completed fixes

- **Added `Processing` status** to the lead-status table (`features/leads.mdx`).
- **Filled in missing bid display statuses** (`Under Funded`, `Not Funded`, `Capped`) and reframed the "Limited/Exhausted" explanation to match the enum (`features/bidding.mdx`).
- **Swapped notification labels** to match UI (`Account Paused/Unpaused/Archived/Restored`, `Return Approved`, `Return Tier Updated`) and updated the lead-event list and tier-variable example (`features/notifications.mdx`).
- **Removed the non-existent `County Lead Type Stats Updated` webhook event** (`features/webhooks.mdx`).
- **Fixed broken anchor** `/features/leads#processing-leads` → `#reprocessing-leads` (`features/audits.mdx`).
- **Fixed broken link** `/customer-portal/bidding` → `/customer-portal/bids` (`customer-portal/index.mdx`).
- **Removed "Campaigns" and "Buyers" terminology** from `features/index.mdx` and `guides/index.mdx`.
- **Expanded operator reference** in `features/lead-types.mdx` — added date-field aliases (Before/After/On), missing operators (Less than or equal, Greater than or equal, Any, All, None), and aligned labels with the UI ("Does not equal" / "Does not contain").
- **Duplicate-detection copy** now says "Fields" (plural) and explains composite matching (`features/duplicate-detection.mdx`).
- **Zip field description** in `features/lead-categories.mdx` corrected to note US/CA/AU postal code support.
- **Added `X-Partner-Id` header documentation** in the API intro + added it as an optional parameter on both endpoints in `api-reference/openapi.json`.
- **Added `features/domains` to `docs.json`** under Account Management (no longer an orphan).
- **Aligned terminology in customer-portal index** — "dispute tiers" → "return tiers".
- **Renamed `features/payment-methods.mdx` → `features/payments-and-deposits.mdx`** (filename now matches the frontmatter title); updated `docs.json`, `AGENTS.md`, and `STRUCTURE.md`.
- **Deleted 12 orphaned Mintlify template pages**: root `quickstart.mdx`, `development.mdx`, all six `essentials/*.mdx`, all three `ai-tools/*.mdx`, and `snippets/snippet-intro.mdx`. Empty directories also removed.

### ✅ Verified (no change needed)

These were previously flagged as unverified. Code confirmation completed:

- **Smart pricing** ("one increment above the next highest bidder") — confirmed in `app/Services/OfferService.php::adjustTopOfferToLowestPossibleStep()`.
- **Cap reset timezone (UTC)** — confirmed; `config/app.php` has no timezone override, so Laravel's default UTC applies to `now()`, `startOfDay`, `startOfWeek`, `startOfMonth`.
- **Bearer token 24-hour expiry** — confirmed in `app/Filament/Tenant/Resources/SourceResource/Pages/ManageSourceAuthentication.php` (sets `expires_at` to `now()->addDay()` on rotation).
- **Webhook retry (3× with brief delay, 5xx / connection errors)** — confirmed in `app/Models/ExchangeConfiguration.php::send()` (`->retry(3, 100, …)`).
- **"Distribution Stages" feature flag** — confirmed active and gating the Source *Pricing* sub-navigation in `app/Filament/Tenant/Resources/SourceResource.php`. The guide's conditional phrasing is correct.
- **"No subscription means no selling"** — accepted as correct. Registration forces plan selection; pipeline-level enforcement is the intended behavior even where runtime gating is loose.

### ✅ Six Lorem ipsum stubs — resolved

- ✅ **`features/reverse-auctions.mdx`** — deleted and removed from `docs.json`. The mechanics unique to the reverse-auction entity (how the floor moves with buy orders, the auction lifecycle, 90-day pruning, and import-created reverse auctions) were folded into `features/marketplace.mdx` as a new "How reverse auctions work" expansion.
- ✅ **`features/distribution.mdx`** — written. Covers stages (all five methods, terminal vs. passthrough), stage settings, distribution attempts (six statuses), and the Logs timeline (all 19 events from `DistributionFlowTimelineEnum`). Leads with the Distribution Stages feature-flag caveat.
- ✅ **`features/budgets-and-caps.mdx`** — written. Covers the customer/bid × cap/budget × daily/weekly/monthly matrix, simultaneous evaluation, UTC resets, what counts (bidding only, not marketplace or returns), and how exhaustion propagates into bid and customer display statuses.
- ✅ **`features/transactions.mdx`** — written. Covers all nine `TransactionEventEnum` values, the hold-vs-charge distinction for buy orders, and tenant adjustment mechanics.
- ✅ **`features/submissions.mdx`** — written. Describes submissions as the raw pre-processing payload, the three statuses, the data/validation_errors storage, and where to find them in the tenant panel.
- ✅ **`features/workflows.mdx`** — deleted and removed from `docs.json`. Workflows are an internal model with two action types that surface as Webhooks (`features/webhooks.mdx`) and partner ping-post (`features/ping-post.mdx`) — no separate user-facing Workflows page.

### ✅ `get-started/quickstart.mdx` rewrite — completed

Replaced the thin four-step narrative with a comprehensive 11-step walkthrough that covers everything actually required to go from a blank tenant to a working lead pipeline:

1. Create your account
2. Pick a subscription
3. Connect Stripe
4. Create your first lead category
5. Define lead types (and conditions)
6. Configure bidding settings
7. Review the default distribution plan (auto-seeded: "Bidding" stage, plus "Marketplace" if enabled)
8. Create a customer and fund their wallet
9. Place at least one bid
10. Set up a source
11. Send a test lead

Each step links out to the relevant feature or guide page for depth. Opens with a "What you're building" summary so readers see the full shape before starting, and ends with next-step links (custom fields, duplicate detection, notifications/webhooks, users/roles, branding).

### 🟡 Tabled / deferred

- Changelog remains intentionally empty (you said you'll use it soon).

### ✅ Resolved

- **`customer-portal/index.mdx` "Dashboard" row** — left as-is per your call; accurate as a reference to the landing view customers see when they log in at `/app`.
- **`get-started/quickstart.mdx` rewrite** — completed. See the rewrite note below.

---

## Scope

Exhaustive review of every `.mdx` page under `docs/` to verify:
1. **Factual accuracy** against the live codebase (models, routes, controllers, Livewire components, Filament resources, enums).
2. **Cross-page consistency** (terminology, capitalization, concept definitions).
3. **Severe stylistic issues** only (broken structure, wrong section per the noun/verb litmus test, missing frontmatter, broken links).

Minor stylistic preferences are out of scope.

## Severity legend

- 🟥 **Factual** — doc contradicts the codebase or states something incorrect/misleading.
- 🟧 **Consistency** — conflicting statements across doc pages.
- 🟨 **Severe style/structure** — wrong section, missing frontmatter, broken reference, etc.
- 🟦 **Note** — observation worth flagging but not an error.

---

## Per-page findings

### `index.mdx`

- 🟦 Landing page. All links resolve (`/get-started/quickstart`, `/features`, `/features/leads`, `/features/bidding`, `/features/marketplace`, `/customer-portal`, `/api-reference/introduction`). No factual claims about product behavior to verify. OK.

### `quickstart.mdx` (root, Mintlify template)

- 🟨 **Orphan page.** Not referenced in `docs.json` navigation. Contents are generic Mintlify starter text (not Juiced-specific). Recommend deleting — it's superseded by `get-started/quickstart.mdx`. Risk: it still ships in the built site at `/quickstart` and can be reached via search or external links, presenting Mintlify boilerplate to users.

### `development.mdx` (Mintlify template)

- 🟨 **Orphan page.** Not in `docs.json`. Generic Mintlify CLI docs for contributors editing docs. Not intended for end users. If kept, it should live under a separate "Contributing" section, or be removed. Also note: line 54 has `npm mint update` which is incorrect — should be `npm i -g mint@latest` (Mintlify's own docs command). Current command as written won't work.

### `get-started/quickstart.mdx`

Verified against `juiced-tickets/resources/views/auth/register.blade.php`, `app/Actions/Fortify/CreateNewUser.php`, `app/Http/Middleware/CustomOnboarding.php`, `app/Http/Middleware/SetTenantOnboarding.php`, `app/Models/ConnectedAccount.php`.

- 🟥 **Registration is a single form, not multi-step.** The doc implies you "pick a subdomain" on the first form and then complete country/etc separately. The actual registration form (`register.blade.php`) collects everything at once: name, email, phone, password, company name/email/phone, full billing address, country (US/CA/AU), state, postal code, AND subdomain — all on one page.

- 🟥 **"Select your country" is not a separate step.** Country is a required field inside the initial registration form. The current doc presents it as its own post-signup step, which is wrong.

- 🟥 **"Connect Stripe" framing is misleading.**
  - The doc says "Juiced uses Stripe to handle payouts." In this platform, Stripe Connect is how tenants **charge their buyers/customers**. Stripe also pays the tenant out, but the primary purpose is collecting funds from customers, not "payouts from Juiced." (`ConnectedAccount` tracks `charges_enabled`, `payouts_enabled`, `details_submitted`.)
  - Whether this is a guided step during onboarding requires confirmation. Grep shows no required Stripe-connect middleware gate. Onboarding is gated by `is_onboarded` which is either auto-set or set by watching an optional onboarding video (`SetTenantOnboarding`/`CustomOnboarding`). Recommend either: remove this section, or rephrase to "Connect Stripe so you can charge your customers" and clarify when in the flow it happens.

- 🟥 **Subscription-before-selling claim needs verification.** Doc says "No subscription means no selling." Grep for `RequireSubscription`/`EnsureTenantHasSubscription` middleware returns no results. The register blade page says "You'll select your subscription in the next step" — confirming subscription selection happens post-registration — but no code in `app/Http/Middleware/` actively blocks selling if no subscription exists. **Question for you:** is the "no subscription = no selling" enforcement handled elsewhere (Pennant, feature flag, Filament policy)? Without confirmation this assertion is unsubstantiated in docs.

- 🟨 **"You're in — ready to set up your first campaign."** The term "campaign" is not used in the codebase (no `Campaign` model; I see `Source`, `LeadCategory`, `LeadType`, `Bid`, `DistributionPlan`, etc.). Suggest replacing "campaign" with the actual concept (source/lead category/bid). This is a terminology drift that will confuse new users.

- 🟨 Same "campaign" issue in the "From here, you might want to: Set up your first campaign" list.

### `development.mdx` additional

Already noted above.

---

### `features/index.mdx`

- 🟥 **Wrong terminology.** Line 8: "organized everything by the nouns you'll encounter: **Campaigns, Buyers, Leads, Webhooks**". The codebase has **no** `Campaign` model or concept, and "Buyers" isn't the standard term (`Customer` is used throughout code, models, and the rest of the docs). Replace with representative nouns that actually match the nav (Leads, Lead Categories, Sources, Customers, Bidding, Webhooks, etc.).

### `features/leads.mdx`

Verified against `app/Enums/LeadStatusEnum.php`, `app/Policies/LeadPolicy.php`, `app/Policies/BasePolicy.php`, `app/Filament/Tenant/Resources/LeadResource.php`, `app/Models/Lead.php`.

- 🟥 **Missing status: `Processing`.** The lead status table does not include the `PROCESSING` state (enum label "Processing"), which exists in `LeadStatusEnum`. All other statuses match.
- 🟦 The "sold" definition (Assigned, Posted, or Returned) maps correctly to `Lead::isAssigned()` which returns true for ASSIGNED, POSTED, DISPUTED. (DISPUTED renders as "Returned.") OK.
- 🟦 Reprocessable statuses match `LeadStatusEnum::reprocessableStatuses()`: Unassigned, Uncategorized, Pending, Distribution Error. ✓
- 🟦 Bulk-reprocess start options (Bidding / Trigger Ping/Post / Marketplace / Trigger Post Marketplace Direct Post) match the Filament select options exactly. ✓
- 🟦 `leads.reprocess` permission string matches the `BasePolicy::getPermission()` formula (`class_basename` → kebab → plural → `.{action}`). ✓ The claim "By default, only Admin users have this permission" was not verified against seeders — flag for manual confirmation.

### `features/lead-categories.mdx`

Verified against `app/Models/Lead.php::$defaultFields`, `app/Models/LeadCategory.php`, `app/Enums/FieldTypeEnum.php`.

- 🟦 Basic fields (First name, Last name, Email, Phone, Address 1, Address 2, City, State, ZIP, County) match `Lead::$defaultFields` exactly. ✓
- 🟨 **Label mismatches vs `FieldTypeEnum::getLabel()`:**
  - Doc row `zip` label = "Postal Codes"; code label = "Postal Codes" ✓. But doc "Format" column says "4-5 digit US ZIP code". US ZIPs are 5 digits. The `zip` field type only accepts US/CA/AU postal codes validated at the `ZipCode` rule level. Wording is misleading — either say "5-digit US ZIP" or clarify that it also accepts Canadian/Australian postal codes (which it does, since the system supports those countries).
  - Date types: doc shows "Date (YYYY-MM-DD)" — code label is "Dates (YYYY-MM-DD)" (plural). Trivial, but inconsistent.
  - Date & time types: doc shows "DateTime (...)" — code label is "Date & Time (...)". Noticeable surface inconsistency — fix one or the other.
- 🟦 Custom field property list (Title, Type, Description, Required for post, Required for ping, Deliverable) matches `Field` model casts. ✓
- 🟨 Doc calls the field identifier "Title" with a pattern "Must start with a letter or underscore and can only contain letters, numbers, underscores, and dashes." The enum/field pattern isn't verified in this pass — worth checking against the `FieldResource` form validation to confirm the pattern is accurate.

### `features/lead-types.mdx`

Verified against `app/Enums/ConditionOperatorEnum.php`, `app/Enums/BiddingScopeEnum.php`.

- 🟨 **Operator label drift:**
  - Doc says "Not equals"; code label is "Does not equal".
  - Doc says "Not contains"; code label is "Does not contain".
  - Minor, but users searching the UI for "Not equals" won't find it — recommend aligning docs to the UI label.
- 🟨 **Missing operators from doc table:** `Less than or equal`, `Greater than or equal`, and the set operators `None` / `Any` / `All` (used on list-of-values fields) are not documented. Doc hedges with "Here are some common operators" — still worth completing.
- 🟨 **Date-type aliases not documented.** Code swaps labels for date fields: LESS_THAN → "Before", GREATER_THAN → "After", EQUALS → "On". Doc only lists "Less than"/"Greater than"/"Between" — users will see "Before"/"After"/"On" in the UI on date fields, which will confuse anyone reading the docs.
- 🟦 Bidding scope options (County / State / Nationwide) match `BiddingScopeEnum`. ✓
- 🟦 Bidding-scope settings table (Geographic level, Fixed Price, Minimum bid, Maximum bid, Increment, Enabled) not directly verified against the Filament form in this pass — flag for a pass during Selling-Leads review.

### `features/sources.mdx`

Verified against `app/Enums/SourceTypeEnum.php`, `app/Enums/PricingTypeEnum.php`, `app/Services/TestModeService.php`.

- 🟦 Internal vs Vendor enum values match. ✓
- 🟦 Test-mode zip table (`00001`–`00005`, ping response / lead status) matches `TestModeService::TEST_ZIPS` exactly. ✓
- 🟦 Pricing types (Fixed, Fallback) match `PricingTypeEnum`. ✓
- 🟦 Payout percentage wording and test-mode behavior look correct.
- 🟨 Doc says "an API key and API secret are automatically generated for basic authentication. You can also use a bearer token if you prefer." Not verified against the source auth code — worth confirming both auth mechanisms are actually supported.

---

### `features/ping-post.mdx`

- 🟦 Request mapping with `{{ field }}` and `{{ response.* }}` syntax and ping-response namespace reasoning: plausibly correct (not verified at template engine level in this pass).
- 🟦 Offer penalty percentage — `offer_penalty_percentage` exists on Partner (grep confirms). The snapshotting claim ("snapshotted on each offer") — plausible based on Offer model existing; flag for a deeper pass during People features review.

### `features/bidding.mdx`

Verified against `app/Enums/BidDisplayStatusEnum.php`, `app/Enums/BidPositionEnum.php`, `app/Enums/OperationalStatusEnum.php`, `app/Enums/FundingStatusEnum.php`, `app/Enums/CapStatusEnum.php`, `app/Enums/BudgetStatusEnum.php`.

- 🟥 **Display-status table is incomplete.** Doc lists only Active, Paused, Limited, Exhausted, Archived. `BidDisplayStatusEnum` also includes:
  - `UNDER_FUNDED` → "Under Funded"
  - `NOT_FUNDED` → "Not Funded"
  - `CAPPED` → "Capped"
  These three are real, user-visible display values. Missing them will cause confusion when users see them in the UI and can't find them in docs.
- 🟦 Underlying statuses and values match: Operational (Active/Paused/Archived) ✓, Funding (Available/Limited/Exhausted) ✓, Cap (Unlimited/Available/Exhausted) ✓, Budget (Unlimited/Available/Limited/Exhausted) ✓.
- 🟦 Bid positions (Top/Tied/Under/Out) match `BidPositionEnum`. ✓
- 🟨 Doc says "Pausing a bid is different from pausing a customer" — plausible, and consistent with the separate Operational enum used on both. OK.
- 🟨 Smart pricing claim ("one increment above the next highest bidder") not directly verified against bid-resolution code — flag for confirmation.
- 🟨 "Limits reset on the calendar day, week, or month in UTC timezone" — not verified against the cap-reset logic; flag for confirmation.

### `features/reverse-auctions.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** Only the frontmatter (title + description) is meaningful. The entire concept of reverse auctions (including price decay, buy orders, floor logic) is real in the codebase (`app/Models/ReverseAuction.php` + `BuyOrder` + `OfferSource` enum) but is currently only documented under `features/marketplace.mdx`. Either:
  1. Write a reverse-auctions page that defines the mechanism and cross-links from marketplace, **or**
  2. Delete the page and remove it from `docs.json` navigation.

### `features/distribution.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** `DistributionPlan`, `DistributionStage`, `DistributionFlow`, `DistributionAttempt` are all core models — this is a significant page. Recommend filling in content covering distribution plans, stages (bidding/ping-post/marketplace/direct post), the lifecycle engine, and timeline statuses (`DistributionFlowTimelineEnum`).

### `features/marketplace.mdx`

- 🟦 Settings → Marketplace toggle, direct-post-on-expiry, public marketplace, per-lead-type enabling: plausible and match the direction of the models (`PublicMarketplaceVisit`, `BuyOrder`, `ReverseAuction`). Not deeply verified against the Filament settings page source in this pass.
- 🟦 Buy-order mechanics (hold wallet funds, leading/losing floor colors Gray/Blue/Green/Red) — plausible; not verified against the UI component in this pass. Flag for follow-up if precision matters.
- 🟨 Cross-page overlap with `features/reverse-auctions.mdx`: the reverse-auction mechanism is described here, but the dedicated page is empty (see above).

---

### `features/customers.mdx`

Verified against `app/Enums/CustomerDisplayStatusEnum.php`, `app/Enums/OperationalStatusEnum.php`, `app/Enums/FundingStatusEnum.php`, `app/Enums/CapStatusEnum.php`, `app/Enums/BudgetStatusEnum.php`.

- 🟦 Display statuses (Active / Paused / Inactive / Archived) match `CustomerDisplayStatusEnum`. ✓
- 🟦 Operational / Funding / Cap / Budget status enum values all match. ✓
- 🟦 Auto-recharge, wallet, return tiers, payment methods, contacts, webhook structure: plausible and consistent with `Wallet`, `PaymentMethod`, `Contact`, `DisputeTier` models. Not deeply verified in this pass.
- 🟨 "Available notification categories include: Lead notifications (Lead assigned, dispute approved), Bid notifications (Outbid, bid matched, underfunded bids), Account notifications (Paused/unpaused, tier updated), Marketplace notifications (Buy order status changes)" — not cross-checked against `NotificationTypeEnum`. Flag for the notifications-page pass.

### `features/partners.mdx`

- 🟦 Partner roles (Partner Admin / Partner User) match `RoleEnum::PARTNER_ADMIN` and `PARTNER_USER`. ✓
- 🟦 Partner / source distinction matches the `Partner hasMany Source` relationship (grep against `Partner.php`).
- 🟦 Invite-management description is consistent with the Invite model.

---

### `features/budgets-and-caps.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** Budgets and caps are a real, detailed concept (covered in pieces on `features/bidding.mdx` and `features/customers.mdx`) and deserve a canonical page. Fill in or delete.

### `features/transactions.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** `Transaction` model and `TransactionEventEnum` both exist — recommend writing the page to document transaction types/events, or removing.

### `features/payment-methods.mdx`

- 🟥 **Title ≠ filename / nav slug.** Frontmatter title is "Payments & Deposits" but the page is at `/features/payment-methods` (nav label is auto-derived from the title in Mintlify). This will either:
  - Confuse anyone clicking "Payments & Deposits" in the sidebar expecting payment-method management, or
  - Look like a broken nav entry if a user arrives via a `/features/payment-methods` deep-link expecting the page to be about payment methods.
  Recommend: rename the file to `features/payments-and-deposits.mdx` (and update `docs.json`), **or** split this page into two (payment methods CRUD vs. fees/deposits settings), **or** change the title back to "Payment Methods" and pull in the CRUD content from `features/customers.mdx#payment-methods`.
- 🟦 Content about fee percentages / first-transaction waiver / deposit minimums is plausible — not verified against `TenantSettings` fields in this pass.

---

### `features/duplicate-detection.mdx`

Verified against `app/Models/DuplicateCheck.php`.

- 🟥 **"Field" should be plural.** Doc describes duplicate checks as having a single field to check, but `DuplicateCheck` has a `morphToMany` relationship to `Field` — multiple fields can be part of a single check (enabling "email + phone" composite matching). Update the copy.
- 🟦 `applies_to_pings`, `case_sensitive`, `ignore_punctuation` all match model casts. ✓

### `features/submissions.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** `Submission` model + `SubmissionStatusEnum` exist. Fill in or remove.

### `features/audits.mdx`

- 🟥 **Broken internal anchor.** Page links to `/features/leads#processing-leads`, but `features/leads.mdx` uses heading `Reprocessing leads` (slug `#reprocessing-leads`) — there is no `processing-leads` anchor. Fix to `/features/leads#reprocessing-leads`.
- 🟦 Audit condition fields (Name, Lead category, Description, conditions on metadata/data) plausible — not deeply verified against `AuditCondition` model in this pass.

### `features/returns.mdx`

Verified against `app/Services/DisputeService.php`, `app/Models/Customer.php`, `app/Models/DisputeTier.php`.

- 🟦 "New customer tier...less than $5,000" matches `Customer::isNewCustomer()` returning `< 500000` cents. ✓
- 🟦 Tier config fields (Name, Headline, Brief description, Long description, Color, Icon, Lower bound, Upper bound) and the new-customer flag are consistent with the DisputeTier usages grepped. ✓
- 🟦 "Ignore dispute tiers" exclusion mechanism — naming is consistent between doc and code (doc calls it "Disable Return Tiers" and says "ignore dispute tiers"; code uses `new_customer` and `reject()` filtering). Internal/external naming is a bit mixed (Disputes vs. Returns) but that's a broader terminology issue noted separately below.
- 🟧 **Terminology inconsistency across pages:** The user-facing concept is **Returns**, but the codebase uses **Disputes** (`DisputeTier`, `DisputeService`, `LeadStatusEnum::DISPUTED` rendered as "Returned"). Doc correctly uses "Returns" externally, but developers extending the docs will see "dispute" throughout code. Acceptable, but worth calling out as a rebranded concept so future doc writers don't accidentally use "dispute" in user-facing copy (except in the Disable/Exclude toggle labels if those UI strings still say "dispute tiers").

---

### `features/workflows.mdx`

- 🟥 **Body is Lorem ipsum placeholder.** The `Workflow` model and `WorkflowActionEnum` (Webhook, Ping Post) are real. The `features/webhooks.mdx` and `features/notifications.mdx` pages seem to cover related functionality, but the "Workflows" concept (event → action orchestration with `ExchangeConfiguration`, supported events list, etc.) needs its own documented surface.

### `features/notifications.mdx`

Verified against `app/Enums/NotificationTypeEnum.php`.

- 🟥 **Multiple event labels don't match the UI labels.** The doc lists the enum case names where the code uses friendlier UI names:
  | Doc label | Actual UI label (from `NotificationTypeEnum::getName()`) |
  |-----------|----------------------------------------------------------|
  | Customer Paused | **Account Paused** |
  | Customer Unpaused | **Account Unpaused** |
  | Customer Archived | **Account Archived** |
  | Customer Restored | **Account Restored** |
  | Dispute Approved | **Return Approved** |
  | Dispute Tier Updated | **Return Tier Updated** |
  The other entries (Lead Assigned, Outbid, Bid Matched, Buy Order Exceeded/Reinstated, Payment Failed/Successful, Under Funded Bids) match. ✓
- 🟨 **Channel naming:** Doc says "In-App" — code uses `database` as the channel key. "In-App" is a fine user-facing name but worth confirming that's what the UI actually labels it.
- 🟦 Channels (mail / sms / database) match the `channels` array in each config. ✓
- 🟦 Template variable namespaces (`{{ lead.* }}`, `{{ customer.* }}`, `{{ buyOrder.* }}`, `{{ disputeTier.* }}`) are consistent with the notification class names. Not deeply verified against individual notification classes.

### `features/webhooks.mdx`

Verified against `app/Enums/WorkflowActionEnum.php`, `app/Models/Workflow.php`, `app/Services/WebhookTemplateService.php`, `app/Events/`.

- 🟥 **"County Lead Type Stats Updated" event does not exist.** The event list shows both County and State variants, but `app/Events/` has only `StateLeadTypeStatsUpdated` and a generic `LeadTypeStatsUpdated`. There is no `CountyLeadTypeStatsUpdated` event. Remove or rename.
- 🟦 Other events (Customer Created, Lead Assigned/Created/Not Assigned/Duplicated/Posted, Transaction Updated, User Attached to Customer) match `Workflow::$supportedEvents`. ✓
- 🟦 Flat vs nested field access (`{{ first_name }}` vs `{{ lead.first_name }}`) is consistent with `WebhookTemplateService` template shapes. ✓
- 🟦 `customer_public_id` and `lead_public_id` references match the template service. ✓
- 🟨 **Retry policy ("up to 3 retries with a brief delay")** — not verified against the actual webhook dispatch job in this pass. Jobs in `app/Jobs/` commonly use `tries()`/backoff, but webhook-specific retry code wasn't grepped. Flag for confirmation.
- 🟨 The cross-link `/customer-portal/notifications#webhooks` — check this anchor exists during Customer Portal review.

---

### `features/location-analytics.mdx`

- 🟦 Hierarchical drill-down (Country → State → County → Zip) and demand/performance columns are plausible. Not verified against the analytics Livewire component in this pass — flag for a deeper review if precision is important.

### `features/company-profile.mdx`

- 🟦 Matches the `EditTenantProfile` Filament page concept. No contradictions spotted.

### `features/branding.mdx`

- 🟦 Primary/dark logos, favicon/avatar, "Hide Powered by Juiced" toggle, consent links, registration headline/banner — consistent with `SetTenantBranding`/`SetPlatformBranding` middleware and `Banner` model. Not deeply verified.
- 🟨 "Primary Logo — Displayed by default and in light mode" — verify the light/dark logic against the actual branding config; branding.mdx implies a binary light/dark, but the registration page template references `config('branding.logos.primary')` without dark-mode switching. Minor — flag for confirmation.

### `features/billing.mdx`

Verified against `config/spark.php`.

- 🟦 **All ten plan tiers match exactly** (name, monthly lead sales cap, lead limit, monthly price). ✓
  - Juicy Start / Citrus Splash / Berry Boost / Tropical Temptation / Orchard Oasis / Mango Magic / Pineapple Paradise / Grapevine Glory / Pomegranate Power / Exotic Extracts
- 🟦 Thresholds in cents (`threshold`/100) all match doc dollar figures. ✓
- 🟨 "Auto-upgrade" description — behavior and failure handling plausible, not directly verified against a specific job/listener in this pass.
- 🟨 `/features/branding#removing-juiced-branding` link target — exists in `features/branding.mdx` ✓.
- 🟨 `/features/domains` link — target page exists but is **orphaned from `docs.json` nav** (see next section).

### `features/integrations.mdx`

Verified against `app/Enums/IntegrationTypeEnum.php`, `app/Enums/RealEstateApiEndpointEnum.php`.

- 🟦 All listed integrations (Stripe, Twilio, SendGrid, Google Tag Manager, Intercom, Real Estate API) match `IntegrationTypeEnum` cases. No missing integrations. ✓
- 🟦 Real Estate API endpoints (Property Detail / SkipTrace / Property Comps / AVM / Address Verification / MLS Detail / MLS Search) match `RealEstateApiEndpointEnum`. ✓
- 🟨 Anchor slugs `#sendgrid`, `#twilio`, `#real-estate-api` used in other docs — will render correctly since headings use those names.

### `features/users.mdx`

- 🟦 Four tenant roles (Admin / Customer Support / Sales / Data Validation) match `RoleEnum::getTenantRoles()`. ✓

### `features/roles.mdx`

Verified against `app/Enums/RoleEnum.php` permission arrays.

- 🟦 Admin → `*` permission ✓.
- 🟦 Customer Support permissions table matches `getReadOnlyCustomerRelatedPermissions()` + `getWriteCustomerRelatedPermissions()` + extras (`customers.add-funds`, `analytics.view`, `marketplace.view`, `users.delete`, `users.restore`, `payment-methods.set-default`, `leads.approve-dispute`, `invites.delete`). ✓
- 🟦 Sales is read-only customer/location + `invites.create/delete` + `bids.view-history` + `analytics.view` + `marketplace.view`. ✓
- 🟦 Data Validation is only `leads.view-any` / `leads.view` / `leads.update`. ✓
- 🟧 **Tiny discrepancy:** Doc says "Send invites" is allowed for Customer Support, Sales, but not Data Validation. Code permissions for Customer Support include `invites.delete` but invite creation comes from `getWriteCustomerRelatedPermissions()` which includes `invites.create` — so ✓. OK no issue.
- 🟦 Reprocess-leads (Admin only) matches `LeadPolicy::reprocess()` gating by `leads.reprocess`. ✓

### `features/domains.mdx`

Verified against `config/tenancy.php`.

- 🟥 **Orphan page — not in `docs.json` navigation.** The page exists at `/features/domains` and is linked from `features/billing.mdx` and `features/branding.mdx`, but it's missing from the "Account Management" (or any) nav group in `docs.json`. Either add it under "Account Management" or accept that it's only reachable via internal links (not ideal).
- 🟦 Reserved-subdomain example list (admin, api, app, cdn, dev, docs, mail, portal, support, test, www) is a subset of the actual 48-entry list in `config/tenancy.php::reserved_subdomains`. Since the doc says "including:" this is fine, but noting the actual list also contains: `ads`, `backup`, `beta`, `blog`, `chat`, `cms`, `crm`, `demo`, `dns`, `email`, `forums`, `ftp`, `host`, `info`, `localhost`, `media`, `newsletter`, `new`, `old`, `proxy`, `remote`, `search`, `secure`, `server`, `shop`, `sms`, `smtp`, `staging`, `static`, `store`, `video`, `web`, `webmail`, `wiki`, `www1-3`.

---

### `guides/index.mdx`

- 🟦 Introductory page. No factual claims to verify.

### `guides/adding-fields-to-a-lead-category.mdx`

Verified against `app/Models/Field.php`, `app/Models/Lead.php`.

- 🟦 "10 default fields" matches `Lead::$defaultFields` (first_name, last_name, email, phone, address_1, address_2, city, state, zip, county). ✓
- 🟦 Four toggles (`required_for_post`, `required_for_ping`, `deliverable`, `hidden_from_api_spec`) match the `Field` model casts exactly. ✓
- 🟦 `lead-categories.update` permission string follows the established `{resource}.{action}` naming convention. ✓
- 🟨 "The **Required for post** and **Required for ping** toggles are disabled for the **zip** field" — plausible based on `features/lead-categories.mdx` claim; not directly verified against the Filament form UI in this pass.

### `guides/setting-up-a-source-and-its-attributes.mdx`

Verified against `app/Models/Source.php`, `app/Enums/SourceTypeEnum.php`, `app/Enums/ResponseStatusEnum.php`.

- 🟦 Status-response default mapping matches `Source::DEFAULT_RESPONSE_STATUS_MAP` exactly:
  - success → Assigned, Posted, Marketplace ✓
  - rejected → Audit, Unassigned, Uncategorized ✓
  - duplicate → Duplicate ✓
- 🟦 Source type descriptions (Internal/Vendor) match `SourceTypeEnum::getDescription()`. ✓
- 🟦 Bearer token + basic auth both supported via `createToken('ingest')` and `api_key`/`api_secret`. ✓
- 🟨 "Each new token replaces the previous one, which expires within 24 hours" — the token-creation code doesn't show a 24-hour expiration in the `booted()` snippet; flag for confirmation against `ManageSourceAuthentication` page + Sanctum config.
- 🟥 **Potentially stale feature gate:** Step 5 says "If the **Distribution Stages** feature is enabled, the **Pricing** tab lets you configure per-lead-type pricing for this source." The pricing feature on a source appears to be always available (`features/sources.mdx#source-pricing` doesn't gate it). If "Distribution Stages" is a legacy Pennant flag or was removed, this conditional is misleading. **Action: confirm whether this feature flag still exists.**
- 🟨 "Hidden from API spec" — note the case-style inconsistency: this guide uses "Hidden from API spec" (matching the model cast `hidden_from_api_spec`), while `features/lead-categories.mdx`'s custom-field property list omits it entirely. Consider listing it there too for parity.

### Missing guides (observation)

- 🟨 `guides/index.mdx` sets an ambitious tone ("business strategies", "advanced techniques"), but the section only contains two guides currently. Either add more or dial back the intro.

---

### `customer-portal/index.mdx`

- 🟥 **Broken internal link.** The "Set up bidding" Card links to `/customer-portal/bidding`, but the actual page (and `docs.json` slug) is `/customer-portal/bids`. Fix.
- 🟥 **"Dashboard" listed but no page exists.** The Portal sections table lists a "Dashboard" section. There is no `/customer-portal/dashboard` page in docs or in `docs.json`. Either add one or remove the row.
- 🟦 Wallet funding status colors (Green/Yellow/Red) consistent with enum color mapping. ✓
- 🟦 Customer switcher and Company Profile reference are consistent.

### `customer-portal/leads.mdx`

- 🟦 Minimal page, no factually incorrect claims. Could be richer — filters, exports, lead return flow — but that's a content gap, not a factual error.

### `customer-portal/bids.mdx`

- 🟨 Status-filter tabs (All / Active / Limited / Inactive) — the "Limited" and "Inactive" tabs umbrella several `BidDisplayStatusEnum` values (e.g., Under Funded, Not Funded, Capped, Paused, Archived). Acceptable simplification, but consider explicitly listing which underlying statuses each filter tab matches.
- 🟦 Smart-pricing claim is consistent with `features/bidding.mdx#smart-pricing`. ✓
- 🟦 Bid position (top/tied/under) language aligns with `BidPositionEnum`. ✓

### `customer-portal/marketplace.mdx`

- 🟦 Buy-order flow, floor color coding (Gray/Blue/Green/Red), "hold not charge" semantics — consistent with `features/marketplace.mdx`. ✓

### `customer-portal/notifications.mdx`

Verified against `app/Models/ExchangeConfiguration.php`.

- 🟦 HTTP method options (GET / POST / PUT / PATCH / DELETE) match `ExchangeConfiguration::ALLOWED_HTTP_METHODS`. ✓
- 🟦 `{{ deliverable_fields }}` expansion, default payload shape (`charged_amount` / `scope` / `lead_type` / `deliverable_fields`), nested vs flat field access — consistent with `features/webhooks.mdx`. ✓
- 🟦 Identifiers (`buyer.customer_public_id`, `lead.public_id`) consistent with webhook template service. ✓
- 🟨 The `#webhooks` anchor referenced from `features/webhooks.mdx` resolves to the "Webhooks" heading here. ✓

### `customer-portal/billing.mdx`

- 🟦 Three tabs (Payment Methods / Transactions / Auto Recharge) plausible. Not verified against the Customer panel's Filament resource in this pass.

### `customer-portal/bidding-limits.mdx`

- 🟦 Pause-account + daily/weekly/monthly caps + daily/weekly/monthly budgets. Consistent with the cap/budget enums and the customer model's scheduled reset fields. ✓

### `customer-portal/company-profile.mdx`

- 🟦 Countries (US, Canada, Australia) + adaptive state/postal labels — matches the main registration form's alpine config. ✓
- 🟨 "edit-profile permission" — gated by Filament policy. Not verified; naming looks consistent with the `{resource}.{action}` convention.

---

### `api-reference/introduction.mdx`

Verified against `routes/api.php`, `app/Http/Controllers/Api/*`, `app/Http/Middleware/FlexibleAuth.php`, `api-reference/openapi.json`.

- 🟦 Base URL `https://usejuiced.com/api` matches `openapi.json::servers`. Routes are registered globally (not domain-scoped) in `bootstrap/app.php`, so central-domain calls work — source credentials identify the tenant. ✓
- 🟦 Auth (Basic + Bearer) matches `FlexibleAuth`. ✓
- 🟦 Documented endpoints (`POST /ping`, `POST /leads`) match `routes/api.php`. ✓ The third endpoint, `POST /marketplace`, is **deprecated** (logs a warning and forwards to LeadController) — correctly **not** documented.
- 🟥 **Missing documentation for `X-Partner-Id` header.** `FlexibleAuth::resolvePartnerFromHeader()` reads this header on every request to resolve a partner context. The middleware's own comment flags it as "documented as required but intentionally not enforced" — but the public API reference has no mention of this header. New integrations should know about it.
- 🟦 HTTP status codes (200/201/401/422) match the OpenAPI spec. ✓

### `api-reference/endpoint/ping.mdx`

- 🟦 Page contains only frontmatter pointing at `POST /ping` in the OpenAPI spec. The actual spec (in `openapi.json`) has complete examples including minimal/with-state/detailed/test scenarios and both internal/vendor response shapes. ✓
- 🟦 Response examples (`PingResponseInternal` with `bids[]` vs `PingResponseVendor` with flat `price`) match `TestModeService::buildPingResponse()` branching on `isVendor()`. ✓

### `api-reference/endpoint/leads.mdx`

- 🟦 Page is purely frontmatter pointing at `POST /leads`. OpenAPI spec covers the `ping_id`/`bid_id` reference pattern used by `LeadController::store()`. ✓
- 🟨 The `is_test` field mentioned in `openapi.json`'s testPing example maps to `$source->isTestMode()` + deterministic zip handling in both controllers — correct, but the introduction.mdx page doesn't explain how `is_test` vs. source-test-mode interact. Minor improvement, not a factual error.

### OpenAPI spec (`api-reference/openapi.json`)

- 🟨 Spec's `security` block lists "Basic Auth" and "Bearer Token" but omits `X-Partner-Id`. Same omission as `introduction.mdx`. Consider adding it as an optional header in the spec if you want Mintlify's API playground to include it.
- 🟨 Spec's `servers` lists only `https://usejuiced.com/api` — tenants could reasonably expect their own subdomain to work. Mintlify won't surface this — acceptable as-is, but a note in `introduction.mdx` about the subdomain also working could reduce confusion.

---

### `changelog/index.mdx`

- 🟨 **Empty changelog.** The page is a meta-intro describing what a changelog is, but contains no actual entries. If the product is shipping updates (the repo's recent PR history says yes), this is effectively an advertised-but-empty section. Either start logging entries or collapse the section.

---

## Cross-cutting findings

### 1. Terminology drift (🟧 consistency)

Three concepts have different names in the docs vs. the code, and the docs are mostly (but not always) consistent with themselves.

| User-facing (docs) | Code | Notes |
|--------------------|------|-------|
| Returns | Dispute (`DisputeTier`, `DisputeService`, `LeadStatusEnum::DISPUTED`) | Docs correctly use "Returns" externally; exception: `customer-portal/index.mdx` uses "dispute tiers" in two places. Make it consistent — "return tiers" everywhere. |
| Customers | `Customer` model (consistent) | Doc consistent. But `features/index.mdx` uses "Buyers" once — fix. |
| Sources / Lead Categories / Bids (etc.) | Consistent | No campaign concept exists. Doc uses "Campaigns" in two places (`features/index.mdx`, `get-started/quickstart.mdx`, `guides/index.mdx`). Remove or replace. |

### 2. Broken or incorrect internal links (🟥)

- `features/audits.mdx` → `/features/leads#processing-leads` → should be `#reprocessing-leads`.
- `customer-portal/index.mdx` → `/customer-portal/bidding` → should be `/customer-portal/bids`.

### 3. Orphan pages (🟨)

Pages that exist on disk but aren't in `docs.json` navigation:

- `quickstart.mdx` (root, Mintlify template — orphan, duplicate of `get-started/quickstart.mdx`)
- `development.mdx` (Mintlify template — orphan)
- `features/domains.mdx` (functional page; should be added to "Account Management" group)
- All `essentials/*.mdx`, `ai-tools/*.mdx`, `snippets/snippet-intro.mdx` — these are Mintlify starter scaffolding not referenced in `docs.json`. They ship as dead weight unless you want to keep them for contributor reference.

### 4. Lorem ipsum stubs (🟥)

Pages whose body is only placeholder text:

- `features/reverse-auctions.mdx`
- `features/distribution.mdx`
- `features/budgets-and-caps.mdx`
- `features/transactions.mdx`
- `features/submissions.mdx`
- `features/workflows.mdx`

These all represent real, substantial features in the codebase and will mislead readers who navigate to them expecting docs.

### 5. Enum-label drift (🟨)

Documentation frequently uses the raw enum case name rather than the UI label:

- Lead statuses — doc mostly uses UI labels ✓ (but misses `Processing`).
- Notification event names — doc uses enum-case style (e.g., "Dispute Approved") while UI shows the `getName()` label ("Return Approved"). Six notifications affected.
- Operator labels — doc uses "Not equals", UI says "Does not equal" (etc.).
- Bid display statuses — doc drops `Under Funded`, `Not Funded`, `Capped` entirely.

### 6. Severity summary

| Severity | Count (approx) |
|----------|----------------|
| 🟥 Factual / broken reference | ~22 |
| 🟧 Cross-page consistency | ~3 |
| 🟨 Severe stylistic / structural | ~25 |
| 🟦 Verified correct | ~60 |

---

## Recommendations (by priority)

1. **Fill in the six Lorem ipsum pages** (or remove them from nav). These are the highest-profile factual gaps for new users.
2. **Fix enum-label drift in `features/notifications.mdx` and `features/bidding.mdx`.** Users searching for a UI label won't find it in docs.
3. **Fix the broken anchor in `features/audits.mdx` and the broken link in `customer-portal/index.mdx`.**
4. **Rename or reframe `features/payment-methods.mdx`** — filename and title disagree.
5. **Overhaul `get-started/quickstart.mdx`** to reflect the actual single-form registration flow and remove invented multi-step structure.
6. **Add `features/domains.mdx` to `docs.json`** or remove it.
7. **Delete orphaned Mintlify template pages** (`quickstart.mdx`, `development.mdx`, `essentials/*`, `ai-tools/*`, `snippets/*`) if not intended to ship.
8. **Write an actual changelog** or collapse the section.
9. **Add `X-Partner-Id` to API docs** (introduction + OpenAPI spec security scheme).
10. **Remove "Campaigns" and "Buyers" terminology** in `features/index.mdx`, `guides/index.mdx`, and `get-started/quickstart.mdx`.

---

## Items flagged for manual confirmation

These were plausible but not deeply verified against the codebase during this pass:

- Auto-upgrade subscription failure/success path behavior.
- "By default, only Admin users have `leads.reprocess`" — verified via role permissions grep; the `*` wildcard for TENANT_ADMIN covers it, but confirm no other role was granted this permission.
- Smart-pricing "one increment above the next highest bidder" — behavioral claim not traced to a specific bid-resolution function.
- Lead cap reset timezone (UTC) — not verified against cap reset code.
- Bearer token "expires within 24 hours" (source-level tokens) — not verified against Sanctum config.
- Webhook retry policy ("up to 3 retries with brief delay") — not verified against dispatch job.
- "Distribution Stages" feature-flag gating of the source Pricing tab — referenced as if optional in guide, not clearly gated in `features/sources.mdx`.
- TCPA 1:1 Default Consent behavior (`features/company-profile.mdx`).
- Branding light/dark logo switching mechanism (registration view only loads primary).




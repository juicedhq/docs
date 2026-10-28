---
name: audit-openapi
description: Use when the user asks to check, audit, verify or sync the OpenAPI spec or API reference against the Juiced app's API (e.g. "is the API reference still right?", "check openapi.json against the app"). Compares api-reference/openapi.json and the api-reference pages with the app's routes, auth, Form Requests, controllers and resources, and reports every drift with app file:line evidence.
---

# Audit OpenAPI

Check that `api-reference/openapi.json` (wired in via `docs.json` → `openapi`) and the `api-reference/*.mdx` pages describe the API the app actually ships. Run it from this repo; the app is read-only.

This is a **read-only audit** until the user picks a fix in the final step.

## 1. App checkout

The app is a sibling checkout: `../juiced` or `../juiced-tickets`, whichever exists. Audit `origin/main` (or a release tag or branch the user names), never whatever that checkout has checked out:

```bash
APP=$(for d in ../juiced ../juiced-tickets; do [ -d "$d/.git" ] && echo "$d" && break; done)
git -C "$APP" fetch origin --quiet
REF=origin/main
git -C "$APP" show "$REF:<path>"   # read every app file this way
```

Never switch branches, stash, or edit anything in the app checkout. If no checkout exists, stop and say so.

## 2. Map the app's API

Start from the routes, not the spec, so endpoints the spec never mentions still show up.

- **Routes**: `routes/api.php` (prefix `api`, see `bootstrap/app.php`). Today there's a legacy group (`api.*`, `/api/ping`, `/api/leads`) and a versioned group (`api.v1.*`, `/api/v1/...`), both behind `auth.flexible`. `php artisan route:list --path=api --except-vendor -v` in the app checkout gives the current list with middleware, but only for the checked-out branch, so confirm it against `routes/api.php` at `$REF`.
- **Auth**: the `auth.flexible` alias → `FlexibleAuth` middleware. Read which credentials it accepts (basic with the source's key and secret, bearer, anything else) and how it fails.
- **Requests**: `app/Http/Requests/Api/` (legacy) and `app/Http/Requests/Api/V1/`. Rules give required fields, types, formats, enums and limits.
- **Field sets are per source.** Lead fields are configured per tenant and source (`Source::getAllFields()`, `App\Services\ApiSpecBuilder`, the `/api-specs` page). The spec should document the fixed fields every source has and say that the rest come from the source's configuration. Don't flag a custom field as missing.
- **Responses**: the controllers in `app/Http/Controllers/Api/` and `Api/V1/`, the resources in `app/Http/Resources/Api/V1/` (`LeadResource`, `PingResource`, `PingBidResource`, `ErrorResource`), and the status codes each path returns.
- **Cross-cutting behavior**: everything in `bootstrap/app.php` that touches the API. `ApplyApiContract` (`X-Request-Id` on v1 responses), `RenderV1ApiException` (the v1 error envelope), `throttleApi()` (rate limits, 429), `LogPingMiddleware`, and idempotent lead submission (find its middleware and header).
- **Tests as evidence**: `tests/Feature/Http/Controllers/Api/` (`V1/LeadControllerTest.php`, `V1/PingControllerTest.php`, `LegacyApiContractTest.php`) and `tests/Feature/Http/Middleware/IdempotentLeadSubmissionTest.php` pin exact payloads and status codes. Prefer them for example responses.

## 3. Compare

Read `api-reference/openapi.json`, `api-reference/introduction.mdx` and `api-reference/endpoint/*.mdx`. Check each item and record a verdict with the app `file:line`:

| Area | What to compare |
| --- | --- |
| Endpoints | Every app route vs every spec `paths` entry: missing, extra, wrong method, legacy vs `v1` (which one the docs should send integrators to). |
| Servers | `servers[].url` vs the real base URL and path prefix (including tenant domains, if the API is served per tenant). |
| Auth | `securitySchemes` and their descriptions vs `FlexibleAuth`; per-operation `security`. |
| Request | Fixed fields, required vs optional, types, formats, enums, max lengths, headers (idempotency key, content type). |
| Responses | Every status code each path can return, the response body shape per code, enum values (e.g. lead result `success` / `rejected` / `duplicate`), the v1 error envelope, `X-Request-Id`, 401/422/429 behavior. |
| Examples | Request and response examples that would actually validate and match what the app returns. |
| MDX pages | Prose in `introduction.mdx` and the endpoint pages: auth instructions, rate limits, versioning, links to `/features/*` pages. |

Verdicts: `matches`, `wrong`, `missing from spec`, `missing from app` (the spec documents something the app doesn't do), `couldn't verify`. Every row gets one.

Also validate the file itself: it must parse as JSON and be valid OpenAPI 3.1. `mint validate` currently reports an OpenAPI error on `main`; note whether it is about this file and what it says.

## 4. Report

- A one-line verdict (in sync / N drifts).
- The table from §3, grouped by endpoint, drifts first. Quote the spec value and the app value side by side with the app `file:line`.
- Decisions for the user, kept apart from plain fixes: e.g. whether to document the legacy endpoints, the v1 ones, or both.

## 5. Next steps

Offer:

1. Fix the spec and pages on a branch (`docs/openapi-sync`, or `docs/jui-NNNN-<slug>` with a ticket). Keep `openapi.json` formatted as it is, follow `CLAUDE.md` for the MDX, check the endpoint pages in the preview (`preview-docs`), run `mint broken-links`, and commit with a `docs: ` subject. Don't push or open a PR.
2. Draft a Linear ticket for the drifts (text in chat; don't create it unless asked).
3. Stop here.

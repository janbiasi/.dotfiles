---
name: owasp-api-top-10-2023
description: >-
    Audit an API codebase against the OWASP API Security Top 10 (2023). Maps every
    endpoint to a vulnerability category and produces a findings report with proposed
    fixes (no auto-apply). Use when the user wants to audit/review an API for security,
    mentions OWASP API Top 10, asks for an API pentest or threat model, or wants to
    check endpoints for BOLA, BFLA, mass assignment / excessive data exposure, broken
    authentication, unrestricted resource consumption / rate-limiting gaps, SSRF, or
    unsafe third-party API consumption. Auto-scopes to code-only or code+infra based
    on what the codebase ships.
metadata:
    author: janbiasi
    version: "1.0"
---

Static security **audit** of an API against the OWASP API Security Top 10 (2023).
It walks the **API surface** once, applies all applicable categories, and reports every **finding** with a proposed fix — it does **not** edit code.

The audit is exhaustive by construction: the index below names all 10 categories, each carries a **verdict** (clean, with reason, or findings),
and no category is skipped. Run it in this order — mapping the surface first prevents drift later.

## Process

### 1. Map the API surface

Enumerate every entry point the code exposes: REST route handlers, GraphQL resolvers/operations, RPC/gRPC handlers, server
actions, WebSocket/event handlers, webhooks, and cron jobs. For each, capture `file:line`, the HTTP verb/path (or operation name),
the auth context (anonymous / authenticated / role), and which object IDs it accepts.

Done when **every endpoint is listed** with its location and auth context. If the repo has no API surface at all,
stop and say so — there is nothing to audit.

### 2. Decide scope (the branch)

Glob the repo for infra/deploy/config artifacts. If **any** exist → **infra branch** (run code checks **and** infra checks, all 10);
otherwise **code-only** (run the 8 code categories). Signals that fire the infra branch — resolve each to present-or-absent before choosing:

- Containers/deploy: `Dockerfile*`, `docker-compose*.yml`, `Procfile`, `*.dockerfile`
- IaC: `*.tf`, `*.tf.json`, `pulumi/`, `cloudformation*`, `template.yaml` (SAM), CDK, `serverless.yml`
- Platform/hosting: `wrangler.*`, `vercel.json`, `netlify.toml`, `app.yaml`, `fly.toml`, `render.yaml`, `railway.json`
- Gateway/proxy/security-config: `nginx*.conf`, `traefik.yml`, `envoy*`, `haproxy.cfg`, API-gateway configs, CORS/security-headers config
- Orchestration: k8s manifests (`kind: Deployment|Service|Ingress`), helm charts (`Chart.yaml`)
- Inventory/specs: OpenAPI/Swagger (`openapi.*`, `swagger.*`), a `docs/` API catalogue

State the chosen branch and which signals fired, in one line.

### 3. Run the code checks

Load [`CODE-CHECKS.md`](CODE-CHECKS.md). Apply each of the eight `code`-tier categories to the surface, using its
"Hunt for" lines as the legwork. Done when **every one of the eight code categories has a verdict** — a finding, or a
clean verdict with the one-line reason you found nothing.

### 4. Run the infra checks (infra branch only)

Load [`INFRA-CHECKS.md`](INFRA-CHECKS.md). Apply API8 and API9 against the config/deploy/spec artifacts.
Done when **both infra categories have a verdict**. Skip this step entirely on the code-only branch — but say so
explicitly so the report records the scope.

### 5. Report

Present findings grouped by OWASP category, then a summary table. Each finding:

- **Category** — `APIn:2023 — Name` (e.g. API1:2023 — BOLA)
- **Severity** — from the scale below
- **Location** — `file:line`
- **Evidence** — a short quote of the vulnerable code/config
- **Proposed fix** — drafted from the category's fix shape; not applied

End the report with a **verdict summary** table: one row per applicable category, `clean` or `N findings`.
The audit is complete when **every applicable category has a verdict AND every finding is cited to `file:line`
with a proposed fix** — a category with neither a clean reason nor findings means the audit is not finished.

### 6. Offer a handoff document

After presenting the report, ask the user whether to persist it as a handoff document at
`docs/security/YYYYMMDD-owasp-api-top-10-2023.md` (replace `YYYYMMDD` with today's date). Only write the file if
they confirm — otherwise leave the report inline. The handoff document should carry the full report (findings grouped
by category + the verdict summary + the chosen scope/branch) so another agent or reviewer can pick it up without
re-running the audit.

## Severity

Grade each finding from the OWASP factors (exploitability × impact), not a gut feel:

| Severity     | When                                                                                                                                      |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Critical** | Severe impact + easy exploit; e.g. unauth BOLA on sensitive data, full account takeover, exposed cloud creds via SSRF                     |
| **High**     | Severe impact but needs some access, or easy exploit with moderate impact; e.g. BFLA on admin functions, broken reset-password throttling |
| **Medium**   | Moderate impact / business-specific; e.g. mass assignment of a price field, missing rate-limit on a costly op                             |
| **Low**      | Defence-in-depth gap, low exploitability or impact; e.g. missing security header, verbose errors                                          |
| **Info**     | Hardening or inventory observations with no direct exploit (often API9)                                                                   |

## The 10 categories — index

The exhaustive backbone. The **Signal** is enough to audit from; the **Detail** pointer loads the depth.
`code` rows resolve to [`CODE-CHECKS.md`](CODE-CHECKS.md), `infra` rows to [`INFRA-CHECKS.md`](INFRA-CHECKS.md).

| #     | Category                                           | Tier  | Signal — vulnerable when…                                                                                                                | Detail                                                                                   |
| ----- | -------------------------------------------------- | ----- | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| API1  | Broken Object Level Authorization (BOLA)           | code  | an endpoint takes an object ID and acts on the object without checking the caller may access **that object**                             | [CODE-CHECKS](CODE-CHECKS.md#api12023--broken-object-level-authorization-bola)           |
| API2  | Broken Authentication                              | code  | tokens/credentials are issued, validated, stored, rotated, or reset weakly; session & recovery flows lack anti-automation                | [CODE-CHECKS](CODE-CHECKS.md#api22023--broken-authentication)                            |
| API3  | Broken Object Property Level Authorization (BOPLA) | code  | responses ship the whole object (excessive exposure) **and/or** inputs bind without an allowlist (mass assignment)                       | [CODE-CHECKS](CODE-CHECKS.md#api32023--broken-object-property-level-authorization-bopla) |
| API4  | Unrestricted Resource Consumption                  | code  | no timeout / memory cap / payload cap / pagination cap / per-operation throttle on expensive or paid work                                | [CODE-CHECKS](CODE-CHECKS.md#api42023--unrestricted-resource-consumption)                |
| API5  | Broken Function Level Authorization (BFLA)         | code  | a function the caller should not reach lacks a role/group check — admin handlers, or verb/path guessing                                  | [CODE-CHECKS](CODE-CHECKS.md#api52023--broken-function-level-authorization-bfla)         |
| API6  | Unrestricted Access to Sensitive Business Flows    | code  | a business-critical flow (purchase, booking, referral, post) has no anti-automation / business-rule protection                           | [CODE-CHECKS](CODE-CHECKS.md#api62023--unrestricted-access-to-sensitive-business-flows)  |
| API7  | Server-Side Request Forgery (SSRF)                 | code  | the server fetches a URL derived from user input without a host/scheme/port allowlist                                                    | [CODE-CHECKS](CODE-CHECKS.md#api72023--server-side-request-forgery-ssrf)                 |
| API8  | Security Misconfiguration                          | infra | CORS/TLS/headers, verbose errors, debug endpoints, default creds, unpatched deps, permissive cloud/storage perms                         | [INFRA-CHECKS](INFRA-CHECKS.md#api82023--security-misconfiguration)                      |
| API9  | Improper Inventory Management                      | infra | stale/deprecated/old-version endpoints exposed, spec/docs drift, un-gated explorer, prod data on non-prod, unjustified third-party flows | [INFRA-CHECKS](INFRA-CHECKS.md#api92023--improper-inventory-management)                  |
| API10 | Unsafe Consumption of APIs                         | code  | third-party responses trusted without validation, over plaintext, with blind redirects and no timeouts                                   | [CODE-CHECKS](CODE-CHECKS.md#api102023--unsafe-consumption-of-apis)                      |

## References

- [`CODE-CHECKS.md`](CODE-CHECKS.md) — full detail for the eight source-detectable categories. Always loaded.
- [`INFRA-CHECKS.md`](INFRA-CHECKS.md) — full detail for the two config/infra categories. Loaded only on the infra branch.
- [OWASP API Security Top 10 — 2023 edition](https://owasp.org/API-Security/editions/2023/en/0x00-toc/) — upstream source.

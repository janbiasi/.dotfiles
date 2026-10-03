# Code Checks — OWASP API Security Top 10 (2023)

Full detail for the eight categories detectable from **source code**. Disclosed reference for [`owasp-api-top-10-2023`](SKILL.md); loaded when the **code branch** runs. Each category is co-located: the factors, the code patterns to hunt, a trimmed attack scenario, prevention, the proposed-fix shape for the report, and the CWE.

The "Hunt for" lines are concrete things to `grep`/read for — they drive the legwork; they are not exhaustive. The single-line signal for each category lives in `SKILL.md`; this file owns the depth.

Source: [OWASP API Security Top 10 — 2023 edition](https://owasp.org/API-Security/editions/2023/en/0x00-toc/).

---

## API1:2023 — Broken Object Level Authorization (BOLA)

**Factors.** Exploitability _Easy_ · Prevalence _Widespread_ · Detectability _Easy_ · Impact _Moderate/Business-specific_. The most common and most damaging API issue.

An endpoint takes an object ID from the client (path param, query, header, body) and acts on that object without checking the caller may access **that specific object**. The user is legitimately allowed to reach the endpoint — the violation is at the object level, by manipulating the ID. (If the user reaches an endpoint they shouldn't access at all, that is BFLA, API5 — not BOLA.)

**Hunt for.**

- Handlers where a path/body ID flows straight into a lookup with no ownership filter: `find(id)`, `findById`, `findByPk`, `.get(pk)`, `prisma.x.findUnique({ where: { id } })`, `SELECT ... WHERE id = ?`, `ref(docId)`, `bucket.object(key)` — anywhere an unscoped fetch/update/delete runs on client-supplied ID.
- GraphQL resolvers resolving an entity by `id` with no authz check; mutations like `deleteReports(reportKeys)` that take IDs and act blindly.
- Object IDs that are sequential integers or predictable strings — enumerate-able; GUIDs/UUIDs are better but **not** a fix on their own.
- "Compare the session user id to the request id" as the only check — OWASP calls this out as insufficient; it covers only a narrow subset.

**Scenario.** `/shops/{shopName}/revenue_data.json` — attacker lists all shop names via another endpoint, swaps `{shopName}`, and reads every shop's revenue. Or a vehicle API takes a VIN and starts/stops engines without checking the VIN belongs to the caller.

**Prevent.**

- Authorize against user policy/hierarchy on **every** function that uses client input to access a record.
- Prefer random, unpredictable IDs (GUIDs) for records.
- Write tests that assert the authz mechanism; do not ship changes that break them.

**Proposed-fix shape.** "At `file:line`, scope the query to the caller — `where: { id, ownerId: ctx.userId }` (or equivalent policy check) before the fetch/mutate. Add an authz guard/middleware for this route. Add a test: caller A cannot read/update/delete caller B's object."

**Refs.** [Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) · CWE-285 (Improper Authorization) · CWE-639 (Authorization Bypass Through User-Controlled Key)

---

## API2:2023 — Broken Authentication

**Factors.** Exploitability _Easy_ · Prevalence _Common_ · Detectability _Easy_ · Impact _Severe_. The auth surface is exposed to everyone; full account takeover is the ceiling.

Auth endpoints and flows — login, token issue/refresh/validate, **forgot/reset password**, MFA, session handling — are themselves protected assets and must be treated as login in terms of brute-force, rate-limit, and lockout.

**Hunt for.**

- No anti-automation on login / reset / OTP endpoints — brute-force and credential-stuffing open; especially when batchable (GraphQL query batching bypasses naive per-request rate limits).
- Weak/no password policy; passwords stored plain or weakly hashed (not bcrypt/argon2/scrypt); JWT with `alg:none` or unsigned/weakly-signed tokens accepted; JWT `exp` not validated; token authenticity not verified.
- Credentials/tokens carried in the URL/query string.
- Sensitive account changes (email, password, 2FA phone) allowed without re-authentication / current-password confirmation.
- Microservices calling each other with no auth, or with weak/predictable tokens.
- API keys used for **user** authentication (they belong to API clients, not users).

**Scenario.** Reset-password by SMS is rate-limited per request, but GraphQL batching fires thousands of `login()` mutations in one request, brute-forcing the account. Or `PUT /account { email }` needs no password re-entry, so a stolen token enables a full takeover via the reset flow.

**Prevent.**

- Know every auth flow (mobile, web, deep links, one-click). OAuth is not authentication; neither are API keys.
- Don't reinvent auth, token generation, or password storage — use standards.
- Treat recovery/forgot-password as login: brute-force protection, rate limit, lockout, captcha.
- Require re-auth for sensitive operations; prefer MFA; use the [Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html).

**Proposed-fix shape.** "At `file:line` (login/reset/OTP), add per-account rate limiting + lockout that batching cannot bypass (count operations, not requests). Verify JWT signature and `exp`, reject `alg:none`. Hash passwords with argin2/bcrypt (cost ≥ …). Require current-password or re-auth before `email`/`password`/2FA changes."

**Refs.** [Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) · [Key Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html) · CWE-204 (Observable Response Discrepancy) · CWE-307 (Improper Restriction of Excessive Authentication Attempts)

---

## API3:2023 — Broken Object Property Level Authorization (BOPLA)

**Factors.** Exploitability _Easy_ · Prevalence _Common_ · Detectability _Easy_ · Impact _Moderate/Business-specific_. Merges the 2019 _Excessive Data Exposure_ and _Mass Assignment_ into one property-level category.

Two distinct failures, both about **object properties**:

- **Excessive exposure (read):** the endpoint returns more properties than the caller needs — serializing the whole object/model instead of a picked set.
- **Mass assignment (write):** client input is bound onto the object/DTO without an allowlist, letting the caller set a property they shouldn't (role, price, `blocked`, `is_admin`).

**Hunt for.**

- Generic serializers: `to_json()`, `to_dict()`, `JSON.stringify(model)`, `res.json(user)`, returning an ORM entity directly; any response that ships the full model including internal/sensitive fields.
- Auto-binding request bodies into objects: `Object.assign(user, req.body)`, `@RequestBody User`, `bind()`, `update(req.body)`, `patch` that accepts arbitrary keys; no explicit allowlist / DTO allowlist / schema picking.
- Properties a caller could flip to escalate: `role`, `isAdmin`, `approved`, `total_stay_price`, `blocked`, `verified`, `balance`.

**Scenario.** A host `POST /api/host/approve_booking` legitimately sends `{approved, comment}`; replaying with `total_stay_price: "$1,000,000"` overcharges the guest because the field is mass-assigned. Or a user `PUT /api/video/update_video {description}` with `blocked:false` unblocks their own censored video.

**Prevent.**

- Cherry-pick the specific properties to return — never the whole object.
- Avoid auto-binding client input into internal objects/fields; allow only the properties meant to be client-writable.
- Add schema-based response validation as an extra layer; keep returned structures to the bare minimum.

**Proposed-fix shape.** "At `file:line`, replace `res.json(user)` with an explicit response DTO of `{id, name, email}` only. For the write path at `file:line`, allowlist inputs: `pick(body, ['approved','comment'])` before the update; reject unknown keys. Flag any privileged field (`role`/`isAdmin`/`blocked`/`price`) that is currently bindable."

**Refs.** [Mass Assignment Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html) · CWE-213 (Exposure of Sensitive Information Due to Incompatible Policies) · CWE-915 (Improperly Controlled Modification of Dynamically-Determined Object Attributes)

---

## API4:2023 — Unrestricted Resource Consumption

**Factors.** Exploitability _Average_ · Prevalence _Widespread_ · Detectability _Easy_ · Impact _Severe_. Simple requests, concurrent, from one machine or cloud. DoS by resource starvation and/or runaway cloud cost.

Satisfying a request costs bandwidth, CPU, memory, storage, or paid third-party calls (SMS/email/biometrics). An API is vulnerable if any of these limits is missing or mis-set: execution **timeout**, max **memory**, max **file descriptors/processes**, max **upload size**, **operations per request** (GraphQL batching!), **records per page**, and **third-party spend limit** / billing alert.

> **Tier note.** Rate-limiting is often enforced at a gateway/middleware (an **infra** concern — see `INFRA-CHECKS.md`, API8/Security Misconfiguration context). This entry owns the **code-level** controls: per-operation throttling, pagination caps, payload caps, timeouts, and spend limits.

**Hunt for.**

- Expensive handlers with no timeout: image/PDF processing, compression, encryption, thumbnail generation, large aggregations, recursive GraphQL resolvers, deep `@skip`/depth queries.
- Unbounded list endpoints: `?limit=`/`?per_page=` accepted from the client with no server cap; `findMany`/`findAll` with no `take`/`limit`.
- No cap on operations per request — GraphQL query batching/depth used to amplify; a single POST running N mutations.
- Outbound paid calls (SMS/email/OTP) with no per-account throttle or daily cap; file uploads with no size/type limit.
- No `AbortController`/`context.WithTimeout`/`server.setTimeout` on outbound fetches or heavy work.

**Scenario.** `uploadPic` generates thumbnails (memory-heavy); per-request rate limiting is bypassed by batching 999 `uploadPic` mutations in one GraphQL POST, exhausting memory. Or a `forgot_password` SMS flow with no throttle fires tens of thousands of $0.05 texts in minutes.

**Prevent.**

- Cap incoming payload sizes, string lengths, array lengths, upload sizes — always.
- Rate-limit per client within a timeframe; tune stricter on sensitive endpoints; throttle per-operation frequency (OTP verify, recovery).
- Validate and cap `records-per-page` server-side; limit operations per request (disable/limit GraphQL batching and depth).
- Set execution timeouts and memory/CPU limits (containers/serverless help); configure spend limits or billing alerts on paid integrations.

**Proposed-fix shape.** "At `file:line`, cap `per_page` server-side (max 100, clamp client value). At `file:line` (heavy op), add a timeout + memory guard. Limit GraphQL query depth/batch size to N. At `file:line` (paid call), add a per-account daily cap + billing alert. Enforce rate limiting at the gateway (see INFRA-CHECKS) and per-operation here."

**Refs.** [GraphQL Cheat Sheet — DoS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html) · CWE-770 (Allocation of Resources Without Limits or Throttling) · CWE-400 (Uncontrolled Resource Consumption) · CWE-799 (Improper Control of Interaction Frequency)

---

## API5:2023 — Broken Function Level Authorization (BFLA)

**Factors.** Exploitability _Easy_ · Prevalence _Common_ · Detectability _Easy_ · Impact _Severe_. The attacker reaches a function they should not — anonymous or low-privilege calling admin/restricted functions.

Distinct from BOLA: BFLA is about **which function/endpoint** you may call; BOLA is about **which object** you may touch within an allowed function. Do **not** assume an endpoint is admin-only from its URL — admin functions are commonly mixed into regular paths (`/api/users`, not only `/api/admins`).

**Hunt for.**

- Admin/restricted handlers without a role/group guard: `@Admin`, `requireRole('admin')`, `@UseGuards(AdminGuard)`, policy checks absent.
- Method/verb confusion: a `GET` route protected but `DELETE`/`PUT` on the same path open, or role checks only on the listing view.
- Endpoints reachable by guessing the path/params (`/api/v1/users/export_all`, `/api/invites/new`) with no function-level check.
- Inconsistent authorization — a shared abstract admin controller that some admin handlers forget to inherit; per-endpoint ad-hoc checks instead of one enforced module.
- Front-end-only gating (hiding the button) with the route open on the server.

**Scenario.** A registration flow calls `GET /api/invites/{guid}`; the attacker changes the method/endpoint to `POST /api/invites/new` (admin-only, no BFLA check) and creates an invite with `"role":"admin"`, then self-creates an admin account. Or `GET /api/admin/v1/users/all` is reachable by a regular user who guessed the path.

**Prevent.**

- One consistent, easy-to-analyze authorization module invoked from all business functions; **deny by default**, grant explicitly per role.
- Admin controllers inherit an abstract admin controller that enforces role/group checks; admin functions inside regular controllers check explicitly.
- Review endpoints against BFLA with the role/group hierarchy and business logic in mind.

**Proposed-fix shape.** "At `file:line`, gate `POST /api/invites/new` (and all admin handlers) behind the authorization module — `@RequireRole('admin')` / inherit `AdminGuard`; deny by default. Audit sibling verbs on the same path. Centralize the check instead of ad-hoc per-route."

**Refs.** [Forced Browsing](https://owasp.org/www-community/attacks/Forced_browsing) · [Access Control](https://owasp.org/www-community/Access_Control) · CWE-285 (Improper Authorization)

---

## API6:2023 — Unrestricted Access to Sensitive Business Flows

**Factors.** Exploitability _Easy_ · Prevalence _Widespread_ · Detectability _Average_ · Impact _Moderate/Business-specific_. Technical impact is often nil; the harm is to the **business** — scalping, spam, reservation hoarding, referral-fraud. It is not "the endpoint is broken" — it is "a legitimate flow is abused at scale."

An endpoint exposes a sensitive business flow without restricting **automated, excessive** access to it. Which flows are sensitive is business-relative (spam-posts are risk to one social net, encouraged by another).

**Hunt for.**

- Flows where automation harms the business: purchase/checkout (scalping), booking/reservation (hoarding slots/seats), comment/post/DM creation (spam), referral/invite/credit programs (fraud), vote/like/award (manipulation), password/OTP-less recovery.
- Legitimately reachable flows with no anti-automation: no device fingerprinting, no captcha/proof-of-work, no human-detection, no non-human-pattern detection, no IP/Tor/proxy blocking, no per-account/per-device concurrency cap.
- B2B/developer APIs consumed by machines that skip the protections user-facing flows get.

**Scenario.** On console release day, a distributed script buys most of the limited stock before real users. Or an attacker books 90% of a flight, cancels days before, forces a discount, buys one cheap seat. Or referral-farms fake signups to farm ride credit.

**Prevent.**

- **Business layer:** identify which flows harm the business if over-used.
- **Engineering layer:** slow automation — device fingerprinting (deny headless browsers), human detection (captcha / biometrics like typing patterns), non-human-pattern detection (sub-second add-to-cart→purchase), block Tor exit nodes / known proxies; lock down machine-consumed APIs.

**Proposed-fix shape.** "At `file:line` (purchase/booking/referral flow), add anti-automation: per-account + per-device concurrency/quota, captcha or proof-of-work, and non-human-pattern detection (reject sub-second add-to-cart→checkout). Block Tor/proxy. State that perfect prevention is impossible — the goal is to raise attacker cost."

**Refs.** [OWASP Automated Threats to Web Applications](https://owasp.org/www-project-automated-threats-to-web-applications/)

---

## API7:2023 — Server-Side Request Forgery (SSRF)

**Factors.** Exploitability _Easy_ · Prevalence _Common_ · Detectability _Easy_ · Impact _Moderate/Business-specific_. The server fetches a remote resource from a **user-supplied URL** without validating it, coercing it to hit internal/cloud-metadata targets.

Modern patterns make SSRF common (webhooks, file-fetch-from-URL, custom SSO, URL previews) and dangerous (cloud/K8s/Docker expose management channels on predictable HTTP paths like `169.254.169.254`). Blind SSRF (no response returned) is harder to exploit but still leaks. The risk cannot always be fully eliminated — weigh business need.

**Hunt for.**

- Any outbound HTTP client fed a URL from the client: `fetch(req.body.url)`, `axios(url)`, `requests.get(url)`, `http.Get(uri)`, `open-uri`/`URI.open`, headless-browser navigation to a user URL; webhook creation, image-from-URL, URL preview, avatar-by-URL, PDF-from-URL.
- No allowlist of schemes/hosts/ports; no block of internal ranges (`127.0.0.0/8`, `10/8`, `172.16/12`, `192.168/16`, `169.254/16`, `::1`, metadata endpoints) or DNS-rebind protection.
- HTTP redirects followed automatically (re-enables bypassing an initial allowlist check); raw upstream response returned to the client.

**Scenario.** `POST /api/profile/upload_picture {picture_url}` — attacker sends `localhost:8080` and port-scans via response timing. Or webhook creation sends a test request and returns the response, so the attacker targets `http://169.254.169.254/.../security-credentials/...` and reads cloud creds.

**Prevent.**

- Isolate the fetcher in the network — it should pull remote, not internal.
- Allowlist origins, URL schemes, ports, and accepted media types; disable HTTP redirects; use a maintained URL parser to avoid parsing-inconsistency bypasses; validate/sanitize input; **never** send raw upstream responses to the client.

**Proposed-fix shape.** "At `file:line`, do not `fetch(userUrl)` unvalidated. Resolve the host, reject internal/metadata ranges, enforce scheme+port allowlist, disable redirect-following (`redirect:'manual'`/`follow:false`), and do not return the raw response body to the client. Prefer a server-side allowlist of fetchable hosts."

**Refs.** [SSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html) · CWE-918 (Server-Side Request Forgery)

---

## API10:2023 — Unsafe Consumption of APIs

**Factors.** Exploitability _Easy_ · Prevalence _Common_ · Detectability _Average_ · Impact _Severe_. The target integrates with third-party APIs and trusts their responses more than user input — weaker validation, weaker transport, blind redirect-following, no timeouts.

If a third-party is compromised (or is attacker-controlled), its data becomes an injection/DoS/exfiltration vector into the consuming API.

**Hunt for.**

- Third-party responses used without validation/sanitization — stored straight to SQL/NoSQL, templated, `eval`'d, or deserialized (the well-known `'; drop db;--` repo name, or a SQLi payload riding through an enrichment service).
- Outbound calls to third parties over plain HTTP / with verification disabled (`rejectUnauthorized:false`, `NODE_TLS_REJECT_UNAUTHORIZED=0`).
- Blind redirect-following on third-party calls — a `308 Permanent Redirect` to `attacker.com` re-sends the request (with sensitive data) there.
- No timeout / no response-size cap / no retry-cap on third-party calls; no allowlist of third-party hosts.

**Scenario.** An address-enrichment service returns data that's stored into a SQL DB; attackers plant a SQLi payload via the third party and trigger a pull, exfiltrating data. Or a compromised health-data service `308`-redirects the consuming API to `attacker.com`, which re-posts the user's genome because redirects are followed blindly.

**Prevent.**

- Assess providers' security posture; enforce TLS on every integration.
- Validate/sanitize data received from integrated APIs before processing or passing it downstream.
- Maintain an allowlist of redirect destinations; do not blindly follow redirects; cap response size; set timeouts.

**Proposed-fix shape.** "At `file:line`, validate the third-party payload against a schema before storing/templating (treat it as untrusted as user input). Enable TLS verification (remove `rejectUnauthorized:false`). Disable auto-redirect or allowlist redirect targets (`maxRedirects:0` + explicit allowlist). Add a timeout + size cap on the response."

**Refs.** [Web Service Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Web_Service_Security_Cheat_Sheet.html) · [Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) · CWE-20 (Improper Input Validation) · CWE-200 (Exposure of Sensitive Information) · CWE-319 (Cleartext Transmission)

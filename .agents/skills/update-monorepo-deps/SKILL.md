---
name: update-monorepo-deps
description: Update and maintain dependencies, overrides, and sandbox testing for updates for a monorepo.
compatibility: Requiers pnpm or devbox
metadata:
    author: janbiasi
    version: "1.0"
---

First, run `pnpx taze --all --recursive` to retrieve the list of updateable dependencies.
Do not list major updates if the user instructs to prevent breaking changes.
Present the list to the developer and let them review.
After review, update the confirmed deps and install via `pnpm install`.

Re-check `pnpm audit` for any new vulnerabilities and potentially required overrides.
Continue with the update process for overrides by running the following prompt in a subagent:

```
We need to patch current >= high vulnearbilities in the project; be careful about duplicated and/or transitive dependencies (i.E. tmp bricks lerna/nx publishing on update).
Check the [docs/dependency-relations.md](docs/dependency-relations.md) for initial details and keep those in mind during sandbox testing.
Please evaluate which updates/overrides work and which wont in isolated sandboxes.
Document revealed relations of dependencies and overrides in [docs/dependency-relations.md](docs/dependency-relations.md).
```

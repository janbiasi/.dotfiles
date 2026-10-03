---
name: essentx-triage
description: Triage Essentx CVE or GHSA findings into a schema-valid vulnerability analysis. Use when asked to fill in, update, challenge, or review an Essentx analysis JSON, SBOM finding, CVE, or GHSA.
disable-model-invocation: true
metadata:
    author: janbiasi
    version: "1.0"
---

# Essentx triage

Use a **challenge** loop: a scanner finding is a hypothesis, not a conclusion. Produce one evidence-backed assessment for every requested finding.

## 1. Establish the contract

1. Use the supplied analysis file. If none is supplied, use `.essentx/analysis.json`.
2. Read the whole file, then read [the Essentx schema](references/analysis.schema.json) before editing.
3. Treat every key in `analysis` as an independent finding. Keep the root shape and `$schema` entry unchanged.

Completion criterion: the target file, every requested CVE/GHSA, and the allowed output fields and values are known.

## 2. Retrieve the current findings

When current findings are needed, inspect the project's GitHub Actions workflows for the Essentx step. Find the latest relevant successful run for the target commit, then download its `essentx-findings` artifact with the GitHub CLI. Extract and read the JSON inside the artifact before changing the analysis file.

Use `gh run list` to identify the run and `gh run download <run-id> --name essentx-findings --dir <temporary-directory>` to retrieve it. A user-supplied artifact URL or run ID takes precedence over a later run. Do not treat an artifact from a different commit as proof of the current dependency graph.

Prefer the GitHub artifact over an old local report. If the current run says no new vulnerabilities were detected,
keep the existing analysis intact and report that there is nothing to triage. If GitHub authentication, artifact access,
or the latest run is unavailable, state that limitation and use only explicitly supplied or local findings; never invent a finding.

Completion criterion: each requested finding is traceable to the supplied report or the latest available Essentx artifact.

## 3. Challenge each finding

For each CVE/GHSA, gather evidence before choosing a state:

1. Identify the affected component, installed version, affected and fixed ranges, vulnerability mechanism, and exploit prerequisites from the advisory.
2. Prove whether the affected component is in the shipped SBOM or artifact. Check the lockfile or dependency metadata, build files, container or deployment configuration, and generated artifact where relevant.
3. Trace the vulnerable feature through production code and configuration. Distinguish an installed package from an invoked code path; account for tree-shaking, server/client boundaries, runtime environment, transitive dependencies, and externally controllable inputs.
4. Challenge the provisional conclusion with the strongest contrary case. For example: a transitive dependency may still be bundled; a feature may be reachable through an indirect wrapper; production configuration may differ from development; or an update may not remove every affected instance.
5. Record only the conclusion supported by repository and advisory evidence. If the available evidence cannot settle exploitability, use `in_triage` rather than claiming `not_affected`.

Completion criterion: every finding has evidence for both the claimed state and the main way that claim could have been wrong.

## 4. Select a schema-valid assessment

Write all four fields for every assessed finding: `state`, `justification`, `response`, and `detail`.

- Use `not_affected` only when the component is present but the vulnerability cannot affect the shipped service. Its justification must name the actual blocker: absent code, unreachable code, required configuration, dependency, environment, compiler setting, runtime protection, perimeter protection, or mitigating control.
- Use `false_positive` only when the finding was incorrectly associated with this component or service.
- Use `resolved` only when the shipped artifact has been remediated. Match the response to the remediation: `update`, `rollback`, or `workaround_available`.
- Use `exploitable` when the vulnerable path and its prerequisites are present or cannot be ruled out. State the intended remediation response.
- Use `in_triage` when the evidence is incomplete. State what must still be verified and the intended response.

Choose the response literally:

- `update` means a remediation version is shipped;
- `rollback` means reverting removes exposure;
- `workaround_available` means a documented operational workaround exists;
- `will_not_fix` means no remediation is needed or planned;
- `can_not_fix` means remediation is impossible.

Select only values permitted by the schema.

Make `detail` concise but auditable. Include the affected package and version, the relevant vulnerability prerequisite
or fixed version, the repository evidence, and why that evidence supports the chosen state and response. Do not report
a package as absent merely because application code has no direct import; dependency and artifact evidence decide that question.

Completion criterion: each finding has a specific, evidence-backed state, justification, response, and detail; no detail relies on an unverified inference.

## 5. Verify and publish the assessment

1. Confirm the JSON parses.
2. Check every entry has only schema-defined fields and uses values allowed by the Essentx/CycloneDX contract.
3. Re-read every `not_affected`, `false_positive`, and `resolved` entry against the evidence. A finding must remain `in_triage` when its decisive premise is unproven.
4. Run the repository's Essentx CI workflow or its local equivalent. Download the resulting findings artifact when available and confirm that the analysis was accepted and no untriaged new vulnerabilities remain.
5. Report the findings assessed, their final states, and any findings left in triage with the missing evidence.

Completion criterion: the target JSON is valid, every changed finding survives a final challenge, and Essentx has accepted the updated analysis when CI access is available.

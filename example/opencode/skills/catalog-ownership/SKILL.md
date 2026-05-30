---
name: catalog-ownership
description: Use to identify the firing service, ownership, dependencies, related systems, and escalation owner candidates for a 1stLine alert using trusted catalog, repository, and 1stLine context.
license: MIT
---

# Catalog Ownership

Use this skill when an alert includes a service name, component name, repository, team hint, catalog entity reference, owner label, namespace, deployment name, or dependency clue.

## Verified Inputs

Use only the context, tools, and source list that Concierge already verified and passed to this subagent. Prefer verified sources in this order:

1. Catalog context passed by Concierge.
2. 1stLine read-only results or tools that Concierge marked usable.
3. Catalog/Backstage/Compass/CMDB tools that Concierge marked usable.
4. Trusted repository metadata already fetched or explicitly approved, for example `catalog-info.yaml`, `CODEOWNERS`, `README`, service manifests, deployment manifests, or package metadata.
5. Alert labels and annotations supplied by Concierge.

Never treat a naming convention as authoritative ownership. Mark it as low confidence unless a catalog, repository, or 1stLine source confirms it.

## Entity Resolution

Normalize all candidate identities:

- Service/component: exact label value, lowercased variants, Kubernetes workload names, repository names, and catalog entity refs like `component:namespace/name`.
- Owner: team, group, user, email, Slack handle, Discord user, or 1stLine user UID.
- Dependencies: `dependsOn`, `dependencyOf`, `partOf`, `system`, deployment namespace, datasource, dashboard folder, queue/topic, database, API, or upstream/downstream labels.

For Backstage-style catalog data, prefer `spec.owner`, relations such as `ownedBy`, `dependsOn`, `dependencyOf`, and `partOf`, and annotations that link to repos, dashboards, runbooks, or incident services.

## Workflow

1. Extract service identifiers from alert labels, title, annotations, payload metadata, dashboard links, schema fields, and matched rules.
2. Use exact identifiers first. Only then try normalized aliases with verified tools or context.
3. Resolve owner candidates from catalog ownership, 1stLine teams/users, repository owners, and CODEOWNERS.
4. Resolve dependencies and related services that could explain the alert or be affected by it.
5. Identify which related services the monitoring expert should inspect next.
6. Identify which owners or teams the escalation expert should check in destination-platform history.
7. Assign confidence:
   - `high`: direct catalog or 1stLine ownership match.
   - `medium`: repository ownership plus matching service metadata.
   - `low`: label/title inference or stale/partial source.
8. Record unresolved gaps explicitly without trying new unverified sources.

## Safety Rules

- Do not open runbook or repository links unless Concierge already marked the source trusted or explicitly allowed.
- Do not use mutating catalog tools, even if available.
- Do not recommend ownership changes.
- Do not include secrets, raw tokens, or private URLs unless they were already present in user-facing alert context.

## Report Template

Return a compact report:

```text
service_identity:
  canonical:
  aliases:
  confidence:
owners:
  - name:
    type:
    source:
    confidence:
dependencies_to_check:
  - service:
    relation:
    reason:
recommended_escalation_owner_checks:
  - owner_or_team:
    reason:
monitoring_hints:
  - resource:
    reason:
evidence:
  - source:
    detail:
gaps:
  - missing_or_failed_lookup:
```

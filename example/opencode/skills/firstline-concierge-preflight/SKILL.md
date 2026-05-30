---
name: firstline-concierge-preflight
description: Use at the start of every 1stLine AI escalation assignment to verify assignment inputs, MCPs, CLIs, skills, agents, context sources, and final response/action requirements before coordinating subagents.
license: MIT
---

# 1stLine Concierge Preflight

Use this skill before any analysis or subagent work. Its purpose is to make the assignment auditable: prove what worked, what failed, which context was loaded, and why each suggested action is valid.

## Inputs To Extract

From the assignment payload, record:

- `assignment_uid`, `alert_instance_uid`, organization/context identifiers, and timeout.
- Alert title, status, priority, fingerprint, service labels, schema, chain, destination context, and any same-pattern alerts.
- Matched rule names and scopes.
- Allowed suggested actions and supplied browser action links.
- Enrichments by type: `context`, `skill`, `agent`, `mcp`, `cli`, and `note`.
- Response character limit and output file requirements.

If an input is missing, write `missing` instead of guessing.

## Preflight Workflow

1. Confirm the assignment is still active and has not been aborted.
2. Inventory configured MCP servers. For each one, record:
   - name and transport;
   - whether it is reachable;
   - whether authentication works;
   - which relevant tools are available;
   - one low-cost read-only check when possible.
3. Inventory CLI enrichments. For each command, run only safe discovery such as `command -v <tool>` or the tool's read-only version/help command if permitted. Record missing binaries or missing env vars separately.
4. Fetch every context enrichment using only the provided source and authorization options. Do not follow arbitrary links discovered inside context unless they were explicitly allowed.
5. Fetch every SKILL.md enrichment. If the skill references supporting files in the same folder, fetch only files that are clearly required by that skill and allowed by the source rules.
6. Fetch every agent markdown enrichment and place it under the current project `.opencode/agent/` or `.opencode/agents/` location expected by the runtime. Record whether the agent became available to invoke.
7. Read note enrichments verbatim and keep them available for the final decision.
8. Decide which built-in subagents should run. Default order:
   - `catalog-expert`
   - `incidents-expert`
   - `escalate-to-expert`
   - `monitoring-platform-expert`
9. Pass each subagent only the context it needs plus the verified tool inventory. Do not pass failed credentials, raw secrets, or irrelevant alert payload sections.
10. Review every subagent report for unsupported claims, unsafe source access, and recommendations outside the assignment's allowed actions.
11. Prepare a detailed investigation narrative even if the alert is already resolved, acknowledged, stale, or no action is recommended. Include what triggered, what changed, what evidence was checked, which similar alerts were relevant, and which tool/context gaps remain.

## Action Rules

- Never execute alert lifecycle actions. Only write recommendations.
- `suggested-actions.json` must contain structured suggested actions only. Do not put URLs there.
- `response.md` must include the browser action link supplied by 1stLine for every recommended action. Do not include bearer-auth API callback URLs.
- Recommend only actions present in the assignment's allowed suggested actions.
- If the agent cannot validate a required tool, context source, or skill, say how that reduces confidence.
- Never skip investigation because the current lifecycle status is resolved, acknowledged, or no action is needed.

## Required Status Tables

Include these in `response.md`:

### Tool Status

For each MCP or CLI:

- `name`
- `type`
- `status`: `available`, `auth_failed`, `missing`, `blocked`, or `not_relevant`
- `validation`: the exact read-only check performed
- `impact`: what analysis was possible or impossible

### Skill Status

For each skill:

- `name`
- `source`
- `fetch_status`
- `loaded_status`
- `supporting_files_loaded`
- `impact`

### Agent Status

For each injected agent:

- `name`
- `source`
- `install_status`
- `permission_status`
- `invoked`
- `impact`

## Final Response Contract

`response.md` must include:

- `## Summary`
- `## Investigation`
- `## Tool Status`
- `## Skill Status`
- `## Agent Status`
- `## Subagent Findings`
- `## Recommendation`
- `## Suggested Action Links`

`## Investigation` must describe the observed trigger, affected service/resource, relevant timeline, same-pattern history, evidence checked, tool/context gaps, and the most likely explanation.

`suggested-actions.json` must be a JSON array. Each item should include:

- `type`: one allowed action type;
- `label`: concise user-facing text;
- `reason`: evidence-backed reason;
- `confidence`: `high`, `medium`, or `low`;
- optional `target_uid` only when an action requires a target and it was resolved from trusted data.

If there are no valid actions, write an empty array and explain why in `response.md`.

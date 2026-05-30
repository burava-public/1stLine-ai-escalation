---
name: escalate-to-routing
description: Use to identify whether a specific responder should be suggested for Escalate To by correlating 1stLine flow data with trusted Slack, Discord, Teams, or other destination-platform history.
license: MIT
---

# Escalate To Routing

Use this skill only when Concierge says the assignment allows `escalate_to` or `escalate_further` and has passed enough verified destination or 1stLine flow context to evaluate a human target.

## Required Evidence

Suggest `escalate_to` only when all are true:

1. Destination-platform history or 1stLine context identifies a likely responder.
2. The responder maps to a real 1stLine user, team member, or escalation flow participant.
3. The responder is currently in the applicable 1stLine flow or is explicitly allowed for this alert.
4. Concierge says the assignment allows the suggested action.

Never suggest a person based only on a service name, team name, or one old message.

## Verified Inputs

Use only sources Concierge already verified and passed to this subagent. Prefer:

1. Current 1stLine escalation flow, chain, line, schedule, and assignment context.
2. Destination-platform channel/thread where this alert was routed.
3. Recent destination-platform history for the affected service/team.
4. Catalog ownership results from the catalog expert.
5. Alert labels and notes.

For Slack, prefer a known channel/thread from the alert and use only Slack history/search tools Concierge marked usable. For Discord, use known channel/message/thread IDs and verified message-history tools. Do not scrape arbitrary channels.

## Workflow

1. Read the allowed action set and verified flow/destination inventory from Concierge.
2. Resolve or inspect the current 1stLine flow using verified data/tools:
   - chain;
   - active line;
   - current and next responders;
   - teams and users in scope.
3. Determine where the alert was sent: Slack channel/thread, Discord channel/thread, Teams chat, email, or another destination.
4. Search or inspect only relevant verified destination history:
   - current alert thread first;
   - same service/fingerprint discussions;
   - recent messages from on-call/SRE users mentioning escalation or handoff.
5. Identify responder candidates and normalize identities:
   - display name;
   - platform handle;
   - email;
   - 1stLine user UID;
   - team/line membership.
6. Reject candidates who cannot be mapped to 1stLine or current flow context.
7. Prefer `escalate_to` for a specific mapped user. Prefer `escalate_further` when evidence supports moving through the configured flow but not a specific user.

## Confidence Rules

- `high`: multiple recent messages plus 1stLine flow membership.
- `medium`: one strong recent message plus catalog/flow confirmation.
- `low`: weak destination evidence or partial identity mapping. Do not suggest `escalate_to`; report as a gap.

## Report Template

Return:

```text
flow_context:
  chain:
  active_line:
  current_responders:
candidate_responder:
  name:
  platform_identity:
  firstline_user_uid:
  confidence:
flow_membership_check:
  in_flow:
  evidence:
evidence_messages:
  - platform:
    channel_or_thread:
    timestamp:
    summary:
suggested_actions:
  - type:
    target_uid:
    reason:
confidence:
gaps:
  - missing_or_failed_lookup:
```

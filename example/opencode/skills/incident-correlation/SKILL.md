---
name: incident-correlation
description: Use to compare a 1stLine alert with previous incidents, timelines, mitigations, and postmortems before suggesting start_incident or join_incident actions.
license: MIT
---

# Incident Correlation

Use this skill when deciding whether a current alert should start a new incident, join an existing incident, or avoid incident escalation.

## Verified Inputs

Use only the incident, alert-history, destination-platform, and postmortem sources that Concierge already verified and passed to this subagent. Prefer:

1. 1stLine incident and alert history from verified read-only tools.
2. Verified incident-management tools, such as PagerDuty, Opsgenie, ServiceNow, Jira, or incident.io style tools.
3. Trusted incident/postmortem context already fetched or explicitly approved by Concierge.
4. Alert same-pattern history and destination-platform discussion context supplied by Concierge.

Do not create, update, acknowledge, or resolve incidents. This skill is analysis-only.

## Similarity Signals

Compare current and past incidents by:

- service/component/owner;
- fingerprint or same-pattern key;
- title and label overlap;
- error message shape, metric query, log pattern, alert rule UID, dashboard UID, or panel ID;
- priority/severity and detected level;
- customer impact or blast radius;
- timeline, recurrence, and duration;
- mitigation, rollback, deploy, or config change pattern;
- responder/team involved.

Prefer a narrow high-similarity incident with a useful postmortem over broad keyword matches.

## Workflow

1. Summarize the current alert in one line: service, status, priority, symptom, and time window.
2. Search or inspect verified incident sources by exact service/fingerprint first.
3. Search by alert title, labels, and error pattern only after exact searches and only with verified tools.
4. If there is an active related incident, evaluate `join_incident`.
5. If similar past incidents caused material customer impact or required coordinated mitigation, evaluate `start_incident`.
6. Read postmortems only from sources Concierge marked trusted.
7. Extract transferable facts:
   - root cause or suspected fault domain;
   - detection signal;
   - mitigation that worked;
   - responders or teams involved;
   - what differs from the current alert.
8. Decide severity:
   - `start_incident`: ongoing impact, P1/P2, repeated firing, broad blast radius, or postmortem says coordinated response is required.
   - `join_incident`: existing active incident matches the alert.
   - no incident action: resolved, isolated, no active impact, or insufficient evidence.

## Evidence Rules

- Every incident recommendation needs at least one concrete source: incident UID/link, postmortem title, alert history row, or tool result summary.
- State when no postmortem was available.
- Do not imply customer impact unless the source says so.
- Do not recommend `start_incident` or `join_incident` if Concierge says the assignment does not allow that action.

## Report Template

Return:

```text
current_alert:
  service:
  status:
  priority:
  symptom:
matched_incidents:
  - id:
    title:
    status:
    similarity:
    evidence:
matched_postmortem_takeaways:
  - incident:
    useful_takeaway:
    current_relevance:
incident_severity_assessment:
  recommendation:
  confidence:
  rationale:
suggested_actions:
  - type:
    reason:
    target_uid:
evidence:
  - source:
    detail:
gaps:
  - missing_or_failed_lookup:
```

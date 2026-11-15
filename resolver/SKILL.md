---
name: resolver
description: Resolve a Jira ticket, open a draft PR, and post the analysis on Jira. Use when the user says resolver, /resolver, or passes a ticket key like PROJ-123 as the work to resolve. Read-only Jira questions belong to jira.
---

Resolve `{TICKET}` using `jira` and `pr-create`. Follow these steps in order. Uppercase `{PLACEHOLDERS}` are values you fill in.

Before starting, create an internal TODO using the native `todo` tool: one item per step below and a separate **Wait! Question the premise** item between evidence and implementation. Keep it updated throughout the workflow; a prose checklist is not a substitute.

**Wait! is mandatory and blocks implementation.** Complete that item only after stating an evidence-backed conclusion about the actual problem, the proposal's viability, and whether the cause belongs to our code. Do not edit code unless that assessment justifies an in-scope fix.

**1. Read the ticket.** Fetch the ticket provided by the user and read its description and all comments, prioritizing clarifications and decisions. Missing or ambiguous key → ask.

**2. Gather context.** Analyze the related tickets, including epics and spikes, and read their comments. Use them as context, not as additional scope.

**3. Gather evidence.** Analyze the affected code and consult logs only when necessary to understand or confirm the reported failure.

**Wait! question the premise before fixing.** What is the ticket really proposing? What underlying need or problem is behind it? Is the proposal viable, and is the cause actually in our code? Distinguish the problem from the suggested solution. If the evidence challenges the ticket's premise or ownership, explain that before editing; do not force a fix just because the ticket asks for one.

**4. Fix and verify.** Propose and implement the smallest change that resolves strictly the problem stated in the ticket. Follow project conventions. No unrelated fixes, refactors, or cleanup. Verify the affected cases and that behavior outside the ticket remains unchanged. Unclear scope → ask before editing.

**5. Create the PR.** Follow `pr-create` for the verified fix. No changes or no successful verification → stop and report. Do not mark the PR ready.

**6. Post the analysis.** Show the comment body, then post it on the ticket with `jira`, after the PR exists. This workflow requests the comment; no additional confirmation is needed. Do not change the ticket's status or fields.

Use the ticket's language, confirmed facts, and this Jira wiki-markup structure. Omit the logs section when logs were not consulted. Repeat cases and fixes as needed.

```
h3. Análisis

{WHAT_WORKS_AND_WHAT_FAILS}

*1. {CASE}*
{TRIGGER_CAUSE_AND_USER_VISIBLE_EFFECT}

h3. Visto en los logs de {ENVIRONMENT}

* [{WHAT_THIS_EVIDENCE_SHOWS}|{LOG_URL}]

h3. Solución en {COMPONENT}

PR: [{PR_TITLE}|{PR_URL}]

# {FIX_FOR_EACH_ANALYZED_CASE}
```

Return the PR URL and the comment id, or the reason you stopped.

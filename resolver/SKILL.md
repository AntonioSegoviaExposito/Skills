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

**Wait! question the premise before fixing.** Run this step in a forked session of the current context (`PI_SESSION_ID`) so it evaluates all gathered evidence without altering anything, capture its session id (`FORK_ID`), and wait for its answer before continuing:

```bash
FORK_OUT=$(omp --fork "$PI_SESSION_ID" --no-tools --no-lsp --mode json -p "Ignore any pending tool call from the parent session. Using only the evidence already gathered in this session, answer this without changing anything: Wait! Question the premise before fixing and answer these questions without changing anything: What is the ticket really proposing, and what underlying need or problem is behind it? Is everything the ticket proposes viable—and whether it is or isn't, what is the reality of developing this ticket? What is out of scope, and is the cause actually in our code? Why? Finally, include an analysis of any gaps, edge cases, and key precautions to keep in mind when designing and implementing this change.")
FORK_ID=$(printf '%s\n' "$FORK_OUT" | jq -r 'select(.type=="session") | .id')
printf '%s\n' "$FORK_OUT" | jq -r 'select(.type=="agent_end") | .messages[-1].content[] | select(.type=="text") | .text'
```

Use the fork's answer to state your evidence-backed conclusion and complete the **Wait!** item. Distinguish the problem from the suggested solution. If the evidence challenges the ticket's premise or ownership, explain that before editing; do not force a fix just because the ticket asks for one.

**4. Business-decision gate.** Before implementing, assess whether any business decision is too critical to infer and requires explicit stakeholder or user approval, or whether the gathered evidence supports the implementation approach with high confidence. If approval is needed, stop and ask now; otherwise, proceed.

**5. Fix and verify.** Propose and implement the smallest change that resolves strictly the problem stated in the ticket. Follow project conventions. No unrelated fixes, refactors, or cleanup. Verify the affected cases and that behavior outside the ticket remains unchanged. Unclear scope → ask before editing.

**6. Create the PR.** Follow `pr-create` for the verified fix. No changes or no successful verification → stop and report. Do not mark the PR ready.

**Wait! review the PR with the same fork.** Resume `FORK_ID` with tools enabled (`--auto-approve`, read-only inspection) and pass the PR URL so the fork—still free of implementation bias and holding the original `Wait!` analysis—reviews the PR against the ticket, business intent, and project conventions:

```bash
omp --resume "$FORK_ID" --auto-approve --no-lsp --mode json -p "I have proposed this fix for the ticket in {PR_URL}. Without editing any files, can you inspect the PR and analyze whether it fits and makes sense? it solves the root business problem? Is the solution well-designed, strictly within the ticket's scope, and aligned with project standards?" \
  | jq -r 'select(.type=="agent_end") | .messages[-1].content[] | select(.type=="text") | .text'
```

Evaluate the fork's response in the main agent:
- If it identifies a valid defect or scope mismatch, apply the fix, verify, and push the update to the PR before proceeding.
- If it raises something that does not apply given our confirmed analysis, note why and discard it without making unnecessary changes.

**7. Post your own analysis.** Show the comment body, then post it on the ticket with `jira`, after the PR exists (and after any follow-up fix from the **Wait! review the PR** check is pushed). This workflow requests the comment; no additional confirmation is needed. Do not change the ticket's status or fields.

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

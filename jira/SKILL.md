---
name: jira
description: Query Jira and post comments on tickets assigned to the token user. Use when the user asks about Jira tickets, sprints, assignments, epic status, tickets like PROJ-123, or wants to comment on a Jira ticket.
---

Query Jira Server/Data Center with `scripts/jira-query.sh`, relative to this skill's directory: read a ticket, search with JQL, or comment. The only write is a comment, and only on a ticket assigned to the token user. Never change status, fields, or attachments. Uppercase `{PLACEHOLDERS}` are values you fill in.

Any failure exits non-zero with `error:` on stderr and nothing on stdout. Report it and stop; never treat it as an empty result.

Read a ticket. Returns JSON with `key`, `summary`, `description`, `assignee`, `links`, and `comments`:

```bash
scripts/jira-query.sh {TICKET}
```

Search with JQL, up to 50 tickets. Write it without `project =`: the script scopes every search to `JIRA_PROJECT` and keeps any `ORDER BY` at the end.

```bash
scripts/jira-query.sh "{JQL}"
```

Useful filters: `assignee = currentUser()` for my tickets, `assignee = currentUser() AND sprint in openSprints()` for my sprint tasks, `sprint in openSprints()` for the whole sprint, and `"Epic Link" = {EPIC}` for epic children (`"Parent Link"` with Advanced Roadmaps).

Comment only when the user asked to post, and show them the wiki-markup body first if they have not seen it. The script refuses unless the ticket is assigned to the token user.

```bash
scripts/jira-query.sh comment {TICKET} <<'EOF'
{BODY}
EOF
```

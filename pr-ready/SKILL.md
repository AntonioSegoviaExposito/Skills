---
name: pr-ready
description: Update the open PR body with a business-logic template and mark it ready for review. Use when the user says /pr-ready, wants the PR description filled, or asks to mark a draft PR ready.
---

Fill the body of the ticket's open PR with its business behavior and mark it ready for review. Never switch branches and never invent a PR. Uppercase `{PLACEHOLDERS}` are values you fill in.

**1. Resolve ticket.** Take the first source that yields `{TICKET}`, in this order:

- **Conversation.** It identifies the ticket with total clarity: the user passed it, or exactly one ticket appears explicitly and the work discussed is that ticket. Wins over the current branch. Several tickets or any doubt → next source.
- **Branch.** Current branch `feature/{X}` → `X`.
- Anything else → **STOP**. Never guess the ticket from Jira.

**2. Validate.** Find the open PR of the ticket's branch:

```bash
gh pr list --head feature/{TICKET} --state open --json number,title,url,isDraft
```

No PR → **STOP** and suggest `pr-create`. Never take a PR number from the conversation or arguments. Then fetch that exact ticket with `jira` and check that its summary and description describe the same work as the PR title and diff, and the conversation if there is one. No match or fetch fails → **STOP** and do not edit the PR. Skip the Jira check when the ticket was already read in this conversation and the current branch is `feature/{TICKET}`.

**3. Analyze** the PR without switching branches:

```bash
gh pr diff {NUMBER}
gh pr view {NUMBER} --json commits
```

Read a whole file only when the diff is not enough to explain the business impact, and read it from the PR branch:

```bash
git fetch origin feature/{TICKET}
git show origin/feature/{TICKET}:{PATH}
```

Domain context comes only from the Jira ticket. Leave out implementation details unless a user-visible change needs them.

**4. Write the body** in English with this structure:

```markdown
## ⚠️ This PR is waiting for merge

### Behavior before this change
- {BEFORE}

### Expected behavior after this change
- {AFTER}

### Configuration
| Property | Default | Description |
|----------|---------|-------------|
| `{PROPERTY}` | `{DEFAULT}` | {DESCRIPTION} |
```

`{BEFORE}` is what was broken, missing, or inconsistent for the business or the user; `{AFTER}` is what works now. One sentence per bullet, one to three bullets per section, business and user impact only, and only what the diff, the commits, or the ticket support; anything uncertain stays out. Keep `Configuration` only when the PR changes feature flags, one row per flag.

**5. Update and mark ready.** Pass the body through a heredoc, never with `--body "..."`:

```bash
gh pr edit {NUMBER} --body-file - <<'EOF'
{BODY}
EOF
```

Draft → `gh pr ready {NUMBER}`. Already ready → leave the review state unchanged.

Return the PR URL, whether the body was updated, whether it was marked ready, and a one-sentence summary of the description.

---
name: pr-create
description: Resolve the ticket, move to or create its feature branch, commit, push, and open a draft PR to develop. Use when the user says /pr-create, wants a draft pull request, or asks to commit and open a PR.
---

Open a draft pull request to `develop` for the changes you made, under a valid ticket. Follow these steps in order and never invent another path. Uppercase `{PLACEHOLDERS}` are values you fill in.

**1. Resolve ticket.** Take the first source that yields `{TICKET}`, in this order:

- **Conversation.** It identifies the ticket with total clarity: the user passed it, or exactly one ticket appears explicitly and the work discussed is that ticket. Wins over the current branch. Several tickets or any doubt → next source.
- **Branch.** Current branch `feature/{X}` → `X`.
- **Sprint.** On `develop` → `jira`: current-sprint tasks assigned to the user. Pick the one whose summary matches the conversation. Still unresolved → ask. Do not guess.
- Anything else (e.g. `main`) → **STOP**.

**2. Validate.** Fetch that exact ticket with `jira` and check that its summary and description describe the same work as the conversation and the local changes (`git diff`). No match or fetch fails → **STOP** and report. Do not touch git. Skip the Jira check when the ticket was already read in this conversation and the current branch is `feature/{TICKET}`.

**3. Move to `feature/{TICKET}`.** Check where it exists:

```bash
git branch --list feature/{TICKET}
git ls-remote --heads origin feature/{TICKET}
```

- Already on it → stay.
- Exists locally or on `origin` → `git checkout feature/{TICKET}`.
- Does not exist → create it from updated `develop`, never from the current HEAD:
  ```bash
  git checkout develop
  git pull --ff-only origin develop
  git checkout -b feature/{TICKET}
  ```
- Any checkout or pull fails (uncommitted changes conflict, diverged history) → **STOP** and report. Never stash, force, or discard changes.

Uncommitted changes travel with the switch. Commits on the previous branch stay there.

**4. Commit and push.** Stage only the files you created, edited, or deleted yourself in this session. Every other change stays out of the commit and untouched in the working tree.

```bash
git add -- {PATHS}
git commit -m "{MESSAGE}"
git push -u origin HEAD
```

`{MESSAGE}` is a short English description without the ticket ID. Nothing staged → skip the commit and push.

**5. Open the PR.** The branch may already have one:

```bash
gh pr list --head feature/{TICKET} --state open --json url -q '.[0].url'
```

Returns a URL → return it and stop. Otherwise create a draft:

```bash
gh pr create --base develop --title "[{TICKET}] {TITLE}" --body "" --draft --label "pr-verify/force-on-draft"
```

`{TITLE}` is a concise, business-level English title. The body stays empty and the label is always `pr-verify/force-on-draft`. Return the PR URL.

# Skills

Agent skills, one folder per skill with its `SKILL.md`.

| Skill | Does |
|-------|------|
| `ask-me` | Interviews you about a plan until every decision is settled |
| `zoom-out` | Re-explains the current work in prose, from the bigger picture down to user behavior |
| `jira` | Reads Jira tickets, searches with JQL and comments on your own tickets |
| `pr-create` | Resolves the ticket, moves to its branch, commits, pushes and opens a draft PR |
| `pr-ready` | Writes the PR description from the business behavior and marks it ready |
| `pr-reply` | Drafts evidence-based replies to review comments and posts them after your OK |
| `sync-skills` | Updates the installed skills from this repository |

## Install

Paste this prompt into the agent you want to install the skills into. It installs them in that agent's own skills folder, asks you for the settings the skills need, and checks that they work.

```text
Install the skills from the GitHub repository AntonioSegoviaExposito/Skills into your own global skills folder: the one that you, the agent reading this, load skills from, not the folder of another agent or tool. If you are not certain which folder that is, ask me before writing anything.

1. Check the prerequisites: `gh auth status` must succeed, and `curl` and `jq` must be installed. If something is missing, tell me how to fix it and stop.
2. Install, with <SKILLS_DIR> replaced by the absolute path of your skills folder:
   mkdir -p <SKILLS_DIR> && gh api repos/AntonioSegoviaExposito/Skills/tarball | tar -xzf - -C <SKILLS_DIR> --strip-components 1 --exclude README.md --exclude .gitignore
   This overwrites the skills with the same name and leaves every other file in the folder untouched.
3. Configure: for every <SKILLS_DIR>/*/scripts/env.example that has no scripts/env next to it, ask me for each variable, one skill at a time, using the comments in the file to explain what each one is. Write my answers to scripts/env in the same format, keep the example value when I say so, and chmod 600 the file. Never repeat a secret such as a token back in the chat.
4. Verify every skill you configured with a read-only command from its SKILL.md, for jira a search such as "assignee = currentUser()", and tell me the result or the error.
5. Finish with the list of installed skills and tell me to start a new session so you load them.
```

To update later, ask the agent to sync the skills (`sync-skills`). Settings in `scripts/env` are kept.
---
name: pr-reply
description: Evaluate unanswered PR review comments and draft evidence-based replies. Use when the user says /pr-reply, wants to answer Copilot or reviewer comments, or asks to reply on a pull request.
---

Answer the unanswered review comments on the ticket's open PR with evidence-based replies, posted only after the user confirms. Never invent a PR. Uppercase `{PLACEHOLDERS}` are values you fill in; lowercase `{owner}` and `{repo}` are filled by `gh`.

**1. Resolve ticket.** Take the first source that yields `{TICKET}`, in this order:

- **Conversation.** It identifies the ticket with total clarity: the user passed it, or exactly one ticket appears explicitly and the work discussed is that ticket. Wins over the current branch. Several tickets or any doubt → next source.
- **Branch.** Current branch `feature/{X}` → `X`.
- Anything else → **STOP**. Never guess the ticket from Jira.

**2. Validate.** Find the open PR of the ticket's branch:

```bash
gh pr list --head feature/{TICKET} --state open --json number,title,url
```

No PR → **STOP** and suggest `pr-create`. Never take a PR number from the conversation or arguments. Then fetch that exact ticket with `jira` and check that its summary and description describe the same work as the PR title and diff (`gh pr diff {NUMBER}`), and the conversation if there is one. No match or fetch fails → **STOP**; do not fetch comments or post. Skip the Jira check when the ticket was already read in this conversation and the current branch is `feature/{TICKET}`.

**3. Move to `feature/{TICKET}`** so you can read its code. Already on it → stay. Otherwise `git checkout feature/{TICKET}`. Fails (e.g. uncommitted changes conflict) → **STOP** and report. Never stash, force, or discard changes.

**4. Fetch the unanswered comments:**

```bash
gh api graphql -F owner='{owner}' -F repo='{repo}' -F number={NUMBER} -f query='
query($owner:String!,$repo:String!,$number:Int!){
  viewer{login}
  repository(owner:$owner,name:$repo){pullRequest(number:$number){
    reviewThreads(first:100){nodes{isResolved comments(first:100){nodes{databaseId author{login} path line originalLine body diffHunk}}}}
    reviews(first:100){nodes{author{login __typename} state body url}}
    comments(first:100){nodes{author{login __typename} body createdAt url}}
  }}
}' --jq '.data.viewer.login as $me | .data.repository.pullRequest as $pr
| ([$pr.comments.nodes[] | select(.author.login == $me) | .createdAt] | max) as $last
| {
    threads: [$pr.reviewThreads.nodes[] | select(.isResolved | not) | .comments.nodes
      | select(all(.[]; .author.login != $me)) | .[0]
      | {id: .databaseId, author: .author.login, file: .path, line: (.line // .originalLine), body, diff_hunk: .diffHunk}],
    general: [($pr.reviews.nodes[] | select(.body != "")), $pr.comments.nodes[]
      | select(.author.__typename != "Bot" and .author.login != $me and ($last == null or .createdAt > $last))
      | {author: .author.login, state, body, url}]
  }'
```

`threads` holds the unresolved code review threads where the authenticated user has not commented; `id` is the root comment to reply to. `general` holds human review summaries (e.g. changes requested with an explanation) and PR conversation comments posted after the authenticated user's last conversation comment. Both empty → **STOP**.

**5. Gather evidence** for each comment before forming an opinion; do not assume the reviewer is right or wrong. For a thread comment, read the code at the file and lines of its diff hunk; for a general comment, read the parts of the diff it refers to. Search the surrounding code for patterns, callers, or related logic, and check the conversation in case the point was already discussed, fixed, or dismissed. Domain behavior comes only from the Jira ticket.

**6. Draft** one reply per comment, in exactly one category. English, 1 to 3 sentences, no dashes, no praise, no filler.

- **Fixed**: already addressed. Say what was done.
- **Valid**: real issue, not fixed yet. Acknowledge it and say it stays pending for a follow-up change. Never claim it is done.
- **Noise**: technically correct but irrelevant given business rules or runtime. Push back with concrete reasoning. Minor nits on functional code fall here.
- **Wrong**: the reviewer misread the code. Correct it factually and cite evidence.

**7. Confirm.** Show `| # | Author | File | Category | Reply (preview) |`, with File `general` for general comments. Ask with the `ask` tool: **Post all** or **Cancel**. Do not post until it returns. Cancel → **STOP**. Honor free-text edits or skips.

**8. Post.** A thread comment gets its reply in the thread:

```bash
gh api repos/{owner}/{repo}/pulls/{NUMBER}/comments --method POST -F in_reply_to={ID} -F body=@- <<'EOF'
{REPLY}
EOF
```

A general comment gets its own PR conversation comment, opening with `@{AUTHOR}` and a one-line `>` quote of the point answered:

```bash
gh pr comment {NUMBER} --body-file - <<'EOF'
{REPLY}
EOF
```

Never pass a reply inline with `-f body="..."` or `--body "..."`.

Return the count of replies posted, any skipped, and the Valid items left pending.

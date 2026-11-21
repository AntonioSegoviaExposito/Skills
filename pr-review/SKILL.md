---
name: pr-review
description: Review an open PR against its Jira ticket using resolver's investigation workflow, approving with no comments if it resolves the ticket or posting short inline code comments strictly within ticket scope. Use when the user says /pr-review, pr-review, or asks to review a PR for a ticket.
---

Review the open PR for `{TICKET}` using `jira` and `resolver`'s investigation workflow (read ticket, gather context, gather evidence, and question the premise) before judging the implementation. Uppercase `{PLACEHOLDERS}` are values you fill in.

Before starting, create an internal TODO using the native `todo` tool: one item per step below and a separate **Wait! Question the premise** item between evidence and evaluation. Keep it updated throughout the workflow; a prose checklist is not a substitute.

**Wait! is mandatory and blocks evaluation.** Complete that item only after stating an evidence-backed conclusion about the actual problem, the proposal's viability, and whether the cause belongs to our code.

**1. Read the ticket.** Fetch the ticket provided by the user with `jira` and read its description and all comments, prioritizing clarifications and decisions. Missing or ambiguous key → ask. Locate the open PR for the ticket; no open PR → **STOP** and report.

**2. Gather context.** Analyze related tickets, including epics and spikes, and read their comments with `jira`. Use them as context only, never as additional scope.

**3. Gather evidence.** Read the PR diff and inspect the affected code around the changed files without altering your local working tree. Consult logs only when necessary to understand or confirm the reported failure.

**Wait! question the premise before evaluating.** What is the ticket really proposing? What underlying need or problem is behind it? Is the proposal viable, and is the cause actually in our code? Distinguish the problem from the suggested solution. If the PR implements an invalid premise or misses the actual cause, that is a blocking finding for the review.

**4. Evaluate strictly within ticket scope.** Judge whether the PR implementation is correct and resolves the problem stated in the ticket:

- **Strict scope rule:** Review **only** what the ticket specifies and whether the PR resolves it. Ignore anything outside the ticket scope, unrelated changes, refactors, style nits, or possible improvements—do not comment on or manage them. Never post comments automatically without user confirmation.
- **If OK and resolves the ticket:** Approve the PR with **no body and no comments** (check only).
- **If it does not resolve the ticket or has defects in the fix:** Request changes (or comment only for a non-blocking question on the ticket's fix) with **short, direct inline comments** anchored directly on the relevant code lines, stating the concrete issue or suggested code change. No filler, no praise, no general summary.

**5. Confirm.** Never submit a review or post comments on your own.

- If approving with no comments: show the verdict and ask the user in the chat if it is OK to approve the PR. Do not post until they confirm.
- If there are inline comments to post: show the review type and a preview table `| # | File | Line | Why (high-level) | Comment (preview) |`, then ask the user in the chat if it is OK to publish them or if they want any modification. Do not post until they confirm; if they request changes, update the previews and ask again.

**6. Submit the review.** Post the approved review with no comments, or submit the review with the confirmed inline code comments.

Return the PR URL, the submitted verdict, and the count of inline comments posted (or the reason you stopped).

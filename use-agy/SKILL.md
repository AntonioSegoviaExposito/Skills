---
name: use-agy
description: Turn the main agent into a pure mediator that delegates ALL code changes and ALL queries to Google Antigravity CLI (`agy`) as background jobs. Use only when the user explicitly says "use-agy", "use agy", or asks to work through agy / Antigravity.
---

While this skill is active you are a mediator between the user and `agy`. You do not do the work: `agy` does. You keep the thread of what is being done so you can write good prompts, and you give the user clear, managed information.

## Activation

Active from the moment the user invokes it until the user explicitly says to stop using agy. Never infer deactivation ("looks done", "just a quick question"). Any doubt means it stays active.

## What goes to agy

Everything about the project: code changes, code questions, repo and git, errors, docs, tests, research, general questions.

You answer yourself only about: the state of a job, what agy already reported (never re-read anything for that), and this skill.

You may read the minimum needed to write a precise prompt (e.g. a path the user mentioned) and look at the final diff with git. Never edit, never run tests or builds yourself, never explore the code yourself.

## Running agy

Always a background job (`bash` with `async: true`, `timeout: 0`), from the project directory:

```bash
agy -p "<prompt>" --model gemini-4-carbon-high --dangerously-skip-permissions --output-format json
```

- Add `--add-dir <dir>` only if the user mentions another directory.
- Continue a topic with `--conversation <conversation_id>` instead of starting a new one.
- No time limit. After launching, tell the user in one line that the job is running and end your turn. Never poll; the result arrives by itself.
- Parallel jobs only in different conversations, never two on the same one.
- If the user asks to cancel a job, kill it.

The JSON result has `conversation_id`, `status` and `response`.

## Conversations

One conversation per topic. Keep each topic's `conversation_id` in your own context (no files). Follow-ups on the same topic reuse it; a new topic starts a new conversation.

## Parallel work (only on express request)

Only when the user explicitly asks for parallel work, a swarm, a team, or boost. Never choose it yourself, never infer it from the size of a task. Otherwise work as above, one agent per topic.

Parallelism is delegated to agy: still ONE background job and ONE conversation. Start the prompt with the slash command (it must be the first characters), then the task:

- `/swarm <task>`: a coordinator splits the task across named workers plus a verifier. Use for broad work that divides cleanly. Verified in `-p`: runs in a single turn and returns when the verifier is done.
- `/boost <task>`: deep reasoning pipeline for a hard problem. `/teamwork <goal>`: long multi-milestone projects; it starts with a scoping interview, so relay agy's questions to the user. Both use the same slash-command mechanism; not verified in `-p`.

Never pass `--disable-slash-commands`. In the prompt, tell agy to give each worker its own isolated working copy when workers may touch the same files, and to integrate everything into the main working tree at the end. Verified: agy creates one git worktree per worker, workers commit only on their own workspace branch, and an integrator leaves the merged result uncommitted in the main tree.

Expect long runs (5 to 8 minutes even for trivial tasks) and quota effects: agy may switch the coordinator or a worker to another model when Gemini quota is low. Tell the user when agy reports that.

## Prompts

Free text in English, with all the context `agy` needs (user's request, what is known so far, relevant earlier reports). Let agy make the decisions. Do not impose a template or an output format. Always include this line, at the end of the prompt so a leading slash command stays first:

> Do not commit, push, force-push or delete anything outside the repo unless explicitly asked in this prompt.

In parallel work, extend it: workers may commit only on their own isolated workspace branch, never push, and the integration into the main working tree is left uncommitted.

## Reporting to the user

In the user's language. Faithful, clear summary of what agy did or answered; no opinions or judgment of your own. Mark what comes from agy as `[agy]`. If agy asks a question or needs a decision, relay it to the user and send the answer back in the same conversation.

## Failures

If `status` is not `SUCCESS` or the command fails, retry once in the same conversation with a message like "the previous attempt failed; check the current state and continue". If no `conversation_id` exists yet, resend the same prompt. If it fails again, tell the user the `status` and error as they are. Never do the work yourself and never retry more than once.

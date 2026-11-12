---
name: pr-triage
description: Watch a pull request until its review lands, then triage the review comments. Use right after opening a PR (gh pr create, non-draft), marking one ready (gh pr ready) or asking for a re-review (an "@grupalia-devs review" comment); when a background pr-review-digest watcher exits; or when the session starts with a "#<PR>: new review" or "N open" line.
---

`pr-review-digest` (in `~/.local/bin`, source in `~/dotfiles/bin`) does all the GitHub work: waiting, the digest, replies, resolving and reactions, and the seen/decision state in `~/.local/state/pr-review-digest/`. It defaults to the current repo and the current branch's PR. Never poll GitHub yourself, and never spend an agent on waiting.

The flow: open the PR, wait for the review (1), triage it (2), apply the picked fixes (3), record every item (4), answer the threads (5), and the user force-pushes.

## 1. Start the watcher

After opening a PR, marking one ready or asking for a re-review, run this as a background Bash command (`run_in_background: true`) and move on:

```
pr-review-digest <PR> --repo <owner/name> --wait
```

It polls once every 30s and costs no tokens. While the PR is a draft it waits up to 8h for it to be marked ready. Once the PR is ready it waits 20 min for the bot (8h in repos without one). The harness wakes you when it exits:

| Exit | Meaning | Do |
|------|---------|----|
| 0 | a new review run finished, digest printed | triage (step 2) |
| 3 | timed out | one line to the user, don't restart it |
| 4 | no PR for the branch | say so |
| 5 | PR closed or merged | say so, stop |
| 6 | the bot's run failed | one line; suggest commenting `@grupalia-devs review`, and post it only if the user says so |

The watcher dies with the session. The SessionStart hook and the status bar (`#155 new review · 3 open`) show the state next time, so a "new review" line at session start means step 2 is pending.

## 2. Triage

1. `pr-review-digest <PR> --format json`. Each item has `key` (b1, n1, agu1: display only), `id` (the ledger key), `open`, `severity`, `path`/`line`, `body`, `replies` and `fix_in` (the commit that introduced the line, from blame).
2. Send **one** read-only agent (Explore) with the open items (id, key, path, line, body, replies). It checks each item against the working tree and reports whether the item still applies, whether it's already fixed, and whether the claim is correct, citing `file:line`.
3. Post the list in three groups, one line per item: `key`, what to change, and its `fix_in` commit:
   - **Worth doing**: real bugs and correct claims that are cheap to fix
   - **Your call**: a design choice, a scope question, or debatable
   - **Skip**: wrong, already fixed, or noise (say why)
4. `pr-review-digest <PR> --mark-seen`, so the same run doesn't come back as new.
5. Stop and wait for the user to pick. Don't fix anything before that.

## 3. Apply the picked items

- Load the `git-committing` skill first.
- Fold each fix into the commit that introduced the code: `git commit --fixup=<fix_in sha>`. A new commit is only for genuinely new scope. When two fixes target different commits but touch the same file, commit them in separate rounds instead of splitting hunks.
- Run the affected specs and lint, then `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash origin/<base>`.
- Don't push yet: the threads get answered first (step 5).

## 4. Record every item

Record a decision on every open item, picked or not, so it stops showing as open. Use the item's `id`, not its key:

```
pr-review-digest <PR> --record <id> done|skipped|deferred "<short reason>"
```

## 5. Answer the threads

Once every item is recorded, draft what goes on GitHub, one line per item, and show it to the user. Post nothing before they say OK.

| Decision | On GitHub |
|---|---|
| done | resolve; react `up` when the comment was right. Reply only when the fix differs from what the comment suggested, saying what changed instead |
| skipped | reply with the reason; react `down` when the comment was wrong; resolve |
| deferred | reply saying where it lands (a later branch, PR or issue); resolve |
| general note (no thread) | nothing: the reviewer's overview and other non-specific comments get no answer on GitHub, only the recorded decision |

Replies are one or two sentences in Spanish, in the user's informal voice, no emojis. Name the change by what it does or by commit subject, never by SHA: the force push changes them.

```
pr-review-digest <PR> --reply <id> "<text>"
pr-review-digest <PR> --react <id> up|down
pr-review-digest <PR> --resolve <id>
```

Then tell the user the branch is ready for `git push --force-with-lease`.

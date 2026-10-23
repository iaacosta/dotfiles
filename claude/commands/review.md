---
description: Preview a PR review against a base branch
---

Use the `pr-reviewer` subagent (via the Task tool) to review the current branch against the `$1` branch. If no base branch argument was provided, tell the subagent to auto-detect by checking which of `main` or `master` exists.

Pass along this instruction to the subagent: before starting the review, check if `.github/pr-review.yml` exists in the repo root. If it does, read it and look for a `skills:` list. For each skill name listed, use the `Skill` tool to load it and apply those conventions during the review. If the file doesn't exist or a skill fails to load, proceed without it.

Relay the subagent's review back to me verbatim.

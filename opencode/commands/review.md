---
description: Preview a PR review against a base branch
agent: pr-reviewer
---

Review the current branch against the `$1` branch. If no base branch argument was provided, auto-detect by checking which of `main` or `master` exists.

Before starting the review, check if `.github/pr-review.yml` exists in the repo root. If it does, read it and look for a `skills:` list. For each skill name listed, call the `skill` tool to load it. Apply those conventions during your review. If the file doesn't exist or a skill fails to load, proceed without it.

---
description: Draft a PR description that mimics my writing style from recent PRs
---

Write a PR description for the current branch that sounds like I wrote it.

## Step 1 — Gather my recent PRs as style reference

Fetch my last 5 merged PRs (excluding production rollouts / release PRs):

```bash
gh pr list --author "@me" --state merged --limit 15 \
  --json number,title,body,createdAt,mergedAt
```

From that list, pick the 5 most recent that are NOT:
- production rollouts
- release / version bump PRs
- pure dependency bumps

Read their `body` carefully. These are your style anchors. Pay attention to:
- voice (first person, casual vs formal)
- structure (headings, paragraphs, bullets)
- length and verbosity
- vocabulary, slang, recurring phrases
- how I introduce context, what I emphasize, what I leave out
- whether I link issues, mention reviewers, call out follow-ups

## Step 2 — Gather the diff

Determine the base branch: use `$1` if provided, otherwise auto-detect:

```bash
git branch -l main master --format='%(refname:short)'
```

Prefer `main` if both exist. Then:

```bash
git log --oneline <BASE>..HEAD
git diff <BASE>...HEAD --stat
git diff <BASE>...HEAD
```

Read the actual changed files when the diff alone doesn't give enough context.

## Step 3 — Write the description

Produce a PR description that:
- **Sounds like the 5 reference PRs** — match their voice, length, structure, and formatting conventions. Don't invent a new format.
- Explains **what** changed and **why**, grounded in the diff and commits.
- Stays concise. If my style is short, don't pad it. If my style is detailed, match that.
- Uses first person.
- Skips boilerplate sections I don't normally include (e.g. don't add "Testing" or "Screenshots" sections unless my reference PRs use them).

If something material is unclear from the diff/commits (e.g. the linked issue, the user-facing motivation), ask me ONE focused question before writing. Otherwise just write it.

## Step 4 — Output

Write the final description to `pr_descriptions/<branch>.md` in the repo root, where `<branch>` is the current branch name with `/` replaced by `-` (e.g. `feat/dev-1809-admin-runs-glance-panel` → `pr_descriptions/feat-dev-1809-admin-runs-glance-panel.md`). Create the directory if it doesn't exist. Then print it to the chat so I can review.

Do NOT open the PR or push anything.

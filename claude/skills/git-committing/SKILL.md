---
name: git-committing
description: Review and organize pending commits. Use when staging changes, organizing multiple changes into separate commits, or reviewing uncommitted work before committing.
---
Review current repository changes in detail.
Organize and commit until no pending changes remain.

## Organization Rules
- Changes with their tests go in the same commit
- If 2 unrelated changes are in one file, modify temporarily to organize commits
- Documentation files (README.md, Schemas.yaml, etc.) go in separate commit
- Translation files go in separate commit

## Commit Format

Format: `type(context): description`

### Types
- **feat**: new feature
- **fix**: bug fix
- **docs**: documentation changes
- **style**: formatting, no code change
- **refactor**: code change without new feature or fix
- **perf**: performance improvement
- **test**: adding or fixing tests
- **chore**: build process or auxiliary tools

### Rules
- Context in `kebab-case` (e.g., `user-signup`)
- Optional component after context with `/` (e.g., `api/LoginService`)
- Imperative verb: "add" not "added" or "adds"
- No capital letter at start
- No period at end
- Max 100 characters

### Modularization
- Separate dependency installation from usage (two commits)
- One commit = one responsibility
- Tell a story: don't commit entire files, make the changes incremental like you are building something

## Important
- Don't add descriptions to the commits, the first line should be enough to explain, if it doesn't, maybe you are coupling too much into one commit
- Never add AI authorship metadata (no "Co-authored-by: <LLM>")
- Keep messages concise and direct

## Carving a large change into a series

When a branch grew as one big diff (or fixups piled onto one commit), restructure it into a story before review. Both failure modes are real: one mega-commit is unreviewable, but over-pure carving is too - a naked `refactor` commit that only exists to enable the next `feat` is noise.

- A refactor whose only purpose is enabling a behavior change merges WITH that change, as one `feat`. Extracting a method and branching it are one thought: `feat(x): differentiate the <thing> by <condition>` - never `refactor: extract` followed by `feat: branch`.
- A new method that replaces the semantics of an existing one commits together with its first consumer switching over, titled by the behavior change (`fix:`/`feat:` of the consumer, not "add helper"). History should read "replacing something that existed", never "new thing appears from nowhere".
- Before extracting a helper to a shared home (a model), ask: does anything else call it? Two or more callers → shared home. One caller → it stays private to that class.
- Grain check per commit: the diff should be readable as the one sentence in its subject. If describing the diff needs an "and", split it; if a commit can't stand without the next one, merge them.
- Mechanics for re-carving safely: snapshot the final file states, reset to the base, rebuild the series additively, run the touched specs (and linters) at every commit, and verify the final worktree is content-identical to the snapshot before declaring done.

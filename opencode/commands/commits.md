---
name: commits
description: Review and organize pending commits. Use when staging changes, organizing multiple changes into separate commits, or reviewing uncommitted work before committing.
---

Always enter plan mode before committing.

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
- *feat*: new feature
- *fix*: bug fix
- *docs*: documentation changes
- *style*: formatting, no code change
- *refactor*: code change without new feature or fix
- *perf*: performance improvement
- *test*: adding or fixing tests
- *chore*: build process or auxiliary tools

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

## Important
- Never add AI authorship metadata (no "Co-authored-by: Claude")
- Keep messages concise and direct

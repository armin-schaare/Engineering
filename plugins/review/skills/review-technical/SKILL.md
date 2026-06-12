---
name: review-technical
description: >
  Do a technically focused code review of the current branch diff and present
  actionable findings. Use when the user asks to review code, check changes,
  or sanity-check a diff — without posting comments to a PR or MR. Trigger on
  phrases like "review my changes", "check my diff", "look at what I've done",
  "any issues with my code?". Skip when user explicitly wants inline comments
  posted to a PR/MR (use the review-technical skill for that instead). The
  /review-technical command always triggers this skill.
allowed-tools:
  - Bash(git *)
  - Agent(review:tech)
---

# Technical Code Review

## Context

**Branch:** !`git branch --show-current`

**Base branch:** !`git symbolic-ref --short refs/remotes/origin/HEAD | cut -d/ -f2`

**Commits:**
```!
git log main..HEAD --oneline
```

**Changed files:**
```!
git diff main...HEAD --stat
```

**Full diff:**
```!
git diff main...HEAD
```

**Project conventions (CLAUDE.md):**
```!
cat CLAUDE.md 2>/dev/null || echo "(no CLAUDE.md found)"
```

## Instructions

### Step 1 — Review the diff

Spawn a `review:tech` agent. Pass it the full diff and CLAUDE.md content from above, and give it this task:

> Read through the diff carefully. Look for:
> - **Correctness** — logic bugs, off-by-one errors, wrong conditions
> - **Error handling** — missing checks at system boundaries (user input, API calls, file I/O)
> - **Code quality** — dead code, misleading names, unnecessary complexity, hardcoded values that belong in config
> - **Test coverage** — missing tests for new behavior or edge cases added in this diff
> - **Security** — injection risks, unsafe deserialization, exposed secrets, missing auth/authz checks
> - **Convention violations** — anything conflicting with CLAUDE.md conventions or clear project patterns
>
> Focus ONLY on code introduced in this diff. Do not flag pre-existing issues.
> If there are ambiguities or unclear parts: do not assume, ask.
>
> For each issue, produce one line: `[path/to/file:line] Short description of issue and why it matters`

### Step 2 — Present findings

Show the full list:

```
Found N issues:

1. [path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced
2. [api/routes.ts:15] Hardcoded timeout of 5000ms should come from config
...
```

If no issues: "No issues found in the diff."

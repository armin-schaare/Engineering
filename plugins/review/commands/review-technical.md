---
name: review-technical
description: Do a technically focused code review.
allowed-tools: Bash(git branch:*), Bash(git symbolic-ref:*)
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

### Step 1 - Gather Agent's Comments

Run a tech-agent with the following task:

Read through the up-to-date diff carefully. Look for:
- **Correctness** — logic bugs, off-by-one errors, wrong conditions
- **Error handling** — missing checks at system boundaries (user input, API calls, file I/O)
- **Code quality** — dead code, misleading names, unnecessary complexity, hardcoded values that belong in config
- **Test coverage** — missing tests for new behavior or edge cases added in this diff
- **Security** — injection risks, unsafe deserialization, exposed secrets, missing auth/authz checks
- **Convention violations** — anything conflicting with CLAUDE.md conventions or clear project patterns

Focus ONLY on code introduced in this diff. DO NOT flag pre-existing issues.
If there are any ambiguities or unclear parts: DO NOT ASSUME, ASK!

**How to write good comments:**
- Be direct: state what's wrong and why it matters
- Suggest a fix when you have a concrete one — don't just flag problems
- One issue per comment — don't stack multiple concerns in one note
- Aim for the shortest version that is still fully actionable

### Step 2 - Present Proposition List 

Show the full list of proposed comments:

```
Found N issues to comment on:

1. [path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced
2. [api/routes.ts:15] Hardcoded timeout of 5000ms should come from config
...
```

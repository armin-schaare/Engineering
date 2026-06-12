---
name: review-technical
description: >
  Technically focused code review with configurable scope: branch diff vs main,
  commit range, specific paths/feature, or whole project. Use when the user asks
  to review code, check changes, or sanity-check a diff — without posting comments
  to a PR or MR. Trigger on "review my changes", "check my diff", "review commit
  X..Y", "review the auth module", "look at what I've done", "any issues with my
  code?". Skip when user explicitly wants inline comments posted to a PR/MR (use
  the review-technical skill for that instead). The /review-technical command
  always triggers this skill.
allowed-tools:
  - Bash(git branch *)
  - Bash(git symbolic-ref *)
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git ls-files *)
  - AskUserQuestion
  - Agent(review:tech)
---

# Technical Code Review

## Orientation

**Branch:** !`git branch --show-current`

**Base branch:** !`git symbolic-ref --short refs/remotes/origin/HEAD | cut -d/ -f2`

**Recent commits:**
```!
git log --oneline -20
```

**Project conventions (CLAUDE.md):**
```!
cat CLAUDE.md 2>/dev/null || echo "(no CLAUDE.md found)"
```

## Instructions

### Step 1 — Resolve review scope

Check the user's message for explicit scope. Map as follows:

| User says | Scope |
|---|---|
| "my changes" / "my diff" / "the branch" / no detail | **branch** — `git diff main...HEAD` |
| commit refs like `abc123..def456` or `HEAD~3..HEAD` | **range** — `git diff <range>` |
| specific path, module, or feature name | **path** — `git diff main...HEAD -- <resolved-path>` |
| "whole project" / "all files" / "the codebase" | **project** — explore all tracked files |

If scope is still unclear after reading the message, ask using `AskUserQuestion`:

- Question: "What would you like to review?"
- Options:
  - **Branch diff** — all changes on current branch vs main
  - **Whole project** — review the full codebase as it stands
  - **Commit range** — use "Other" and type refs, e.g. `abc123..def456` or `HEAD~3..HEAD`
  - **Specific path** — use "Other" and type a folder or glob, e.g. `src/auth/` or `**/*.ts`

  If the user selects "Other": if the input contains `..`, treat as a commit range; otherwise treat as a path.

### Step 2 — Collect context

Run the stat first so the user can see what's in scope:

- Branch: `git diff main...HEAD --stat`
- Range `A..B`: `git diff A..B --stat`
- Path: `git diff main...HEAD --stat -- <path>`
- Project: `git ls-files` (show file count / tree overview)

Then collect the full content to pass to the review agent:

- Branch / Range / Path: run the same command without `--stat` to get the full diff
- Project: no diff — the review agent will explore files directly using its read tools

### Step 3 — Review

Spawn a `review:tech` agent. Pass it:
- The review scope (one sentence describing what's being reviewed)
- The full diff text, OR for whole-project mode: instruct the agent to explore the repo using Glob/Read/LS
- CLAUDE.md content from above

Give it this task:

> Review the provided scope carefully. Look for:
> - **Correctness** — logic bugs, off-by-one errors, wrong conditions
> - **Error handling** — missing checks at system boundaries (user input, API calls, file I/O)
> - **Code quality** — dead code, misleading names, unnecessary complexity, hardcoded values that belong in config
> - **Test coverage** — missing tests for new behavior or edge cases
> - **Security** — injection risks, unsafe deserialization, exposed secrets, missing auth/authz checks
> - **Convention violations** — anything conflicting with CLAUDE.md or clear project patterns
>
> For diff-based scopes: focus ONLY on code introduced in the diff, not pre-existing issues.
> For whole-project scope: focus on high-confidence systemic issues worth addressing.
>
> For each issue, produce one line: `[path/to/file:line] Short description of issue and why it matters`

### Step 4 — Present findings

```
Reviewed: <scope description>

Found N issues:

1. [path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced
2. [api/routes.ts:15] Hardcoded timeout of 5000ms should come from config
...
```

If no issues: "No issues found in the reviewed scope."

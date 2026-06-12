---
name: make-msg
description: >
  Generates a conventional commit message from staged or unstaged changes.
  Use when asked to write, draft, or suggest a commit message — including
  casual phrasings like "what should my commit say", "help me commit this",
  "write a commit message", "what should I call this commit", or "draft a
  message for my changes". Always trigger this skill before Claude writes a
  commit message on its own.
allowed-tools:
  - Bash(git diff:*)
  - Bash(git diff --staged:*)
---

# Conventional Commit Message Generator

## Instructions

**Determine scope:** If the user didn't specify which changes the message is for, clarify before proceeding. Usually it's the work from the current conversation — check `git diff --staged` or `git diff` to gather context.

### Subject line (first line)

- Use one of these conventional commit prefixes (no others): `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `style:`, `ci:`, `build:`, `perf:`
- Optional scope in parentheses after the type: `feat(auth):`, `fix(api):` — include it only if the project conventionally uses scopes; omit otherwise
- Breaking changes: append `!` to the type (e.g. `feat!:`, `fix!:`) when the change breaks a public API or contract
- Max 50 characters (hard limit: 72)
- Imperative mood ("add", not "added" or "adds")
- No trailing period

### Body (after blank line)

- Omit the body entirely for self-evident changes (typo fixes, dependency bumps, trivial renames)
- Wrap at 72 characters per line
- Focus on WHY the change was made, not what changed (the diff shows what)
- Explain motivation, trade-offs, and non-obvious decisions
- Use bullet points (`-`) only when there are multiple distinct reasons; prefer a short paragraph otherwise
- For breaking changes: add a `BREAKING CHANGE: <description>` line at the end of the body, separated by a blank line, explaining what breaks and how to migrate

### Output rules

- Plain text only — no Markdown link syntax like `[filename](path)` for files or symbols; just type the name
- Do NOT write a file-by-file changelog ("Updated File A to do X, extended File B to do Y") — assume the reviewer can read the diff; explain the overarching goal instead
- Recount every body line before outputting; if any line exceeds 72 characters, rewrite it thinner
- Output the message inside a single plain text code block so it can be easily copied

The message should be useful to a reviewer now and to anyone reading `git log` months from now.

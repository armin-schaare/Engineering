---
allowed-tools: Bash(git diff:*)
description: Generates a conventional commit message from staged or unstaged changes. Use when asked to write, draft, or suggest a commit message — including casual phrasings like "what should my commit say" or "help me commit this".
---

**Determine scope:** If the user didn't specify which changes the message is for, clarify before proceeding. Usually it's the work from the current conversation — check `git diff --staged` or `git diff` to gather context.

**Subject line (first line):**
- Use one of these conventional commit prefixes (no others): `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `style:`, `ci:`, `build:`, `perf:`
- Optional scope in parentheses after the type: `feat(auth):`, `fix(api):` — include it only if the project conventionally uses scopes; omit otherwise
- Breaking changes: append `!` to the type (e.g. `feat!:`, `fix!:`) when the change breaks a public API or contract
- Max 50 characters (hard limit: 72)
- Imperative mood ("add", not "added" or "adds")
- No trailing period

**Body (after blank line):**
- Omit the body entirely for self-evident changes (typo fixes, dependency bumps, trivial renames)
- Wrap at 72 characters per line
- Focus on WHY the change was made, not what changed (the diff shows what)
- Explain motivation, trade-offs, and non-obvious decisions
- Use bullet points (`-`) only when there are multiple distinct reasons; prefer a short paragraph otherwise
- For breaking changes: add a `BREAKING CHANGE: <description>` line at the end of the body, separated by a blank line, explaining what breaks and how to migrate

**Output Format:** The commit message MUST be plain text. Do not use Markdown link syntax `[filename](path)` for files or code symbols. If you mention a file, just type its name.

**Negative Constraint:** DO NOT write a file-by-file changelog (e.g., "Updated File A to do X. Extended File B to do Y"). Assume the reviewer can read the code. Instead, explain the overarching business or architectural goal that these changes combine to achieve.

**Goal:** The message should be useful to a reviewer now and to anyone reading `git log` months from now.

**Final Output Rule:** Recount every body line before outputting. If any line exceeds 72 characters, rewrite it thinner. Output the message inside a single plain text code block so it can be easily copied.
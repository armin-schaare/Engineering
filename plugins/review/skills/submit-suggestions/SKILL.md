---
name: submit-suggestions
description: >
  Post review propositions as inline comments on a GitLab merge request, one
  at a time with user confirmation. Use when the user has a list of review
  findings (from /review-technical or typed directly) and wants to submit them
  to an open MR. Trigger on phrases like "submit suggestions", "post comments
  to MR", "add these to the merge request", "post the findings". Skip when
  there are no propositions yet — run review-technical first. GitLab only.
allowed-tools:
  - Bash(git *)
  - Bash(glab *)
  - Bash(python3 *)
---

# Submitting Merge Request Comments

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

**Propositions** must already exist — captured by a prior review-technical run or provided directly by the user. If none are available, ask the user for them and stop until provided.

### Step 1 — Find the MR

```bash
glab mr list --source-branch <current-branch>
```

If no open MR exists, tell the user and stop.

### Step 2 — Sync to MR head

The MR may have received commits since the diff was captured. Fetch the latest:

```bash
git fetch origin <current-branch>
git diff main...origin/<current-branch>
```

Use this up-to-date diff for the rest of the review.

### Step 3 — Fetch existing comments

Pull all existing MR notes to avoid posting duplicates:

```bash
glab api "projects/<encoded-path>/merge_requests/<ID>/notes?per_page=100"
```

Build a list of already-addressed topics (file, approximate line, topic summary).

### Step 4 — Process propositions one by one

For each proposition:

1. **Check for duplicates** — if the issue is already covered by an existing comment, skip it with a short notice.

2. **Present to user:**
   ```
   [path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced
   ```

3. **Ask:** keep / edit / skip
   - **keep** — submit as-is
   - **edit** — apply user's changes (wording, line number), then submit
   - **skip** — move to next

4. **Submit** (see below), then continue to the next proposition.

---

## Submitting an Inline Comment

### Get diff refs

```bash
glab api "projects/<encoded-path>/merge_requests/<ID>" \
  | python3 -c "import json,sys; d=json.load(sys.stdin)['diff_refs']; print(d['base_sha'], d['start_sha'], d['head_sha'])"
```

### Compute line_code

```bash
# Added line (+):   old_line=0,      new_line=<line in new file>
# Deleted line (-): old_line=<line>, new_line=0
# Context line:     old_line=<line>, new_line=<line>
${CLAUDE_PLUGIN_ROOT}/scripts/line_code.py <file_path> <old_line> <new_line>
```

### Post inline comment

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/post_gl_discussion.sh \
  <encoded-path> <mr-id> "<body>" \
  <base_sha> <start_sha> <head_sha> \
  <file_path> <new_line> <line_code>
```

The script builds the JSON payload, posts the inline discussion via `glab api`, and falls back to a file-level note if inline positioning fails.

---
name: submit-suggestions
description: Start thread on merge requests for found code propositions.
allowed-tools: Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git log:*), Bash(git diff:*), Bash(git fetch:*), Bash(glab mr list:*), Bash(glab api:*), Bash(scripts/line_code.py:*), Bash(scripts/post_gl_discussion.sh:*)
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

**Propositions**

The propositions must have already been captured by a previous called command or the user directly. If not prompt the user and stop. 

### Existing Comments/Threads

#### Step 1 — Find the MR

```bash
glab mr list --source-branch <current-branch>
```

If no open MR exists, tell the user and stop.

#### Step 2 — Sync to MR head

The MR may have received commits since the diff was captured. Fetch the latest state:

```bash
git fetch origin <current-branch>
git diff main...origin/<current-branch>
```

Use this up-to-date diff for the rest of the review.

#### Step 3 — Fetch existing comments

Pull all existing review comments so duplicates are not posted.

```bash
glab api "projects/<encoded-path>/merge_requests/<ID>/notes?per_page=100"
```

Build a list of already-addressed topics (file, approximate line, topic).


## Instructions

For each proposition:
1. Check if the current proposition is already addressed in existing coments/threads. If so, skip this proposition with a short notice.
2. Preset the proposition to the user in the following format: `[path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced`
3. Ask the user whether to keep/edit/skip this proposition
    - keep: Submit the proposition as is
    - edit: Apply the user's changes to the proposition (e.g. line numbers, wording) 
    - skip: continue with the next proposition 
4. Perform the Instructions under the section "Submitting MR Comment" for the current comment
5. Continue with the next proposition


## Submitting MR Comment

Get the diff refs (base_sha, start_sha, head_sha):
```bash
glab api "projects/<encoded-path>/merge_requests/<ID>" \
  | python3 -c "import json,sys; d=json.load(sys.stdin)['diff_refs']; print(d['base_sha'], d['start_sha'], d['head_sha'])"
```

Compute `line_code` for the comment using the helper script (added line: old_line=0; deleted line: new_line=0; context: both set):
```bash
scripts/line_code.py <file_path> <old_line> <new_line>
```

Post the comment using the helper script (falls back to a file-level note if inline positioning fails):
```bash
scripts/post_gl_discussion.sh <encoded-path> <ID> "<body>" <base_sha> <start_sha> <head_sha> <file-path> <new-line> <line-code>
```

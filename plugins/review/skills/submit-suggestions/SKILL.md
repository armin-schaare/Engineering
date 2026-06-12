---
name: submit-suggestions
description: >
  Posts review findings as inline comments on a GitLab merge request, one at a
  time with user confirmation. Use whenever the user wants to push review results
  to an MR — even casually phrased: "post these", "add comments to the MR",
  "submit my findings", "annotate the merge request", "push inline feedback",
  "add these to the diff". Also triggers after /review-technical when the user
  wants to act on the findings. Requires an existing list of propositions;
  if none yet, prompt the user to run review-technical first.
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/mr/get_context.sh *)
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/mr/calc_line_code.py *)
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/mr/submit_discussion.sh *)
  - AskUserQuestion
---

# Submitting Merge Request Comments

## Context

**Project conventions (CLAUDE.md):**
```!
cat CLAUDE.md 2>/dev/null || echo "(no CLAUDE.md found)"
```

**MR** (synced diff, MR ID, diff refs, existing comments):
```!
"${CLAUDE_PLUGIN_ROOT}/scripts/mr/get_context.sh"
```

## Instructions

**Propositions** must already exist — captured by a prior review-technical run or provided directly by the user. If none are available, ask the user for them and stop until provided.

### Step 1 — Check MR context

Read the MR context above.

- If the context starts with `>` (blockquote error message): relay it to the user and stop.
- Otherwise read: MR number, encoded path, diff refs (base / start / head SHA), existing comments, and the diff.
- Use the diff from the MR context for all subsequent work — it reflects the latest remote state, not the local snapshot.

### Step 2 — Process propositions one by one

For each proposition:

1. **Check for duplicates** — if the issue is already covered by an existing comment, skip it with a short notice.

2. **Present to user:**
   ```
   [path/to/file.py:42] Missing null check — getUser() can return null but result is immediately dereferenced
   ```

3. Use `AskUserQuestion`: "What would you like to do with this finding?"
   - **Keep** — submit as-is
   - **Edit** — reply with the current proposition text and tell the user to type their replacement (wording, line number, or both) in their next message; wait for the reply, apply it, then submit
   - **Skip** — move to next

4. **Submit** (see below), then continue to the next proposition.

### Step 3 — Summary

Once all propositions are processed, report:

```
Done. X posted inline, Y as file-level notes (inline positioning failed), Z skipped.
```

---

## Submitting an Inline Comment

### Determine old_line and new_line

Find the target line in the diff hunk for the file. The hunk header (`@@ -A,B +C,D @@`) tells you where old and new line numbering starts. Count from there:

- Line prefixed `+` (added): `old_line=0`, `new_line=<line number in new file>`
- Line prefixed `-` (deleted): `old_line=<line number in old file>`, `new_line=0`
- Line with no prefix (context): `old_line=<old>`, `new_line=<new>` (both set)

When a proposition references a line number, treat it as the new-file line. If the line is added (`+`), set `old_line=0`.

### Compute line_code

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/mr/calc_line_code.py <file_path> <old_line> <new_line>
```

### Post inline comment

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/mr/submit_discussion.sh \
  <encoded_path> <mr_id> "<body>" \
  <base_sha> <start_sha> <head_sha> \
  <file_path> <new_line> <line_code>
```

The script builds the JSON payload and posts the inline discussion via `glab api`. If inline positioning fails, it falls back to a file-level note — note this in your tally for the summary.

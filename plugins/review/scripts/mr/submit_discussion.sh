#!/usr/bin/env bash
# Posts an inline discussion on a GitLab MR.
# Usage: submit_discussion.sh <encoded-path> <mr-id> <body> <base_sha> <start_sha> <head_sha> <file-path> <new-line> <line-code>
# Falls back to a file-level note if inline positioning fails.
set -euo pipefail

ENCODED_PATH="$1"
MR_ID="$2"
BODY="$3"
BASE_SHA="$4"
START_SHA="$5"
HEAD_SHA="$6"
FILE_PATH="$7"
NEW_LINE="$8"
LINE_CODE="$9"

PAYLOAD=$(mktemp)
trap 'rm -f "$PAYLOAD"' EXIT

jq -n \
  --arg body "$BODY" \
  --arg base_sha "$BASE_SHA" \
  --arg start_sha "$START_SHA" \
  --arg head_sha "$HEAD_SHA" \
  --arg path "$FILE_PATH" \
  --arg line_code "$LINE_CODE" \
  --argjson new_line "$NEW_LINE" \
  '{
    body: $body,
    position: {
      position_type: "text",
      base_sha: $base_sha,
      start_sha: $start_sha,
      head_sha: $head_sha,
      old_path: $path,
      new_path: $path,
      new_line: $new_line,
      line_range: {
        start: { line_code: $line_code, type: "new", new_line: $new_line },
        end:   { line_code: $line_code, type: "new", new_line: $new_line }
      }
    }
  }' > "$PAYLOAD"

glab api "projects/$ENCODED_PATH/merge_requests/$MR_ID/discussions" \
  --method POST \
  --input "$PAYLOAD" \
  -H "Content-Type: application/json" \
  || glab mr note "$MR_ID" -m "$BODY"

#!/usr/bin/env bash
# Posts an inline discussion on a GitLab MR.
# Usage: post_gl_discussion.sh <encoded-path> <mr-id> <body> <base_sha> <start_sha> <head_sha> <file-path> <new-line> <line-code>
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

cat > /tmp/gl_comment.json << EOF
{
  "body": $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$BODY"),
  "position": {
    "position_type": "text",
    "base_sha": "$BASE_SHA",
    "start_sha": "$START_SHA",
    "head_sha": "$HEAD_SHA",
    "old_path": "$FILE_PATH",
    "new_path": "$FILE_PATH",
    "new_line": $NEW_LINE,
    "line_range": {
      "start": { "line_code": "$LINE_CODE", "type": "new", "new_line": $NEW_LINE },
      "end":   { "line_code": "$LINE_CODE", "type": "new", "new_line": $NEW_LINE }
    }
  }
}
EOF

glab api "projects/$ENCODED_PATH/merge_requests/$MR_ID/discussions" \
  --method POST \
  --input /tmp/gl_comment.json \
  -H "Content-Type: application/json" \
  || glab mr note create "$MR_ID" -m "$BODY"

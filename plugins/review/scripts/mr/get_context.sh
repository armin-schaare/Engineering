#!/usr/bin/env bash
# Syncs branch, finds open MR, fetches existing comments.
# Outputs markdown context for use in skill instructions.
# Usage: get_context.sh
set -euo pipefail

BRANCH=$(git branch --show-current)
BASE_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD | cut -d/ -f2)

# 1 — Sync to MR head
git fetch origin "$BRANCH" >&2

# 2 — Find open MR
MR_LIST=$(glab mr list --source-branch "$BRANCH" --output json 2>/dev/null)

if [ "$(echo "$MR_LIST" | jq 'length')" -eq 0 ]; then
  echo '> No open MR found for this branch. Stop here and inform the user.'
  exit 0
fi

MR_ID=$(echo "$MR_LIST" | jq -r '.[0].iid')
MR_TITLE=$(echo "$MR_LIST" | jq -r '.[0].title')
PROJECT_PATH=$(echo "$MR_LIST" | jq -r '
  .[0] |
  if .references.full | contains("!") then
    .references.full | split("!")[0]
  else
    .web_url | split("/-/")[0] | split("/")[3:] | join("/")
  end
')
ENCODED_PATH=$(printf '%s' "$PROJECT_PATH" | jq -Rr '@uri')

# 3 — Fetch diff refs and existing comments
MR_DETAILS=$(glab api "projects/$ENCODED_PATH/merge_requests/$MR_ID")
BASE_SHA=$(echo "$MR_DETAILS" | jq -r '.diff_refs.base_sha')
START_SHA=$(echo "$MR_DETAILS" | jq -r '.diff_refs.start_sha')
HEAD_SHA=$(echo "$MR_DETAILS" | jq -r '.diff_refs.head_sha')

COMMENTS=$(glab api "projects/$ENCODED_PATH/merge_requests/$MR_ID/notes?per_page=100" \
  | jq -r '.[] | "- [\(.id)] \(.body | .[0:300])"')

DIFF=$(git diff "$BASE_BRANCH...origin/$BRANCH")

# Output markdown
echo "**MR:** !${MR_ID} — ${MR_TITLE}"
echo "**Project:** ${PROJECT_PATH}"
echo "**Encoded path:** ${ENCODED_PATH}"
echo "**Diff refs:** base=${BASE_SHA} start=${START_SHA} head=${HEAD_SHA}"
echo ""
echo "**Existing comments:**"
echo "${COMMENTS}"
echo ""
echo "**Diff:**"
echo '```diff'
printf '%s\n' "${DIFF}"
echo '```'

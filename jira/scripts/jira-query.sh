#!/bin/bash
# Query Jira Server/Data Center (ticket or JQL) or post a comment on a ticket assigned to the token user.
# Usage:
#   jira-query.sh <TICKET | JQL>
#   jira-query.sh comment <TICKET> [body]   # body from args or stdin
# Config: copy env.example to env in this directory and fill it in (env is gitignored):
#   JIRA_BASE_URL   base URL, including any context path, no trailing slash (e.g. https://jira.example.com/jira)
#   JIRA_TOKEN      personal access token, sent as Bearer
#   JIRA_PROJECT    project key every JQL search is scoped to (e.g. PROJ)
#   JIRA_CURL_OPTS  optional extra curl flags (e.g. "--resolve jira.example.com:443:10.0.0.1")
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/env"
: "${JIRA_BASE_URL:?}" "${JIRA_TOKEN:?}" "${JIRA_PROJECT:?}"
TICKET_RE='^[A-Za-z][A-Za-z0-9_]*-[0-9]+$'

usage() {
  echo "Usage: jira-query.sh <TICKET | JQL> | comment <TICKET> [body]" >&2
  exit 1
}

# Prints the response body; on HTTP or network failure prints "error: ..." to stderr and exits 1.
jira_api() {
  local out
  out=$(curl -sS --fail-with-body ${JIRA_CURL_OPTS:-} \
    -H "Accept: application/json" -H "Authorization: Bearer $JIRA_TOKEN" "$@") ||
    { echo "error: Jira request failed${out:+: $out}" >&2; exit 1; }
  printf '%s\n' "$out"
}

readonly JQ_ISSUE_MAP='{
  key: .key,
  summary: .fields.summary,
  description: (.fields.description // null),
  assignee: (.fields.assignee.name // null),
  links: (
    [ .fields.issuelinks[]?
      | select(.type.name != "Cloners")
      | {
          type: .type.name,
          direction: (if .outwardIssue then .type.outward else .type.inward end),
          issue: ((.outwardIssue // .inwardIssue) | { key: .key, summary: .fields.summary, status: .fields.status.name })
        }
    ]
  ),
  comments: (
    [ .fields.comment.comments[]? | {
      author: .author.displayName,
      created: .created,
      body: .body
    }]
  )
}'

post_comment() {
  local ticket="$1"
  local body="$2"
  local me assignee

  me=$(jira_api "$JIRA_BASE_URL/rest/api/2/myself" | jq -r '.name // empty')
  [[ -n "$me" ]] || { echo "error: cannot resolve token user" >&2; exit 1; }

  assignee=$(jira_api "$JIRA_BASE_URL/rest/api/2/issue/${ticket}?fields=assignee" | jq -r '.fields.assignee.name // empty')
  if [[ "$assignee" != "$me" ]]; then
    echo "error: ${ticket} is assigned to '${assignee:-unassigned}', not '${me}'. Comment refused." >&2
    exit 1
  fi

  jq -n --arg body "$body" '{body: $body}' |
    jira_api -H "Content-Type: application/json" -X POST -d @- \
      "$JIRA_BASE_URL/rest/api/2/issue/${ticket}/comment" |
    jq '{id, created, author: .author.displayName, body}'
}

[[ $# -ge 1 ]] || usage

if [[ "$1" == "comment" ]]; then
  [[ $# -ge 2 ]] || usage
  [[ "$2" =~ $TICKET_RE ]] || { echo "error: invalid ticket: $2" >&2; exit 1; }
  TICKET=$(tr '[:lower:]' '[:upper:]' <<< "$2")
  if [[ $# -ge 3 ]]; then
    BODY="${*:3}"
  else
    BODY=$(cat)
  fi
  [[ -n "$BODY" ]] || { echo "error: empty comment body" >&2; exit 1; }
  post_comment "$TICKET" "$BODY"
  exit 0
fi

INPUT="$1"

if [[ "$INPUT" =~ $TICKET_RE ]]; then
  TICKET=$(tr '[:lower:]' '[:upper:]' <<< "$INPUT")
  jira_api "$JIRA_BASE_URL/rest/api/2/issue/$TICKET?fields=summary,description,comment,issuelinks,assignee" | \
    jq "$JQ_ISSUE_MAP"
else
  FILTER="$INPUT" ORDER=""
  shopt -s nocasematch
  if [[ "$INPUT" =~ ^(.*)(ORDER[[:space:]]+BY[[:space:]].*)$ ]]; then
    FILTER="${BASH_REMATCH[1]}" ORDER=" ${BASH_REMATCH[2]}"
  fi
  shopt -u nocasematch
  JQL="project = \"$JIRA_PROJECT\""
  [[ "$FILTER" =~ [^[:space:]] ]] && JQL="$JQL AND ($FILTER)"
  jira_api -X GET -G \
    --data-urlencode "jql=$JQL$ORDER" \
    --data-urlencode "fields=summary,description,comment,issuelinks,assignee" \
    --data-urlencode "maxResults=50" \
    --data-urlencode "startAt=0" \
    "$JIRA_BASE_URL/rest/api/2/search" | \
    jq "[.issues[]? | $JQ_ISSUE_MAP]"
fi

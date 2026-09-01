#!/usr/bin/env bash
# PreToolUse hook (Bash): approval gate for anything that looks like a
# production deploy. This is the pattern from Stage 5 of the playbook —
# adjust the match condition to whatever your real deploy command looks
# like, and RELEASE_APPROVAL to however you actually record sign-off
# (an env var set by a release-approval step in CI is one option; a file
# checked into a short-lived location is another).
#
# Exit 0 to allow, exit 2 to block (stderr is shown to Claude as the reason).

set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# TODO: match your real deploy invocation.
if [[ "$cmd" == *"deploy"* && "$cmd" == *"production"* ]]; then
  if [ -z "${RELEASE_APPROVAL:-}" ]; then
    echo "Production deploys need release authorization. Get sign-off and set RELEASE_APPROVAL=1, or hand this off to a human." >&2
    exit 2
  fi
fi

exit 0

#!/usr/bin/env bash
# Minimal eval harness: runs every evals/examples/*.json prompt against
# Claude non-interactively in a disposable copy of the repo, then runs its
# command checks. "manual" checks are printed for a human (or LLM-judge job)
# to score separately — this script doesn't attempt to auto-grade those.
#
# Usage: evals/run.sh
# Exit code: 0 if all command checks pass, 1 if any fail.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLES_DIR="$REPO_ROOT/evals/examples"
FAILED=0

for eval_file in "$EXAMPLES_DIR"/*.json; do
  id=$(jq -r '.id' "$eval_file")
  description=$(jq -r '.description' "$eval_file")
  prompt=$(jq -r '.prompt' "$eval_file")

  echo "=== $id ==="
  echo "$description"

  workdir=$(mktemp -d)
  # Copy the repo (tracked files only) into a disposable sandbox so the run
  # can't leave state behind or touch anything outside itself.
  git -C "$REPO_ROOT" archive HEAD | tar -x -C "$workdir"

  ( cd "$workdir" && claude -p "$prompt" --permission-mode acceptEdits ) \
    || { echo "  claude invocation failed for $id"; FAILED=1; }

  checks_len=$(jq '.checks | length' "$eval_file")
  for i in $(seq 0 $((checks_len - 1))); do
    type=$(jq -r ".checks[$i].type" "$eval_file")
    if [ "$type" = "command" ]; then
      cmd=$(jq -r ".checks[$i].command" "$eval_file")
      if ( cd "$workdir" && eval "$cmd" ); then
        echo "  [PASS] command check $i"
      else
        echo "  [FAIL] command check $i: $cmd"
        FAILED=1
      fi
    elif [ "$type" = "manual" ]; then
      criteria=$(jq -r ".checks[$i].criteria" "$eval_file")
      echo "  [MANUAL] $criteria (needs human or LLM-judge review — see $workdir)"
    fi
  done

  echo
done

exit $FAILED

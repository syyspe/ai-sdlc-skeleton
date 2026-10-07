#!/usr/bin/env bash
# Regression tests for session-start-check.sh — the hook that tells every
# session which stage it is in. An artifact, and an approval, only counts
# once it is committed in HEAD; one that is merely on disk keeps the session
# in the stage that produces it.
#
# Self-contained: builds a throwaway git repo whose default branch is
# `master`, walks it through each stage in order, and checks the stage line
# the hook reports. No test framework, because the skeleton doesn't pick one
# for you.
#
# Run: bash .claude/hooks/session-start-check.test.sh

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/session-start-check.sh"

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT

commit() {
  git -C "$repo" add -A
  git -C "$repo" -c user.email=t@example.com -c user.name=t \
    commit -q -m "$1"
}

# artifact <path> <status> — write a file with that frontmatter status
artifact() {
  printf -- '---\nstatus: %s\n---\n\n# demo\n' "$2" >"$repo/$1"
}

git -C "$repo" init -q -b master
mkdir -p "$repo/.claude" "$repo/intent" "$repo/design" "$repo/plans"
touch "$repo/.claude/.bootstrapped"
commit init
git -C "$repo" checkout -q -b demo

pass=0
fail=0

# check <expected substring of the hook's context>
check() {
  expected="$1"

  context=$(CLAUDE_PROJECT_DIR="$repo" bash "$HOOK" | python3 -c \
    'import json, sys
print(json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"])')

  if printf '%s' "$context" | grep -qF -- "$expected"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL: wanted %s\n      got:\n%s\n' "$expected" "$context"
  fi
}

check 'Stage 1 (Plan) — not started.'

artifact intent/demo.md draft
check 'Stage 1 (Plan) — intent written, not committed.'
check '(on disk, not committed)'

commit intent
check 'Stage 1 (Plan) — intent committed, waiting on product-owner approval.'

# An approval flipped on disk but not committed doesn't open the next stage.
artifact intent/demo.md approved
check 'Stage 1 (Plan) — intent committed, waiting on product-owner approval.'
check 'reads status: approved on disk, but not in HEAD'

commit 'approve intent'
check 'Stage 2 (Design) — intent approved, no spec yet.'

artifact design/demo.spec.md draft
check 'Stage 2 (Design) — spec written, not committed.'

commit spec
check 'Stage 2 (Design) — spec committed, waiting on approval.'

artifact design/demo.spec.md approved
check 'Stage 2 (Design) — spec committed, waiting on approval.'

commit 'approve spec'
check 'Stage 3 (Build) — spec approved, no plan yet.'

# The case that used to report work in progress: an uncommitted plan
# dirties the tree.
artifact plans/demo.plan.md approved
check 'Stage 3 (Build) — plan written, not committed.'

commit plan
check 'Stage 3 (Build) — plan committed, no code yet.'

# Commits that only touch the artifacts aren't code.
echo 'more plan' >>"$repo/plans/demo.plan.md"
commit 'revise plan'
check 'Stage 3 (Build) — plan committed, no code yet.'

echo code >"$repo/code.txt"
check 'Stage 3 (Build) — plan committed, work in progress.'

# Drift: the build amends the plan in the same commit as the code. Dating
# from the last commit to touch the plan would hide this code.
echo 'drifted' >>"$repo/plans/demo.plan.md"
commit 'code, with plan amended'
check 'Stage 4 (Test) — code committed since the plan.'
check '[x] code committed'

git -C "$repo" checkout -q master
check 'on the default branch'

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]

#!/usr/bin/env bash
# SessionStart hook, two jobs:
#
#   1. Unconfigured clone (no .claude/.bootstrapped) — push the session into
#      the bootstrap skill.
#   2. Configured repo — report where the current branch stands in the SDLC
#      loop and what the next action is. The stage is derived from the
#      artifact chain itself — which of intent/design/plans are committed in
#      HEAD for the branch slug, the "status:" those commits carry, and
#      whether code has landed since the plan commit — never from separate
#      state, and never from what is merely on disk. An approval counts once
#      it is committed. Every boundary is computable here; the sdlc skill says
#      why that constraint drives where verification sits.
#
# Both paths only inject context — this hook never blocks anything, and any
# probe that can't run (no git, missing dirs) falls back to silence.

set -euo pipefail
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

if [ ! -f .claude/.bootstrapped ]; then
  cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "This is an unconfigured clone of the ai-sdlc-skeleton (no .claude/.bootstrapped marker). Start the bootstrap flow immediately in your first message: a one-line intro plus the first question (project name and purpose) in the same message — don't ask permission to begin, and don't bundle further questions in with it. Follow .claude/skills/bootstrap/SKILL.md exactly: one question at a time, waiting for each reply, including its tech-stack scaffolding step."}}
EOF
  exit 0
fi

HOWTO="Orientation, not a script to recite: if the user opens with something \
open-ended (what next, let's continue, hi), lead with the stage and next \
action in at most two lines. Otherwise hold this as context and answer what \
was asked. Rules and reasoning: the sdlc skill."

STAGES=".claude/skills/sdlc/stages"

emit() {
  MSG="$1" python3 -c 'import json, os
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": os.environ["MSG"],
}}))'
  exit 0
}

committed() {
  git cat-file -e "HEAD:$1" 2>/dev/null
}

# Frontmatter "status:" of a file's content on stdin, or empty if absent.
status_in() {
  sed -n '1,12s/^status:[[:space:]]*\([a-z]*\).*/\1/p' | head -1
}

# The status an artifact carries in HEAD — the only one that counts.
status_of() {
  git show "HEAD:$1" 2>/dev/null | status_in || true
}

approved() {
  [ "$(status_of "$1")" = "approved" ]
}

# Appended to a waiting-on-approval message when the file on disk already
# says approved: someone flipped it and hasn't committed the flip.
uncommitted_approval() {
  if [ "$(status_in 2>/dev/null <"$1" || true)" = "approved" ]; then
    printf '\n%s reads status: approved on disk, but not in HEAD — an approval\ncounts only once committed.' "$1"
  fi
}

checklist_line() {
  if committed "$1"; then
    printf '  [x] %-34s %s\n' "$1" "$(status_of "$1")"
  elif [ -f "$1" ]; then
    printf '  [ ] %-34s %s\n' "$1" "(on disk, not committed)"
  else
    printf '  [ ] %s\n' "$1"
  fi
}

slug=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
[ -n "$slug" ] || exit 0

case "$slug" in
  main | master | HEAD)
    emit "SDLC loop: on the default branch ($slug) — no work stream checked out.

Next: Stage 1 (Plan). Pick a short kebab-case slug for the initiative, run
git checkout -b <slug>, then write intent/<slug>.md from intent/TEMPLATE.md.
Full instructions: $STAGES/1-plan.md

$HOWTO"
    ;;
esac

intent="intent/$slug.md"
spec="design/$slug.spec.md"
plan="plans/$slug.plan.md"

if [ ! -f "$intent" ] && [ ! -f "$spec" ] && [ ! -f "$plan" ] && [ ! -d intent ]; then
  exit 0  # not a skeleton layout (or the dirs were removed) — say nothing
fi

# Has code landed since the plan was committed? Dated from the commit that
# ADDED the plan, not the last one to touch it — a build session is told to
# amend the plan in the same commit as the code it drifted from, and dating
# from that would hide the very code it's meant to detect.
code=""
if committed "$plan"; then
  plan_commit=$(git log --diff-filter=A --format=%H -1 -- "$plan" 2>/dev/null || true)
  if [ -n "$plan_commit" ]; then
    code=$(git log --format=%H "$plan_commit"..HEAD -- . \
      ':(exclude)intent' ':(exclude)design' ':(exclude)plans' 2>/dev/null || true)
  fi
fi

chain=$(
  checklist_line "$intent"
  checklist_line "$spec"
  checklist_line "$plan"
  if [ -n "$code" ]; then
    printf '  [x] code committed\n'
  else
    printf '  [ ] code committed\n'
  fi
)

# One imperative per state. The reasoning behind each lives in the sdlc skill,
# which HOWTO points at — repeating it here is what lets the two drift apart.
if ! committed "$intent" && [ -f "$intent" ]; then
  stage="Stage 1 (Plan) — intent written, not committed."
  next="commit $intent as status: draft. That commit ends the stage."
elif ! committed "$intent"; then
  stage="Stage 1 (Plan) — not started."
  next="write $intent from intent/TEMPLATE.md, interviewing the user one
question at a time, then commit it. That commit ends the stage. Full
instructions: $STAGES/1-plan.md"
elif ! approved "$intent"; then
  stage="Stage 1 (Plan) — intent committed, waiting on product-owner approval."
  next="nothing to build yet. Stage 2 (Design) opens once a commit sets $intent
to status: approved. Don't draft the spec before then.$(uncommitted_approval "$intent")"
elif ! committed "$spec" && [ -f "$spec" ]; then
  stage="Stage 2 (Design) — spec written, not committed."
  next="commit $spec as status: draft. That commit ends the stage. Full
instructions: $STAGES/2-design.md"
elif ! committed "$spec"; then
  stage="Stage 2 (Design) — intent approved, no spec yet."
  next="draft $spec from $intent using design/TEMPLATE.spec.md, then commit
it. Full instructions: $STAGES/2-design.md"
elif ! approved "$spec"; then
  stage="Stage 2 (Design) — spec committed, waiting on approval."
  next="nothing to build yet. Policy flags go to their owners; Stage 3 (Build)
opens once a commit sets $spec to status: approved.$(uncommitted_approval "$spec")"
elif ! committed "$plan" && [ -f "$plan" ]; then
  stage="Stage 3 (Build) — plan written, not committed."
  next="commit $plan BEFORE any code. That commit ends this session. Full
instructions: $STAGES/3-build.md"
elif ! committed "$plan"; then
  stage="Stage 3 (Build) — spec approved, no plan yet."
  next="call the EnterPlanMode tool now, as your first action. Read $spec and
iterate, then write $plan from plans/TEMPLATE.plan.md and commit it BEFORE any
code. Full instructions: $STAGES/3-build.md"
elif [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  stage="Stage 3 (Build) — plan committed, work in progress."
  next="finish $plan's work order and commit it; if the implementation departed
from the plan, update $plan in the same commit. That commit ends the stage.
Full instructions: $STAGES/3-build.md"
elif [ -z "$code" ]; then
  stage="Stage 3 (Build) — plan committed, no code yet."
  next="implement $plan's work order and commit it — simple-code applies from
the first line. That commit is this session's whole job and ends the stage.
Full instructions: $STAGES/3-build.md"
else
  stage="Stage 4 (Test) — code committed since the plan."
  next="read $STAGES/4-test.md and run its steps in order; it runs straight on
into $STAGES/5-deploy.md in this same session."
fi

emit "SDLC loop — branch: $slug

$chain

$stage
Next: $next

$HOWTO"

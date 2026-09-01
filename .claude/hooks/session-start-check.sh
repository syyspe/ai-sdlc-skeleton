#!/usr/bin/env bash
# SessionStart hook: nudges Claude to run the bootstrap skill on a freshly
# cloned/templated copy of this skeleton. No-ops once .claude/.bootstrapped
# exists, so this only fires once per new project.

set -euo pipefail
cd "$CLAUDE_PROJECT_DIR"

[ -f .claude/.bootstrapped ] && exit 0

cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "This is an unconfigured clone of the ai-sdlc-skeleton (no .claude/.bootstrapped marker). Start the bootstrap flow immediately in your first message: a one-line intro plus the first question (project name and purpose) in the same message — don't ask permission to begin, and don't bundle further questions in with it. Follow .claude/skills/bootstrap/SKILL.md exactly: one question at a time, waiting for each reply, including its tech-stack scaffolding step."}}
EOF

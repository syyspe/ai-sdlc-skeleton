#!/usr/bin/env bash
# SessionStart hook: nudges Claude to run the bootstrap skill on a freshly
# cloned/templated copy of this skeleton. No-ops once .claude/.bootstrapped
# exists, so this only fires once per new project.

set -euo pipefail
cd "$CLAUDE_PROJECT_DIR"

[ -f .claude/.bootstrapped ] && exit 0

cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "This is an unconfigured clone of the ai-sdlc-skeleton (no .claude/.bootstrapped marker). Before anything else, offer to run the bootstrap skill (.claude/skills/bootstrap/SKILL.md): ask the user for project name, purpose, tech stack, and commands, then fill in CLAUDE.md, README.md, REVIEW.md, and the .claude/hooks/*.sh placeholders."}}
EOF

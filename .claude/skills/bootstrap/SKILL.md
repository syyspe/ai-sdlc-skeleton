---
name: bootstrap
description: Use at the start of a session in a freshly cloned/templated copy of this skeleton that hasn't been configured yet (no .claude/.bootstrapped file). Also user-invocable any time as /bootstrap to redo setup. Walks through project name, purpose, tech stack, and commands, then fills in every current placeholder across CLAUDE.md, README.md, REVIEW.md, and .claude/hooks/.
---

# Bootstrap a new project from this skeleton

This repo is a template — the person you're talking to just cloned or
templated it to start a *new* project, not to edit the skeleton itself.
Your job is to ask a few questions, then fill in every `<placeholder>` in
the repo with real values so it's usable immediately.

## Conversation

Ask these conversationally (not as a rigid form) — free text, not
multiple-choice, since the answers are project-specific:

1. **Project name and one-line purpose.** What is this project, in one
   sentence?
2. **Tech stack.** Language/runtime, framework, package manager.
3. **Commands.** Build, test (unit + integration if distinct), lint,
   format — the actual commands, and what healthy output looks like.
4. **Architecture.** Top-level directories and what lives in each (it's
   fine if this is still rough — a best guess is enough to start).
5. **Deploy.** What does a production deploy command look like, roughly
   (used to configure the production-gate hook's match condition)? Skip if
   not applicable yet.
6. **Protected/generated paths**, if any exist yet (e.g. a schemas
   directory, frozen legacy code). Most new projects have none — that's a
   fine answer.

Confirm the summary with the user before editing files.

## What to edit

- **`CLAUDE.md`** — fill in Commands, Conventions, Architecture from the
  answers above. Leave "Things Claude gets wrong here" empty; it fills in
  from real use over time.
- **`README.md`** — replace the title and opening framing with the actual
  project name/purpose. Leave the stage-map table and process notes as-is
  — they're generic to the workflow, not project-specific.
- **`REVIEW.md`** — fill in "Excluded paths" with the stack's known
  generated/build directories (e.g. Node → `dist/`, `node_modules/`;
  Python → `__pycache__/`, `.venv/`). If you can't confidently infer
  something, leave that line's placeholder and say so in your summary
  rather than guessing.
- **`.claude/hooks/production-gate.sh`** — update the `if [[ "$cmd" ==
  ...deploy...production... ]]` match to fit the real deploy command
  described. If there's no deploy command yet, leave the hook as-is.
- **`.claude/hooks/post-edit-reminder.sh`** — replace the TODO with the
  real format command from CLAUDE.md's Commands section.
- **`.claude/hooks/protected-paths.sh`** — fill `PROTECTED_PATTERNS` if
  the user named any; otherwise leave it empty (an empty array is a valid,
  intentional state here, not a leftover placeholder).

## What NOT to touch

These are deliberately left for real use, not initial setup — don't
fabricate content for them to seem thorough:

- `bands.yaml` (Stage 6 monitoring thresholds — needs live metrics)
- `evals/examples/*.json` (Stage 4 — needs a real incident to regress-test)
- `intent/`, `design/`, `plans/` templates (per-initiative, copied when
  starting an actual piece of work, not part of global setup)

## Finishing

1. Write `.claude/.bootstrapped` with the captured project name, stack,
   and today's date (plain text, a few lines — this is a marker the
   `session-start-check.sh` hook looks for, not a config file other
   tooling reads).
2. Report a short summary: what was filled in, and what's still deferred
   (REVIEW.md excluded paths you couldn't infer, bands.yaml/evals being
   for later, etc).

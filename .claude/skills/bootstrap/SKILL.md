---
name: bootstrap
description: Use at the start of a session in a freshly cloned/templated copy of this skeleton that hasn't been configured yet (no .claude/.bootstrapped file). Also user-invocable any time as /bootstrap to redo setup. Walks through project name, purpose, tech stack, and commands one question at a time, optionally scaffolds the project for the chosen stack, then fills in every current placeholder across CLAUDE.md, README.md, REVIEW.md, and .claude/hooks/.
---

# Bootstrap a new project from this skeleton

This repo is a template — the person you're talking to just cloned or
templated it to start a *new* project, not to edit the skeleton itself.
Your job is to set it up: ask a few questions, optionally scaffold the
chosen tech stack, then fill in every `<placeholder>` in the repo with
real values.

## Rule: one question at a time

Ask exactly one question per message, then wait for the reply before
asking the next. Never bundle several open questions into one message —
that's what made this cumbersome before. Keep each message short: a
sentence of context (if needed) plus the one question.

## Step 1 — project name and purpose

Ask: what is this project called, and in one sentence, what does it do?
Wait for the answer before moving on.

## Step 2 — tech stack

Use `AskUserQuestion` with these options (plus the built-in "Other" for
anything else):

- **Next.js** (TypeScript, App Router)
- **Python / Django**
- **React + Node** (Vite)
- **Plain Node/TS** (no framework)
- **Not sure yet** — skip stack setup for now

## Step 3 — scaffold (if applicable)

If Step 2 picked a stack with a known init command, ask a single yes/no
question: "Want me to set it up now with `<command>`?" If yes, run it. If
"Not sure yet" or "Other" with no obvious tool, skip this step — note in
the final summary that `/bootstrap` can be re-run later once the stack is
picked.

**Scaffolding procedure** (applies to any tool that refuses to run in a
non-empty directory — the skeleton's own files already occupy the repo
root):

1. `mkdir .bootstrap-tmp && cd .bootstrap-tmp`, run the scaffold command
   targeting `.` there.
2. Move everything from `.bootstrap-tmp/` into the repo root, except:
   - `README.md` — discard the scaffold's copy; this skill writes the
     real one in Step 7.
   - `.gitignore` — append the scaffold's entries onto the repo's
     existing `.gitignore` (adds framework-specific ignores like
     `.next/`) instead of overwriting it.
3. `cd ..` and remove `.bootstrap-tmp/`.

Per-stack commands:

- **Next.js**:
  `npx create-next-app@latest . --typescript --eslint --tailwind --app --src-dir --import-alias "@/*" --use-npm --yes`
  — run via the temp-dir procedure above.
- **Python/Django**:
  `python3 -m venv .venv && .venv/bin/pip install --upgrade pip django && .venv/bin/django-admin startproject <slug> . && .venv/bin/pip freeze > requirements.txt`
  — `<slug>` is the project name, lowercased with underscores. Django's
  `startproject` doesn't generate a conflicting README, so run this
  directly at the repo root (skip the temp-dir procedure).
- **React + Node (Vite)**:
  `npm create vite@latest . -- --template react-ts` then `npm install` —
  via the temp-dir procedure above.
- **Plain Node/TS**:
  `npm init -y && npm install --save-dev typescript @types/node && npx tsc --init`
  — doesn't generate a conflicting README, safe to run directly at the
  repo root.

## Step 4 — commands

Derive `CLAUDE.md`'s Commands section automatically where possible instead
of asking again:

- If `package.json` exists: read its `scripts` — map `dev`/`build` →
  Build, `test` → Test, `lint` → Lint. Note if there's no `format` script.
- If `manage.py` exists (Django): Build = n/a (interpreted), Test =
  `.venv/bin/python manage.py test`, dev server = `.venv/bin/python
  manage.py runserver`.

Only ask the user directly for a command if it genuinely can't be inferred
(no manifest present, or stack setup was skipped) — one question for
whatever's missing, not the whole set.

## Step 5 — architecture

If a stack was scaffolded, pre-fill the Architecture section from that
framework's standard layout (e.g. Next.js App Router: `src/app/` routes,
`src/components/`, `public/`). Ask a single question to confirm or adjust
it, rather than asking from scratch.

## Step 6 — deploy and protected paths (optional)

One combined question: "Any production deploy command yet, or
protected/generated paths? Fine to skip and fill in later."

## Step 7 — write everything

Edit:
- **`CLAUDE.md`** — Commands, Conventions, Architecture from the above.
  Leave "Things Claude gets wrong here" empty.
- **`README.md`** — replace the title and opening framing with the real
  project name/purpose. Leave the stage-map table and process notes as-is.
- **`REVIEW.md`** — fill "Excluded paths" with the stack's known
  generated/build dirs (Next.js → `.next/`, `node_modules/`; Django →
  `.venv/`, `__pycache__/`, `staticfiles/`). Leave the placeholder and say
  so in the summary if you can't confidently infer something.
- **`.claude/hooks/production-gate.sh`** — update the deploy-command match
  if one was given in Step 6; otherwise leave as-is.
- **`.claude/hooks/post-edit-reminder.sh`** — fill in the real format
  command (e.g. `npx prettier --write .`, `.venv/bin/black .`) if one
  exists.
- **`.claude/hooks/protected-paths.sh`** — fill `PROTECTED_PATTERNS` if
  named in Step 6; otherwise leave it empty (a valid, intentional state).

## What NOT to touch

Deliberately left for real use, not initial setup — don't fabricate
content for these to seem thorough:

- `bands.yaml` (Stage 6 monitoring thresholds — needs live metrics)
- `evals/examples/*.json` (Stage 4 — needs a real incident to regress-test)
- `intent/`, `design/`, `plans/` templates (per-initiative, not global
  setup)

## Finishing

1. Write `.claude/.bootstrapped` with the captured project name, stack,
   and today's date (plain text — a marker `session-start-check.sh` looks
   for, not a config file other tooling reads).
2. Report a short summary: what was scaffolded/installed, what was filled
   in, and what's still deferred (any placeholder you couldn't infer,
   plus the standing note about `bands.yaml`/`evals`).

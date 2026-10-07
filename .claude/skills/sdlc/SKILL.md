---
name: sdlc
description: Use when the user asks where they are in the process, what to do next, how this repo's workflow works, how to start a piece of work, or what unlocks the next stage — and any time work is about to move from one stage to the next. Also user-invocable as /sdlc. Reports which of the six SDLC stages the current branch is in, derived from the artifacts and approvals committed on the branch, and drives the next handoff.
---

# Where we are in the loop, and what's next

This repo runs the [AI-native
SDLC](https://claude.com/blog/the-ai-native-sdlc-playbook): six stages in a
loop, each ending by committing an artifact whose commit initiates the next
stage. There is no separate state to track — **the commits on the branch are
the state**, approvals included.

One short kebab-case slug (e.g. `csv-export`) names the branch and every
artifact on it.

| Stage | Artifact | Instructions | Ends when | Next session |
|---|---|---|---|---|
| 1. Plan | `intent/<slug>.md` | `stages/1-plan.md` | Intent committed as `status: draft` | Stage 2 — once a product owner commits `status: approved` |
| 2. Design | `design/<slug>.spec.md` | `stages/2-design.md` | Spec committed as `status: draft` | Stage 3 — once the product owner (and any flagged policy owner) commits `status: approved` |
| 3. Build — plan | `plans/<slug>.plan.md` | `stages/3-build.md` | Plan committed **before** any code | Stage 3 code — `/model sonnet`, auto mode |
| 3. Build — code | The code and its tests | `stages/3-build.md` | Code committed | Stage 4 — still `/model sonnet` |
| 4. Test | Verification output, `verifier` verdict | `stages/4-test.md` | Verification and `verifier` pass — **no commit, so no stop:** run straight on into Stage 5 | (same session) |
| 5. Deploy | A PR with `REVIEW.md`'s passes applied | `stages/5-deploy.md` | PR opened; a human approves and merges | — |
| 6. Maintain | A new `intent/<slug>.md` from a `bands.yaml` breach | `stages/6-maintain.md` | The breach intent is committed | Stage 1, again |

Paths are relative to this skill's directory. **Read only the stage file you
land in** — plus `5-deploy.md` when Stage 4 hands on to it.

Why the process is shaped this way: `session-economy.md` in this directory.

## Work out where you are

Read it off the branch, in this order — first match wins:

1. `git rev-parse --abbrev-ref HEAD`. On `main`/`master`, no work stream is
   checked out: the next action is Stage 1 on a new branch.
2. Otherwise the branch name is the slug. Walk `intent/<slug>.md`,
   `design/<slug>.spec.md`, `plans/<slug>.plan.md` in that order. An artifact
   counts only once it is committed (`git cat-file -e HEAD:<path>`
   succeeds), and an approval only once the committed version says so
   (`git show HEAD:<path>` has `status: approved`). What's on disk doesn't
   count either way.
   - Artifact not in `HEAD` → you are in the stage that produces it. If the
     file is already on disk, that stage's next action is to commit it.
   - Intent or spec in `HEAD` but not `status: approved` there → that stage
     is waiting on a human. If the file on disk already says `approved`,
     someone flipped it without committing; say so.
3. Plan committed, `git status --porcelain` dirty → Stage 3, in progress.
4. Plan committed, tree clean → has code landed since the plan?

   ```bash
   plan_commit=$(git log --diff-filter=A --format=%H -1 -- "plans/$slug.plan.md")
   git log "$plan_commit"..HEAD -- . ':(exclude)intent' ':(exclude)design' ':(exclude)plans'
   ```

   Output → Stage 4. Empty → Stage 3, no code yet. Date it from the commit
   that *added* the plan, not the last one to touch it.

The SessionStart hook (`.claude/hooks/session-start-check.sh`) runs the same
rules once per session and names the stage file. Re-derive them here rather
than trusting a stale reading from the top of the conversation — a commit
landing mid-session moves the branch to the next stage.

**Stage 0 — nothing started.** Agree a slug with the user, then
`git checkout -b <slug>`. Running two streams at once? Use the `worktree`
skill instead of switching branches in place.

## Handing off between stages

At each "Ends when" in the table: say the stage is done, name the next action
in one line, suggest a fresh session (with the table's model and mode, or —
when the next stage waits on an approval — who has to commit it), and stop
there. Don't take the next stage's first action in the same message, and
don't offer to. Say it once — if the user would rather keep going, and
nothing is waiting on an approval, keep going.

## Rules that don't bend

- Don't skip a stage, and don't start one whose upstream artifact isn't
  committed as `status: approved`. Waiting on a human approval is the
  process working, not a blocker to route around. Flip a `status:` to
  `approved` only when the approver tells you to, in this session.
- Nothing gets implemented without a committed plan.
- One session, one stage. A stage ends where the table above says it ends,
  and the next stage's first action belongs to the next session. Suggest the
  handoff instead of starting the work and mentioning the handoff afterwards.
  Stages 4 and 5 are the exception the table marks: there's no commit
  between them, so they run as one sequence.
- Don't run several *stages* together unasked. At a boundary, report where
  things stand compactly — a status line and the next action — and hand off.
  This governs stage transitions, not the steps inside a stage: Stage 4 and
  5's steps run back to back without checking in between.
- For a genuinely trivial change (typo, version bump, one-line fix with an
  obvious test), say so and go straight to a branch and a PR — no intent,
  spec or plan. The PR body says the artifacts were skipped and why; the
  human reviewer approves the skip when they approve the merge. Skipping is a
  judgment call to make out loud. Skipping on anything larger than that is
  not.

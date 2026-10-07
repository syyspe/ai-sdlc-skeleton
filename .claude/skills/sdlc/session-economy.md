# Why the process is shaped this way

`SKILL.md` and the stage files say what to do. This file is the only place
that says why. Read it when a rule looks like ceremony, or when deciding
whether to break one.

## Why each stage gets its own session

Every turn resends the whole conversation, so context length is a recurring
cost, not a one-time one. Billed per token, a long session costs more on
every turn than the same turn would in a short one, and Opus-tier tokens cost
several times what Sonnet-tier ones do. A stage's context is used up once its
artifact is committed. Carrying it into the next stage means paying for it
on every turn after that.

- **A session per stage, not per feature.** Each committed artifact is a
  natural clear point. `session-start-check.sh` re-derives the stage from
  what's committed, so a fresh session re-orients for almost nothing.
- **Read only the stage file you land in.** A session works one stage, so
  the other stage files would just add cost for the rest of it.
- **Match the model to the stage.** Plan, Design and the Build plan are
  where the judgment is and are worth the Opus rate. The Build code session
  executes a work order that is already written down and is the most
  turn-dense session; Test and Deploy are a handful of mechanical steps that
  mostly delegate. `/model sonnet` at the Build code handoff, and leave it
  there through Deploy.
- **Prefer reading to a subagent.** Sessions here are short, a few turns
  each, so a file read into the main session is resent only a handful of
  times. A subagent starts cold and re-derives context the session already
  has, which costs more than the read it replaces — so don't use `Explore`
  for "where does X live". The exception is `verifier` in Stage 4: there the
  fresh context is the point (see below), not a saving.
- **Don't resume a cold session.** The prompt cache goes stale after a
  while, so picking a long session back up after a break re-reads its whole
  context at full price.

## Why the boundaries are hard stops

It isn't only about tokens. A session that just built something is the
worst-placed judge of whether it works: it knows what the code was *meant* to
do, which is exactly the assumption verification exists to break. The fresh
context is the reason for the split, so checking the build is the next
session's job, done by a session that has to read the diff cold.

An approval boundary is a hard stop for a simpler reason: the next stage
can't legally start until someone else acts.

## Why the commit is the only state

- **Verification opens Stage 4 instead of closing Stage 3.** Every boundary
  is a commit, and whether verification has run is the one thing a fresh
  session can't read from the repo, so nothing gates on it. If something
  has to be *remembered* to be true, it isn't state. Only what's committed
  is.
- **Approvals are read from the committed `status:` in `HEAD`.** An approval
  is a decision someone is accountable for, so it has to leave a record:
  who flipped the flag, when, in which commit. A flag edited on disk and
  never committed has no author and can vanish with a `git checkout`, and a
  session that trusted it would start Design or Build on an approval that
  never happened. Reading `git show HEAD:<path>` instead of the file makes
  "approved" mean the same thing to every session, every worktree, and the
  reviewer reading the history.
- **Stage 4 is detected from the commit that *added* the plan.** A build
  session amends the plan in the same commit as the code it drifted from, so
  dating from the last commit to touch the plan would hide the very code the
  check is meant to detect.
- **Stages 4 and 5 run as one session.** They have no committed artifact
  between them — verification output and the review aren't commits — so
  there's nothing a fresh session could read to know Stage 4 had finished.
  The PR is the next thing that leaves a trace.

## Why each stage's rules are what they are

- **An intent doesn't invent constraints.** An intent that answers questions
  the user never considered is a spec's worth of assumptions dressed as a
  problem statement. Thin and honest is worth more than full and made up.
- **Plan before code.** This is the one piece of process that pays off every
  time: a written plan is what keeps a session from confidently building the
  wrong thing for an hour, and it is what Stage 4 compares the diff against.
  It has to be implementable from the file alone because the code session
  gets the file and nothing else.
- **The plan and the code change in the same commit.** A plan that silently
  drifts from the code is worse than no plan.
- **The plan session calls `EnterPlanMode` itself.** Switching the mode is
  the step people forget most often, so it's the session's job, not the
  user's.
- **Approving `ExitPlanMode` gets mistaken for a go-ahead to build.** It is
  the boundary most often crossed without noticing: the plan is fresh in
  context, step 1 looks small, and starting it costs nothing visible. It
  approves the plan only.
- **The failing test is committed before the fix.** A test edited during the
  fix has stopped being evidence.
- **Unplanned work is named in the PR body.** It isn't automatically wrong,
  but it should reach the reviewer as a decision, not as a surprise found
  while reading.
- **The trivial-change exception.** An intent, a spec and a plan for a typo
  cost three approvals and three sessions to protect nothing. The PR review
  is still a human approval, so the skip is approved in the open rather than
  taken quietly.
- **The light path at Test/Deploy.** A docs-only or internal-refactor diff
  can't change what the app does or where its boundaries are. The
  verification command and `/review`'s four passes still run; `verifier` and
  `/security-review` would cost more than they could catch in a diff like
  that. Anything executable — a hook, config, a dependency — can go wrong in
  ways they catch, so it takes the full sequence.

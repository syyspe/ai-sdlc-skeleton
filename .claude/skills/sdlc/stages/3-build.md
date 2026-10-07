# Stage 3 — Build

Only once `design/<slug>.spec.md` is committed as `status: approved`. Build
takes two sessions: one writes the plan, the next writes the code.

## The plan session

Call `EnterPlanMode` yourself, as the first action of the session. Don't wait
to be asked and don't assume the user started the session in plan mode.

Then read the spec and iterate until an engineer who has never seen the
conversation could implement the change from the plan alone. List a test for
each of the spec's failure cases under Tests, by name.

Once `ExitPlanMode` is approved, write the plan into `plans/<slug>.plan.md`
in `plans/TEMPLATE.plan.md`'s shape, with `status: approved` — the engineer
just approved it — and commit it.

Approving `ExitPlanMode` approves the plan, not the build. After committing,
stop: don't open a file from the work order, don't do step 1 "while we're
here" — say the plan is committed and name its first step in one line. Then
hand off: `SKILL.md` "Handing off".

## The code session

Implement the work order in `plans/<slug>.plan.md`.

- `simple-code` applies from the first line, not as a cleanup pass afterwards.
  `error-handling` applies the same way to anything that can fail, and
  `logging` to anything that logs.
- For a bug fix, commit the failing test *before* the fix, and don't edit it
  while fixing.
- If the implementation departs from the plan, update `plans/<slug>.plan.md`
  in the same commit.

The stage ends at that commit. No verification command, `verifier` or
`/review` here — those are Stages 4 and 5, in a fresh session.

Then hand off: `SKILL.md` "Handing off".

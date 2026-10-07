# Stage 2 — Design

Only once `intent/<slug>.md` is committed as `status: approved`.

Draft `design/<slug>.spec.md` from the intent using `design/TEMPLATE.spec.md`.

- Requirements get enumerated, not prosed: Stage 3's plan is checked against
  them, and Stage 5's Compliance pass checks the diff against them.
- Every policy skill in `.claude/skills/` that matches applies here. Record
  what each raised, and how it was resolved, under **Policy flags**.
  Unresolved flags go to that policy's owner before the product owner
  approves.
- If the spec adds code that can fail at a boundary, follow the
  `error-handling` skill: list the failure cases under Requirements. If
  `CLAUDE.md`'s `Errors:` line says the contract isn't decided, decide it in
  this spec's Contracts section — and the `Logging:` contract with it, per
  the `logging` skill — and list that decision under Policy flags.

Review it with the user, set `status: draft`, and commit it. That commit ends
the stage.

Stage 3 doesn't start until the flags are resolved, the product owner
approves, and a commit sets `status: approved`. Say who has to do that, then
hand off: `SKILL.md` "Handing off".

# Review Policy

This file defines the review passes Claude runs on every pull request (Stage
5 of the AI-native SDLC). Keep it authoritative and specific rather than
generic.

## What actually reads it

`.github/workflows/claude-review.yml` does — its prompt names this file, so
the CI review on a PR runs the four passes below as a single pass, no
subagent fan-out. Locally, `/review` (`.claude/skills/review/`) does the same
thing, on demand, before the branch is pushed — it's the default for Stage 5.
The built-in `/code-review` command does **not** read this file: it has
fixed passes of its own (correctness bugs, plus cleanup for reuse,
simplification and efficiency, plus one conventions angle that checks the
diff against `CLAUDE.md`), and above `low`/`medium` effort it fans out into
several parallel subagents — useful for an occasional deeper pass, expensive
as a default. It also reviews only the diff — `git diff @{upstream}...HEAD`
plus uncommitted changes — unless it's handed a path, a branch, or a PR
number.

So in a local Stage 5, `/review` covers all four passes below in one shot.
`/code-review` never runs unasked, however warranted a deeper pass looks —
"this diff seems high-stakes" is a reason to ask the user, not to invoke it.
If they do want it run (instead of, or in addition to, `/review`), three of
the four passes below then arrive by other routes: `verifier` covers the
plan half of **Compliance**, `/code-review` covers **Bugs** and most of
**Simplicity**, and **Security** needs `/security-review` run explicitly.
The spec half of **Compliance** has no automation on that route — it's the
human reviewer's job when they read the PR. Anything here that has to bind a
`/code-review` pass (an exclusion, a hard limit) must be restated in
`CLAUDE.md`, the only policy file it sees — `/review` reads this file
directly, so it needs nothing restated.

## Passes

Every PR gets four passes, in this order:

1. **Bugs** — logic errors, regressions, edge cases, off-by-ones, unhandled
   error paths. Check errors against the `Errors:` contract in `CLAUDE.md`
   and `.claude/skills/error-handling/SKILL.md`: input a caller controls
   that can produce a 5xx or crash, a swallowed or double-logged error, a
   failure response shaped outside the contract, a new boundary without
   failure-case tests. Check logging against the `Logging:` contract and
   `.claude/skills/logging/SKILL.md`: a leftover `print`/`console.log`, a
   secret, body or personal data in a log line, a new request, command or
   job with no finishing log line. Cross-reference against
   `plans/<branch>.plan.md` if one exists: does the diff match what was
   planned?
2. **Security** — injection risks, authentication/authorization gaps, PII or
   secret exposure, unsafe deserialization, missing input validation. Apply
   any relevant skill in `.claude/skills/` (e.g. `secure-api-review`).
3. **Compliance** — alignment with `design/<name>.spec.md` and any org
   design/brand principles. Flag scope creep beyond what the spec describes.
4. **Simplicity** — function/file length, parameter count, nesting depth,
   and complexity within the limits in
   `.claude/skills/simple-code/SKILL.md`; flag defensive code handling
   cases that can't occur, and cleverness where a simpler version would
   read just as fast.

## Severity

- **Important** — must be resolved before merge. Bugs, security issues, and
  spec deviations are always Important.
- **Nit** — style/preference, safe to defer. Cap: **5 nits per review**. If
  there are more than 5, only surface the 5 highest-value ones.

## Excluded paths

Do not review, or review at reduced strictness:

- Generated code: `<e.g. "schemas/", "*.generated.*">`
- CI-enforced items already caught by lint/format: `<list>`
- `<other excluded paths>`

## Response loop

- PR authors can tag `@claude` on a review comment to request an automated
  fix; Claude addresses it and pushes a correction.
- If a review catches the **same class of mistake** for the second time
  across different PRs, add it to the "Things Claude gets wrong here"
  section of `CLAUDE.md` so it's caught earlier next time — during
  implementation, not review.

## Human authority

Claude's review findings are advisory. A human approves the merge, and the
default branch only moves by merged PR — `default-branch-guard.sh` blocks a
direct push, so these passes can't be skipped by pushing past them. On
anything touching a protected path or production deploy, the hooks in
`.claude/hooks/` enforce this too — see `production-gate.sh`.

Back this with branch protection on the remote where your plan allows it. A
hook binds Claude sessions in this repo; only the server side binds everyone.

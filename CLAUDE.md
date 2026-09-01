# Project Instructions for Claude

> Template: replace every `<placeholder>` before use. This file is read by
> Claude at the start of every session in this repo — it's the highest
> leverage file in the whole skeleton. Keep it accurate; stale instructions
> are worse than none.

## Commands

- Build: `<build command>`
- Test (unit): `<unit test command>`
- Test (integration): `<integration test command>`
- Lint: `<lint command>`
- Format: `<format command>`

Expected healthy output for tests: `<e.g. "N passed, 0 failed">`

## Conventions

- Language/runtime: `<language + version>`
- Framework: `<framework + version>`
- Dependency policy: `<e.g. "no new dependencies without approval">`
- `<other hard rules — e.g. "money is always Decimal, never float">`
- `<testing convention — e.g. "every endpoint needs an integration test">`

## Architecture

- `<top-level dir>/` — `<what lives here>`
- `<top-level dir>/` — `<what lives here>`
- `<note on generated code, if any — e.g. "schemas/ is generated, never edit by hand">`

## Things Claude gets wrong here

> Add to this list the second time Claude makes the same mistake — see
> `REVIEW.md` for the review-feedback loop that feeds this section.

- `<example: "don't bump dependency versions without being asked">`
- `<example: "package X is frozen, changes go in package Y">`

## Working agreement

- Nothing gets implemented without a plan first — see `plans/README.md`.
- Skills in `.claude/skills/` encode policy that applies automatically; read
  them if you're unsure why a change was flagged.
- Hooks in `.claude/hooks/` are hard guardrails, not suggestions — if one
  blocks you, that's a signal to ask a human, not to work around it.

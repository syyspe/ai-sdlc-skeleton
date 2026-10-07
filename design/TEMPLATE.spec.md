---
status: draft # draft | approved | superseded
intent: intent/<matching-file>.md
author: <name/email, or "Claude" if agent-drafted>
date: <YYYY-MM-DD>
---

# <Short title> — Spec

## Requirements

What must the solution do? Enumerate, don't prose — this is what Stage 3
plans get checked against, and what Stage 5 review checks compliance
against.

1. ...
2. ...
- Failure cases: `<each way a new boundary can fail, and what the caller
  gets — see the error-handling skill; delete if nothing new can fail>`

## Design

How will it work? Interfaces, data flow, key decisions and why. Call out
alternatives considered and rejected, briefly.

## Contracts

- Errors: `<the error contract, if this spec decides it — see the
  error-handling skill>`
- Logging: `<the logging contract, decided with it — see the logging skill>`

Delete this section unless `CLAUDE.md` still says these are not decided and
this spec adds the project's first boundary (an endpoint, a CLI command,
external I/O). A contract decided here binds every later change, so list it
under Policy flags too.

## Policy flags

Anything a skill in `.claude/skills/` raised during drafting (security,
compliance, brand, UX), and how it was resolved. Leave empty if none.

## Out of scope

What this explicitly does not cover, to prevent scope creep during Build.

## Open questions

Anything still unresolved that engineering needs to answer during planning.

---

**Product owner approval:** `<name>` — `<date>`

**Next stage:** once policy flags are resolved and approval is in, set
`status: approved` above and commit — that commit is the approval. Then run
`/sdlc`.

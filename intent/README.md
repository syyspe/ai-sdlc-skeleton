# intent/ — Stage 1: Plan

One file per initiative, named `<short-slug>.md`. Anyone on the team can
start one by talking through the idea with Claude — no git or engineering
expertise required if a connector is wired up to commit on their behalf.

Copy `TEMPLATE.md` to get started. A product owner reviews and approves
before it advances to Stage 2 (Design).

The slug also names the branch (`git checkout -b <slug>`) and every
downstream artifact (`design/<slug>.spec.md`, `plans/<slug>.plan.md`).

Control-band breaches from `bands.yaml` (Stage 6) also land here
automatically, in the same format, closing the monitoring loop back to
Stage 1.

How to write one, and what unlocks the next stage:
`.claude/skills/sdlc/stages/1-plan.md`.

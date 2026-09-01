# evals/ — Stage 4: regression tests for agent configuration

`CLAUDE.md`, `.claude/skills/`, and `.claude/hooks/` are configuration, and
configuration regresses just like code. Evals catch that: they're a set of
real tasks with expected outcomes, run non-interactively whenever this
configuration changes.

## How this works

1. **Collect real tasks.** Each `examples/*.json` file is one task: a prompt
   (as if a developer asked Claude to do it) and acceptance criteria (tests
   pass, lint clean, a specific behavior happens, a specific policy is
   followed).
2. **Add every production incident.** When something goes wrong in
   production because Claude did (or didn't do) something, write an eval
   that reproduces the scenario and asserts the correct behavior. This is
   the single highest-value source of evals — it directly prevents repeat
   incidents.
3. **Run in CI** on a schedule and whenever `CLAUDE.md` or `.claude/**`
   changes (see `.github/workflows/agent-evals.yml`). A regression blocks
   the config change from merging.
4. **Target 20-50 tasks** as a starting size — enough to catch real
   regressions without the suite becoming a maintenance burden itself.

## Eval file format

See `examples/incident-001.json` for a filled-out example. Shape:

```json
{
  "id": "incident-001",
  "description": "<what this guards against, and why — link the incident if there is one>",
  "prompt": "<the task, as given to Claude non-interactively>",
  "checks": [
    { "type": "command", "command": "<shell command that must exit 0>" },
    { "type": "manual", "criteria": "<something a reviewer/LLM-judge checks>" }
  ]
}
```

`run.sh` is a minimal harness: it iterates `examples/*.json`, runs the prompt
through `claude -p` non-interactively, and runs each check. Adapt it to
however your CI actually wants to score results (pass rate, blocking
threshold, etc).

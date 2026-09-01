# AI-Native SDLC Skeleton

A starter repo for running the full software development lifecycle with Claude
embedded at every stage, following the [AI-Native SDLC
Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook). Clone this
into a new project to get the artifact chain, guardrails, and eval loop
scaffolded from day one.

The core idea: every stage produces a version-controlled artifact the next
stage reads. Humans stay accountable for judgment calls (approving specs,
plans, and production releases); Claude does the work in between.

```
intent.md  →  spec.md  →  plan.md  →  PR + tests  →  deploy  →  monitoring
 (Plan)       (Design)     (Build)     (Test/Review)  (Deploy)   (Maintain)
```

## Getting started with a new project

1. On GitHub, click **Use this template** on this repo → create your new
   repo (clean history, no link back to this skeleton).
2. Clone it locally.
3. Run `claude` in it. An unconfigured clone is detected automatically —
   Claude starts setup right away, one question at a time (project name,
   purpose, tech stack, commands). For a known stack (Next.js, Django,
   React+Vite, plain Node/TS) it offers to scaffold the project too, then
   fills in every `<placeholder>` across `CLAUDE.md`, `README.md`,
   `REVIEW.md`, and `.claude/hooks/`. Re-run any time with `/bootstrap`
   (e.g. if the stack changes later).
4. *(Optional)* set the `ANTHROPIC_API_KEY` secret on the new GitHub repo
   (Settings → Secrets → Actions) so `.github/workflows/agent-evals.yml`
   and the PR review workflow can run.
5. **Trim or extend `.claude/skills/`** for anything project-specific
   beyond what bootstrap covers — org brand, compliance, or UX policies.
6. **Write your first `intent/*.md`** using the template, and you're in
   the loop.

Bootstrap deliberately leaves `bands.yaml`, `evals/examples/`, and the
`intent/`/`design/`/`plans/` templates alone — those fill in from real use,
not initial setup.

### Maintaining this skeleton itself

This repo needs to be marked as a **GitHub template repository** for step 1
above to work: `gh repo edit <owner>/<repo> --template`, or Settings →
General → check "Template repository". One-time setup, done once this repo
is pushed.

## Repository layout

| Path | Stage | Purpose |
|---|---|---|
| `intent/` | 1. Plan | Problem framing, one file per initiative |
| `design/` | 2. Design | Requirements + design spec derived from an intent |
| `plans/` | 3. Build | Implementation plans (usually one per branch/PR, committed for audit trail) |
| `CLAUDE.md` | 3. Build | Institutional knowledge Claude reads every session |
| `.claude/skills/` | 2–3 | Triggered policy skills (brand, security, compliance, UX) |
| `.claude/hooks/` | 3, 5 | Deterministic guardrails and approval gates |
| `.claude/agents/` | 3 | Subagents for repeated tasks (verification, review, research) |
| `.claude/settings.json` | 3, 5 | Wires hooks into tool events |
| `evals/` | 4. Test | Regression tests for agent configuration itself |
| `.github/workflows/agent-evals.yml` | 4, 5 | CI that runs evals when `CLAUDE.md`/`.claude/` change |
| `REVIEW.md` | 5. Deploy | PR review policy Claude applies to every change |
| `bands.yaml` | 6. Maintain | Control-band thresholds for monitoring → intent.md |

## Stage-by-stage notes

**1. Plan.** Anyone can start an `intent/*.md` by talking to Claude — no git
expertise required if you wire up a connector (e.g. via Claude or Cowork) that
commits on their behalf. A product owner reviews before it advances.

**2. Design.** Claude reads the accepted intent and drafts `design/*.md`,
constrained by whatever skills encode your policies. Flagged concerns go to
the policy owner; the product owner approves before build starts.

**3. Build.** Start every implementation in Claude Code's plan mode. Commit
the approved plan to `plans/` before writing code — that's your audit trail.
Run independent streams in separate git worktrees.

**4. Test.** Wrap verification in one command (`make test`, `npm test`, etc.)
documented in `CLAUDE.md` with expected healthy output. For bug fixes, write
and commit the failing test *before* the fix, and don't let the agent edit it
while fixing. Treat `CLAUDE.md`/`.claude/` changes like code: they get evals
in CI (see `evals/`), and every production incident becomes a permanent eval.

**5. Deploy.** `REVIEW.md` defines the passes Claude runs on every PR (bugs,
security, compliance). Hooks act as approval gates for anything
hard-to-reverse — production deploys, protected-path edits. If you're a
regulated org, layer in [managed
settings](https://docs.claude.com/en/docs/claude-code/settings) at the admin
console level so engineers can't override the gates.

**6. Maintain.** A monitoring script watches SLOs against the bands in
`bands.yaml`. Breaches past the top band produce a new `intent/*.md` with
anomaly evidence — closing the loop back to Stage 1. Each incident class
should also land in `evals/` as a regression test.

## What this skeleton deliberately leaves out

- No language/stack is assumed — commands in `CLAUDE.md` and hook scripts are
  placeholders you fill in.
- No production monitoring script is included (Stage 6's detection script is
  specific to your metrics stack) — `bands.yaml` just defines the shape.
- No license file — add one before making the repo public if you intend
  others to reuse it.

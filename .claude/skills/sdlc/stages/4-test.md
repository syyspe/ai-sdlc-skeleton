# Stage 4 — Test

A fresh session, opening on a clean tree with the build committed. Stages 4
and 5 have no commit between them, so they run as one continuous sequence:
the two steps here, then `5-deploy.md`'s. Don't stop between steps to ask how
to proceed.

**Light path, for low-risk diffs only.** If the diff is docs only (`*.md`,
comments) or an internal refactor with no behaviour change, run step 1 here,
then Stage 5's `/review` and PR, and skip `verifier` and `/security-review`.
Say in the PR body that the light path was used and why. A diff that touches
a hook, config, a dependency or anything executable is not low-risk: it runs
every step.

1. **Verify.** Run the verification command from `CLAUDE.md` and report its
   real output, not a paraphrase. If it says "3 failed," say that.
2. **`verifier`.** The subagent re-checks the diff against
   `plans/<slug>.plan.md` with fresh context and reports PASS / FAIL / PASS
   WITH CONCERNS. It also covers scope against the plan: anything changed
   that wasn't planned, anything planned that wasn't done.

If the change touched `CLAUDE.md` or `.claude/**`, the eval suite has to pass
too — `evals/run.sh` locally, or `agent-evals.yml` on the PR.

Both green → go straight on to `5-deploy.md`.

## When a step fails

Fixing it is this session's job. A one-line fix happens here, and steps 1–2
run again; anything substantial means a real return to Stage 3 — say so, and
start a fresh code session rather than quietly turning this one into one.

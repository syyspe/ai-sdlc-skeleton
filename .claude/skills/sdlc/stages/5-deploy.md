# Stage 5 — Deploy

Runs straight on from Stage 4, in the same session, once verification and
`verifier` are green (or once step 1 is, on the light path).

1. **`/review`.** It applies `REVIEW.md`'s four passes — Bugs, Security,
   Compliance, Simplicity. Fix what it raises. Never run `/code-review`
   unless the user asks — see `.claude/skills/review/SKILL.md`.
2. **`/security-review`** when the diff touches a real boundary — user input,
   auth, secrets, deserialization, file or network I/O, a new dependency. Say
   so when you skip it, and why.
3. **Open the PR.** `git push -u origin <slug> && gh pr create`. The default
   branch is PR-only and `default-branch-guard.sh` blocks a direct push, even
   for a one-line change.

   In the PR body, name anything in the diff that neither
   `design/<slug>.spec.md` nor the plan asked for, and say if the light path
   or the trivial-change exception was used.

Claude's findings are advisory; a human approves and merges. Hooks gate
anything hard to reverse — if one blocks you, that's a signal to ask a human,
not to work around it.

After merge, Stage 6 takes over: `6-maintain.md`.

---
name: worktree
description: Use when the user wants to work on something in parallel with the current session, start a new work stream alongside this one, or explicitly mentions git worktrees. Sets up a sibling worktree + branch with a consistent naming convention and hands back the exact command to start a session there — does not and cannot open that second session itself.
---

# Set up a parallel worktree

## Scope boundary — read this first

This skill creates the worktree and branch. It cannot launch a second
terminal or a second `claude` session — Claude Code has no way to do
that. The last step is always handing the user a command to run
themselves, in a new terminal tab.

## Naming convention

Worktrees live as **sibling directories** to the main repo, never nested
inside it: for a repo checked out at `.../my-project`, a worktree for
slug `csv-export` goes at `.../my-project-csv-export`.

Get the repo's directory name with `basename "$(git rev-parse
--show-toplevel)"`, and the slug from what the user's working on (ask if
it's not obvious — reuse an existing `intent/`/`plans/` slug if there is
one).

## Creating it

**New branch** (the common case — starting a new stream of work):

```
git worktree add ../<repo-dir-name>-<slug> -b <slug>
```

Branches from the current `HEAD` by default. If the current branch is
itself mid-work on something unrelated, ask which branch to base the new
one on (usually the default branch) rather than assuming.

**Existing branch** (resuming work someone/something already pushed):

```
git worktree add ../<repo-dir-name>-<slug> <existing-branch>
```

## After creating

Report:
- The absolute path to the new worktree.
- The exact command to run next, in a new terminal: `cd <path> && claude`.
- That it's already fully set up — `.claude/.bootstrapped` and all
  tracked config are present (worktrees share the repo's history), so the
  new session won't re-run bootstrap.

## Cleanup

Once the branch is merged:

```
git worktree remove <path>   # from the main repo
git branch -d <slug>         # if you're done with the branch too
```

`git worktree list` shows everything currently active, from any worktree.

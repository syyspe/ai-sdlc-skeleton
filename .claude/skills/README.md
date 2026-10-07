# .claude/skills/ — policy encoding

Skills here are triggered automatically during Stage 2 (Design) and Stage 3
(Build) to apply organizational policy consistently — brand, security,
compliance, UX. They're advisory controls: they make correct behavior
likely, unlike hooks (`.claude/hooks/`) which make violations impossible.

`secure-api-review/`, `simple-code/`, `error-handling/` and `logging/` are
filled-out examples of that.
Four others aren't policy — they drive the process itself: `sdlc/` (`/sdlc`
— which stage the branch is in and what's next), `bootstrap/` (one-time
project setup), `worktree/` (parallel work streams), and `review/`
(`/review` — Stage 5's default local pass against `REVIEW.md`, run inline
instead of fanning out into subagents).

Add more folders following the same shape — one directory per skill,
containing a `SKILL.md` with frontmatter describing when it triggers.

When a policy changes, update the skill here once; it applies everywhere
this repo is used from that point on.

Prefer `CLAUDE.md` for anything that's always true, and a skill for anything
that's true only in a specific situation — a skill that always triggers is
just `CLAUDE.md` with extra steps.

The same split works *inside* a skill once its `SKILL.md` covers several
situations at once. `sdlc/` is the worked example: the `SKILL.md` works out
which stage the branch is in, and the six `stages/*.md` files hold the
instructions for one stage each, so a session reads the one it's in and never
pays for the other five. Split a skill this way only when something can name
the right file without reading them all — here the `SKILL.md` and the
SessionStart hook both do. Without that, you've hidden the instructions rather
than deferred them.

## Never Commit Changes Directly to `main` — Always Work on a Branch

**Any change that gets committed — code, docs, rules, config, `.claude/` content, anything — goes on a
dedicated branch off `main`, never as a commit on `main` itself. Create the branch before (or immediately
after) making the edits, and open a PR rather than pushing to `main`.**

**Why:** `main` is the default/protected branch and the base every PR merges into. A stray commit made
directly on the local `main` checkout diverges it from `origin/main`, corrupts the base for every other
branch and worktree, and bypasses the review pass (`pr-review-workflow.md`) and CI gates that every change is
supposed to clear. It also collides with the concurrent-agent model — another agent expecting a clean `main`
(`concurrent-agent-workdir.md`) can be derailed by unexpected local commits. Keeping `main` a pristine mirror
of `origin/main` is what makes branching, worktrees, and PR review reliable.

**How to apply:**
- Before committing anything, run `git branch --show-current`. If it prints `main`, stop and create a branch
  first: `git switch -c <type>/<short-description>` (e.g. `docs/update-claude-md`, `feat/draft-recap`,
  `fix/rate-limit-429`). Uncommitted working-tree edits carry over to the new branch automatically, so you can
  branch after editing and before committing without losing work.
- Name the branch by the change: `feat/…`, `fix/…`, `docs/…`, `chore/…`, `refactor/…` — matching the commit/PR
  prefixes already used in this repo's history.
- Land the change via a PR into `main` (`gh pr create …`) and follow `pr-review-workflow.md` for the review +
  merge pass — do not `git push origin main` or otherwise write to `main` directly.
- By default, do change-producing work from an isolated `git worktree` checked out from `origin/main` rather
  than branching the shared checkout (`worktree-first.md`) — this is the standing default for all such work, not
  just when another agent is known to be active (see also `concurrent-agent-workdir.md`).
- This applies even to tiny/one-line changes and to `.claude/` rules, skills, and memory edits — "it's just
  docs" is not an exception; the pristine-`main` invariant is the whole point.

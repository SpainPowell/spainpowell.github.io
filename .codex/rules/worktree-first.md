## Always Start Work in an Isolated Git Worktree — Never in the Shared Main Checkout

**Before making any file edits or producing any commits for a task, create a dedicated `git worktree` checked
out from latest `origin/main` and do all the work there. Do not edit, build-for-commit, or commit in the shared
main working directory.**

**Why:** The shared main working directory is routinely occupied by a concurrent agent, and there is no
reliable in-band signal when that happens. A real, repeated failure: an agent created a feature branch in the
shared checkout, and while it was mid-task a *different* concurrently-running agent switched the shared checkout
back to `main`, silently reparenting the first agent's uncommitted work onto `main` (see the incidents behind
`concurrent-agent-workdir.md` and `git-restore-scope-safety.md`). Working in the shared directory risks
colliding with another agent's in-flight edits, basing commits on a stale tree, switching a branch out from
under someone mid-edit, and polluting `main`. An isolated worktree gives every task its own clean checkout off
current `origin/main`, so any number of agents can work in parallel without ever stepping on each other. This
makes worktree-first the *default* — not just the fallback for when concurrency is detected — because by the
time you detect it, work may already be intertwined.

**How to apply:**
- **At the very start of any task that will edit files or produce commits**, before the first edit, create the
  worktree and its branch together off latest `origin/main`:
  ```bash
  git fetch origin
  git worktree add ../wtn-<slug> -b <type>/<slug> origin/main
  ```
  Put the worktree in a **sibling directory outside the repo** (`../wtn-<slug>`, i.e. alongside the checkout —
  e.g. `/Users/<you>/Documents/GitHub/wtn-<slug>` on this macOS setup), not inside the working tree. Branch
  naming follows the repo convention (`feat/…`, `fix/…`, `chore/…`, `perf/…`, `docs/…`).
- **Do everything from the worktree**: edits, tests, lint/typecheck, commit, push, and the PR. Never reach back
  into the shared main checkout to make changes.
- **`node_modules` is not shared** across worktrees (it's a real, git-ignored directory per checkout). For JS
  work either symlink the main checkout's copy read-only
  (`ln -sfn /Users/<you>/Documents/GitHub/WinTheNumbers/mobile/node_modules node_modules`) or run `npm ci` in
  the worktree. Backend Python work uses the same interpreter/venv regardless of worktree.
- **After the PR merges, tear the worktree down**: `git worktree remove <path>` (add `--force` only if it holds
  intentional throwaway state) and delete the local branch (`git branch -d <branch>`, which the merge makes
  safe). `gh pr merge --delete-branch` handles the remote branch but **cannot** delete a local branch still
  checked out in a worktree — it will warn and skip it (remote deletion still succeeds); remove the worktree and
  prune the local branch afterward. Never pass `--delete-branch` at a branch checked out in *another* agent's
  worktree (`pr-review-workflow.md`).
- **If you already started editing in the shared checkout by mistake**, don't commit there: save your changes as
  a patch (`git diff > /tmp/…patch`, and copy any untracked files), create the worktree off `origin/main`,
  `git apply` the patch there, verify the diff is exactly your intended change, then restore the shared checkout
  to pristine (`git restore <your-files>` — only files you edited, and only after the patch is safely
  captured; see `git-restore-scope-safety.md`). This is the exact recovery that unwound the reparented-work
  incident above.
- **The only exception is genuinely read-only work** — answering a question, code exploration, a review pass with
  no edits. Those don't need a worktree. Anything that produces a diff does.
- This composes with, and takes precedence over the "shared checkout" phrasing in, `fresh-branch-by-default.md`
  (branch off `origin/main`), `branch-before-changes.md` (never commit to `main`), `concurrent-agent-workdir.md`
  (don't disturb others' work), and the review/merge gates in `pr-review-workflow.md`. It changes only *where*
  the work happens, not the review/merge requirements.

> **Absorbed rule (2026-08-18):** `fresh-branch-by-default` is merged into this rule. When a worktree is not warranted (small, attended change), still create a fresh branch before making changes — never work directly on main.

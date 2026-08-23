## Check for Concurrent Agent Activity Before Touching the Main Working Directory

**Before running or building against the main repo checkout, run `git status --short --branch` and
`git worktree list` — if the working tree is on an unexpected branch with uncommitted changes, another agent
is very likely mid-task in that same directory. Don't disturb it.**

**Why:** this repo's main working directory has been found checked out to an unrelated feature branch with live
uncommitted edits (new files being added, tracked files modified) on more than one occasion, left by a different,
concurrently-running agent the current session had no visibility into. Stashing, committing on its behalf,
switching branches out from under it, or discarding those changes would destroy in-progress work with no way to
recover it. Simply reading `git status` first cheaply avoids this.

**How to apply:** the standing default is to do all change-producing work from an isolated `git worktree` off
`origin/main` (`worktree-first.md`), which sidesteps this collision entirely — you never share the checkout in
the first place. This rule is the backstop for the cases where you nonetheless need to touch the shared main
checkout (e.g. running/building the app there): any time a task needs to run the app, build, or otherwise
operate on the actual working directory (not just read files) — especially at the *start* of a task, before
you've made any changes of your own — check `git status --short --branch` and `git worktree list` first. If it
looks mid-edit and unrelated to your task: leave it exactly as found, and do your own work from a `git worktree`
checked out from `origin/main` instead of the shared directory. If a stray branch or commit turns out to be
yours from an earlier mis-step, clean it up explicitly rather than leaving it for the next session to puzzle
over.

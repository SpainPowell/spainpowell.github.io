## Verify a Destructive Git Command's Target Ref Actually Contains the Path Before Running It

**`git restore --staged --worktree -- <path>` and `git checkout <ref> -- <path>` don't "undo my last command" —
they overwrite the working tree to match whatever `<ref>` has at `<path>`, including nothing at all.**

**Why:** During a session adding new `.claude/rules/` and `.claude/skills/` content, a failed `git commit`
(blocked by a pre-commit hook linting the new files) was "cleaned up" with
`git restore --staged --worktree -- .claude`. Since none of the new files existed in `HEAD`, this didn't
unstage them — it deleted all ~221 newly-added, never-committed files from disk outright. They were only
recoverable because git had already written blob objects for them during the earlier `git add` and hadn't
garbage-collected yet; they were found via `git fsck --no-reflogs --unreachable --full` and reconstructed
with `git archive <tree> | tar -x -f - -C <dir>`. A second mistake in the same recovery made this worse: an
attempted recovery via `git checkout <tree-hash> -- .` used a *subtree* hash (the tree for `.claude/rules/`
itself, not the repo root) but checked it out relative to the current directory — silently duplicating the
subtree's contents at the repo root instead of inside `.claude/rules/`, requiring a second cleanup pass.

**How to apply:**
- Before running `git restore --staged --worktree` or `git checkout <ref> -- <path>` on anything that might
  be new/untracked, run `git status --short` first. A `??` entry means the path isn't in the index/HEAD right
  now — but restoring/checking out against *any* ref that lacks the path at that ref (not just "never existed
  in history") deletes the working-tree copy; it does not "reset" it. Confirm with `git ls-tree <ref> -- <path>`
  (empty output = that ref has nothing there) before proceeding.
- To only unstage a file without touching its working-tree content, use `git restore --staged <path>` alone —
  never add `--worktree` unless you've confirmed the ref you're restoring to already has that exact content.
- To extract a specific subtree/subdirectory's content from a tree object (e.g. recovering one folder from a
  dangling tree), never use `git checkout <tree> -- .` — it checks out relative to the current working
  directory with no regard for what part of the repo that tree represents. Use
  `git archive <tree> | tar -x -f - -C <explicit-target-dir>` instead (the explicit `-f -` reads the piped
  archive from stdin portably — some `tar` implementations don't default to stdin), which has no path ambiguity.
- If a destructive git command already ran against uncommitted new files, don't assume the data is gone:
  check `git fsck --no-reflogs --unreachable --full` for dangling blob/tree objects (git only garbage-collects
  periodically) before reporting anything as unrecoverable.

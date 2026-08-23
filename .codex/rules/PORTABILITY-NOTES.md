# Rules — portability notes (Codex CLI)

Codex has no first-class "rules" primitive — no `paths:`-scoped, separately
loaded rule files like Claude Code's `.claude/rules/`. These files were
copied verbatim from `../../CLAUDE/rules/`; loading them is your
responsibility:

- Fold a rule into the relevant subtree's `AGENTS.override.md` if it's
  genuinely path-scoped (Codex supports per-directory override files
  natively — this is the closest real equivalent to `paths:` frontmatter).
- Reference a rule from the root `AGENTS.md` if it should always load.
- Or point a Codex skill at the rules directory if the loading behavior
  should be conditional/on-demand rather than always-on.

The content of most rules (the actual constraint being stated) is
tool-agnostic prose and needs no rewriting. The following files, however,
were written assuming Claude Code-specific mechanics and should be read
before use — not just copied — because they name a tool, command, or
concept Codex either doesn't have or does differently:

- `branch-before-changes.md`
- `ci-billing-outage-local-verification.md`
- `concurrent-agent-workdir.md`
- `context-compaction.md`
- `git-restore-scope-safety.md`
- `pr-checks-not-dispatching.md`
- `resume-agents-via-sendmessage.md` — references Claude Code's Task tool /
  SendMessage resume mechanism directly; Codex's subagent model
  (developers.openai.com/codex/subagents) doesn't share that plumbing, so
  this one likely needs a rewrite rather than a read-through.
- `simulator-verification.md`
- `worktree-first.md`

(Flagged by grepping for "Task tool", "SendMessage", "worktree",
".claude/", "Claude Code", and "CLAUDE_PROJECT_DIR" across this directory —
not a line-by-line read of each file, so treat this as a starting point for
review, not a verified translation.)

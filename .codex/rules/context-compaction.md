## Context Compaction

**When conversation context reaches ~150k tokens, compact it — preserving any active plan.**

- Watch context usage as the conversation grows. Once it approaches ~150k tokens, run `/compact` with
  the `<keep plans>` argument (e.g. `/compact <keep plans>`), the same way the finalization-plan session
  did, rather than letting it run further toward the hard limit.
- "Keep plans" means: any approved plan (plan-mode output, `.claude/plans/*.md` content, workstream/PR
  breakdowns) must survive compaction verbatim — full scope, decisions, and structure, not a shortened
  paraphrase. Task state (which PRs are open, which agents are mid-flight, dependency order) should also
  be preserved since it's what lets work resume without re-deriving context.
- Do not wait for the automatic hard-limit compaction to kick in if a plan is active — compacting early
  and deliberately, with an explicit instruction to keep plans, produces a better summary than the
  default reactive compaction.

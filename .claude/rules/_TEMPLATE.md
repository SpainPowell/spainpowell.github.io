---
paths:
  - "<glob the rule applies to, e.g. src/api/**/*.ts>"
---

## <Imperative title stating the rule itself — not a topic label>

**<One-sentence bolded restatement of the rule. This is the line that gets remembered.>**

**Why:** <The concrete failure this prevents. Name the real incident if there
was one: what happened, what it cost, what made it non-obvious. A rule
derived from something that actually broke is followed better and pruned
more honestly than a rule derived from principle.>

**How to apply:**
- <Specific, checkable step — could two competent engineers agree it was followed?>
- <Specific, checkable step>
- <The exception, if there is one, stated explicitly so the agent doesn't invent its own>
- <How this composes with related rules, and which wins on conflict, if relevant>

---
Delete the frontmatter block above if this rule is genuinely universal (rare —
most "always" content belongs in AGENTS.md instead, not a rule file; see
HARNESS.md §5). Keep the whole file under ~100 lines — longer means it's a
skill, not a rule. One rule per file; name the file after the behavior it
prevents, not the topic (`branch-before-changes.md`, not `git.md`).

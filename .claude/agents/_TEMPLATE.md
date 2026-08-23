---
name: <kebab-case-name>
description: >
  <What it is> + <the trigger phrase, in the user's own words> + <the
  concrete artifacts it touches>. Example: "Profiles hot paths and proposes
  optimizations grounded in measurement. Use when a benchmark or profile
  shows a regression."
tools: <minimum tool list — read-only for anything that reviews or audits>
model: <omit to inherit, or name a specific model for a cheap/read-heavy scan>
---

You <one-sentence identity tied to the job, not a persona>. <State plainly
what you do NOT do — e.g. "You do not modify files.">

## Method

1. <First concrete step>
2. <Second step>
3. <How you verify your own claim before reporting it>

## Return contract

Your final message IS the deliverable — the parent sees nothing else.

- <Shape: a fixed section list or schema>
- <Budget: an explicit cap, e.g. "at most 10 findings" / "≤1,500 tokens">
- <Evidence: commands run and what they returned, not assertions>
- <Filtering: what NOT to return — e.g. "don't list files you found clean">
- Prefix anything you could not verify with `UNVERIFIED:`.
- End with a machine-checkable terminal token, e.g. `RESULT: OK` or `RESULT: FINDINGS <n>`.

---
Before keeping this agent: is it a context firewall (isolates noisy
intermediate output) or a tool cage (restricted tools = a real safety
property)? If its only value proposition is "it knows about X" and the base
model already knows X, delete it instead — HARNESS.md §7, "persona subagents
sit inert." Roster cap: 10-15 total, mutually exclusive descriptions.

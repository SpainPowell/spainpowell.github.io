---
name: co-storm
description: >
  Runs Stanford's Co-STORM method: parallel perspective-driven research
  discourse that converges on a cited, hierarchically-organized report. Use
  when the user asks for a comprehensive or thorough writeup, a
  multi-perspective / 360-degree / all-angles analysis, a landscape or
  state-of-the-art survey, "research this and write it up," or when a
  decision needs several independently-sourced perspectives synthesized
  before a recommendation. This is also the harness's own method for
  auditing itself — see manifests/2026-08-18-harness-optimization.yaml.
---

# Co-STORM discourse

Adapts Stanford OVAL's Co-STORM (Jiang et al., 2024) — multi-perspective
simulated discourse plus a moderator that steers into ungrounded gaps, plus
a growing mind map that keeps a long investigation organized — onto this
harness's existing orchestration primitives (HARNESS.md §7: fan-out,
evaluator-optimizer, barrier). Nothing here is a new mechanism; it's those
patterns run in a specific sequence for a specific job. Full background and
the one deliberate simplification (round-based fan-out replacing Co-STORM's
learned turn-policy manager) are in `references/algorithm.md` — read it once
if you're extending this skill, not on every run.

## When to Apply

- The user wants a thorough or comprehensive treatment of a topic, not a
  quick answer.
- The task needs several genuinely distinct angles (technical, legal,
  competitive, historical, security, UX...) synthesized, not one lens.
- A recommendation or decision doc needs independently-sourced perspectives
  before the synthesis, so the write-up isn't just one line of reasoning
  dressed up as several.
- Not for: a question with one clear answer, a task finishable in a
  handful of tool calls, or anything where the "perspectives" would just be
  paraphrases of each other — see step 1's mutual-exclusivity check.

## Workflow

### 1. Warm start — discover perspectives

Do a quick research pass (repo read, web search, whatever the topic needs)
to identify **3–6 perspectives** that are genuinely non-overlapping — state
the boundary between each pair in one clause, the same test HARNESS.md §7
applies to subagent descriptions. If you can't state the boundary, merge
the perspectives.

Create the mind map file at `.storm/<topic-slug>/mindmap.md` (format:
`references/mindmap-format.md`) with one empty top-level header per
perspective, plus an `## Unexplored threads` section.

### 2. Discourse round — fan out

One `perspective-researcher` subagent per perspective, run in parallel
(HARNESS.md §7 fan-out pattern). Each task prompt must carry, verbatim:

- The topic and this perspective's exact wording.
- The **current mind map file contents** (or the sections relevant to its
  perspective) — so it doesn't re-report what's already there.
- The return contract from `agents/perspective-researcher.md` (or the
  Codex TOML equivalent): claims + sources, capped, `UNVERIFIED:` prefix
  for anything unsourced, terminal token.

Round 1 perspectives are the ones from step 1. Later rounds use the
moderator's questions from step 4 instead — each question becomes one
subagent's assigned angle.

### 3. Update the mind map

Merge each subagent's claims into the mind map: file each under an
existing header if it fits, or create a new header (grow-and-refine, not a
flat append). Drop exact duplicates. Leave `UNVERIFIED:` claims in place
but tagged — the moderator step below decides whether to chase them.

### 4. Moderator step — inline, not delegated

Read the full mind map yourself (this is a "how does the whole thing look"
judgment, not noisy intermediate work — it doesn't earn a subagent per
HARNESS.md §7 "when not to delegate"). Identify:

- Gaps: headers with one claim, or claims that contradict each other.
- Retrieved-but-unused threads: anything a subagent flagged `UNVERIFIED:`
  or mentioned in passing without pursuing.

Turn those into **1–3 grounded next-round questions** (Co-STORM's actual
mechanism: ground the moderator's questions in real retrieved gaps, never
in a generic "tell me more"). File them under `## Unexplored threads`.

**If working attended,** show the user the moderator's proposed questions
before spawning round 2 and let them redirect or add their own — this is
Co-STORM's human-co-steering piece, and it's cheap to offer. **If
unattended,** proceed with the moderator's own questions.

### 5. Loop until dry

Repeat steps 2–4. Stop when either is true:

- A round adds **zero new top-level headers or genuinely new claims** to
  the mind map (dry).
- **3 rounds** have run (default cap — say so if you stop here, and say
  the topic warrants more if it clearly does; never cap silently).

### 6. Synthesize

Convert the mind map's header hierarchy directly into the report outline —
don't re-derive structure from scratch, the mind map already did that
work. Write the report section by section. Every factual sentence gets a
trailing citation in the exact form `(source: <source string copied
verbatim from the mind map>)`.

### 7. Validate

```
python scripts/check_citations.py <report.md> .storm/<topic-slug>/mindmap.md
```

Exit 0 = every citation resolves to a real mind-map source. Exit 1 lists
the unmatched citation and its line — fix by correcting the citation text
or pulling the claim (it isn't grounded), then re-run. **Do not deliver the
report until this passes.**

## References

| Topic | File |
|-------|------|
| Full method background, the turn-policy simplification, precedent in this harness | `references/algorithm.md` |
| Mind map file format and the round-log convention | `references/mindmap-format.md` |

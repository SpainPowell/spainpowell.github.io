# Co-STORM — background and the adaptation made here

## Table of contents
- [Source](#source)
- [The four mechanisms](#the-four-mechanisms)
- [What this skill keeps, and the one simplification](#what-this-skill-keeps-and-the-one-simplification)
- [Precedent in this harness](#precedent-in-this-harness)

## Source

Jiang et al., Stanford OVAL — *"Into the Unknown Unknowns: Engaged Human
Learning through Language Model-Driven Guided Discovery"* (2024), the
Co-STORM ("Collaborative STORM") system. Builds on the earlier STORM
paper's outline-then-write article generation. Read the paper if you're
changing this skill's mechanism, not to run it.

## The four mechanisms

Co-STORM's contribution over plain multi-agent research is specifically
these four pieces working together — losing any one degrades it to
"several agents answered the same question independently":

1. **Multi-perspective simulated discourse.** Distinct expert personas,
   discovered from the topic itself (not fixed in advance), each research
   and contribute from their own angle.
2. **A moderator grounded in unused retrieval.** The moderator doesn't ask
   generic follow-ups — it asks questions built from information the
   discourse retrieved but didn't use. This is what pushes the discourse
   into genuinely new territory ("unknown unknowns") instead of circling
   the same ground.
3. **A turn-policy manager.** In the original system, a learned policy
   decides which expert (or the moderator, or the human) speaks next each
   turn, based on relevance and information gain.
4. **A dynamically growing mind map.** Claims get filed into a hierarchical
   concept tree as they arrive, not a flat transcript — this is what keeps
   a long discourse navigable and is also what the final report's outline
   comes from directly.

## What this skill keeps, and the one simplification

Mechanisms 1, 2, and 4 transfer directly onto this harness's existing
primitives and are implemented as written in `SKILL.md`: perspective
discovery → mind map → moderator step grounded in the mind map's own gaps.

Mechanism 3 (the turn-policy manager) is replaced with **round-based
fan-out**: every perspective/question active in a round runs in parallel,
rather than one expert speaking at a time by learned policy. This is a
deliberate simplification, not an oversight — a coding harness's subagents
already run as isolated, stateless calls (HARNESS.md §7), so there is no
natural place to plug in a turn-by-turn conversational policy the way
Co-STORM's live discourse loop has one. Round-based fan-out gets the same
outcome (breadth first, moderator narrows next) at lower orchestration
cost, and it's the same trade the harness's own §7 fan-out pattern already
makes for other investigations. If a future harness gains a cheap way to
run genuinely sequential, context-sharing subagent turns, revisit this.

## Precedent in this harness

This is not a new method being introduced speculatively. The 2026-08-18
harness optimization round used exactly this shape ad hoc — "Four
independent perspective reviewers (subagent roster, rules layer, skills
layer, structure & permissions) each posed the audit questions implied by
HARNESS.md's own doctrine and answered them from the files; findings were
then synthesized, conflicts resolved, and changes applied" — see
`manifests/2026-08-18-harness-optimization.yaml` and
`manifests/2026-08-18-optimization-report.md`. This skill exists so that
shape is repeatable and documented instead of reinvented per use.

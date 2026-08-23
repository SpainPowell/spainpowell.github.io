---
created: 2026-08-22
modified: 2026-08-23
type: template
tags:
  - harness/operations
aliases:
  - Harness Self-Optimization Runbook
status: evergreen
---

## Purpose

Use this runbook before allowing an agent system to propose or evaluate changes to its own harness. It extends [[HARNESS#11. EVALS — proving a harness change helped|the harness evaluation doctrine]]: optimization is an experiment, not permission to rewrite the controls.

## Fixed and mutable boundaries

- **Optimization objective and held-out evaluation set:**
- **Explicitly mutable files/regions:** Use narrow named files or marked blocks only.
- **Immutable controls:** Permissions, secrets handling, sandbox/isolation configuration, protected-path rules, evaluation integrity, and budget caps.
- **Change owner and approval boundary:**

## Candidate protocol

- Mine traces for repeated, evidence-backed failure patterns.
- Harvest human feedback from review comments, Slack replies/reactions, rejected outputs, and manual corrections into batches; do not let the executor rewrite itself from single-run feedback.
- Classify each failure before proposing changes: missing context, missing capability, missing verifier, insufficient model capability, or insufficient effort.
- Propose the smallest candidate diff with a change manifest and predicted improvement.
- Run the candidate and baseline on the held-out tasks under matching conditions.
- Review benchmark health before trusting the score: contamination risk, flawed tests, underspecified tasks, saturation, and whether the eval still predicts real-world success.
- Have an evaluator outside the optimizer score outcome evidence; it must not modify candidates or the evaluation set.
- Merge only a candidate that meets the written decision rule. Record rejected candidates and their evidence.

## Reflection to eval loop

- Convert repeated manual run reviews into structured eval cases before changing broad instructions.
- If the candidate is a guidance change, ask whether the same lesson belongs in a test, hook, skill, path rule, permission, or deterministic script instead.
- If a new tool is proposed, require a test scenario proving the tool improves the agent's outcome before granting broader access.
- Keep learned bug classes out of the hot path until reviewed; self-improvement proposes diffs, humans approve control changes.

## Safety checks

- [ ] No candidate can edit an immutable control.
- [ ] The evaluator and held-out tasks are independent of the optimizer.
- [ ] The candidate has a rollback target and an attributable manifest.
- [ ] Cost, wall-clock, regressions, and benchmark saturation are reported with the score.
- [ ] Public/training-data contamination risk, flawed tests, and underspecified tasks have been reviewed for the eval set.
- [ ] The candidate does not solve a context/tool/verifier failure by merely raising model or effort.
- [ ] A human approves any expansion of the mutable scope.

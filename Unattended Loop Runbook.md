---
created: 2026-08-22
modified: 2026-08-23
type: template
tags:
  - harness/operations
aliases:
  - Loop Runbook
status: evergreen
---

## Purpose

Use this runbook before enabling an agent task to run without a human present. It operationalizes [[HARNESS#9. HOOKS & GATES — the enforcement layer|the harness gate]], [[HARNESS#10. PERMISSIONS & ISOLATION — the blast-radius layer|unattended isolation]], and [[HARNESS#12. OBSERVABILITY & DRIFT|per-run observability]]. A loop is not ready until every required field is specific and testable.

## Identity

- **Loop name:**
- **Owner:**
- **Home artifact:** Ticket, PR, board item, alert, document, or queue where humans can see context, status, and handoff.
- **Repository and branch/worktree policy:**
- **Task it performs:**
- **Why it recurs:** Include evidence of the actual cadence; do not schedule a hypothetical task.

## Trigger and scope

- **Trigger:** Event, cron schedule, or manual command.
- **Start condition:**
- **Scheduler boundary:** The scheduler only triggers a versioned procedure; it must not embed hidden state-dependent decisions. The procedure records every skip, action, and outcome to persistent state.
- **Allowed paths and systems:**
- **Explicit exclusions:**
- **Idempotency / duplicate-run behavior:**

## Work contract

- **Named skill or procedure:** Keep the operational steps in a maintained skill, not an inline scheduled prompt.
- **Capability provenance:** Skills, plugins, MCP servers, tools, and models used by the loop, with owner, version, permissions, network reach, and update path.
- **Handoff type:** Check, stop condition, trigger, or full recurring workstream. Use the smallest loop primitive that fits.
- **Unknowns preflight:** Blind spots, architecture-changing questions, references, and "good outcome" rubric are recorded before implementation begins.
- **Implementation notes path:** Where deviations, edge cases, conservative decisions, and unresolved hypotheses are written during the run.
- **Inputs gathered deterministically:** Links, tickets, logs, prior state, and source files.
- **Threat-intel freshness:** For external reports, advisories, vulnerability posts, or threat feeds that may influence action, record source status, publication or last-seen date, freshness window, and corroborating source.
- **Permitted actions:**
- **Remediation authorization matrix:** For each autonomous action, name severity, confidence threshold, permitted command/API, max blast radius, notification timing, evidence retained, and rollback.
- **Human decision boundary:** What must be escalated rather than decided by the loop.
- **Public-world boundary:** Whether the loop may contact real people, public services, public repositories, external maintainers, or downstream agents; if allowed, name the channel, approval gate, and audit evidence.
- **Benign-closure boundary:** Whether the loop may mark something benign, must escalate inconclusive cases, or may only act on confirmed malicious findings.
- **Autonomy dial by lifecycle stage:** For triage, specification, implementation, review, verification, shipping, and monitoring, name whether the loop may act, may only propose, or must stop for human approval.
- **Promotion criteria:** What measured agreement, acceptance rate, cost, and failure profile must be observed before the loop moves from recommendation-only to autonomous action.
- **Hunt hypothesis:** What periodic hypothesis-driven review will look for even when no alert fired.

## Gate

- **Deterministic acceptance command:**
- **Verifier source:** Test/lint/typecheck, hook, verification skill, rubric grader, read-only reviewer, or human review. Prefer deterministic checks.
- **Expected pass signal:** Exit code and the exact evidence retained.
- **Sensor heartbeat and freshness:** Positive signal that each gate ran, maximum age before stale, owner, and fail-open or fail-closed behavior.
- **Muted-check policy:** Any filtered, allowlisted, delayed, or noisy check has an owner, reason, expiry, and replacement visibility.
- **Independent review:** Required / not required. If required, name the read-only reviewer and its fault-finding brief.
- **Security checks:** SAST, dependency audit, secret scan, or explicitly `N/A` with reason.

The producing agent never certifies its own output alone. Prefer a deterministic check whenever one can decide the question.

## State and recovery

- **State file path:** Version-controlled, human-readable, and outside the conversation.
- **State schema:** Verified facts (never re-guess), material decisions with rationale and rejected alternatives, general rules (confirmed reusable lessons), open failures (with evidence and clearly marked hypotheses), blocked/escalated items, and a timestamped last-session/next-action resume pointer.
- **Resume rule:**
- **Failure recovery:** State whether to retry, roll back, or escalate; never silently continue after an unknown partial failure.

## Stop conditions and limits

- **Success stop condition:** A measurable condition, not “looks complete.”
- **No-work stop condition:**
- **Per-run turn/token cap:**
- **Per-run wall-clock cap:**
- **Retry cap and backoff:**
- **Exhausted-item policy:** On exhausting the retry cap, record the item as `blocked` with failure evidence and escalation destination, then continue only with independent permitted items.
- **Circuit breaker:** Exact repeated-action threshold that halts the run (for example, the same tool and arguments three times).
- **Daily spend / run cap:**
- **Kill switch:** Exact command, configuration flag, or schedule disablement.

## Isolation and permissions

- **Execution environment:** Full-process sandbox, container, or VM. A shell-only sandbox is insufficient for unattended work.
- **Network allowlist:**
- **Agent identity:** Single-purpose account or runtime identity; no shared human credentials.
- **Identity telemetry:** Login source, credential/token use, privilege changes, conditional-access or MFA exceptions, and cross-environment pivots monitored for this identity.
- **Agent activity profile:** Expected processes, commands, parent/child process shapes, network destinations, file paths, working hours, and normal output artifacts.
- **Independent recovery path:** Separate identity, vendor plane, or human-controlled channel that can detect, disable, and roll back the loop if the primary control plane is compromised.
- **Responder path:** Tested break-glass or bypass procedure for cases where a sandbox, deny rule, hosted-model refusal, or safety guardrail blocks investigation or remediation.
- **Credential paths denied:**
- **Write permissions:**
- **Agent-to-agent boundary:** Which agents this loop may contact, over which auditable channel, and what permissions cannot be delegated.
- **Untrusted-input quarantine:** Which agents may read untrusted/public/adversarial content, and which higher-privilege agents are barred from receiving executable instructions from them.
- **Memory/contextual-integrity boundary:** Which memories, prior tickets, logs, user attributes, secrets, and cross-project notes may be used for this task; name prohibited disclosures and tool-call recipients.
- **Signal trust labels:** How alerts, blocked events, issue comments, external reports, and generated findings are labeled by source, confidence, and whether they could be adversary-planted.
- **Historical-source boundary:** Whether old news, stale feeds, or archived reports may only inform patterns/drills, or may influence action after fresh corroboration.
- **Detection tuning rule:** Expected agent behavior may lower severity only with retained evidence, owner, expiry, and compensating signal; it must not become a blanket allowlist.
- **Protected paths / destructive operations denied:**
- **Parallelism:** Read-only work may share a checkout; every writer gets an isolated worktree.

## Escalation and review

- **Escalation destination:**
- **Escalate when:** Ambiguous requirements, failed gate, security finding, cap reached, or an excluded/protected area is needed.
- **Heartbeat and alert:** Record the expected cadence and the owner alert sent when a run stalls or misses its heartbeat.
- **Human review cadence:** Review accepted changes and a sample of the state log at least weekly.
- **Rollback owner and method:**

## Evidence and health metric

- **Per-run record:** Task ID, harness revision, model/effort, permission mode, gate evidence, token and wall-clock use, tool-call count, errors, hook blocks, and state-file update.
- **Audit trail:** Automated approvals, reviewer signals, tool calls, identity used, agent-to-agent messages, and denied actions.
- **Sensor health:** Heartbeat/freshness evidence for each gate, plus every muted or filtered check with owner, reason, expiry, and replacement signal.
- **Runtime drift:** Evidence that live processes, generated files, artifacts, containers, permissions, or cloud resources still match the expected build/run manifest.
- **Hunt evidence:** Hypothesis tested, telemetry reviewed, gaps found, detector/rule changes proposed, and whether exploitability was proved or ruled out.
- **Case bundle:** Related alerts, tool calls, identity events, file writes, network destinations, gate results, remediation actions, notifications, and rollback evidence.
- **Patch-chain evidence:** Attack path or choke point, generated fix, regression result, bypass attempt, and post-fix exploitability confirmation.
- **Feedback harvest:** Where human corrections, Slack replies/reactions, review comments, or rejection reasons are collected for later prompt/config diffs.
- **Primary metric:** Cost per accepted change.
- **Guardrail metrics:** Acceptance rate, human-intervention rate, rejected-edit rate, and cap-hit rate.
- **Baseline and review date:** Run a baseline before broadening scope; remove or revise the loop if it does not improve the stated measure.

## Activation checklist

- [ ] The task demonstrably recurs and has an objective gate.
- [ ] Skills, plugins, MCP servers, tools, and models have recorded provenance and permissions.
- [ ] Agent-facing signals are labeled by source/trust before they can influence privileged actions.
- [ ] External threat reports have publication/last-seen dates, source status, freshness decision, and corroboration before they trigger action.
- [ ] Memory and cross-context data use has purpose labels, disclosure boundaries, and a test for inappropriate leakage.
- [ ] Security-sensitive tasks have loophole tests for indirect public contact, identity switching, artifact reuse, prompt injection, network bypass, and downstream-agent manipulation.
- [ ] Agent activity has a telemetry profile and detection-tuning rule.
- [ ] Autonomous remediation is limited by an explicit authorization matrix.
- [ ] Benign closure, inconclusive escalation, and confirmed-malicious action have separate authority levels.
- [ ] The loop has a state file, a success stop, a no-work stop, and explicit caps.
- [ ] Permissions and isolation are appropriate for unattended execution.
- [ ] Every required sensor has heartbeat/freshness evidence and documented fail-open or fail-closed behavior.
- [ ] Agent identity, cloud access, and independent recovery paths have been reviewed.
- [ ] Responder paths and hosted-model fallback procedures have been tested before production use.
- [ ] A failure cannot silently become a retrying spend loop.
- [ ] A failure class has a retry path: context/tool/skill/verifier fix, model escalation, effort escalation, or human escalation.
- [ ] Human escalation and a kill switch have been tested.
- [ ] A change manifest and evaluation plan exist before enabling the schedule.
- [ ] A bounded pilot has run on a representative slice; review its acceptance rate, cost, cap hits, and failure modes before broadening scope or frequency.
- [ ] Prompt/config/memory changes go through reviewed diffs; the running loop cannot silently rewrite itself.

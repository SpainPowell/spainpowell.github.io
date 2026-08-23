---
paths:
  - "**/*agent*/**"
  - "**/*automation*/**"
  - "**/*workflow*/**"
  - "**/*remediation*/**"
  - "**/*security*/**"
  - "**/*incident*/**"
  - ".claude/**"
  - ".codex/**"
  - ".agents/**"
---

## Define the production-agent operating envelope before granting autonomy

**Any unattended, agentic, remediation, or security-sensitive automation needs an owner, bounded authority, observable sensors, trusted inputs, and rollback before it acts.**

**Why:** Recent security-operations sources converged on the same failure mode: controls, agents, and detections can fail silently, be manipulated by hostile inputs, or look like attackers in telemetry. Runtime behavior must be bounded by evidence, not intention.

**How to apply:**
- Record owner, home artifact, kill switch, rollback path, promotion rule, and audit trail.
- Define sensor heartbeat/freshness, fail-open/fail-closed behavior, and what evidence proves each gate ran.
- Label agent-facing alerts, comments, external reports, and generated findings by source/trust before they can influence privileged actions.
- For external threat intelligence, record source status, publication or last-seen date, freshness window, and corroboration before it can trigger remediation.
- Test for loopholes around identity switching, public contact, artifact reuse, prompt injection, network bypass, and downstream-agent manipulation.
- Define memory/contextual-integrity boundaries: which prior facts, user attributes, logs, tickets, and secrets may be used or disclosed for this task.
- Document the agent activity profile: identity, expected processes, commands, network destinations, file paths, and normal output artifacts.
- Separate confirmed-malicious action, inconclusive escalation, and benign closure; do not let the same confidence threshold govern all three.
- For autonomous remediation, name severity, confidence threshold, permitted actions, max blast radius, notification timing, retained evidence, and rollback.
- Treat muted checks and detection tuning as visibility loss: require owner, reason, expiry, and replacement signal.
- Treat skills, plugins, MCP servers, tools, and models as supply-chain artifacts with provenance, version, permissions, and update path.

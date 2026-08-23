## Autonomously Close or Refine No-Decision PRs — Don't Surface Them

**When triaging PRs (especially Dependabot/dependency bumps), close or refine the ones whose right
answer is objective, without asking. Only surface PRs that need a genuine human decision, plus a terse
summary of what you merged.**

**Why:** Asking "should I close this redundant/uninstallable/trap PR?" spends the user's attention on
choices with one correct answer. During a dependency-triage session the user said, verbatim, of the
avoid/redundant PRs: *"There is no reason for me to see those."* Closing objectively-not-mergeable PRs
is housekeeping, not a decision — treat it that way. See `pr-review-workflow.md` (the merge/review pass
this builds on) and `legal-*`/`simplicity` rules for what still warrants a human.

**How to apply:**
- **Close autonomously** (always leave a one-line explanatory comment on the PR for the record):
  - **Redundant** — superseded by another open/merged PR (e.g. a lone package bump a coordinated
    migration PR already covers; a version another PR already lands).
  - **Structurally blocked / uninstallable** — violates a pinned platform constraint (Python floor,
    Expo SDK ↔ react-native/expo-* version lock, an eslint/tooling peer cap) and can't merge as-is; its
    CI is red at install/lint for that reason.
  - **Traps / regressions** — installable but would degrade the codebase: re-introduces a constraint you
    deliberately removed, downgrades a transitive, reverts a fix, or re-caps a dependency the rest of the
    stack needs (e.g. a lib version that pins `numpy<2` when the app wants numpy 2.x).
  - **Obsolete** — the change was already made another way.
- **Prefer an `ignore` rule over repeated closes.** When a whole *class* of these keeps recurring, add a
  Dependabot `ignore` (or the equivalent config) so it stops reopening — scope it precisely (the right
  `update-types`/`versions`, remembering `react-native`/`expo` use `0.x` or SDK-locked versioning so the
  "breaking" bump is often a semver-*minor*). Note that editing `dependabot.yml` triggers a re-scan that
  auto-closes newly-ignored open PRs, so you often don't need to close them by hand.
- **Refine autonomously** — if a PR has the right intent but wrong shape (Dependabot proposes an
  impossible version but a bounded one is valid), fix the config so the correct version is proposed, or
  land the correct version yourself, and close the wrong-shaped one.
- **Still bring to the user** (don't auto-close, don't blind-merge):
  - Anything with real tradeoffs or that needs a decision — major bumps needing evaluation, changes to
    product behavior, security/compliance-sensitive changes, or anything you can't verify is safe.
  - A bump that is legitimate but requires a **separate cleanup effort** to adopt (e.g. a linter version
    that surfaces many pre-existing violations) — close it as *deferred* with that reason, and mention it
    once as available future work; don't hide it as if it were junk, and don't blind-merge over a red gate.
  - A **terse** summary of what you actually merged — the residue that needs them, not per-PR play-by-play.
- **Report by exception.** Fold autonomous closes into one line ("closed N redundant/blocked bumps: …").
  The user wants what needs them and what changed, not the noise you already handled.

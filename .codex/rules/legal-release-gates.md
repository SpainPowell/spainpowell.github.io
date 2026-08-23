## Legal Release Gates — What Must Be True Before Any App Store Submission

**`docs/release-checklist.md` is the canonical pre-submission checklist; this rule is the standing instruction to
actually run its legal items and keep it in sync with the compliance docs.**

**Why:** The July 2026 compliance research identified hard submission blockers that no automated check catches
(App Review enforces them; CI cannot). They live in `docs/compliance/legal-compliance-report.md` with the
work items in `docs/compliance/remediation-backlog.md`. A submission attempted before the P0 backlog items land
will be rejected; a submission whose disclosures drift from code behavior risks post-approval removal.

**How to apply — before any submission (first or update), verify:**
- Privacy policy URL is live, linked in-app (Settings) and in App Store Connect, and its text still matches
  actual data flows (FTC §5 accuracy — report §2.2).
- In-app account deletion exists and works end-to-end on device (Apple 5.1.1(v)).
- App Privacy nutrition label matches the mapping table in `docs/release-checklist.md` / report §1.3, including
  AdMob under "Data Used to Track You".
- `ITSAppUsesNonExemptEncryption: false` is present in `app.config.ts` `ios.infoPlist`.
- ATT prompt copy/timing verified on device per the checklist; reward flow works with tracking denied.
- Third-party data posture is resolved per report §4: PFR advanced stats removed and the residual draft-picks
  usage a knowingly-accepted risk (decided 2026-08-02, §4.1 — not an open blocker); Sleeper written confirmation
  (incl. headshots) or avatar fallback; nflverse/CFBD attribution present.
- If the release introduces subscriptions: every Phase-2 gate in `legal-ads-monetization.md` is met.

**Keeping docs in sync:**
- When a PR changes data collection, ads, auth, or data sources, update `docs/release-checklist.md` and the
  relevant section of `docs/compliance/legal-compliance-report.md` in that same PR — the checklist points at real
  files/behaviors and rots fast if changes bypass it.
- When a remediation-backlog item lands, check it off in `docs/compliance/remediation-backlog.md` in the same PR.
- The report was researched July 2026 (US-only scope). Re-verify platform-guideline citations if more than ~6
  months old at submission time, and re-open the GDPR question before any international launch.

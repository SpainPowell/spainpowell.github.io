## Any New User-Data Collection Must Update the Privacy Disclosures That Legally Bind Us

**FTC Act §5 applies to this app today, with no size threshold: if the privacy policy or App Store nutrition
label says less than the code actually collects, that mismatch alone is an actionable deceptive practice.**

**Why:** The July 2026 compliance research (`docs/compliance/legal-compliance-report.md` §2.2) confirmed that
while every threshold-gated privacy statute (CCPA, state laws) is currently out of scope for this pre-launch app,
privacy-disclosure *accuracy* is enforceable now — the FTC has pursued small apps and SDK-disclosure mismatches
(e.g., InMarket). Apple independently rejects or removes apps whose App Privacy label doesn't match observed SDK
behavior. The disclosures are only accurate as long as every data-flow change keeps them in sync.

**How to apply:**
- Before merging any change that collects, stores, or transmits a **new** category of user data (a new Supabase
  column/table holding user input, a new SDK that phones home, a new identifier sent to the backend), update in
  the same PR: (1) the privacy policy text, (2) the nutrition-label mapping in `docs/release-checklist.md`, and
  (3) `docs/compliance/legal-compliance-report.md` §5 (the PII inventory used for breach scoping).
- New Supabase tables holding user data get owner-scoped RLS (`auth.uid()` pattern per `0001_phase1.sql`) and
  must be added to the account-deletion cascade (see `legal-account-lifecycle.md`).
- PII never goes to AsyncStorage or persisted production logs. The bar is the existing code:
  `mobile/src/services/supabase.ts` (tokens → SecureStore only) and `mobile/src/services/logging.ts` (prod log
  persistence disabled because auth errors can contain emails). Don't regress either.
- Never add an analytics/crash-reporting SDK casually — there are deliberately none today; adding one changes the
  nutrition label, the privacy policy, and possibly the "tracking" declaration, and needs all three updated first.
- Do not collect birthdates or age signals — that creates a COPPA "actual knowledge" data path the app is
  currently (correctly) positioned to avoid (report §2.4).

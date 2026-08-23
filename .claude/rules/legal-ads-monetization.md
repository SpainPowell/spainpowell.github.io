## Ads and Subscription Changes Have Hard Platform-Policy Invariants — Don't Regress Them

**The consent ordering, the "reward works even if tracking is denied" property, and (Phase 2) the paywall
disclosure set are compliance requirements, not implementation details.**

**Why:** Apple 5.1.2 forbids conditioning functionality or rewards on granting ATT; AdMob's rewarded-ad policy
requires pre-ad disclosure of the reward and affirmative opt-in; ROSCA and California's ARL (amended July 2025)
put subscription disclosure/consent-evidence/renewal-reminder duties on the app, not on Apple. Details and
citations: `docs/compliance/legal-compliance-report.md` §1.5–1.8, §3.3. The current implementation is compliant
by construction — the risk is a future refactor silently breaking an invariant no test asserts.

**How to apply:**
- Preserve the flow in `mobile/src/services/rewardUnlocks.ts` `ensureAdsConsent()`: ATT prompt → UMP
  `gatherConsent()` → manual `MobileAds().initialize()`, lazily before the first ad (never at app launch), with
  `delayAppMeasurementInit: true` in `app.config.ts`. No AdMob call may fire before this runs.
- Never gate a reward or unlock on the ATT authorization *result*. A user who denies tracking must still be able
  to watch the ad and receive the unlock (non-personalized ads). Today the code doesn't inspect the ATT result —
  keep it that way.
- Every `RewardedGate` must state the specific reward ("5 calculator credits", "unlock this position") in the
  locked-panel copy *before* the ad plays. Rewards stay non-monetary and in-app-only.
- Once set (backlog P1), don't remove `tagForChildDirectedTreatment: false` / `maxAdContentRating` from the
  AdMob request configuration; the UMP US-states message config lives in the AdMob console — note console-side
  changes in the PR when ad behavior changes.
- **Phase 2 (RevenueCat) merge gate** — a subscription PR is not mergeable without: paywall showing
  title/length/price + auto-renewal language *before* the purchase sheet; a functional Restore Purchases button;
  Privacy Policy + Terms of Use links on the paywall; a Manage Subscription deep-link; a logged
  disclosure+purchase consent record per transaction; and the privacy policy updated for payment-data flows.
  The annual renewal reminder (CA ARL) must be scheduled work, not forgotten.
- Keep App Store metadata free of "win money"/"cash prizes" phrasing, and never ship any fee + contest + prize
  combination without fresh legal review — that single combination triggers multi-state fantasy-operator law
  (report §3.1).

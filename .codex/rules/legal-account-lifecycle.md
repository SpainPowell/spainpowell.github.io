## Auth-Surface Changes Must Keep the Full Account Lifecycle Legally Intact

**Apple requires in-app account deletion (5.1.1(v)) — sign-out is explicitly insufficient — and deletion must
actually erase the user's data everywhere, or the privacy policy's deletion promise becomes a §5 misstatement.**

**Why:** The app supports account creation (email + Sign in with Apple), so Apple's account-deletion guideline
applies and is one of the most consistently enforced rejection reasons. Deletion must remove the Supabase
`auth.users` row (service-role only — the client anon key cannot do it), relying on the `ON DELETE CASCADE`
wiring in `supabase/migrations/0001_phase1.sql` to wipe `profiles`/`leagues`/`watchlist_items`/`user_settings`/
`entitlements`. See `docs/compliance/legal-compliance-report.md` §1.2 and the P0 backlog item.

**How to apply:**
- Until the account-deletion flow exists (backlog P0), treat it as a prerequisite for any App Store submission —
  do not submit without it.
- Once built: any new Supabase table keyed to a user MUST (a) get owner-scoped RLS and (b) either cascade from
  `auth.users` or be explicitly handled in the deletion path. A table that survives deletion is a compliance bug,
  not a data bug.
- Account deletion must also clear device state: the AsyncStorage keys in `mobile/src/services/storage.ts` and
  the SecureStore session chunks (`mobile/src/services/supabase.ts`). Signed-out-but-lingering local data
  contradicts a "your data is deleted" claim.
- Deletion is full deletion, not a `disabled` flag; identity re-verification friction is allowed, redirecting to
  a website/support ticket is not.
- Build/keep the deletion endpoint server-side and platform-agnostic — Google Play will additionally require a
  **web-accessible** deletion URL when an Android build ships; don't design it in-app-only.
- Keep email verification and (once added, backlog P1) password reset working through any auth refactor — a user
  locked out with no self-serve recovery escalates into data-rights complaints.
- Adding any third-party social login (Google/Facebook) triggers Apple Guideline 4.8 — Sign in with Apple must
  remain offered alongside it.

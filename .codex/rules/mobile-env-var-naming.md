---
paths:
  - "**/.env*"
  - "**/app.config.*"
  - "**/eas.json"
---

## Mobile Env Vars Must Be `EXPO_PUBLIC_`-Prefixed to Ever Reach the Client

**A `mobile/.env` variable without the `EXPO_PUBLIC_` prefix is never inlined into the JS bundle — `process.env.X`
reads back `undefined` in every build (dev client, simulator, TestFlight, App Store), not just locally.**

**Why:** `mobile/.env` sets `ADVANCED_STATS_API_KEY` (no prefix), and `backendConfig.ts`'s `getApiKey()` reads it
via `process.env.ADVANCED_STATS_API_KEY`. Expo's default Metro/Babel config only auto-inlines vars prefixed
`EXPO_PUBLIC_` — everything else is stripped, so this line always evaluates to `undefined`, regardless of
environment. This was misdiagnosed at first as a local-only quirk ("this machine happens to have `API_KEY` set
when it should be unset for local dev"), which is true but is not the root cause: even with a correctly-configured
backend, the mobile app has no way to ever send this header, in any environment, today. Confirmed by grepping the
Metro-served bundle directly (`node_modules/expo/AppEntry.bundle`) for the literal key value — only the unresolved
variable name appeared, never the value — across both a raw `xcodebuild` build and a normal `expo start` session.

**How to apply:**
- Before adding any new `mobile/.env` variable that a screen/service needs to read at runtime via
  `process.env.<VAR_NAME>`, prefix it `EXPO_PUBLIC_<VAR_NAME>` (e.g. `ADVANCED_STATS_API_KEY` would become
  `EXPO_PUBLIC_ADVANCED_STATS_API_KEY`; see `EXPO_PUBLIC_SUPABASE_URL`/`EXPO_PUBLIC_SUPABASE_ANON_KEY` in
  `mobile/.env` for the working pattern) — or don't reach for `process.env` in a screen/service at all if the
  value must stay secret, since `EXPO_PUBLIC_*` vars ship in cleartext inside the client bundle and are trivially
  extractable from any built app. An API key that must stay secret cannot be safely read from the client this way
  regardless of prefix — it needs a different flow (e.g. server-issued session token from a user identity the
  backend already trusts, not a shared static key baked into the client).
- If a `process.env.X` reference isn't behaving as expected on-device, first grep the actual Metro/production
  bundle for the literal value (not just the variable name) before assuming a native-build or backend-config
  problem — this is the fastest way to distinguish "not inlined" from "inlined but backend rejects it" from
  "genuinely a backend bug."
- `backend/.env`'s `API_KEY` is documented as "unset = open, for local dev" — this remains correct guidance for
  local dev, but does not by itself explain 401s if the *client* can never send the key in the first place; check
  both ends.

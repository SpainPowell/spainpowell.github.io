---
paths:
  - "**/eas.json"
  - "**/app.config.*"
---

## Always Run `eas submit`/`eas build` With `EXPO_DEBUG=1` When Diagnosing a Failure

**A bare `eas submit`/`eas build` failure surfaces a useless generic message — "eas-cli failed to resolve
submission config. Add EXPO_DEBUG: \"1\" to the job env to see the error." — instead of the real underlying
error. Don't spend time re-running the same command hoping for a better message; set the env var first.**

**Why:** During TestFlight submission work (2026-08-05), a submission repeatedly failed at the
`prepare_asc_api_key` step with only that generic message. Several re-runs and a real code fix (a genuinely
missing `ascAppId` in `eas.json`, landed in PR #316) did not change the error text at all, which looked like the
fix hadn't taken effect. Only after setting `EXPO_DEBUG=1` as an EAS project environment variable and submitting
again did the actual error appear: `Error: Run this command inside a project directory` plus a Node engine
mismatch on the remote worker (`required: >=20.0.0`, `current: v18.18.0`) — a problem in EAS's own remote
submission worker environment, unrelated to anything in this repo. Without debug mode, that distinction (our
config vs. EAS's infra) was impossible to tell from the error message alone.

**How to apply:**
- Before investigating any `eas submit` or `eas build` failure beyond a first attempt, set `EXPO_DEBUG=1` as a
  plaintext EAS environment variable for the relevant environment: `eas env:create --environment <env> --name
  EXPO_DEBUG --value 1 --visibility plaintext --non-interactive` (from `mobile/`). This applies to new
  build/submit jobs going forward, not retroactively to already-scheduled or already-queued ones — a fresh
  invocation is required after setting it.
- Don't treat the generic "failed to resolve submission config" message as diagnostic on its own — it fires for
  many unrelated underlying causes (missing `ascAppId`, credentials issues, or infra-side problems like the Node
  version mismatch above). Get the real stack trace before proposing a fix.
- Remove it once done: `eas env:delete <env> --variable-name EXPO_DEBUG --non-interactive`. EAS env vars are
  persistent per-environment settings injected into every subsequent remote build/submit job, not a one-shot
  flag scoped to a single invocation — there's no way to set it "just for this run" of a cloud build. Verbose
  debug output can include request/response detail that shouldn't sit indefinitely in a shared project's
  environment config, so treat it as a temporary diagnostic tool: turn it on, get the real error, turn it off.

## During a Confirmed GitHub Actions Billing Outage, Verify Locally and Admin-Merge — Don't Just Wait

> **Sunset clause:** this rule exists only while GitHub Actions billing outages recur. When CI runs reliably again, delete this rule.

**Once a GitHub Actions billing/payment block is confirmed (not just suspected), run the exact same checks
`.github/workflows/ci.yml` runs, locally, in the PR's own worktree; document the results; then
`gh pr merge <number> --admin --merge`. This is a standing authorization for the duration of the outage, not a
per-PR question.**

**Why:** During the UI-overhaul session, `test-mobile`/`test-backend` began failing instantly (2-3s, no steps
run) on every PR and on direct pushes to `main` starting ~2026-07-24 21:46 UTC. `gh run view <id>` showed the
job-level annotation "The job was not started because recent GitHub Actions payments have failed or your
spending limit needs to be increased" — confirmed account-wide (reproduced on `main` itself, not just one PR),
not a code problem. Nearly 24 hours later it was still unresolved. The user was explicitly asked how to handle
this and chose local-verification-plus-admin-merge over standing up a self-hosted runner (uncertain to actually
bypass an account-level payment suspension) or continuing to block all work on their resolving billing.

**How to apply:**
- **Confirm the outage first, every time** — don't assume it's still the same outage from earlier in the
  session. Check `gh run view <id>` for the job-level annotation on the PR's own latest run, and cross-check
  against `main`'s own latest run (`gh run list --branch main --limit 1`) to confirm it's account-wide, not
  PR-specific. Per `git-verify-ancestry-before-rewind-claim.md`'s spirit: prove the infra state, don't guess it.
  If checks are dispatching and failing for a *different* reason (an actual code/test failure), this rule does
  not apply — fix the real regression instead.
- **Run the exact commands `ci.yml` runs**, in the PR's own worktree/branch, not just "the tests pass generally":
  - Mobile (`test-mobile` job): `cd mobile && npm ci && npm run lint && npx tsc --noEmit && npx vitest run --reporter dot`
  - Backend (`test-backend` job, only if the PR touches `backend/`): `cd backend && pip install -r requirements.txt
    && black --check . && flake8 . && mypy . && python -m unittest discover -s tests` (skip if the PR touches
    zero backend files — there's nothing for that job to meaningfully check either way).
- **Document the substitution** in a PR comment (or the PR body) before merging: which commands were run, that
  they passed, the exact outage evidence (the `gh run view` annotation + the `main`-is-also-broken cross-check),
  and the timestamp. This preserves the same audit trail a real CI run would have left.
- **Then merge**: `gh pr merge <number> --admin --merge`. This is the same admin-merge mechanism already used for
  legitimate BEHIND-branch-protection races (see `pr-review-workflow.md`) — always call out explicitly in the
  final summary that this was an admin-merge and why, exactly as that existing pattern requires.
- This authorization covers the **merge gate** (required status checks) only. It does not relax the **review
  gate** — the internal agent review panel (`pr-review-workflow.md`) is still required before merging.
- The moment a PR's checks dispatch and run normally again (a real run appears, not an instant billing-annotated
  failure), this rule stops applying — go back to waiting on/trusting real CI, don't keep admin-merging out of
  habit once the outage is actually resolved.

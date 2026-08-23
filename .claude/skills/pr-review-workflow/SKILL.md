---
name: pr-review-workflow
description: >
  Step-by-step workflow for reviewing and responding to pull-request feedback:
  triaging review comments, deciding what to adopt, replying, and re-requesting
  review. Use when handling PR review comments, addressing reviewer feedback,
  or when the user mentions a PR review, review comments, or re-review.
---

## PR Review Workflow

**Every PR gets a real review pass before merge — no exceptions. Reviews are performed internally by our own
agent panel; we do NOT request Copilot reviews. GitHub CI checks are still used as a merge gate whenever they're
available.**

When an agent (or the orchestrator) opens a PR:

1. **Run the internal agent review panel** (see below) against the PR's current diff. This *is* the review pass —
   there is no Copilot request/poll step. Don't request `copilot-pull-request-reviewer[bot]`.
2. **Check CI if it's available**: `gh pr view <number> --json statusCheckRollup`. Required checks
   (`test-mobile` + `test-backend`) must pass before merge. Two documented exceptions still apply:
   - During a **confirmed** GitHub Actions billing/outage, verify the same checks locally and admin-merge per
     `ci-billing-outage-local-verification.md` (prove the outage first; don't assume it).
   - If required checks **won't dispatch at all** (no run created for the head SHA), follow
     `pr-checks-not-dispatching.md` — surface it to the user; don't bypass required checks unilaterally.
3. **Evaluate every finding the panel raises** on its merits — do not apply suggestions blindly:
   - **Valid** → fix it and push a new commit to the same branch (never open a second PR for the same work).
   - **Invalid / false positive** → verify concretely (re-run the actual check the finding claims will fail),
     then record why on the PR (in the synthesized review comment thread) and leave the code as-is.
4. Do the same for any failing CI check: fix real regressions; for pre-existing/out-of-scope debt the PR didn't
   cause, say so explicitly in the PR body rather than silently leaving it unexplained.
5. Re-verify (tests/lint/typecheck) after any fix commit. If the PR touches a screen, navigation, or any other
   visual component, this step also means following `simulator-verification.md` — automated checks alone don't
   verify a screen actually renders correctly.
6. **If new commits land after the review pass, the new diff needs its own pass** — re-run the panel on the
   updated diff before merging.

### The agent review panel

Launch a small panel via the `Agent` tool, run in parallel (one message, multiple tool calls) since each is an
independent lens on the same diff:

- **`code-reviewer`** — always include. The baseline pass: quality, security, performance, maintainability,
  correctness bugs.
- **`chaos-engineer`** — always include as a second, adversarial lens: what breaks this under a bad network,
  a killed process, a race between two calls, a malformed/partial response from an upstream (Sleeper/CFBD/
  Supabase), or a concurrent-agent collision on shared state. Frame its brief around *this* PR's actual failure
  surface, not generic infra chaos-testing — e.g. "what happens if the Supabase write in this PR fails halfway"
  rather than asking it to design a Kubernetes game day.
- **Additional agents, picked by what the PR actually touches** (not exhaustive — use judgment):
  - `security-auditor` — auth, secrets, RLS policies, anything touching `supabase/migrations/`, API keys, or
    the ad/consent flow (`rewardUnlocks.ts`, `legal-ads-monetization.md`).
  - `accessibility-expert` — new/changed screens, navigation, or any other visual component.
  - `performance-engineer` — data-heavy screens, list rendering, anything the redesign specs call out as
    perf-sensitive (long lists, per-row async fetches, chart rendering).
  - `mobile-developer` or `react-native-expert` — native-module wiring, platform-specific code, build config
    (`app.config.ts`, `babel.config.js`, Podfile-adjacent changes).
  - `python-expert` — backend/Flask changes when the PR touches `backend/`.

Give each agent the actual PR diff/number and the same context a human reviewer would want (what changed, why,
what's out of scope) — don't just say "review PR #N." Brief them concretely: the file paths touched, the change's
intent, and what to focus on, the same way you'd brief any subagent per the Agent tool's own guidance.

Synthesize the agents' findings into a single PR comment (`gh pr comment <number> --body "..."`) attributing which
agent raised what, so there's a durable, visible review record on the PR — then run the exact same step-3
evaluation (valid → fix; invalid → verify and explain) before merging.

**Once one full review pass is complete** (the agent panel has run on the PR's current diff and every finding and
CI failure has been addressed or explained, per steps 3-4) **the PR may be merged without asking the user first**:
`gh pr merge <number> --merge --delete-branch` (repo default: merge commit, not squash). **Always pass
`--delete-branch`** so the merged head branch is removed on both the remote and (if present) the local checkout —
merged branches are dead weight that clutter `git branch -r`, slow `fetch`, and make it harder to see what's
actually in flight. The repo also has `delete_branch_on_merge` enabled as a safety net, but pass the flag
explicitly regardless (it's a no-op if the setting already handled it, and it also prunes your local branch, which
the repo setting does not). Do **not** `--delete-branch` a branch that is checked out in another agent's active
`git worktree` (see `concurrent-agent-workdir.md`) — leave those alone even after merge. Skip
`gh pr review <number> --approve` — GitHub rejects self-approval ("Can not approve your own pull request") since
these PRs are authored under the same account; go straight to merge.

**Only pass `--delete-branch` on a merge you have confirmed will actually succeed — never on a not-yet-mergeable
PR, and never as a retry loop.** Verify mergeability *first*
(`gh pr view <n> --json mergeStateStatus,mergeable` — two separate fields) and only run
`gh pr merge --merge --delete-branch` once the `mergeable` field is `MERGEABLE` **and** the `mergeStateStatus`
field is `CLEAN` (or `UNSTABLE`, for a non-required check still running) — not while `mergeStateStatus` is
`UNKNOWN` (GitHub still computing — wait and re-poll), `BEHIND` (update/rebase the branch first), or `BLOCKED`. **Why:** repeatedly
firing `gh pr merge --merge --delete-branch` at a PR that keeps rejecting the merge as "not mergeable" / "out of
date" still deletes the head branch as a side effect — and for a **Dependabot** PR, a deleted head ref makes
Dependabot immediately auto-close the PR (it then recreates a fresh one on its next run). This happened to a
verified-safe jsdom bump: the branch was destroyed mid-merge and the PR auto-closed, forcing the change to be
re-landed by hand. When a PR is `BEHIND`, bring it up to date first (`gh pr update-branch <n>`, or for a Dependabot
PR comment `@dependabot rebase`), wait for CI to go green on the new head, and only *then* merge with
`--delete-branch`. If you must retry a merge, drop `--delete-branch` from the retry and delete the branch
separately after the merge is confirmed.

Periodically the accumulated backlog of already-merged branches can be swept in bulk: after
`git fetch --prune origin`, `git branch -r --merged origin/main` lists every remote branch whose tip is an
ancestor of `main` (its work is fully in `main`, so deleting the ref loses nothing —
`git-verify-ancestry-before-rewind-claim.md`). Build the delete list from that output, **stripping the `origin/`
prefix** and **excluding** `main`, the `origin/HEAD -> origin/main` symbolic ref (any line containing `->`), any
long-lived branch, and any branch currently checked out in a worktree (`git worktree list`) — e.g.:

```bash
git fetch --prune origin
git branch -r --merged origin/main \
  | sed 's/^[* ]*//' | grep '^origin/' | grep -v '\->' \
  | grep -vx 'origin/main' | grep -vx 'origin/<long-lived-or-worktree-branch>' \
  | sed 's#^origin/##' \
  | xargs -r git push origin --delete
```

Then prune the matching local branches with `git branch -d <branch>` (`-d`, never `-D`, so git refuses anything
not actually merged; it also refuses a branch checked out in a worktree — a built-in safety net).

Respect dependency order between stacked/related PRs (e.g. a schema PR before the client PR that reads it) — merge
prerequisites first, and note the required order in the PR body when a PR depends on another still-open one.

This is a standing authorization: it replaces asking for merge approval on a per-PR basis, as long as the review
pass above actually happened. It does not authorize skipping the review pass, merging over an unexplained red CI
check, or merging unrelated/out-of-scope changes bundled into a PR without calling them out first.

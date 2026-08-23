## Verify the Actual Push Target Before Pushing

**Never guess a branch name from context — read it off the PR/remote first.**

**Why:** This mistake happened twice this session. Once, `git push origin feat/w3-reward-gates`
failed because the actual branch was `feat/w3-rewarded-gates` (guessed from the PR title
instead of checked). Later, when pushing a Copilot-review fix commit for PR #86, a local
fix branch (`pr-86-fix`) was pushed with `git push origin pr-86-fix:feat/w2-cloud-sync-watchlist-settings`
— inventing a *new* remote branch name instead of the PR's actual head ref
(`feat/w2-sync-service`), which silently created a second, unrelated branch on GitHub
that had to be found and deleted as cleanup.

**How to apply:** before pushing a fix commit to an existing PR, get the real branch name
first — `gh pr view <n> --json headRefName` or `git branch --show-current` — and push
explicitly to that exact ref (`git push origin <local>:<real-head-ref>`). Do not push to
a name assembled from the PR title or your own recollection of what you branched it as.
After pushing, it's cheap to confirm with `gh pr view <n> --json headRefName,commits` that
the commit landed on the PR you intended, and to clean up immediately if a stray branch
was created by mistake.

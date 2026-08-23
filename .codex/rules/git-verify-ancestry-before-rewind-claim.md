## Verify Branch Ancestry Before Declaring a Rewind or Lost Work — a Misleading HEAD Message Is Not Evidence

**A shared branch's HEAD commit *message* and a default (date-ordered) `git log` are not evidence of what the
branch contains. Prove work is actually missing with `git merge-base --is-ancestor` before ever telling the user a
branch was rewound — and never "recover" by force-push/reset until you have.**

**Why:** In one session, moments after merging PR #168, `main`'s HEAD (via
`gh api repos/<owner>/<repo>/commits/main`) was a merge commit whose message read *"Merge pull request #119"* — an
old, low-numbered dependabot PR — and `git log --oneline -5 origin/main` surfaced only a dependabot lineage with
none of the just-merged work at the top. This looked exactly like `main` had been force-pushed backward to an old
commit, dropping five merged PRs (#164/#165/#166/#168 and another agent's #167), and an alarm was raised to the
user. **It had not happened.** GitHub's "update branch" had merged current `main` *into* each stale dependabot PR
branch before merging it back, so #123 and #119 were merged **last** and their merge commits sit **on top of** the
recent work. The definitive check settled it instantly: `git merge-base --is-ancestor dad51c1 origin/main` **exited
0** — the command prints nothing; its *exit status* is the whole signal — and `git log --first-parent origin/main`
showed the true sequence
`#119 → #123 → #167 → #168 → #166 → #165 → #164 → …`. Nothing was lost. Had a "recovery" force-push
(`git push --force origin dad51c1:main`) been run on that false alarm, it would have **destroyed** the
legitimately-merged #167 (another agent's work) and two dependabot PRs — manufacturing the exact data-loss the
action was meant to fix.

**How to apply:**
- Treat an old PR number or an unexpected message at a branch's HEAD as **normal**, not alarming. A stale PR that
  was updated-and-merged most recently lands its merge commit on top of everything, carrying its own (old-numbered)
  title. A date-ordered `git log -N` can likewise surface a just-merged old lineage *above* your recent commits.
  Neither is evidence of a rewind.
- Before claiming a shared branch was rewound or work was lost, run the **ancestry proof** (after `git fetch` so
  refs are current): `git merge-base --is-ancestor <suspected-lost-sha> <branch>`. It prints nothing and signals
  purely through its **exit status** — `0` means the commit **is** in the branch's history (nothing lost), `1` means
  it is not; inspect `$?` or chain it (`git merge-base --is-ancestor <sha> <branch> && echo present || echo MISSING`)
  rather than looking for output. Cross-check with `git log --first-parent <branch> --oneline` (the real merge
  sequence, not date order) and `gh pr view <n> --json state,mergeCommit` (a still-`MERGED` PR whose merge commit is
  an ancestor of the branch is fine — GitHub keeps the "merged" flag even if the branch were later rewritten, so it
  is not proof either way; the ancestry check is).
- **Never** force-push or reset a shared branch to "recover" from a *suspected* rewind until the ancestry check
  proves commits are genuinely absent. On a false alarm the recovery **is** the destructive act — it discards
  everything merged after your last-known tip (including other agents' work). See also `push-target-verification.md`
  and `git-restore-scope-safety.md`.
- Do not raise a data-loss alarm to the user before running the ancestry check — investigate to certainty first,
  then report. If ancestry genuinely fails, the objects almost always still exist
  (`git fsck --no-reflogs --unreachable --full`, `gh api repos/<o>/<r>/commits/<sha>`); coordinate recovery with the
  user rather than unilaterally force-pushing, especially while another process/agent may still be pushing to the
  branch.

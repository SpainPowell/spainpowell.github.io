# Harness Optimization Report — 2026-08-18

Method: STORM / CO-STORM. Four independent perspective reviewers (subagent roster, rules layer, skills layer, structure & permissions) each posed the audit questions implied by HARNESS.md's own doctrine and answered them from the files; findings were then synthesized, conflicts resolved, and changes applied. OBSIDIAN_VAULT_RULES.md was applied config-first: vault obligations honored at the boundary (change log written, no links broken — verified none exist into Harness/, `.obsidian/` untouched), no Obsidian frontmatter forced onto runtime config.

Nothing was destroyed. Everything removed lives in `Harness/_to_delete/` (including originals of every rewritten agent in `_to_delete/agents-originals/`). Review it and delete when comfortable.

---

## 1. Agents: 41 → 7

The roster was the classic anti-pattern HARNESS.md names: an installed collection of persona agents ("Senior X Expert") with zero return contracts anywhere and 8 description-collision clusters (6-way on security, 6-way on documentation, 5-way on planning...). Per the doctrine — subagents are context firewalls or tool cages, cap at 10–15, delete personas — the roster is now:

| Agent | Why it earned its slot |
|---|---|
| code-reviewer | Tool cage: read-only diff reviewer |
| debugger | Firewall: isolates noisy failure output; returns diagnosis only |
| security-auditor | Absorbs cryptography-expert, penetration-tester, devsecops, zero-trust |
| legal-compliance-expert | Real trigger: your legal-* rules; app-store/privacy review |
| performance-engineer | Measurement-grounded; refuses to speculate without a number |
| github-workflow | Carries git conventions; `jd/` placeholder fixed; tools restricted |
| project-docs-curator | Doc-sync firewall; absorbs claude-md-expert; another repo's specifics stripped |

All seven rewritten to the doctrine template: router-rule descriptions (what + trigger + artifacts), restricted tools, short prompts (≤32 lines each except github-workflow), and full return contracts (shape, budget, evidence, filtering, `RESULT:` terminal token, `UNVERIFIED:` channel).

Moved to `_to_delete/agents/`: 34 personas (python-expert, react-expert, cloud-architect, chaos-engineer, the four documenters, the five planners, the data quartet, etc.).

## 2. Rules: 28 → 21, correctly layered

- **Vercel packs repatriated.** `rules/composition-patterns/` (7 files) and `rules/react-best-practices/` (72 files) were borrowed reference libraries sitting in the rules layer while their same-named skills indexed files that didn't exist next to them. Both directories now live inside their skills (`skills/<name>/rules/`); composition-pattern files renamed to match the index. **All 69 + 7 index references now resolve — verified programmatically.**
- **Always-on content promoted.** `think`, `simplicity`, `surgical`, `goal-driven` were universal principles masquerading as conditional rules. Distilled into a "Working style" section of the new `AGENTS.md`; files moved to `_to_delete/rules/`.
- **Path scoping introduced** (previously used by zero rules): `eas-submit-debug-mode`, `mobile-env-var-naming`, `ci-native-build-alignment`, `simulator-verification`, `refactor-extraction-checklist` now carry `paths:` frontmatter so they load only when relevant files are touched.
- **Merges/renames:** `fresh-branch-by-default` absorbed into `worktree-first` (which already declared precedence); `agent-tool-usage.md` → `resume-agents-via-sendmessage.md` (name the behavior, not the topic); `pr-review-workflow` (110 lines — over the rule cap, and a procedure) converted to a skill; `ci-billing-outage-local-verification` given an explicit sunset clause.
- **Kept as-is:** the earned git rules (`git-restore-scope-safety`, `git-verify-ancestry-before-rewind-claim`, `push-target-verification`, `concurrent-agent-workdir`, `worktree-first`), `pr-triage-autonomy`, and all five legal rules (left unscoped deliberately — correctness beats token savings for legal invariants).

## 3. Skills: 14 → 13, collisions resolved

Six descriptions previously matched "make the UI look better." The design cluster now has mutually exclusive boundaries:

- **design** — creating a *visual asset* (logo, icon, banner, slides, social image); explicitly "not for writing app UI code." Dead routing to ui-styling removed; a note flags the claudekit phantom-skill references (`ai-artist`, `chrome-devtools`, …) with fallbacks.
- **brand** / **design-system** — fire only on explicit brand-guideline / design-token requests, or when routed from design.
- **frontend-design** — aesthetic direction for new screens.
- **ui-ux-pro-max** — *reviewing/auditing* existing UI. Body cut from 693 → 357 lines (over the 500-line cap); the rule dump and checklist moved to `references/` per progressive disclosure.
- **Deleted** (→ `_to_delete/skills/`): `banner-design` (fully duplicated inside design, depended on four nonexistent skills) and `ui-styling` (shadcn/Tailwind/Next.js — a stack you don't use).
- Phantom cross-references to nonexistent skills (`graphql-schema`, `formik-patterns`, `storybook`) removed from react-ui-patterns and core-components; run-ios-simulator's dated conditional ("as of 2026-07-25") rephrased per doctrine.

## 4. Missing layers added

HARNESS.md's own bootstrapping order says these come *before* skills and agents; the harness had none of them:

- **`AGENTS.md`** — always-on template (Appendix A1 shape: Commands / Working style / Non-obvious constraints / Conventions / Boundaries), plus a one-line `CLAUDE.md` importing it (`@AGENTS.md`) for portability.
- **`settings.json`** — replaces `settings.local.json`, which contained `"Bash(*)"` (nullifying all 28 narrow allows and every safety property) plus accreted one-project residue (`routes.py`, `sleeper_proxy.py`, …) and stdin-python escapes. New file: deny (secrets, force-push, destructive git, the agent's own guardrail configs) → ask (push, rm -rf, publish, eas submit) → allow (read-only git, checks, test runners).
- **`hooks/README.md`** — the day-one hook set with wiring examples (branch guard backing `branch-before-changes`, lint-on-write, guardrail-edit block, secret scan) and the exit-code wiring rule.
- **`manifests/`** — change-manifest template; this optimization is logged as the first manifest.
- **`evals/`** — minimum-viable-eval scaffold with one example case.

## 5. Vault boundary

`_meta/Vault Change Log.md` created at the vault root with this session's entry. No wikilinks into Harness/ existed (verified by vault-wide grep), so no links broke. `.DS_Store` litter and the empty `worktrees/` dir moved into `_to_delete/`. `.obsidian/` untouched.

## Recommended next steps

1. **Fill in the AGENTS.md placeholders per project** — especially the verify command (§3 Step 0: "a harness without a working verify command is a wish").
2. **Wire the hooks** in one project and test each by deliberately breaking something.
3. **Run the first eval round** using your next few real corrections as cases, so the `verified:` field in `manifests/2026-08-18-harness-optimization.yaml` can be filled honestly.
4. **Empty `_to_delete/`** once you've confirmed nothing you miss lives there.
5. Known deferred items: `context-compaction.md` still lacks a "Why" incident; legal rules could be path-scoped once project layouts stabilize; `mobile-env-var-naming` and `refactor-extraction-checklist` are candidates for promotion to lint rules in the projects themselves.

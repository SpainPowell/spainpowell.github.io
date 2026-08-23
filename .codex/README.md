# CODEX — Codex CLI implementation

> [!note] Vault navigation
> [[Harness MOC]] is the harness dashboard. [[HARNESS]] explains the shared methodology, and [[Harness/CLAUDE/README|the Claude Code implementation]] is the native counterpart.

A best-effort translation of `../CLAUDE/` onto Codex CLI's mechanics,
researched 2026-08-21. Codex's hooks and subagents features are both
recent additions on their side — re-verify anything marked UNVERIFIED below
against your installed version before trusting it in a real project. Full
layer-by-layer reasoning: `../claude/harness-codex-portability-2026-08-21.md`
in the Harness Engineering project.

When a Codex workflow needs current OpenAI developer guidance, prefer the
official machine-readable surfaces before broad web capture: Developers RSS,
sitemap, `llms.txt`, and `.md` page variants. Record the model/API/runtime
surface a prompt or tooling rule came from so it can be revalidated when that
surface changes.

| This folder | Deploys to | What it is | Status |
|---|---|---|---|
| `agents/` | `.codex/agents/` | Subagents as TOML (`name`/`description`/`developer_instructions`/`sandbox_mode`) | Translated. `sandbox_mode` is a coarser cage than Claude Code's per-agent `tools:` allowlist — there's no "commands=yes, edits=no" tier, see the note in each file |
| `hooks/` | `.codex/hooks.json` + `.codex/hooks/scripts/` | PreToolUse/PostToolUse wiring; scripts are unchanged copies of `../CLAUDE/hooks/scripts/` | Best-effort JSON shape, UNVERIFIED. Codex's own hook coverage has gaps upstream — see `hooks/README.md` |
| `rules/` | `.codex/rules/`, loaded via `AGENTS.md`/`AGENTS.override.md` | Same content as `../CLAUDE/rules/` — Codex has no first-class "rules" primitive, so wiring one in is on you | Copied as-is; see `rules/PORTABILITY-NOTES.md` for which files assume Claude Code-only mechanics |
| `skills/` | **`.agents/skills/`, not `.codex/skills/`** | SKILL.md skills, identical to `../CLAUDE/skills/` | Directly portable — same open agent-skills standard both tools read |
| `config.toml` | `.codex/config.toml` | Permissions translation (`sandbox_mode` + `approval_policy` + network rules) | Best-effort. Codex has no per-command allow/deny/ask glob list like `settings.json` — path-level protection moved into the hooks layer instead, see comments in the file |
| `evals/` | wherever you keep evals project-side | `run-codex-eval.sh` drives `codex exec`, same multi-arm/multi-run methodology as Claude's | Translated. The with/without-context contrast is approximated (context prepended into the prompt) — no confirmed `--append-system-prompt` equivalent found |

Skills are the one deploy-path exception: Codex discovers skills from
`.agents/skills/` (repo-level, walking up to the repo root, or
`$HOME/.agents/skills` user-level) — not `.codex/skills/`.

`../HARNESS.md` (doctrine), `../AGENTS.md` (shared always-on instructions —
Codex reads this natively, no import needed) live one level up, same as for
`../CLAUDE/`.

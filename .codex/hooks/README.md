# Hooks — the enforcement layer (Codex CLI)

Translated from ../../CLAUDE/hooks/README.md. Same scripts, same intent
(instructions are advisory; hooks are deterministic — HARNESS.md §9) but
Codex's own hooks system, wired via `hooks.json` in this folder instead of
`settings.json`'s `hooks` key.

**This whole layer is UNVERIFIED as of 2026-08-21.** Codex's hooks feature is
recent, its documented field names come from third-party summaries (not a
raw schema this was tested against), and its own hook coverage is
incomplete upstream: an open issue (openai/codex#20204, filed 2026-04-29)
documents that only `shell`, `unified_exec`, `apply_patch`, and `mcp` tool
calls reliably fire hook events — everything else (`list_dir`, plan/goal
updates, multi-agent orchestration, web search) silently never fires.
The matchers below (`apply_patch`, `shell`) are in the working set, but
test each one per the "Testing a hook" section before trusting it — don't
assume this ports 1:1 just because the event names (PreToolUse/PostToolUse)
are the same as Claude Code's.

## What's wired

| Script | Event | Matcher / `if` | Effect |
|---|---|---|---|
| `scripts/protect-files.sh` | `PreToolUse` | `apply_patch` | Blocks (exit 2) edits to `.env*`, `.claude/settings*.json`/`.codex/config.toml`, `.claude/hooks/`/`.codex/hooks/`, `.github/workflows/`, `.git/`, `package-lock.json` — update the pattern list in the script if your project's protected paths differ from the Claude Code defaults it was written for |
| `scripts/branch-guard.sh` | `PreToolUse` | `shell`, `if: git commit *` | Blocks (exit 2) commits while `HEAD` is `main`/`master` |
| `scripts/secret-scan.sh` | `PreToolUse` | `shell`, `if: git commit *` | Blocks (exit 2) commits whose staged diff matches an AWS key, private-key header, or a `secret=`/`token=`-shaped assignment |
| `scripts/format-changed.sh` | `PostToolUse` | `apply_patch` | Silently runs `black`/`prettier` on the touched file if the project already has one configured |
| `scripts/lint-changed.sh` | `PostToolUse` | `apply_patch` | Runs `ruff`/`flake8`/`eslint` on the touched file; on failure prints `{"decision":"block","reason":"..."}` |
| `scripts/run-check.sh` | *(not a hook — invoke manually or from AGENTS.md's Commands section)* | — | The Step-0 verify command: auto-detects Node/Python, runs lint+typecheck+tests |

## The two decision mechanisms — check this against your version

Per the third-party documentation this was drafted from, Codex's
`PostToolUse` honors exit code 2 for blocking directly — unlike Claude
Code, where `PostToolUse` ignores exit 2 and requires a JSON
`{"decision":"block","reason":"..."}` on stdout instead (the exact gotcha
CLAUDE/hooks/README.md warns about). The scripts here already emit the JSON
form, which the same documentation says Codex also accepts — so they should
work either way, but this is exactly the kind of wiring detail that's worth
confirming with a real test run rather than trusting a summary.

## Requirements

`jq` must be on PATH. Formatters/linters are invoked only if already
present/configured in the project.

## Testing a hook (do this before trusting it — mandatory here, not optional)

Same tests as CLAUDE/hooks/README.md: deliberately break the thing each
script protects (edit `.env`, commit on `main`, stage a fake AWS key, write
a lint-broken file) and confirm Codex actually surfaces the block. If it
doesn't, the hook is decorative — check whether the tool call you're testing
is even in Codex's current hook-coverage working set before assuming the
script itself is broken.

## Adding a new hook

1. Pick the event from the taxonomy in ../../HARNESS.md §9 (event names are
   Claude Code's; confirm the Codex equivalent exists before assuming it
   ports).
2. Write the script under `scripts/`, `chmod +x` it, handle its own errors.
3. Wire it into `hooks.json`.
4. Test it per the section above.
5. Log it as a change manifest (`../../manifests/_template.yaml`).

# Hooks — the enforcement layer

Instructions are advisory; hooks are deterministic (HARNESS.md §9). This
folder's scripts are wired into `settings.json`'s `hooks` key and are copied
verbatim when this template becomes a project's `.claude/` — no assembly
required.

Schema grounding: [Claude Code hooks reference](https://code.claude.com/docs/en/hooks) and
[hooks guide](https://code.claude.com/docs/en/hooks-guide), current as of 2026-08-18. Field
names and event names change; re-verify against the docs before copying this
pattern to a new runtime.

## What's wired

| Script | Event | Matcher / `if` | Effect |
|---|---|---|---|
| `scripts/protect-files.sh` | `PreToolUse` | `Edit\|Write` | Blocks (exit 2) edits to `.env*`, `.claude/settings*.json`, `.claude/hooks/`, `.github/workflows/`, `.git/`, `package-lock.json` |
| `scripts/branch-guard.sh` | `PreToolUse` | `Bash`, `if: Bash(git commit *)` | Blocks (exit 2) commits while `HEAD` is `main`/`master` |
| `scripts/secret-scan.sh` | `PreToolUse` | `Bash`, `if: Bash(git commit *)` | Blocks (exit 2) commits whose staged diff matches an AWS key, private-key header, or a `secret=`/`token=`-shaped assignment |
| `scripts/format-changed.sh` | `PostToolUse` | `Edit\|Write` | Silently runs `black`/`prettier` on the touched file if the project already has one configured |
| `scripts/lint-changed.sh` | `PostToolUse` | `Edit\|Write` | Runs `ruff`/`flake8`/`eslint` on the touched file; on failure prints `{"decision":"block","reason":"..."}` so Claude sees the errors as feedback |
| `scripts/run-check.sh` | *(not a hook — invoke manually or from AGENTS.md's Commands section)* | — | The Step-0 verify command: auto-detects Node/Python, runs lint+typecheck+tests |

## The two decision mechanisms — don't confuse them

- **`PreToolUse` blocks with exit code 2** + a message on stderr. Claude Code
  passes that stderr text to Claude as the reason the call didn't happen.
- **`PostToolUse` cannot block with exit 2** — the exit code is ignored for
  this event. To surface a failure (e.g. a lint error) after the edit already
  happened, print JSON on stdout with a **top-level** `decision: "block"` and
  a `reason` string, and exit 0. `lint-changed.sh` does exactly this.

Getting this backwards is the single most common way a hook silently does
nothing (HARNESS.md §9, "the wiring rule everyone gets wrong").

## Requirements

`jq` must be on PATH (`brew install jq` / `apt-get install jq`). Formatters
and linters (`black`, `prettier`, `ruff`, `flake8`, `eslint`) are invoked only
if already present/configured in the project — nothing here installs a
dependency on your behalf.

## Testing a hook (do this before trusting it)

Deliberately break the thing the hook protects and confirm Claude mentions
the block:

- **protect-files.sh:** ask Claude to add a comment to `.env`. It should be
  blocked before the write happens, with the reason visible in the transcript.
- **branch-guard.sh:** on `main`, ask Claude to commit. It should refuse and
  name this rule.
- **secret-scan.sh:** stage a file containing `AKIAABCDEFGHIJKLMNOP` and ask
  Claude to commit. It should refuse.
- **lint-changed.sh:** ask Claude to write an obviously lint-broken file (in
  a project with ruff/eslint configured). The next model turn should mention
  the lint errors without you pasting them in yourself.

If any of these don't happen, the hook is decorative — check `/hooks` in
Claude Code to confirm it's registered, and check the debug log.

## Adding a new hook

1. Pick the event from the taxonomy in HARNESS.md §9.
2. Write the script under `scripts/`, `chmod +x` it, handle its own errors
   (a script that dies with a raw stack trace is worse than no script).
3. Wire it into `settings.json`'s `hooks` key.
4. Test it per the section above.
5. Log it as a change manifest (`../manifests/_template.yaml`).

# CLAUDE — Claude Code implementation

> [!note] Vault navigation
> [[Harness MOC]] is the harness dashboard. [[HARNESS]] explains the shared methodology, and [[Harness/CODEX/README|the Codex implementation]] is the translated counterpart.

Everything in this folder is Claude Code-native as written — no translation
needed. Copy it into a project as its `.claude/` directory.

When a Claude workflow needs current OpenAI developer guidance, prefer the
official machine-readable surfaces before broad web capture: Developers RSS,
sitemap, `llms.txt`, and `.md` page variants. Record the model/API/runtime
surface a prompt or tooling rule came from so it can be revalidated when that
surface changes.

| This folder | Deploys to | What it is |
|---|---|---|
| `agents/` | `.claude/agents/` | Subagents — Markdown + YAML frontmatter, `tools:` allowlist |
| `hooks/` | `.claude/hooks/` | PreToolUse/PostToolUse scripts + README on the exit-code wiring rule |
| `rules/` | `.claude/rules/` | Path-scoped and universal rule files, loaded via CLAUDE.md/AGENTS.md |
| `skills/` | `.claude/skills/` | SKILL.md skills — same content as `../CODEX/skills/`, duplicated here for a self-contained drop-in |
| `settings.json` | `.claude/settings.json` | Permissions (allow/deny/ask) plus the hooks wiring |
| `evals/` | wherever you keep evals project-side | `run-eval.sh` drives `claude -p`, multi-arm/multi-run |

The doctrine both `CLAUDE/` and `../CODEX/` implement lives one level up in
`../HARNESS.md`. The shared, tool-agnostic instructions layer is
`../AGENTS.md`; `../CLAUDE.md` is Claude Code's actual project-instructions
entry point and already does `@AGENTS.md` so it inherits that content.

See `../CODEX/README.md` for the Codex CLI counterpart and
`../claude/harness-codex-portability-2026-08-21.md` (Harness Engineering
project) for the full portability analysis this split was built from.

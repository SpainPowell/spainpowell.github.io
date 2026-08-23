#!/bin/bash
# protect-files.sh — PreToolUse(Edit|Write) — block edits to the harness's own
# guardrails and common secret/lockfile paths.
# Schema: exit 2 + message on stderr blocks a PreToolUse call (Claude Code
# hooks reference, "Exit Code 2" table). Claude receives the stderr text as
# feedback and can adjust its approach.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FILE_PATH="${FILE_PATH//\\//}"   # normalize Windows separators

# Keep this list in sync with the deny rules in settings.json — rule + gate,
# per HARNESS.md §14 ("Always/never written as prose" anti-pattern).
PROTECTED_PATTERNS=(
  ".env"
  ".claude/settings.json"
  ".claude/settings.local.json"
  ".claude/hooks/"
  ".github/workflows/"
  ".git/"
  "package-lock.json"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'. If this edit is intentional (e.g. a deliberate harness-maintenance session), ask the user to make the change directly or temporarily disable this hook." >&2
    exit 2
  fi
done

exit 0

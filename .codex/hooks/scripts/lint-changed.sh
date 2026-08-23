#!/bin/bash
# lint-changed.sh — PostToolUse(Edit|Write)
# Per Claude Code docs, PostToolUse can't block with exit 2 (it's ignored),
# but a top-level {"decision":"block","reason":"..."} on stdout (exit 0)
# surfaces the message back to the model. That's the mechanism this script
# uses to make lint failures visible without silently logging to a debug
# file nobody reads (HARNESS.md §9, "the wiring rule everyone gets wrong").

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

block() {
  local reason="$1"
  jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
  exit 0
}

case "$FILE_PATH" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      OUT=$(ruff check "$FILE_PATH" 2>&1)
      [ -n "$OUT" ] && block "Lint errors in $FILE_PATH:
$OUT

Fix these before continuing."
    elif command -v flake8 >/dev/null 2>&1; then
      OUT=$(flake8 "$FILE_PATH" 2>&1)
      [ -n "$OUT" ] && block "Lint errors in $FILE_PATH:
$OUT

Fix these before continuing."
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    if [ -f package.json ] && [ -f .eslintrc.js -o -f .eslintrc.json -o -f .eslintrc.cjs -o -f eslint.config.js ]; then
      OUT=$(npx --no-install eslint "$FILE_PATH" 2>&1)
      CODE=$?
      [ $CODE -ne 0 ] && block "ESLint errors in $FILE_PATH:
$OUT

Fix these before continuing."
    fi
    ;;
esac

exit 0

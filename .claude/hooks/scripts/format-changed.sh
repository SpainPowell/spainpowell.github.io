#!/bin/bash
# format-changed.sh — PostToolUse(Edit|Write)
# Silent on success (Claude Code docs' own Prettier example). No config
# present = no-op; never installs a formatter on the user's behalf.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

case "$FILE_PATH" in
  *.py)
    command -v black >/dev/null 2>&1 && black --quiet "$FILE_PATH" 2>/dev/null
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md)
    if [ -f package.json ] && { [ -f .prettierrc ] || [ -f .prettierrc.json ] || [ -f .prettierrc.js ] || grep -q '"prettier"' package.json 2>/dev/null; }; then
      npx --no-install prettier --write "$FILE_PATH" >/dev/null 2>&1
    fi
    ;;
esac

exit 0

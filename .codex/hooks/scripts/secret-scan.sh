#!/bin/bash
# secret-scan.sh — PreToolUse(Bash), wired with "if": "Bash(git commit *)"
# Blocking scan of staged changes for obvious secrets. Prevention, not
# detection (HARNESS.md §9 "What to hang where" — secret scanner belongs
# BEFORE write/commit).
#
# This is a cheap backstop, not a substitute for a real scanner (gitleaks,
# trufflehog) — swap in one of those if the project handles real credentials.

STAGED=$(git diff --cached -U0 2>/dev/null)
[ -z "$STAGED" ] && exit 0

# Only inspect added lines (start with a single '+', not '+++').
ADDED=$(echo "$STAGED" | grep -E '^\+[^+]' )

PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                          # AWS access key
  '-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'      # private key
  '(api[_-]?key|apikey|secret|password|token)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9/+_=-]{16,}'
)

HIT=""
for p in "${PATTERNS[@]}"; do
  match=$(echo "$ADDED" | grep -Eio "$p" | head -3)
  if [ -n "$match" ]; then
    HIT="yes"
    echo "Possible secret matching pattern: $p" >&2
  fi
done

if [ -n "$HIT" ]; then
  echo "" >&2
  echo "Blocked: staged changes look like they contain a credential. Remove it, rotate it if it was ever committed before, and use an env var or secret manager instead. If this is a false positive, ask the user to commit manually." >&2
  exit 2
fi

exit 0

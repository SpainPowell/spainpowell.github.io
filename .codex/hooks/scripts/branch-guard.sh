#!/bin/bash
# branch-guard.sh — PreToolUse(Bash), wired with "if": "Bash(git commit *)"
# Enforces rules/branch-before-changes.md and rules/worktree-first.md:
# never commit directly to main/master.

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "Blocked: HEAD is on '$branch'. Create a branch or worktree first — see rules/branch-before-changes.md and rules/worktree-first.md." >&2
  exit 2
fi

exit 0

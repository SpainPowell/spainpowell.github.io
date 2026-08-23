#!/bin/bash
# run-check.sh — the Step-0 "verify command" HARNESS.md requires before
# anything else in the harness is worth building ("a harness without a
# working verify command is not a harness; it's a wish", §3).
#
# Auto-detects the project type and runs format+lint+typecheck+fast-tests.
# Point AGENTS.md's Commands section at this script, or replace it with a
# project-native `make check` / `npm run check` once one exists.

set -uo pipefail
FAIL=0
section() { echo ""; echo "── $1 ──"; }

if [ -f package.json ]; then
  section "Node/TS project detected"
  if jq -e '.scripts.check' package.json >/dev/null 2>&1; then
    npm run check || FAIL=1
  else
    if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then
      npm run lint || FAIL=1
    fi
    if jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then
      npm run typecheck || FAIL=1
    elif [ -f tsconfig.json ] && command -v npx >/dev/null 2>&1; then
      npx tsc --noEmit || FAIL=1
    fi
    if jq -e '.scripts.test' package.json >/dev/null 2>&1; then
      npm test -- --watchAll=false 2>/dev/null || npm test || FAIL=1
    fi
  fi
fi

if [ -f requirements.txt ] || [ -f pyproject.toml ] || compgen -G "*.py" > /dev/null 2>&1; then
  section "Python project detected"
  if command -v ruff >/dev/null 2>&1; then
    ruff check . || FAIL=1
  elif command -v flake8 >/dev/null 2>&1; then
    flake8 . || FAIL=1
  fi
  if command -v mypy >/dev/null 2>&1; then
    mypy . || FAIL=1
  fi
  if command -v pytest >/dev/null 2>&1; then
    pytest -q || FAIL=1
  elif [ -d tests ]; then
    python3 -m unittest discover -s tests || FAIL=1
  fi
fi

section "Result"
if [ $FAIL -ne 0 ]; then
  echo "FAILED — fix the errors above before continuing."
  exit 1
else
  echo "All checks passed."
  exit 0
fi

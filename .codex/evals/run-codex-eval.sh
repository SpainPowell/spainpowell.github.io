#!/bin/bash
# run-codex-eval.sh — Codex CLI counterpart to ../../CLAUDE/evals/run-eval.sh.
# Same methodology (HARNESS.md §11): run each case's prompt through Codex
# headless mode, once per arm, N times per arm, save transcripts, and grade
# by hand against the case's written expectations. This does NOT auto-grade.
#
# Usage:
#   ./run-codex-eval.sh <case.json> [with-context-file]
#
# Requires: the `codex` CLI on PATH, `jq`.
#
# UNVERIFIED (2026-08-21): `codex exec`'s flag surface may have moved on
# since this was written — run `codex exec --help` before trusting it.
# In particular, there is no confirmed --append-system-prompt equivalent
# (the flags found: --model, --json, -o/--output-last-message, --ephemeral,
# -i/--image, --output-schema), so the "with_*" arm's context is prepended
# straight into the prompt text below rather than injected as a separate
# system-level layer. That's a rougher with/without contrast than the
# Claude Code version gets from --append-system-prompt — keep that in mind
# when grading, and swap in a cleaner mechanism if `--help` reveals one.

set -euo pipefail

CASE_FILE="${1:?Usage: run-codex-eval.sh <case.json> [with-context-file]}"
CONTEXT_FILE="${2:-}"

command -v codex >/dev/null 2>&1 || { echo "ERROR: 'codex' CLI not found on PATH." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: 'jq' not found on PATH." >&2; exit 1; }
[ -f "$CASE_FILE" ] || { echo "ERROR: case file not found: $CASE_FILE" >&2; exit 1; }

ID=$(jq -r '.id' "$CASE_FILE")
PROMPT=$(jq -r '.prompt' "$CASE_FILE")
RUNS=$(jq -r '.runs_per_arm // 3' "$CASE_FILE")
mapfile -t ARMS < <(jq -r '.arms[]' "$CASE_FILE")

OUTDIR="$(dirname "$CASE_FILE")/runs/$ID"
mkdir -p "$OUTDIR"

echo "Eval: $ID"
echo "Prompt: $PROMPT"
echo "Arms: ${ARMS[*]} | Runs per arm: $RUNS"
echo ""

for ARM in "${ARMS[@]}"; do
  for i in $(seq 1 "$RUNS"); do
    OUT="$OUTDIR/${ARM}-run${i}.txt"
    echo "-> $ARM run $i/$RUNS -> $OUT"
    if [[ "$ARM" == with_* ]] && [ -n "$CONTEXT_FILE" ] && [ -f "$CONTEXT_FILE" ]; then
      FULL_PROMPT="$(cat "$CONTEXT_FILE")

$PROMPT"
      codex exec "$FULL_PROMPT" > "$OUT" 2>&1 || echo "  (run exited non-zero — see $OUT)"
    else
      codex exec "$PROMPT" > "$OUT" 2>&1 || echo "  (run exited non-zero — see $OUT)"
    fi
  done
done

echo ""
echo "Done. Grade each transcript in $OUTDIR against these written expectations:"
jq -r '.expectations[] | "  - " + .' "$CASE_FILE"
echo ""
echo "Report mean pass/fail per arm — do not eyeball a single run (HARNESS.md §11: 'agents are non-deterministic; a single run tells you almost nothing')."

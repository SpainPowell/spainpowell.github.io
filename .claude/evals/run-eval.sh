#!/bin/bash
# run-eval.sh — minimum-viable eval runner (HARNESS.md §11).
# Runs an eval case's prompt through Claude Code headless mode, once per arm,
# N times per arm, and saves transcripts for grading against the case's
# written expectations. This does NOT auto-grade — HARNESS.md is explicit
# that behavior evals need human review of transcripts; this script only
# removes the toil of running and organizing the arms.
#
# Usage:
#   ./run-eval.sh <case.json> [with-context-file]
#
# <case.json> — one of the evals/*.json files (id, prompt, expectations,
#   arms, runs_per_arm).
# [with-context-file] — optional file whose contents are appended as
#   --append-system-prompt for the "with_*" arm, so the baseline arm runs
#   without it and the treatment arm runs with it. Omit to run the same
#   prompt in both arms as a smoke test.
#
# Requires: the `claude` CLI on PATH, `jq`.

set -euo pipefail

CASE_FILE="${1:?Usage: run-eval.sh <case.json> [with-context-file]}"
CONTEXT_FILE="${2:-}"

command -v claude >/dev/null 2>&1 || { echo "ERROR: 'claude' CLI not found on PATH." >&2; exit 1; }
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
      claude -p "$PROMPT" --append-system-prompt "$(cat "$CONTEXT_FILE")" > "$OUT" 2>&1 || echo "  (run exited non-zero — see $OUT)"
    else
      claude -p "$PROMPT" > "$OUT" 2>&1 || echo "  (run exited non-zero — see $OUT)"
    fi
  done
done

echo ""
echo "Done. Grade each transcript in $OUTDIR against these written expectations:"
jq -r '.expectations[] | "  - " + .' "$CASE_FILE"
echo ""
echo "Report mean pass/fail per arm — do not eyeball a single run (HARNESS.md §11: 'agents are non-deterministic; a single run tells you almost nothing')."

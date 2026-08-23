# Evals — proving a harness change helped

Minimum viable eval (HARNESS.md §11): 5–20 tasks from real failures, run each
with and without the new artifact (the baseline arm IS the experiment), ~3
runs per arm, grade against expectations written before looking at output.
Keep the artifact only if it wins. Cases live here as JSON; see
`example-eval.json`.

Before trusting a benchmark, record its health: contamination risk from public
or training data, flawed or overly narrow tests, underspecified prompts,
saturation, and whether score movement still predicts real-world task success.
Reasoning/monitorability signals are sensors; revalidate them when model,
effort, prompt, tools, or task distribution changes.

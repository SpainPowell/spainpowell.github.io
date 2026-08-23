# Change manifests

> [!note] Vault navigation
> [[Harness MOC]] is the harness dashboard. Use [[HARNESS#11. EVALS — proving a harness change helped|the evaluation guidance]] before marking a change verified.

Every harness edit (rule/skill/agent/hook added, changed, or deleted) ships
with a manifest — a falsifiable claim, not a rationalization (HARNESS.md §11).
Copy `_template.yaml`, name it `YYYY-MM-DD-<slug>.yaml`, fill it in, and check
the prediction at the next eval round. When the predicted improvement doesn't
materialize, revert that file.

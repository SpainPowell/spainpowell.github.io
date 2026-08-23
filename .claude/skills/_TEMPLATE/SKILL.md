---
name: <kebab-case-name, matches the folder name>
description: >
  <What it does, third person> + <"Use when..." trigger clause using the
  words a user would actually say>. Example: "Reviews database migration
  files for reversibility, lock duration, and backfill safety. Use when a
  migration file is added or changed, or when the user mentions migrations,
  schema changes, or ALTER TABLE."
---

# <Skill title>

<One or two sentences. Assume the model is already smart — don't explain
what the domain is, only what's specific to this procedure.>

## When to Apply

- <Trigger condition>
- <Trigger condition>

## Workflow

1. <Step, with the exact command if there is one>
2. <Step>
3. **Validate:** `<command>` — must pass before proceeding.
4. If validation fails: read the error, fix, re-validate.

## References

| Topic | File |
|-------|------|
| <topic> | `references/<file>.md` |

---
Delete this comment block before shipping the skill.
Checklist (HARNESS.md Appendix C "Reviewing a skill"):
- description says what AND when, in the user's own words
- body under ~500 lines; long content moved to references/ (one level deep only)
- one recommended approach, not a menu of options
- at least one validation/feedback loop
- no dated conditionals; consistent terminology throughout

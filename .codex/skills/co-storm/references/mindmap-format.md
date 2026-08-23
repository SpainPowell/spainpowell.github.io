# Mind map file format

## Location

`.storm/<topic-slug>/mindmap.md` in the working directory. `.storm/` is
scratch — add it to `.gitignore` unless the user wants the discourse trail
kept. Only the final report (step 6 of `SKILL.md`) is the deliverable.

## Structure

```markdown
# <Topic>

## <Perspective or concept — one per top-level header>

### <Subconcept, created as claims accumulate>

- <Claim> — source: <URL, file:line, or doc title>
- <Claim> — source: <URL, file:line, or doc title>

## Unexplored threads

- <Gap or contradiction the moderator flagged> — from: <perspective/round>
- <UNVERIFIED claim a subagent surfaced but didn't source> — from: <perspective/round>

## Round log

- Round 1 (<perspectives>): +<n> headers, +<n> claims
- Round 2 (<questions>): +<n> headers, +<n> claims
```

## Rules

- **Headers are the taxonomy, not the transcript.** File a claim under the
  concept it's about, not under which subagent said it. Two subagents
  contributing to the same header is expected and fine.
- **One claim per bullet**, ending in ` — source: <exact string>`. The
  citation checker (`scripts/check_citations.py`) matches this string
  verbatim against report citations — don't paraphrase it when copying
  into the report.
- **`## Unexplored threads` is the moderator's scratch space**, not
  dead weight — step 4 of `SKILL.md` reads it to write next-round
  questions, and a thread that gets resolved moves up into a real header
  and is deleted from here.
- **`## Round log` is what step 5's stopping condition checks.** A round
  entry with `+0 headers, +0 claims` (or only duplicate/already-covered
  claims) means that round was dry.

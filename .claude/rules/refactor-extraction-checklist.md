---
paths:
  - "**/*.tsx"
---

## Screen-Refactor Extraction Checklist

**Extracting JSX/logic into a new file must preserve the original's performance characteristics, not just its behavior.**

During the W4 screen refactors (PlayerDetail/Trades/Players/League/Team split into
`components/`+`utils.ts`), several extracted components dropped the `useMemo` wrapper
around `makeStyles(theme)` that sibling components in the same refactor kept — e.g.
`PlayersScreen/components/FilterBar.tsx`, `FilterMenus.tsx`, `FilterPills.tsx`,
`PlayerPeekSheet.tsx` and `TradesScreen/components/ProposalCard.tsx`,
`SuggestionsFilterBar.tsx`, `SuggestionsFilterMenus.tsx` all called
`const styles = makeStyles(theme)` directly instead of
`const styles = useMemo(() => makeStyles(theme), [theme])`. The bug was caught by a
PR 7.1 code-review sweep, not by tests — behavior was identical (same style values),
so no test failed; only performance regressed (a fresh `StyleSheet.create` on every
render of every extracted row/menu component).

**Why:** an extraction-only refactor's test suite only asserts logic/output equivalence.
It cannot catch "this now recomputes on every render" — that requires an explicit
memoization check.

**How to apply:** when extracting a component out of a screen (or reviewing a PR that
does), diff its hook usage against a sibling component extracted in the same PR (or
against the pre-refactor file). If the original wrapped a stylesheet, computed value,
or callback in `useMemo`/`useCallback`, the extracted version must too — don't let it
silently degrade to recomputing every render just because it's now "a component's own
line" instead of "a line inside the parent's already-memoized closure."

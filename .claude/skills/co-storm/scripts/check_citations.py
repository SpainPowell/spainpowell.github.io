#!/usr/bin/env python3
"""Validation gate for the co-storm skill (SKILL.md step 7).

Every factual sentence in the report must cite a source that actually
exists in the mind map, in the exact form:

    report.md:   ...claim text (source: <string>)
    mindmap.md:  - <claim> — source: <string>

The two <string> values must match verbatim — the skill tells the agent to
copy the mind map's source string, not paraphrase it, specifically so this
check can be a string comparison instead of a fuzzy one.

Usage:
    python check_citations.py <report.md> <mindmap.md>

Exit 0: every report citation resolves to a mind-map source. Prints the count.
Exit 1: at least one citation doesn't resolve. Prints each one with its
        report line number and the closest mind-map source (if any), so the
        fix is either correcting the citation text or removing the claim.
Exit 2: usage error (wrong arg count, file not found) — this is a script
        problem, not a validation failure; fix the invocation and rerun.
"""
import re
import sys
import difflib
from pathlib import Path

# Matches "(source: ...)" up to the closing paren. Mind map lines and report
# citations both use this exact marker so one regex covers both files.
CITATION_RE = re.compile(r"\(source:\s*([^()]+?)\)")
MINDMAP_SOURCE_RE = re.compile(r"—\s*source:\s*(.+?)\s*$")


def die(msg: str, code: int = 2) -> None:
    print(f"check_citations.py: {msg}", file=sys.stderr)
    sys.exit(code)


def load_mindmap_sources(mindmap_path: Path) -> set[str]:
    sources: set[str] = set()
    for line in mindmap_path.read_text(encoding="utf-8").splitlines():
        m = MINDMAP_SOURCE_RE.search(line)
        if m:
            sources.add(m.group(1).strip())
    return sources


def check_report_citations(report_path: Path, sources: set[str]):
    missing = []  # (line_no, cited_string, closest_match_or_None)
    total = 0
    for line_no, line in enumerate(
        report_path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        for m in CITATION_RE.finditer(line):
            total += 1
            cited = m.group(1).strip()
            if cited not in sources:
                closest = difflib.get_close_matches(cited, sources, n=1)
                missing.append((line_no, cited, closest[0] if closest else None))
    return total, missing


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        die(f"usage: {argv[0]} <report.md> <mindmap.md>")

    report_path = Path(argv[1])
    mindmap_path = Path(argv[2])
    if not report_path.is_file():
        die(f"report file not found: {report_path}")
    if not mindmap_path.is_file():
        die(f"mind map file not found: {mindmap_path}")

    sources = load_mindmap_sources(mindmap_path)
    if not sources:
        die(
            f"no ' — source: ...' lines found in {mindmap_path} — "
            "either the mind map is empty or step 3 of SKILL.md wasn't followed"
        )

    total, missing = check_report_citations(report_path, sources)

    if not missing:
        print(f"OK — {total} citation(s) in {report_path.name}, all resolve to {mindmap_path.name}")
        return 0

    print(
        f"FAIL — {len(missing)}/{total} citation(s) in {report_path.name} "
        f"do not match any source in {mindmap_path.name}:",
        file=sys.stderr,
    )
    for line_no, cited, closest in missing:
        suggestion = f" — closest mind-map source: \"{closest}\"" if closest else " — no close match; this claim may not be grounded at all"
        print(f"  {report_path.name}:{line_no}  cited \"{cited}\"{suggestion}", file=sys.stderr)
    print(
        "Fix: correct the citation text to match the mind map verbatim, or "
        "remove the claim if it isn't actually sourced there.",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))

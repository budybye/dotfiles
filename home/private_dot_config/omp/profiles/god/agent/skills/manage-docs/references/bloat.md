## Split, index, stop (catalog shape)

**MANDATORY — READ ENTIRE FILE when** the SKILL.md load-table row matches exactly (asked to split; one file unreadably long; docs exceed ~6 **and navigation fails**; adding `guidance.md`; same table in two files). Read from the top.
**Do NOT Load** for ordinary Bootstrap / Sync / Verify, source-of-truth, DESIGN/ROADMAP structure, catalog-split why, unless that parent row matches exactly. Size alone is not a trigger. This file is not a TOC.

Do not split on line count. Split only at a contract boundary that already has owner and source (architecture vs directory vs tech vs product). No matching row: do not split; report Unknowns. Interactive: one question. Non-interactive: blocked.

- Same table twice → link, do not copy.
- Rename / split onto catalog names → NEVER (ownership dies; the new name looks like Bootstrap coverage).
- `guidance.md` only if more than ~6 docs **and** navigation fails. An index "in case" is a second spec.
- **navigation fails** (same as SKILL.md Terms): after the documented reading order, the reader cannot name one owner, one source, and one entry for the topic, or two files still claim the same axis.
- Never `docs/README.md`.
- One unreadably long file: extract only overflow that matches a vacant contract row; leave the original as the remaining decision. If nothing matches, blocked (ask). Do not invent a file.

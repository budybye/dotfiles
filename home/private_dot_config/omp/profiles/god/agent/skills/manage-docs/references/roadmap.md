## ROADMAP.md structure (axes, not a required TOC)

**MANDATORY — READ ENTIRE FILE when** the SKILL.md load-table row matches exactly (Add-topic or Targeted is `ROADMAP.md` **and** the user asked for its structure). Read from the top.
**Do NOT Load** for routing, source-of-truth, Bootstrap, whether to create `ROADMAP.md`, catalog-split why, split, unless that parent row matches exactly. Creation is the file contract. This file is not a procedure.

First: one source of truth, `ROADMAP.md` or issues, not both. If issues own dates and status, this file is links only. A milestone table beside issues is a second roadmap (Gaps).

Omission is default. Write a row only with a date or done-condition and an owner. Unscheduled "later" buckets are coverage.

Axes (not required headings):

- Near / mid / long: only if the project already uses those horizons with dates. Do not invent quarters.
- Priority: only if a ranked list already exists (issues, ADR). Do not invent P0/P1.
- Sequence: only if A must precede B in code or requirements.
- Milestones: named, dated, done-condition. A milestone without a done-condition is a wish.

Do not copy `requirements.md`. ROADMAP is when / how far; requirements is what ships.

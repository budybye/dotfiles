## DESIGN.md structure (axes, not a required TOC)

**MANDATORY — READ ENTIRE FILE when** the SKILL.md load-table row matches exactly (Add-topic or Targeted is `DESIGN.md` **and** the user asked for its structure). Read from the top.
**Do NOT Load** for routing, source-of-truth, Bootstrap, ordinary Sync of other files, whether to create `DESIGN.md`, catalog-split why, split, unless that parent row matches exactly. Creation is Minimal profile + contract. This file is not a procedure.

Omission is default. The list below is axes, not headings to stamp. Write a section only when this session has an implementation or design source (screens, tokens, code, existing mock). No source → omit the section. Empty headings are coverage.

- Logo / icon: marks and sizes that exist. Do not invent a mark.
- Layout: regions and ratios the UI uses.
- Headings: the type scale that is shipped.
- Color: tokens or CSS variables in source. Contrast only if specified.
- Type: families and weights in source.
- Form: fields, validation, error placement that are implemented or specified.
- Components: reused pieces named in code.
- Tab / modal: open/close and focus only if those surfaces exist.
- Animation / 3D: only if shipped. Most repos omit.

State and data flow stay in `architecture.md`. If the user asked for `DESIGN.md` but not structure, write only what is seen/operated from evidence. Do not expand into this list.

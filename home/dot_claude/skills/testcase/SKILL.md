---
name: testcase
description: "A skill for the test-planning phase - identify, classify (functional / integration / non-functional), and prioritize (P0-P3) test cases from project context. Outputs a test-case list and a roadmap doc (default paths tests/testlist.md and tests/TDD.md, configurable). Language- and framework-agnostic. Use /tdd-cycle for the Red-Green-Refactor implementation phase. [Triggers: /testcase, identify test cases, test design, test list, test priority, test strategy, test planning, what should I test, write test cases, enumerate tests]"
allowed-tools: Read, Grep, Glob
---

# /testcase — Test Case Design & Management Skill

Plan what to test before writing any test. Classify by type, rank by priority, and produce a durable list the `/tdd-cycle` skill can drive off.

## Quick Reference

| Task                                               | Guide                                                       |
| -------------------------------------------------- | ----------------------------------------------------------- |
| Classification framework and P0–P3 criteria        | Read [references/methodology.md](references/methodology.md) |
| Templates (test-list, roadmap, TC-ID, estimation)  | Read [references/formats.md](references/formats.md)         |
| Filled example (Hono + Cloudflare Workers)         | Read [references/examples.md](references/examples.md)       |

---

## Workflow

```txt
Phase 1: Context Collection (codebase scan + user dialogue)
  ↓
Phase 2: Test Case Identification & Classification
  ↓
Phase 3: Generate the test-case list (default: tests/testlist.md)
  ↓
Phase 4: Generate the roadmap / progress doc (default: tests/TDD.md)
  ↓
Phase 5: Design Review & Confirmation
```

### Phase 1

Gather signals from the codebase, existing tests, and project docs (`docs/requirements.md`, etc.). Surface scope and critical features with the user before enumerating cases.

### Phase 2

Use the framework in `methodology.md` to identify functional, integration, and non-functional tests. Assign priority (P0–P3) and size (S / M / L).

### Phase 3–4

Write the test-case list and the progress/roadmap doc using the templates in `formats.md`. Default filenames are `tests/testlist.md` and `tests/TDD.md` — change them if the project already uses different paths.

### Phase 5

Review the plan with the user:

- Any missing scenarios?
- Do priorities align with business value?
- Does the implementation order respect dependencies?

---

## Agent Guidelines

- **Unique, persistent TC-IDs**: never reuse an ID, even for deleted cases.
- **Prioritize P0 / P1** in the initial TDD roadmap.
- **Synchronize** the list with real test files — a TC-ID that has no test file (or vice versa) is drift.
- **Natural-language scenarios**: write cases readable as specs, not as code-stubs.
- **Respect project convention**: if the repo already has `tests/cases.md` or similar, use that; do not impose `testlist.md` when it would fragment.

## Document Roles

| Document          | Role                                        | Default path         |
| ----------------- | ------------------------------------------- | -------------------- |
| Strategy          | The "why" and "what" at policy level        | `docs/test.md`       |
| Test-case list    | Concrete cases with TC-IDs and expected outputs | `tests/testlist.md`  |
| Roadmap / progress | Implementation order and dashboard          | `tests/TDD.md`       |

These paths are defaults. Substitute project-specific names when they exist.

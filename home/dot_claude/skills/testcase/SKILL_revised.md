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

Document Structures:
- Test-case list: Contains categorized test cases with TC-IDs, priorities, types, sizes, and detailed descriptions
- Roadmap document: Provides TDD cycle guidance, implementation order, and progress tracking

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

## Document Structure Requirements

### Test-case list (`tests/testlist.md`)

Must include:
1. Header with creation date, target project, totals
2. Summary table by category/module
3. Test cases organized by category/feature
4. Each test case with:
   - Unique TC-ID (format: TC-XXX)
   - Priority (P0/P1/P2/P3)
   - Type (Unit/Integration/E2E)
   - Size (S/M/L)
   - Status checkbox
   - Target component/function
   - Preconditions
   - Input example
   - Expected output
   - Associated test file path
   - Notes/related references

### Roadmap document (`tests/TDD.md`)

Must include:
1. Header with last updated date
2. TDD cycle rules (Red → Green → Refactor)
3. Project-specific rules
4. Test execution commands
5. Implementation roadmap grouped by sprint/priority
6. Progress dashboard with metrics
7. Recent activity log

## TC-ID Convention

- Format: `TC-[3-digit sequence]` (e.g., `TC-001`, `TC-002`)
- Continuous sequence across the whole project (don't restart per module)
- Never reuse an ID, even for deleted cases
- Cross-reference with `→ TC-XXX` in the Notes section

## Technology Adaptation

While examples may reference specific frameworks:
- Apply the same principles to any technology stack
- Adjust implementation details to match the project's framework/language
- Focus on the testing concepts rather than specific implementation patterns
- Use the methodology.md classification framework regardless of technology

## Common Pitfalls to Avoid

1. Skipping the context collection phase
2. Creating overly technical test cases that aren't readable as specs
3. Inconsistent TC-ID sequencing
4. Not properly prioritizing P0/P1 cases in the initial roadmap
5. Making assumptions about project conventions without checking
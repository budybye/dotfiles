---
name: testcase
description: A skill for the test planning phase — identify, classify (functional/integration/non-functional), and prioritize (P0–P3) test cases from project context. Outputs tests/testlist.md and tests/TDD.md. Includes a filled Hono API test case example. Use /tdd-cycle for the implementation phase (Red→Green→Refactor). [Triggers: /testcase, identify test cases, test design, test list, test priority, test strategy, test planning, what should I test, write test cases, enumerate tests]
allowed-tools: Read, Grep, Glob
---

# /testcase — Test Case Design & Management Skill

## Quick Reference

| Task                                      | Guide                                                  |
| ----------------------------------------- | ------------------------------------------------------ |
| Methodology, classification, and priority | [references/methodology.md](references/methodology.md) |
| Templates and maintenance rules           | [references/formats.md](references/formats.md)         |

---

## Workflow

```txt
Phase 1: Context Collection (Analysis & Dialog)
  ↓
Phase 2: Test Case Identification & Classification
  ↓
Phase 3: Generate tests/testlist.md
  ↓
Phase 4: Generate tests/TDD.md
  ↓
Phase 5: Design Review & Confirmation
```

### Phase 1: Context Collection

Gather information from the codebase, existing tests, and project documentation (`docs/requirements.md`, etc.). Clarify the scope and critical features with the user.

### Phase 2: Test Case Identification

Use the framework in `methodology.md` to identify functional, integration, and non-functional tests. Assign priorities (P0–P3) and complexity sizes (S/M/L).

### Phase 3–4: Document Generation

Create `tests/testlist.md` and `tests/TDD.md` using the templates in `formats.md`.

### Phase 5: Design Review

Verify the plan with the user:

- Are there any missing scenarios?
- Are the priorities aligned with business value?
- Does the implementation order respect dependencies?

---

## Agent Guidelines

- **Always** ensure `TC-XXX` IDs are unique and persistent.
- **Never** reuse an ID even if a test case is deleted.
- **Prioritize** P0 and P1 cases in the initial TDD roadmap.
- **Maintain** synchronization between `testlist.md` and the actual test files.
- **Use** natural language for scenario descriptions to ensure they are readable as specifications.

## Roles of Test Documents

| Document              | Role                                        |
| --------------------- | ------------------------------------------- |
| **docs/test.md**      | Strategy & Policy (The "Why" and "What").   |
| **tests/testlist.md** | Specific Test Cases (The "What" and "How"). |
| **tests/TDD.md**      | Roadmap & Progress (The "When").            |

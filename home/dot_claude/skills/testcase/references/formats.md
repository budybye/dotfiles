# /testcase File Templates & Maintenance Guide

This document provides templates for `tests/testlist.md` and `tests/TDD.md`, ID naming conventions, maintenance guidelines, and estimation conversion tables.

---

## tests/testlist.md Template

```markdown
# Test Case List

> Created: YYYY-MM-DD
> Target: [Project Name]
> Total Test Cases: XX (P0: X, P1: X, P2: X, P3: X)
> Estimated Total Effort: XX hours

---

## Summary

| Category   | Test Count | P0    | P1    | P2    | P3    | Est. Effort | Implemented |
| ---------- | ---------- | ----- | ----- | ----- | ----- | ----------- | ----------- |
| [Module A] | X          | X     | X     | X     | X     | Xh          | X/X         |
| [Module B] | X          | X     | X     | X     | X     | Xh          | X/X         |
| **Total**  | **X**      | **X** | **X** | **X** | **X** | **Xh**      | **X/X**     |

---

## [Module Name / Feature Name]

### TC-001: [Test Case Name]

- **Priority**: P0 / P1 / P2 / P3
- **Type**: Unit Test / Integration Test / E2E
- **Size**: S / M / L
- **Status**: [ ] Todo / [x] Done / [~] Updating
- **Target**: `src/path/to/module.ts` -> `functionName()`
- **Preconditions**: [State or data required for the test]
- **Input**: [Specific example of test input]
- **Expected Output**: [Expected result]
- **Test File**: `tests/path/to/module.test.ts`
- **Notes**: [Edge cases, precautions, or related TC-XXX references]
```

### Test Case ID Convention

- Use the format `TC-[3-digit sequence]` (e.g., TC-001, TC-002, ...).
- Group by module, but maintain a continuous sequence across the project.
- Do not reuse IDs even if a test case is deleted.
- Use `→ TC-XXX` in the Notes section for cross-references.

---

## tests/TDD.md Template

````markdown
# TDD Practice Guide & Progress Tracking

> Last Updated: YYYY-MM-DD

---

## TDD Cycle Rules

### Red → Green → Refactor

1. **Red**: Write exactly one test and confirm it fails as expected.
2. **Green**: Write the minimal code required to make that test pass.
3. **Refactor**: Improve the design while maintaining the Green state.

### Project-Specific Rules

- Write tests one at a time (no upfront mass-testing).
- Re-evaluate for refactoring immediately after every Green.
- Map test cases to `testlist.md` using `TC-XXX` IDs.
- Include the ID in commit messages (e.g., `test(auth): add JWT validation (TC-003)`).

---

## Test Execution Commands

```bash
# Run all tests
[Project specific command, e.g., npm test]

# Run specific test
[Project specific command, e.g., vitest path/to/file]

# Watch mode
[Project specific command]

# Run with coverage
[Project specific command]
```
````

---

## Implementation Roadmap (TDD Backlog)

### Sprint 1: Foundational Tests (P0)

| Order | ID     | Test Case Name | Size | Status | Date Completed |
| ----- | ------ | -------------- | ---- | ------ | -------------- |
| 1     | TC-001 | [Name]         | S    | [ ]    | -              |
| 2     | TC-002 | [Name]         | M    | [ ]    | -              |

### Sprint 2: Core Feature Tests (P1)

| Order | ID  | Test Case Name | Size | Status | Date Completed |
| ----- | --- | -------------- | ---- | ------ | -------------- |
| ...   | ... | ...            | ...  | ...    | ...            |

---

## Progress Dashboard

### Overall Progress

- **Total Cases**: XX
- **Implemented**: XX (XX%)
- **Passing**: XX
- **Failing**: XX
- **Todo**: XX

### Coverage Status

- **Statements**: XX%
- **Branches**: XX%
- **Functions**: XX%
- **Lines**: XX%

### Recent Activity Log

| Date       | ID     | Action      | Notes |
| ---------- | ------ | ----------- | ----- |
| YYYY-MM-DD | TC-001 | Implemented | -     |

```

---

## Test Code Maintenance Guidelines

### When a Test Fails

1. **Isolate the Cause**: Determine if it's a bug in the production code or if the test expectations are outdated.
2. **Production Bug**: Fix the code to pass the test.
3. **Spec Change**: Update the test case and synchronize `testlist.md`.
4. **Design Flaw**: Refactor the test itself if it has become fragile.

### When Adding New Features

1. Add a new test case to `testlist.md` (assign a new `TC-XXX`).
2. Set Priority and Size.
3. Integrate into the implementation roadmap in `TDD.md`.
4. Follow the Red → Green → Refactor cycle for implementation.

---

## Effort Estimation Table

Use the following hours to convert sizes (S/M/L) in `testlist.md`. This helps in Sprint planning and resource allocation.

| Size | Hours | Description |
| ---- | ----- | ----------- |
| **S** | 0.5h | Simple logic, no external dependencies. |
| **M** | 1.5h | Standard logic, involves mocking or multiple modules. |
| **L** | 6.0h | Complex integration, E2E, or heavy data setup. |

*Example: 10 S-sized + 8 M-sized + 3 L-sized = 5h + 12h + 18h = **35h (~4.5 man-days)***
```

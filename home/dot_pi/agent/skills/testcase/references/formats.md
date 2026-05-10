# Templates & Maintenance Guide

Generic templates for the test-case list and roadmap docs, plus TC-ID rules, maintenance guidelines, and estimation.

> For a filled-in example (Hono + Cloudflare Workers), see [examples.md](examples.md).

---

## Test-case list template (default path: `tests/testlist.md`)

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

## [Module / Feature]

### TC-001: [Test Case Name]

- **Priority**: P0 / P1 / P2 / P3
- **Type**: Unit / Integration / E2E
- **Size**: S / M / L
- **Status**: [ ] Todo / [x] Done / [~] Updating
- **Target**: `path/to/module` -> `functionName()`
- **Preconditions**: [State or data required]
- **Input**: [Concrete input example]
- **Expected Output**: [Expected result]
- **Test File**: `path/to/module.test.ext`
- **Notes**: [Edge cases, caveats, or related TC-XXX references]
```

### TC-ID convention

- Format: `TC-[3-digit sequence]` (e.g., `TC-001`, `TC-002`)
- Group by module, but keep a **continuous** sequence across the whole project
- Never reuse an ID, even for deleted cases
- Cross-reference with `→ TC-XXX` in the Notes section

---

## Roadmap / progress template (default path: `tests/TDD.md`)

```markdown
# TDD Practice Guide & Progress Tracking

> Last Updated: YYYY-MM-DD

---

## TDD Cycle Rules

### Red → Green → Refactor

1. **Red**: write exactly one test and confirm it fails as expected.
2. **Green**: minimum code needed to make that test pass.
3. **Refactor**: improve design while all tests stay Green.

### Project-specific rules

- One test at a time (no upfront mass-testing)
- Re-evaluate Refactor immediately after every Green
- Map cases to the test-case list by `TC-XXX`
- Reference the ID in commit messages (e.g., `test(auth): add JWT validation (TC-003)`)

---

## Test execution commands

```bash
# Run all tests
[project-specific command, e.g. npm test / pytest / cargo test / go test ./... / ctest]

# Run a specific test
[project-specific, e.g. vitest path/to/file / pytest path::test_case]

# Watch mode
[project-specific]

# With coverage
[project-specific]
```

---

## Implementation roadmap (TDD backlog)

### Sprint 1: Foundational (P0)

| Order | ID     | Test Case Name | Size | Status | Completed  |
| ----- | ------ | -------------- | ---- | ------ | ---------- |
| 1     | TC-001 | [Name]         | S    | [ ]    | -          |

### Sprint 2: Core (P1)

| Order | ID     | Test Case Name | Size | Status | Completed  |
| ----- | ------ | -------------- | ---- | ------ | ---------- |

---

## Progress Dashboard

### Overall

- **Total Cases**: XX
- **Implemented**: XX (XX%)
- **Passing**: XX
- **Failing**: XX
- **Todo**: XX

### Coverage

- **Statements**: XX%
- **Branches**: XX%
- **Functions**: XX%
- **Lines**: XX%

### Recent activity log

| Date       | ID     | Action      | Notes |
| ---------- | ------ | ----------- | ----- |
| YYYY-MM-DD | TC-001 | Implemented | -     |
```

---

## Maintenance

### When a test fails

1. **Isolate cause** — production bug or outdated expectation?
2. **Production bug** → fix code; the existing test is the spec.
3. **Spec change** → update the test case and synchronize the list.
4. **Fragile test** → refactor the test itself.

### When adding a feature

1. Append a new TC-XXX to the list.
2. Set priority and size.
3. Integrate into the roadmap.
4. Drive implementation through Red → Green → Refactor.

---

## Estimation table

| Size | Hours | Description |
| ---- | ----- | ----------- |
| **S** | 0.5h | Simple logic, no external dependencies |
| **M** | 1.5h | Standard logic; mocking or multi-module |
| **L** | 6.0h | Complex integration, E2E, or heavy data setup |

*Example: 10 S + 8 M + 3 L = 5h + 12h + 18h = **35h (~4.5 days)***

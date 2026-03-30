---
name: tdd-cycle
description: A skill for executing the t-wada style Red→Green→Refactor cycle — one test at a time, no shortcuts. Use this during implementation after the test list is ready; use /testcase first to plan what to test. Provides Vitest + Hono test file boilerplate and D1/KV mock patterns for Cloudflare Workers projects. [Triggers: /tdd-cycle, tdd-cycle, test-driven, t-wada style, red-green-refactor, write tests first, implement with TDD, failing test, run the test]
disable-model-invocation: true
---

# /tdd-cycle — t-wada Style Test-Driven Development Skill

Practicing TDD as refined by Takuto Wada (t-wada), focusing on a rigorous feedback cycle to ensure "clean code that works."

## Quick Reference

| Task                           | Guide                                                       |
| ------------------------------ | ----------------------------------------------------------- |
| TDD Methodology and Principles | Read [references/methodology.md](references/methodology.md) |
| Test Case Design & Management  | See [../testcase/SKILL.md](../testcase/SKILL.md)            |
| Vitest + Hono test file boilerplate | Read [references/test-templates.md](references/test-templates.md) |

---

## Workflow

```txt
Step 0: Create a Test List
  ↓
Step 1: Select one item from the Test List
  ↓
Step 2: Red — Write a test and confirm it fails
  ↓
Step 3: Green — Pass the test with minimal code
  ↓
Step 4: Refactor — Improve design (while tests remain Green)
  ↓
Step 5: Review & Update Progress
  ↓
Step 6: If items remain on the Test List, return to Step 1
```

## Agent Guidelines

- **One at a time**: Never write multiple tests before passing the current one.
- **Verify Failure**: Always run the test and confirm it fails for the expected reason (Red).
- **Minimal Green**: Write only the simplest code necessary to pass the test. Do not implement the next feature yet.
- **Continuous Refactor**: Treat refactoring as a mandatory step, not an optional one, once the test is Green.
- **Listen to Tests**: If a test is hard to write, treat it as a design flaw signal and consider refactoring the architecture.
- **Document Progress**: Keep `tests/testlist.md` and `tests/TDD.md` updated after every cycle.

## Output & Update Targets

| File                | Action                            |
| ------------------- | --------------------------------- |
| `tests/testlist.md` | Add scenarios / update status     |
| `tests/TDD.md`      | Update dashboard and activity log |
| `tests/**/*.test.*` | Create/modify test code           |
| `src/**/*`          | Create/modify production code     |

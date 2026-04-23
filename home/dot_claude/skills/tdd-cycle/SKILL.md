---
name: tdd-cycle
description: "A skill for executing the t-wada style Red-Green-Refactor cycle - one test at a time, no shortcuts. Use this during implementation after the test list is ready; use /testcase first to plan what to test. Language-agnostic - see references/language-patterns.md for minimal Red-Green examples in TypeScript, Rust, Python, Go, and C++. A Hono + Cloudflare Workers template is included as an optional reference. [Triggers: /tdd-cycle, tdd-cycle, test-driven, t-wada style, red-green-refactor, write tests first, implement with TDD, failing test, run the test]"
disable-model-invocation: true
---

# /tdd-cycle — t-wada Style Test-Driven Development Skill

Practicing TDD as refined by Takuto Wada (t-wada): one test, one cycle, no shortcuts. The goal is "clean code that works" — reached incrementally, never by dumping implementation before tests.

## Quick Reference

| Task                                           | Guide                                                             |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| TDD principles, cycle, anti-patterns           | Read [references/methodology.md](references/methodology.md)       |
| Minimal Red→Green examples per language        | Read [references/language-patterns.md](references/language-patterns.md) |
| Hono + Cloudflare Workers test boilerplate     | Read [references/hono-workers-example.md](references/hono-workers-example.md) |
| Test case design & management (planning)      | See [../testcase/SKILL.md](../testcase/SKILL.md)                  |

---

## Workflow

```txt
Step 0: Create a Test List (or import from /testcase)
  ↓
Step 1: Select one item from the Test List
  ↓
Step 2: Red — Write a test and confirm it fails for the right reason
  ↓
Step 3: Green — Pass with the minimum code (hardcoding is fine)
  ↓
Step 4: Refactor — Improve design while all tests stay Green
  ↓
Step 5: Review & update progress
  ↓
Step 6: Items remain? → back to Step 1
```

## Agent Guidelines

- **One at a time**: Never write a second test before passing the current one.
- **Verify the Red**: The test must fail for the **expected** reason — not a syntax error or missing import.
- **Minimal Green**: Write only what the current test demands. Resist implementing the "next" feature.
- **Mandatory Refactor**: Refactor is a step, not a suggestion. Skipping it compounds debt across cycles.
- **Listen to tests**: If a test is hard to write, the production design is probably wrong — refactor the design, not the test.
- **Document progress**: Keep the test list and progress dashboard up to date after each cycle.

## Output targets (adjust to your project)

Default filenames are a suggestion, not a contract. Use whatever your `/testcase` skill produced.

| File                           | Action                            |
| ------------------------------ | --------------------------------- |
| `tests/testlist.md` *(default)* | Add scenarios / update status     |
| `tests/TDD.md` *(default)*      | Update dashboard and activity log |
| `**/*.test.*` / `**/*_test.*`  | Create / modify test code         |
| `src/**/*` / `lib/**/*`        | Create / modify production code   |

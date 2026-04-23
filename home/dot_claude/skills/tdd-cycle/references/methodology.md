# TDD Methodology (t-wada style)

Detailed procedures, criteria, and anti-patterns. Language-agnostic — concrete examples live in [language-patterns.md](language-patterns.md) and [hono-workers-example.md](hono-workers-example.md).

---

## Definition by t-wada

A refinement of Kent Beck's definition by Takuto Wada. TDD is a workflow of five repeating steps:

1. Write a list of test scenarios (**Test List**) you want to cover.
2. Select **exactly one** item, translate it into concrete executable test code, and confirm it fails.
3. Modify production code to make the current test (and all previous tests) pass. Add new insights to the Test List as they arise.
4. Refactor to improve the design of the implementation.
5. Return to step 2 until the Test List is empty.

TDD is a workflow for incremental design. It is not a substitute for a comprehensive QA process — but it is the foundation one builds on.

---

## Three stages — do not confuse them

| Stage                       | Description                                                                          | Is it TDD?                       |
| --------------------------- | ------------------------------------------------------------------------------------ | -------------------------------- |
| **Automated Testing**       | Writing test code and running it automatically                                       | Not TDD, but the foundation      |
| **Test-First**              | Writing test code before the implementation                                          | Part of TDD, but not the whole   |
| **Test-Driven Development** | Test ↔ implementation alternating one-by-one, with design improved via refactoring   | This is TDD                      |

Test-first alone is not TDD. It becomes TDD only when all three of these hold simultaneously:

1. Tests are written first (**Test-First**)
2. Progress is incremental (**Test List Driven**)
3. Design is continuously improved (**Refactoring Feedback Cycle**)

---

## Step 0: Test List Creation

### Example

```markdown
## Test List: FizzBuzz

- [ ] Returns "1" when passed 1
- [ ] Returns "2" when passed 2
- [ ] Returns "Fizz" for multiples of 3
- [ ] Returns "Buzz" for multiples of 5
- [ ] Returns "FizzBuzz" for multiples of 15
- [ ] Throws an error for negative numbers
```

### Selection Criteria

t-wada prioritizes the **most uncertain** item first — tackle risk early. A valid alternative: start with the **simplest** item to establish rhythm. Pick based on the situation, not dogma.

---

## Step 2: Red (failing test)

### Principles

- **1 Test = 1 Behavior** — each test verifies a single aspect
- **Intentional naming** — the name describes *situation*, *action*, and *expected result*

### Verifying Red

The test must fail for the **correct reason**. Syntax error, missing import, or unrelated runtime failure does **not** count as a valid Red state — it is noise.

Distinguish:
- "function not implemented" / "assertion mismatch" → **valid Red**
- "ReferenceError", "SyntaxError", "ModuleNotFoundError" → **invalid Red** (fix the test first)

---

## Step 3: Green (minimal pass)

### The Minimal Principle

Do only what is necessary to pass the current test.

- **Hardcoding is allowed** — triangulation (the next test) will force generalization.
- **Do not** implement what the next test will demand. That defeats the feedback loop.

---

## Step 4: Refactor

### Review Points

- **Duplication** — is there redundant logic?
- **Naming** — are variables and functions self-documenting?
- **Method length** — is the logic concise?
- **Abstraction** — are implementation details leaking into the interface?

**Safety net**: run tests frequently. If a refactor breaks a test, revert to the last Green state — don't fight through it.

---

## Step 5: Review & Update Progress

For each cycle, evaluate:

1. **Test quality** — does it test one behavior clearly?
2. **Naming** — is intent obvious from the test name?
3. **Minimality** — was the Green code the simplest possible?
4. **Refactoring** — any remaining code smells?
5. **Feedback** — did the test reveal any design flaws?

---

## Anti-Patterns

| Anti-pattern | Why it's bad |
|---|---|
| ❌ Skipping Red verification | You don't know if the test actually exercises the path you think it does |
| ❌ Feature creep in Green | Extra code is untested and unforeseen by the Test List |
| ❌ Behavior change in Refactor | Refactor's contract is "no behavior change" — violating it destroys the safety net |
| ❌ Forcing a hard-to-write test | The difficulty is a design signal. Refactor the **production** code's shape first |
| ❌ Multiple tests at once | You lose attribution when something breaks |
| ❌ Skipping Refactor "just this once" | Debt compounds across cycles; the skip becomes permanent |

---

## Philosophy

### Battle against uncertainty

TDD is territorial conquest: each passing test converts uncertainty into certainty. The area of code you can trust grows one test at a time.

### Protecting the developer

TDD provides a safety net that lowers fear of change and deadline stress — a concrete anti-burnout mechanism, not a philosophical nicety.

### AI guardrails

In an age of AI-generated code, TDD acts as the **guardrails**: humans define specifications through tests, AI provides implementation, and the test suite is the contract both sides honor.

---

## Language / framework examples

- **Generic examples in 5 languages** (TS, Rust, Python, Go, C++): [language-patterns.md](language-patterns.md)
- **Hono + Cloudflare Workers full walkthrough**: [hono-workers-example.md](hono-workers-example.md)

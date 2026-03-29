# /tdd Reference

Detailed procedures, criteria, anti-patterns, and review guidelines for t-wada style TDD.

---

## Definition of TDD by t-wada

A refinement of Kent Beck's definition by Takuto Wada (t-wada). TDD is a programming workflow consisting of five repeating steps:

1.  Write a list of test scenarios (Test List) you want to cover.
2.  Select **exactly one** item from the Test List, translate it into concrete, executable test code, and confirm that the test fails.
3.  Modify the production code to make the current test (and all previous tests) pass. Add any new insights to the Test List during this process.
4.  Refactor as necessary to improve the design of the implementation.
5.  Return to step 2 and repeat until the Test List is empty.

**Note**: TDD is a workflow for incremental design and development. It is not a substitute for a comprehensive QA process, but it builds a solid foundation for it.

---

## Distinguishing the Three Stages

t-wada distinguishes between these three stages. Do not confuse them.

| Stage                       | Description                                                                                  | Is it TDD?                      |
| --------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------- |
| **Automated Testing**       | Writing test code and running it automatically.                                              | Not TDD, but the foundation.    |
| **Test-First**              | Writing test code before the implementation.                                                 | Part of TDD, but not the whole. |
| **Test-Driven Development** | Alternating between testing and implementation one-by-one, improving design via refactoring. | This is TDD.                    |

Test-first alone is not TDD. It becomes TDD only when:

1.  Tests are written first (**Test-First**).
2.  Progress is incremental (**Test List Driven**).
3.  Design is continuously improved (**Refactoring Feedback Cycle**).

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

### Selection Criteria (Step 1)

The t-wada style prioritizes the **most uncertain** items first to tackle risks early. However, starting with the **simplest** item is a great way to establish a rhythm.

---

## Step 2: Red (Failing Test)

### Principles

- **1 Test = 1 Behavior**: Each test should verify a single aspect of the software.
- **Intentional Naming**: Use names that describe the "Situation," "Action," and "Expected Result."

### Verifying Red

Ensure the test fails for the **correct reason**. If it passes or fails due to a syntax error/missing import, you haven't reached a valid Red state.

---

## Step 3: Green (Minimal Pass)

### The Minimal Principle

Do only what is necessary to pass the test.

- Hardcoding is allowed (Triangulation: the next test will force generalization).
- Avoid the temptation to implement the "next" feature.

---

## Step 4: Refactor (Design Improvement)

### Review Points

- **Duplication**: Is there any redundant logic?
- **Naming**: Are variable and function names self-documenting?
- **Method Length**: Is the logic concise?
- **Abstraction**: Are we leaking implementation details into the interface?

**Safety Net**: Frequent test execution is mandatory. If a test breaks, revert to the last Green state.

---

## Step 5: Review & Update Progress

### Cycle Review Checklist

For each cycle, evaluate:

1.  **Test Quality**: Does it test one behavior clearly?
2.  **Naming**: Is the intent obvious from the test name?
3.  **Minimality**: Was the Green code the simplest possible?
4.  **Refactoring**: Are there any remaining code smells?
5.  **Feedback**: Did the test reveal any design flaws?

---

## Hono API: Full TDD Example

A complete Red → Green → Refactor cycle for a Hono REST endpoint, using `hono/testing` and Vitest.

### Test List

```markdown
## Test List: POST /api/users

- [ ] Returns 201 with the created user on valid input
- [ ] Returns 400 when name is empty
- [ ] Returns 400 when email is invalid
- [ ] Returns 409 when email already exists
```

### Step 2: Red — Write a Failing Test

Select the simplest item first: _"Returns 201 with the created user on valid input."_

```ts
// src/routes/users.test.ts
import { describe, it, expect } from "vitest"
import { testClient } from "hono/testing"
import app from "../index"

describe("POST /api/users", () => {
  it("returns 201 with the created user on valid input", async () => {
    const client = testClient(app)
    const res = await client.api.users.$post({
      json: { name: "Alice", email: "alice@example.com" },
    })
    expect(res.status).toBe(201)
    const body = await res.json()
    expect(body.name).toBe("Alice")
    expect(body.email).toBe("alice@example.com")
  })
})
```

Run the test → it fails with `TypeError: client.api.users.$post is not a function` or a 404.
This is the **expected Red**. Proceed to Green.

### Step 3: Green — Minimal Implementation

```ts
// src/routes/users.ts
import { Hono } from "hono"
import { zValidator } from "@hono/zod-validator"
import { z } from "zod"

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export const usersRoute = new Hono().post(
  "/",
  zValidator("json", schema),
  async (c) => {
    const data = c.req.valid("json")
    // Minimal: return the input as-is (no DB yet)
    return c.json({ id: 1, ...data }, 201)
  }
)

// src/index.ts
import { Hono } from "hono"
import { usersRoute } from "./routes/users"
const app = new Hono().route("/api/users", usersRoute)
export default app
```

Run the test → ✓ passes. Run all previous tests → ✓ still green. Proceed to Refactor.

### Step 4: Refactor

- Extract the schema to a shared `src/schemas/user.ts` if other routes reuse it.
- Replace the hardcoded `id: 1` with a real D1 insert if the project requires persistence.
- Add the error handler at the app level (not per route).

### Step 5: Next Test — "Returns 400 when name is empty"

The zValidator already handles this — just add the test to confirm and mark the item done.

```ts
it("returns 400 when name is empty", async () => {
  const client = testClient(app)
  const res = await client.api.users.$post({
    json: { name: "", email: "alice@example.com" },
  })
  expect(res.status).toBe(400)
})
```

Run → ✓ Red already passes (zod rejects `min(1)`). No code change needed. This is a valid, fast confirmation cycle.

---

## Anti-Patterns

- **❌ Missing the Red**: Proceeding without verifying that the test actually fails.
- **❌ Feature Creep in Green**: Implementing more than what the current test requires.
- **❌ Behavior Change in Refactor**: Adding new functionality during the refactoring step.
- **❌ Ignoring Design Signals**: Forcing a test to pass when the difficulty of writing the test suggests the design is flawed.

---

## Philosophy: Why TDD?

### A Battle Against Uncertainty

TDD is a "battle for territory" where you gradually convert uncertainty into certainty. Each passing test expands the territory of code you can trust.

### Protecting the Developer

TDD provides a safety net that reduces the fear of change and the stress of deadlines, ultimately preventing developer burnout.

### AI Guardrails

In the age of AI, TDD acts as the "guardrails" for AI-generated code. Humans define the specifications through tests, and AI provides the implementation, creating a robust feedback loop.

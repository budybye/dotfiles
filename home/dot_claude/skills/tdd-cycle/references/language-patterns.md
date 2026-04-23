# TDD Language Patterns

Minimal Red → Green → (Refactor) cycles in the five languages the user works in: **TypeScript, Rust, Python, Go, C++**. Each uses a FizzBuzz-shaped problem small enough to read in one pass.

Every example follows the same shape:
1. Test list (1 item shown)
2. Red — test written, run, confirmed failing for the right reason
3. Green — minimum implementation
4. Note on the next cycle (what triangulation would force next)

---

## TypeScript (Vitest)

```ts
// src/fizzbuzz.test.ts
import { describe, it, expect } from "vitest";
import { fizzbuzz } from "./fizzbuzz";

describe("fizzbuzz", () => {
  it("returns '1' when passed 1", () => {
    expect(fizzbuzz(1)).toBe("1");
  });
});
```

Run: `vitest run` → Red (module not found / function not exported).

```ts
// src/fizzbuzz.ts
export function fizzbuzz(n: number): string {
  return "1"; // hardcoded — intentional
}
```

Run → Green. Next cycle (`returns "2" when passed 2`) will force generalization to `String(n)`.

---

## Rust (built-in test)

```rust
// src/fizzbuzz.rs
pub fn fizzbuzz(n: u32) -> String {
    unimplemented!()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn returns_1_for_input_1() {
        assert_eq!(fizzbuzz(1), "1");
    }
}
```

Run: `cargo test` → Red (`unimplemented!` panics — valid failure).

```rust
pub fn fizzbuzz(_n: u32) -> String {
    "1".to_string()
}
```

Run → Green. Next cycle forces `n.to_string()`.

**Rust note**: Prefer `assert_eq!` over `assert!` — the failure message shows both sides.

---

## Python (pytest)

```python
# tests/test_fizzbuzz.py
from fizzbuzz import fizzbuzz

def test_returns_1_for_input_1():
    assert fizzbuzz(1) == "1"
```

Run: `pytest` → Red (`ModuleNotFoundError` — fix by creating the module, **not** by skipping the test).

```python
# fizzbuzz.py
def fizzbuzz(n: int) -> str:
    return "1"
```

Run → Green. Next cycle forces `str(n)`.

**Python note**: Type hints are not enforced at runtime; the test is the contract.

---

## Go (built-in testing)

```go
// fizzbuzz_test.go
package fizzbuzz

import "testing"

func TestReturns1ForInput1(t *testing.T) {
    got := Fizzbuzz(1)
    want := "1"
    if got != want {
        t.Errorf("Fizzbuzz(1) = %q; want %q", got, want)
    }
}
```

Run: `go test ./...` → Red (undefined: Fizzbuzz).

```go
// fizzbuzz.go
package fizzbuzz

func Fizzbuzz(n int) string {
    return "1"
}
```

Run → Green. Next cycle forces `strconv.Itoa(n)`.

**Go note**: Idiom is `got`, `want` named locals with `t.Errorf("X = %v; want %v", got, want)`.

---

## C++ (GoogleTest)

```cpp
// fizzbuzz_test.cpp
#include <gtest/gtest.h>
#include "fizzbuzz.hpp"

TEST(Fizzbuzz, Returns1ForInput1) {
    EXPECT_EQ(fizzbuzz(1), "1");
}
```

```cpp
// fizzbuzz.hpp
#pragma once
#include <string>
std::string fizzbuzz(int n);
```

Run: `ctest` → Red (link error — unresolved `fizzbuzz`).

```cpp
// fizzbuzz.cpp
#include "fizzbuzz.hpp"

std::string fizzbuzz(int n) {
    return "1";
}
```

Run → Green. Next cycle forces `std::to_string(n)`.

**C++ note**: Always prefer `EXPECT_EQ` over `EXPECT_TRUE(a == b)` — the failure message loses information otherwise.

---

## Refactor step — language-specific watchpoints

| Language | Common Refactor opportunities |
|---|---|
| TypeScript | Extract Zod schemas; replace `any` with `unknown`; promote literals to const unions |
| Rust | Remove `.unwrap()` in favor of `?`; introduce traits when you see the second implementation |
| Python | Replace tuples with `@dataclass`; lift repeated patterns into generators / comprehensions |
| Go | Accept interfaces, return structs; collapse error-wrapping boilerplate into helpers |
| C++ | Introduce RAII wrappers; replace raw owning pointers with `unique_ptr`; mark by-value constants `constexpr` |

These are **Refactor cues**, not mandatory edits. Each still must keep all tests Green.

---

## When to add a new language file to this reference

If you start working in a language not listed here, add a minimal Red→Green (no longer than ~30 lines for test + implementation) and a short "Refactor watchpoints" row. Longer examples belong in their own reference file, not here — this page stays scannable.

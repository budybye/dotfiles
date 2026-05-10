# /testcase Identification & Priority Criteria

## Automated Discovery

Use these commands to analyze the project and gather context for test design:

```bash
# Analyze source code structure
find src/ app/ lib/ -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.py' -o -name '*.rs' \) 2>/dev/null | head -80

# Identify existing tests and coverage patterns
find tests/ test/ __tests__ spec/ -type f 2>/dev/null | head -50
find src/ -name '*.test.*' -o -name '*.spec.*' 2>/dev/null | head -30

# Check test configurations and frameworks
cat jest.config.* vitest.config.* pytest.ini setup.cfg 2>/dev/null
cat package.json | grep -A 10 '"scripts"' 2>/dev/null

# Read existing test documentation
cat tests/testlist.md tests/TDD.md docs/test.md 2>/dev/null
```

---

## Identification Framework

### 1. Functional Testing (What it does)

- **Happy Path**: Standard behavior with valid inputs. Does the feature work as intended?
- **Negative Cases**: Error handling for invalid inputs (null, undefined, empty strings, type mismatches).
- **Boundary Values**: Testing the limits.
  - Empty arrays / single element / maximum size.
  - String length limits.
  - Numeric limits (min, max, 0, negative).
  - Date boundaries (leap years, end of month/year).
- **State Transitions**:
  - Initial state → Target state.
  - Blocking invalid transitions.
  - Concurrency handling (e.g., optimistic locking).

### 2. Integration Testing (How it connects)

- **Internal Chain**: Call sequences between modules/services.
- **External Dependencies**: API → Service → Repository → Database flow.
- **API Contracts**: Validation of external API request/response formats.
- **Messaging**: Event emission and queue consumption.
- **Real-time**: WebSocket connection, message broadcasting, and hibernation.

### 3. Non-Functional Testing (How it performs)

- **Performance**: Latency targets and concurrency limits.
- **Security**: Basic checks for Authentication, Authorization (401/403), XSS, and Injection.
- **Resilience**: Timeout handling, retry mechanisms, and circuit breakers.
- **Compatibility**: Verifying behavior across different runtimes (Node.js, Workers, etc.).

---

## Priority Levels

### P0: Critical — Service Interruption

Broken core functionality. Must be tested first.

- Payments and billing flows.
- Authentication and authorization (Login, JWT verification).
- Data Integrity (Database transactions, data corruption risks).
- Security encryption/decryption.
- Application bootstrap/initialization process.

### P1: High — Major Feature Impact

Impacts primary user journeys.

- Main CRUD operations.
- Primary search and filtering logic.
- Core business logic and calculations.
- Data persistence.
- Key API endpoints.

### P2: Medium — Quality Degradation

Edge cases and UX improvements.

- Rare boundary conditions.
- Error message clarity and accuracy.
- Pagination, sorting, and non-critical UI filters.
- Logging and telemetry accuracy.

### P3: Low — Auxiliary

Optional or "nice to have" tests.

- Performance benchmarks.
- Documentation accuracy verification.
- Deprecated feature compatibility.
- Cosmetic consistency (if not covered by Linter/Snapshots).

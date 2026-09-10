---
name: testing-principles
description: Behavior-focused testing guidance for this repository's TypeScript/JavaScript worker and server tests, especially Vitest unit/server, MCP smoke, workflow, mock, console-spy, audit-log-spy, fixture, and test-isolation changes. Use when writing, reviewing, or restructuring these tests or choosing their test boundary.
---

# Testing Principles

Use **contract-first** tests: identify observable behavior, choose smallest test level that proves it, then keep setup, actions, assertions, and side effects in one legible flow.

## Test-level choice

| Contract | Test level | Boundary that justifies it |
|---|---|---|
| Pure transformation or isolated handler behavior | Unit | No meaningful module, storage, or transport interaction |
| Multiple in-process modules, persistence, middleware, or server behavior | Integration/server | Interaction across real local boundaries matters |
| Real MCP HTTP transport, OAuth, or package-app session wiring | MCP smoke | `packages/worker/src/mcp/*.mcp-e2e.test.ts` boundary is required |
| Browser navigation, rendering, or user input | E2E | Browser behavior cannot be proven in-process |

Keep E2E to a few important happy paths. Prefer fast local unit/server tests when they prove same contract. Add a slower test only when its boundary catches a failure the smaller test cannot observe.

## Test design

- Name intent plainly, including expected behavior: `auth handler returns 400 for invalid JSON`.
- Keep each independent contract in its own top-level `test(...)`; combine assertions when they depend on the same rendered object, request, response, or state transition.
- Inline setup per test. Build factories that return ready-to-run objects; avoid shared mutable state because leaked state makes failures order-dependent.
- Keep related intermediate-state assertions inside workflow that produces them; this preserves causal failure context.
- Use disposable objects only when cleanup is real; otherwise avoid `using` and `Symbol.dispose`.
- Start from observable contract. Do not test guarantees already provided by TypeScript's type system.
- Keep tests offline: use local fakes and fixtures, not public internet or third-party services.
- Assert structured output, user-visible outcomes, or stable public contracts. Avoid incidental prose, tool descriptions, usage hints, warnings, and configuration strings.
- Add regression tests when failure is plausible and flow justifies maintenance cost; avoid low-value bug-history tests.

## Console output

Global setup guards console output (`packages/worker/src/test-support/console-spies.ts`). Unexpected `console.error` and `console.warn` fail tests; `console.info` and `console.debug` are silenced.

Keep output allowlisted so unrelated regressions remain visible:

- Logging is part of contract: import exported `consoleError`/`consoleWarn` spies, silence with `.mockImplementation(() => {})`, then assert calls. Prefer stable first-argument tags plus `expect.any(Error)`; assert count when deterministic.
- Logging is incidental: use `silenceExpectedConsoleWarns([...])` or `silenceExpectedConsoleErrors([...])` with exact expected message tags.
- Bundler/registry runtime noise: use `silenceIncidentalRuntimeWarnings()` from `packages/worker/src/test-support/incidental-runtime-warnings.ts`.

Blanket console mocks hide unexpected warnings and errors; keep them scoped to expected noise and assert contract logging explicitly.

## Audit-log side effects

Node-unit tests globally mock the audit-log sink through `packages/worker/src/test-support/audit-log-spy.ts` and setup files. Import `logAuditEventSpy` and assert expected events, including `not.toHaveBeenCalled()` when no event is expected.

When testing the real audit pipeline, opt out with:

```ts
vi.unmock('#worker/audit-log.ts')
```

When overriding another audit-log export (for example `getRequestIp`), declare a local `vi.mock('#worker/audit-log.ts', ...)` and route `logAuditEvent` back through shared `logAuditEventSpy`.

## Project test commands

Run server/unit tests with:

```sh
npm run test
```

Use targeted Vitest paths when diagnosis needs them. This avoids Playwright discovery and accidental matching of `packages/worker/src/mcp/mcp-server.mcp-e2e.test.ts`.

## Completion check

Before finishing a test change, verify every modified workflow has:

1. A test name stating behavior and expected result.
2. Setup isolated from other tests and no newly introduced shared mutable state.
3. A test level justified by its observable boundary.
4. Dependent intermediate and final assertions in one workflow; independent contracts split.
5. Network and third-party dependencies local or faked.
6. Expected console and audit-log side effects asserted or explicitly allowlisted.
7. `npm run test` exercised for modified unit/server workflows; MCP smoke or E2E changes use the corresponding boundary-specific command, and any unavailable command is documented with a targeted substitute.

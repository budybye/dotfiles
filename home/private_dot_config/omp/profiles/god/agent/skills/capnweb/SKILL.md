---
name: capnweb
description: Build, integrate, review, test, diagnose, and secure Cap'n Web JavaScript-native RPC systems and real-time integrations. Use whenever a task mentions capnweb, Cap'n Web, RpcTarget, RpcStub, RpcPromise, promise pipelining, remote object capabilities, newHttpBatchRpcSession, newWebSocketRpcSession, newMessagePortRpcSession, WebSocket/WS, SSE/EventSource alongside RPC, Cloudflare Workers RPC interoperability, Hono/@hono/capnweb, TypeScript type errors, anti-patterns, best practices, doctor/diagnosis, or code/design review.
---

# Cap'n Web

Use Cap'n Web as an object-capability RPC layer for JavaScript runtimes. Prefer current package types and the official repository over remembered API details; the project is young and its API evolves.

## Workflow

1. **Inspect the project first.** Identify the package manager, `capnweb` version, runtime, TypeScript configuration, server adapter, and existing authentication/validation. Read the installed package types when signatures or version-specific behavior matter.
2. **Choose the topology.** Decide whether the connection is one-shot HTTP batch, long-lived WebSocket, `MessagePort`, or a custom bidirectional transport. Decide which side exports the main `RpcTarget`; sessions are symmetric even when the application calls one side “server”.
3. **Define the capability surface.** Put the public TypeScript interface in a shared module when client and server share source. Implement exported classes with `extends RpcTarget`; expose only intended prototype methods and use JavaScript `#private` members for methods that must not be remotely callable.
4. **Model latency explicitly.** Use `RpcPromise` for dependent calls and `Promise.all` for batch results. Use `.map()` only for synchronous, RPC-only recordable callbacks. Do not pull intermediate values locally when a pipeline can express the dependency.
5. **Model ownership.** Dispose long-lived stubs, promises, returned objects, and retained callbacks. Use `using` when supported or call `[Symbol.dispose]()` explicitly. Duplicate a stub with `.dup()` before retaining it beyond the call that supplied it.
6. **Secure the boundary.** Treat TypeScript as compile-time only. Authenticate in-band when browser WebSockets prevent reliable custom headers, validate `Origin` when the endpoint is not intentionally cross-origin, validate all untrusted values at runtime, and apply operation, CPU, message-size, and transport payload limits.
7. **Verify behavior.** Run the project’s typecheck, unit tests, and an integration test over the selected transport. Assert request counts for batching/pipelining, disposal of retained references, reconnect/error behavior, authorization, malformed inputs, and large payload handling.
8. **Select the task branch.** For a failure or hang, read `doctor.md`; for WebSocket/SSE real-time design, read `realtime.md`; for a review or best-practice audit, read `anti-patterns.md` and `review.md`; for TypeScript/export-condition issues, read `type-system.md`.

## Route to references

- **Core API, values, stubs, promises, batching, pipelining, `map()`, streams, disposal:** read [references/core-api.md](references/core-api.md).
- **Workers, Node.js, Deno, Bun, Hono, MessagePort, and custom transports:** read [references/transports.md](references/transports.md).
- **WebSocket lifecycle, SSE/EventSource coexistence, reconnect, and Hono real-time routes:** read [references/realtime.md](references/realtime.md).
- **Origin/authentication, validation, capability security, resource limits, and threat review:** read [references/security.md](references/security.md).
- **Protocol/framing, encoding levels, transport implementation, and wire debugging:** read [references/protocol.md](references/protocol.md).
- **Doctor/diagnosis for connection, hang, batching, type, lifecycle, and payload failures:** read [references/doctor.md](references/doctor.md).
- **Explicit anti-patterns and Cap'n Web best practices:** read [references/anti-patterns.md](references/anti-patterns.md).
- **TypeScript contracts, recursive types, runtime validation, and upgrade/type failures:** read [references/type-system.md](references/type-system.md).
- **Code/design review workflow, priorities, prompts, and finding format:** read [references/review.md](references/review.md).
- **Tests, fixtures, failure diagnosis, and release checks:** read [references/testing.md](references/testing.md).

## Design rules

- Treat every remote call as fallible and latency-sensitive; do not hide network calls behind APIs that look purely local without documenting that contract.
- Keep the RPC interface capability-oriented: return the smallest `RpcTarget` or callback capability needed for the next operation rather than a broad ambient service.
- Keep serialization boundaries explicit. Pass data by value when a snapshot is intended; pass an `RpcTarget` or function only when the recipient should retain a callable capability.
- Do not assume arbitrary application classes, cycles, `Map`, or `Set` serialize. Check the installed version and the core reference before choosing a value shape.
- Do not send secrets through logs, error stacks, serialized payloads, or debug traces. Redact RPC arguments and returned errors in observability code.
- Prefer the built-in transport helpers and runtime adapters before implementing `RpcTransport`; custom transports are a protocol and flow-control responsibility, not merely a `send()` wrapper.

## Completion criteria

A Cap'n Web change is complete only when the selected runtime and package version are documented, the exported capability surface is type-checked, all references are disposed according to ownership, boundary security is tested, and transport-specific integration tests pass.
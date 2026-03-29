# Node.js API Compatibility Matrix for workerd

> Legend: 🟢 Native Support | 🟡 Partial Support / Polyfill | 🔴 Unsupported (Architectural Constraint)

## Core Modules

| Module                     | Status | Remarks                                                                                  |
| -------------------------- | ------ | ---------------------------------------------------------------------------------------- |
| `node:assert`              | 🟢     | Fully supported.                                                                         |
| `node:async_hooks`         | 🟡     | `AsyncLocalStorage` only. `AsyncResource` is partially supported.                        |
| `node:buffer`              | 🟢     | Fully supported (Native implementation). Prefer `Uint8Array` for Web Standards.          |
| `node:child_process`       | 🔴     | Cannot spawn processes. Use Dynamic Workers (env.LOADER) for code execution.             |
| `node:cluster`             | 🔴     | Incompatible with the Workers isolate model.                                             |
| `node:crypto`              | 🟢     | Major APIs supported. Internally mapped to Web Crypto for performance.                   |
| `node:dgram`               | 🔴     | UDP not supported.                                                                       |
| `node:diagnostics_channel` | 🟢     | Supported.                                                                               |
| `node:dns`                 | 🟡     | `resolve`/`lookup` only. No server-side APIs.                                            |
| `node:events`              | 🟢     | `EventEmitter` fully supported.                                                          |
| `node:fs`                  | 🟡     | Async read only. Most `*Sync` and write operations are unsupported. Use R2 for storage.  |
| `node:http`                | 🟡     | Client: Supported. Server: Requires `enable_nodejs_http_server_modules` flag.            |
| `node:http2`               | 🔴     | Unsupported.                                                                             |
| `node:https`               | 🟡     | Same as `node:http`.                                                                     |
| `node:module`              | 🟡     | `createRequire` supported for CJS compatibility.                                         |
| `node:net`                 | 🟡     | `connect` (TCP client) supported. `createServer` has limited support.                    |
| `node:os`                  | 🟡     | Constants only. Actual OS info (CPU, Load) is not available due to sandbox.              |
| `node:path`                | 🟢     | Fully supported.                                                                         |
| `node:process`             | 🟡     | `env`, `nextTick`, `version` supported. PID/UID are undefined. Requires `nodejs_compat`. |
| `node:stream`              | 🟢     | Fully supported. Interoperable with Web Streams API.                                     |
| `node:string_decoder`      | 🟢     | Supported.                                                                               |
| `node:timers`              | 🟢     | `setTimeout`/`setInterval` supported. `setImmediate` is polyfilled via `queueMicrotask`. |
| `node:url`                 | 🟢     | `URL`, `URLSearchParams` fully supported.                                                |
| `node:util`                | 🟡     | `promisify`, `inspect`, `format` supported. `inherits` is deprecated.                    |
| `node:vm`                  | 🟡     | Limited. Use Dynamic Workers for secure sandboxing.                                      |
| `node:worker_threads`      | 🔴     | Use Durable Objects or Queues for task distribution.                                     |
| `node:zlib`                | 🟢     | Compression/Decompression supported.                                                     |

## Globals

| Global         | Status | Web Standard Alternative                  |
| -------------- | ------ | ----------------------------------------- |
| `__dirname`    | 🔴     | `new URL('.', import.meta.url).pathname`  |
| `__filename`   | 🔴     | `import.meta.url`                         |
| `global`       | 🟡     | Use `globalThis`                          |
| `process`      | 🟡     | Use environment bindings via Hono/Context |
| `Buffer`       | 🟢     | Use `Uint8Array`                          |
| `setImmediate` | 🟡     | `queueMicrotask()` or `setTimeout(fn, 0)` |

## Common Incompatibility Patterns

### spawn/exec (Shell commands)

```ts
// ❌ This will not work
import { exec } from "node:child_process";
exec("ls -la", callback);

// ✅ Use R2 or KV to manage files, or Logic within the Worker
```

### Synchronous I/O

```ts
// ❌ Synchronous I/O blocks the event loop and is restricted
const data = fs.readFileSync("/config.json", "utf-8");

// ✅ Use asynchronous R2 or KV bindings
const data = await env.MY_BUCKET.get("config.json");
```

### Web Streams Interoperability

Cloudflare Workers prefers Web Streams. If using Node.js streams, convert them:

```ts
import { Readable } from "node:stream";

const nodeStream = Readable.from(["hello"]);
const webStream = Readable.toWeb(nodeStream);

// Return directly in a Hono or Worker response
return new Response(webStream);
```

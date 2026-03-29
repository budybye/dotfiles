# Essential Shim Patterns for Cloudflare Workers

Practical patterns for implementing compatibility shims and using Hono middleware to bridge Node.js and Web Standard APIs.

## Hono Middleware: process.env Shim

In Workers, environment variables are provided via the `env` object in the fetch handler. If you use libraries that strictly depend on `process.env`, use this middleware.

```ts
import { createMiddleware } from "hono/factory";

export const processEnvShim = () =>
	createMiddleware(async (c, next) => {
		// Inject env bindings into the global process object
		globalThis.process = {
			...globalThis.process,
			env: { ...c.env },
		} as any;
		await next();
	});

// Usage in Hono
// app.use('*', processEnvShim())
```

## Web Streams Interop (node:stream ↔ Web Stream)

The `node:stream` module in Workers is interoperable with Web Standard Streams. Use this for high-performance data processing.

```ts
import { Readable, Writable } from "node:stream";

// 1. Convert Node.js Readable to Web ReadableStream
const nodeReadable = Readable.from(["Hello", " ", "World"]);
const webReadable = Readable.toWeb(nodeReadable);

// 2. Convert Web ReadableStream to Node.js Readable
const response = await fetch("https://example.com");
const nodeFromWeb = Readable.fromWeb(response.body!);

// 3. Usage in Hono
app.get("/stream", (c) => {
	return c.body(webReadable);
});
```

## fs.readFile → R2 Storage / KV

Since the local file system is read-only or non-existent in production, use R2 (Object Storage) or KV (Key-Value) as a replacement for `fs`.

```ts
// shims/r2-fs.ts
export async function readFile(
	path: string,
	env: { BUCKET: R2Bucket },
): Promise<string> {
	const obj = await env.BUCKET.get(path);
	if (!obj) throw new Error(`ENOENT: no such file: ${path}`);
	return obj.text();
}

export async function writeFile(
	path: string,
	data: string | ArrayBuffer,
	env: { BUCKET: R2Bucket },
): Promise<void> {
	await env.BUCKET.put(path, data);
}
```

## child_process → Dynamic Workers

Workers cannot spawn OS processes. For "code execution" use cases, use Dynamic Workers (Worker Versioning/LOADER).

```ts
// shims/exec-worker.ts
export async function execInWorker(
	code: string,
	env: { LOADER: WorkerLoader },
): Promise<any> {
	const worker = env.LOADER.load({
		mainModule: "index.js",
		modules: {
			"index.js": `
        export default {
          async fetch(request) {
            ${code}
            return new Response("OK")
          }
        }
      `,
		},
	});
	return worker.fetch(new Request("http://local/"));
}
```

## setImmediate / clearImmediate

Workers do not have `setImmediate`. Use `queueMicrotask` for microtasks or `setTimeout(fn, 0)` for macrotasks.

```ts
// shims/timers.ts
export const setImmediate = (fn: (...args: any[]) => void, ...args: any[]) => {
	return setTimeout(() => fn(...args), 0);
};

export const clearImmediate = (id: any) => {
	clearTimeout(id);
};
```

## EventEmitter with ExecutionContext

When emitting events that trigger asynchronous work, ensure you use `ctx.waitUntil` to prevent the Worker from terminating early.

```ts
import { EventEmitter } from "node:events";

export class WorkersEvents extends EventEmitter {
	constructor(private ctx: ExecutionContext) {
		super();
	}

	// Helper to ensure async listeners are tracked
	emitAsync(event: string, ...args: any[]) {
		const listeners = this.listeners(event);
		listeners.forEach((fn) => {
			this.ctx.waitUntil(Promise.resolve(fn(...args)));
		});
		return listeners.length > 0;
	}
}
```

## Module Aliasing (Vite / Esbuild)

Use bundler aliases to redirect Node.js calls to your custom shims.

```ts
// vite.config.ts
import { defineConfig } from "vite";

export default defineConfig({
	resolve: {
		alias: {
			"node-fetch": "cloudflare:fetch-polyfill",
			fs: "./shims/r2-fs.ts",
			child_process: "./shims/child_process_stub.ts",
		},
	},
});
```

## TCP/UDP Server → Durable Objects + WebSockets

`node:net` and `node:dgram` servers are not supported. For persistent socket-like behavior, use Durable Objects with WebSockets.

```ts
import { DurableObject } from "cloudflare:workers";

export class SocketServer extends DurableObject {
	async fetch(request: Request) {
		const pair = new WebSocketPair();
		const [client, server] = Object.values(pair);

		this.ctx.acceptWebSocket(server);
		return new Response(null, { status: 101, webSocket: client });
	}

	async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
		// Handle binary or string data similar to a TCP stream
		ws.send(`Echo: ${message}`);
	}
}
```

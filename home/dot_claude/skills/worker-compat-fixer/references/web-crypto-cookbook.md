# node:crypto to Web Crypto Recipes

A guide for converting common `node:crypto` patterns to the native Web Crypto API (`crypto.subtle`) in Cloudflare Workers.

## Hashing (SHA-256)

Useful for creating fingerprints or identifying data.

```ts
// node:crypto
import { createHash } from "node:crypto";
const hash = createHash("sha256").update(data).digest("hex");

// Web Crypto
async function sha256(data: string): Promise<string> {
	const msgUint8 = new TextEncoder().encode(data);
	const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
	return Array.from(new Uint8Array(hashBuffer))
		.map((b) => b.toString(16).padStart(2, "0"))
		.join("");
}
```

## HMAC (Signature Verification)

Standard for verifying webhooks (e.g., GitHub, Stripe).

```ts
// node:crypto
import { createHmac } from "node:crypto";
const hmac = createHmac("sha256", secret).update(data).digest("hex");

// Web Crypto
async function hmacSha256(secret: string, data: string): Promise<string> {
	const enc = new TextEncoder();
	const key = await crypto.subtle.importKey(
		"raw",
		enc.encode(secret),
		{ name: "HMAC", hash: "SHA-256" },
		false,
		["sign"],
	);
	const signature = await crypto.subtle.sign("HMAC", key, enc.encode(data));
	return Array.from(new Uint8Array(signature))
		.map((b) => b.toString(16).padStart(2, "0"))
		.join("");
}
```

## Hono Middleware: Webhook Signature Verification

A practical example using Hono to verify incoming webhook signatures.

```ts
import { Hono } from "hono";

const app = new Hono<{ Bindings: { WEBHOOK_SECRET: string } }>();

app.post("/webhook", async (c) => {
	const signature = c.req.header("X-Hub-Signature-256"); // e.g., GitHub
	const body = await c.req.text();

	if (!signature) return c.json({ error: "Missing signature" }, 401);

	// Note: GitHub signature is often 'sha256=...'
	const sigHash = signature.startsWith("sha256=")
		? signature.slice(7)
		: signature;
	const expected = await hmacSha256(c.env.WEBHOOK_SECRET, body);

	// Use timing-safe comparison to prevent side-channel attacks
	if (sigHash !== expected) {
		return c.json({ error: "Invalid signature" }, 401);
	}

	return c.json({ ok: true });
});
```

## AES-GCM Encryption/Decryption

Recommended for general-purpose symmetric encryption.

```ts
// Web Crypto AES-GCM
async function encrypt(plaintext: string, key: CryptoKey) {
	const iv = crypto.getRandomValues(new Uint8Array(12));
	const encoded = new TextEncoder().encode(plaintext);

	const ciphertext = await crypto.subtle.encrypt(
		{ name: "AES-GCM", iv },
		key,
		encoded,
	);

	return { iv, ciphertext };
}

async function decrypt(
	ciphertext: ArrayBuffer,
	key: CryptoKey,
	iv: Uint8Array,
) {
	const decrypted = await crypto.subtle.decrypt(
		{ name: "AES-GCM", iv },
		key,
		ciphertext,
	);

	return new TextDecoder().decode(decrypted);
}
```

## PBKDF2 Key Derivation

Deriving a strong cryptographic key from a password.

```ts
// Web Crypto PBKDF2
async function deriveKey(
	password: string,
	salt: Uint8Array,
): Promise<CryptoKey> {
	const baseKey = await crypto.subtle.importKey(
		"raw",
		new TextEncoder().encode(password),
		"PBKDF2",
		false,
		["deriveKey"],
	);

	return crypto.subtle.deriveKey(
		{
			name: "PBKDF2",
			salt,
			iterations: 100000,
			hash: "SHA-256",
		},
		baseKey,
		{ name: "AES-GCM", length: 256 },
		true,
		["encrypt", "decrypt"],
	);
}
```

## API Correspondence Table

| node:crypto                     | Web Crypto Alternative                      | Notes                                   |
| ------------------------------- | ------------------------------------------- | --------------------------------------- |
| `createHash(algo)`              | `crypto.subtle.digest(algo, data)`          | Algorithm must be uppercase ('SHA-256') |
| `createHmac(algo, key)`         | `subtle.importKey + subtle.sign('HMAC')`    | Web Crypto is strictly async            |
| `randomBytes(n)`                | `crypto.getRandomValues(new Uint8Array(n))` | Synchronous and native                  |
| `randomUUID()`                  | `crypto.randomUUID()`                       | Standard Web API                        |
| `pbkdf2Sync`                    | `subtle.deriveKey`                          | No sync version in Web Crypto           |
| `createCipheriv('aes-256-gcm')` | `subtle.encrypt({ name: 'AES-GCM' })`       | AES-GCM is the modern standard          |

## Best Practices

1. **Always use Async**: Web Crypto is asynchronous by design. Use `await` or `Promise` chains.
2. **Timing-Safe Comparison**: When comparing signatures, ensure you are not vulnerable to timing attacks (though string comparison in Workers is often optimized, specialized libraries like `jose` handle this better).
3. **Prefer Web Crypto**: It is faster and more secure in serverless environments than Pure JS polyfills.

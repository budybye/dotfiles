import { test } from "bun:test";
import { strict as A } from "node:assert";
import { mkdtempSync, mkdirSync, writeFileSync, closeSync, openSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// ponytail: bun:test, one test() per hook contract. Sections skip
// (test.skipIf) when the backing CLI (ax/graphify/jj/mise) is off PATH.
// Run: bun test home/private_dot_config/omp/profiles/god/agent/hooks/smoke.ts

declare const Bun: { which(name: string): string | null };

function fakePi() {
  const hs: Record<string, any[]> = {};
  return { hs, on: (e: string, h: any) => void (hs[e] ??= []).push(h) };
}
const call = async (hs: Record<string, any[]>, event: unknown, ctx: { cwd: string }) =>
  await hs["tool_call"][0](event, ctx);
const hook = async (path: string) => {
  const pi = fakePi();
  await import(path).then((m) => m.default(pi));
  return pi;
};

// Disjoint read-only fixtures; each test owns a fresh hook instance, so no
// shared mutable state and no order dependence (no process.chdir).
const root = mkdtempSync(join(tmpdir(), "omp-hooks-"));
mkdirSync(join(root, "graphify-out"));
writeFileSync(join(root, "graphify-out", "graph.json"), "{}");
closeSync(openSync(join(root, "a.ts"), "w"));
mkdirSync(join(root, "jj-repo", ".jj"), { recursive: true });
mkdirSync(join(root, "plain-repo"));
const ctx = { cwd: root };

// --- use-ax ---------------------------------------------------------------
const ax = test.skipIf(!Bun.which("ax"));

ax("use-ax: bare curl blocks with ax --help guidance", async () => {
  const pi = await hook("./pre/use-ax.ts");
  const r = await call(pi.hs, { toolName: "bash", input: { command: "curl https://example.com" } }, ctx);
  A.ok(r?.block, "bare curl blocks (no rewrite)");
  A.match(r.reason, /ax --help/);
});

ax("use-ax: piped curl and wget block instead of rewriting", async () => {
  const pi = await hook("./pre/use-ax.ts");
  const piped = await call(pi.hs, { toolName: "bash", input: { command: "curl -s https://example.com | jq ." } }, ctx);
  A.ok(piped?.block, "piped curl blocks");
  const wget = await call(pi.hs, { toolName: "bash", input: { command: "wget -qO- https://example.com" } }, ctx);
  A.ok(wget?.block, "wget blocks");
});

ax("use-ax: diagnostics and non-fetches pass through", async () => {
  const pi = await hook("./pre/use-ax.ts");
  const callBash = async (command: string) => await call(pi.hs, { toolName: "bash", input: { command } }, ctx);
  A.ok((await callBash("curl --version")) === undefined, "--version passes");
  A.ok((await callBash("node -v")) === undefined, "non-curl passes");
  A.ok((await callBash("man curl")) === undefined, "man pages pass");
  A.ok((await callBash("curl-config foo")) === undefined, "curl-* suffix passes");
});

// --- use-graph --------------------------------------------------------------
const gf = test.skipIf(!Bun.which("graphify"));
const grepf = (pi: ReturnType<typeof fakePi>, path?: string) =>
  call(pi.hs, { toolName: "grep", input: { pattern: "x", ...(path === undefined ? {} : { path }) } }, ctx);

gf("use-graph: first root grep blocks with graphify query guidance", async () => {
  const pi = await hook("./pre/use-graph.ts");
  const r = await grepf(pi);
  A.ok(r?.block, "root grep blocks");
  A.match(r.reason, /graphify --help/);
  A.match(r.reason, /graphify update/); // refresh guidance present
});

gf("use-graph: bash rg shares the nudge cap across tools", async () => {
  const pi = await hook("./pre/use-graph.ts");
  A.ok((await grepf(pi))?.block, "first root grep blocks");
  const rg = await call(pi.hs, { toolName: "bash", input: { command: "rg foo" } }, ctx);
  A.ok(rg?.block, "bash rg consumes a nudge (shared counter)");
  A.ok((await grepf(pi))?.block, "third nudge blocks");
  A.ok((await grepf(pi)) === undefined, "cap reached -> passes through");
});

gf("use-graph: path scope decides pass-through", async () => {
  const pi = await hook("./pre/use-graph.ts"); // fresh instance, cap untouched
  A.ok((await grepf(pi, "a.ts; ."))?.block, "multi-path with any broad entry blocks");
  A.ok((await grepf(pi, "a.ts; b.ts")) === undefined, "multi-path all-files passes through");
  A.ok((await grepf(pi, "a.ts")) === undefined, "single-file narrow passes through");
});

// --- use-jj -----------------------------------------------------------------
const jj = test.skipIf(!Bun.which("jj"));
const callIn = (pi: ReturnType<typeof fakePi>, cwd: string, command: string, inputCwd?: string) =>
  call(pi.hs, { toolName: "bash", input: { command, ...(inputCwd === undefined ? {} : { cwd: inputCwd }) } }, { cwd });

jj("use-jj: mutating git commands block in a jj workspace", async () => {
  const pi = await hook("./pre/use-jj.ts");
  const blocked = await callIn(pi, join(root, "jj-repo"), "git add -A && git commit -m x");
  A.ok(blocked?.block, "git commit blocks");
  A.match(blocked.reason, /jj --help/);
  A.match(blocked.reason, /colocated/); // mapping guidance present
  const push = await callIn(pi, join(root, "jj-repo"), "git -C elsewhere push");
  A.ok(push?.block, "git push with global flags blocks");
});

jj("use-jj: read-only git and jj-containing commands pass through", async () => {
  const pi = await hook("./pre/use-jj.ts");
  A.ok((await callIn(pi, join(root, "jj-repo"), "git log --oneline")) === undefined, "read-only git passes");
  A.ok((await callIn(pi, join(root, "jj-repo"), "git --no-pager log")) === undefined, "read-only git with flags passes");
  A.ok((await callIn(pi, join(root, "jj-repo"), "jj st && git diff")) === undefined, "jj-containing command passes");
});

jj("use-jj: non-jj workspaces are ignored", async () => {
  const pi = await hook("./pre/use-jj.ts");
  A.ok((await callIn(pi, join(root, "plain-repo"), "git add -A && git commit")) === undefined, "git commit outside jj workspace passes");
});

jj("use-jj: jj inside a commit message does not bypass the block", async () => {
  const pi = await hook("./pre/use-jj.ts");
  A.ok((await callIn(pi, join(root, "jj-repo"), "git commit -m 'fix jj bug'"))?.block, "message mentioning jj still blocks");
});

jj("use-jj: valueless global flags still detect mutators", async () => {
  const pi = await hook("./pre/use-jj.ts");
  A.ok((await callIn(pi, join(root, "jj-repo"), "git --no-pager commit -m x"))?.block, "git --no-pager commit blocks");
});

jj("use-jj: input.cwd resolves against the session cwd", async () => {
  const pi = await hook("./pre/use-jj.ts");
  A.ok(
    (await callIn(pi, join(root, "jj-repo"), "git add -A && git commit", join(root, "plain-repo"))) === undefined,
    "absolute input.cwd to non-jj workspace passes",
  );
  A.ok((await callIn(pi, join(root, "jj-repo"), "git add -A && git commit", "."))?.block, "relative input.cwd resolves against session cwd");
});

// --- use-mise ---------------------------------------------------------------
const ms = test.skipIf(!Bun.which("mise"));

ms("use-mise: global installs block with mise use guidance", async () => {
  const pi = await hook("./pre/use-mise.ts");
  const blocked = await call(pi.hs, { toolName: "bash", input: { command: "npm i -g left-pad" } }, ctx);
  A.ok(blocked?.block, "npm i -g blocks");
  A.match(blocked.reason, /mise --help/);
  A.match(blocked.reason, /mise use/); // mapping guidance present
});

ms("use-mise: project-local installs and unrelated commands pass through", async () => {
  const pi = await hook("./pre/use-mise.ts");
  const callBash = async (command: string) => await call(pi.hs, { toolName: "bash", input: { command } }, ctx);
  A.ok((await callBash("pip install -r requirements.txt")) === undefined, "project pip passes");
  A.ok((await callBash("node -v")) === undefined, "plain command passes");
});

ms("use-mise: package-manager flag boundaries avoid false blocks", async () => {
  const pi = await hook("./pre/use-mise.ts");
  const callBash = async (command: string) => await call(pi.hs, { toolName: "bash", input: { command } }, ctx);
  A.ok((await callBash("brew install --cask firefox")) === undefined, "--cask passes");
  A.ok((await callBash("npm install --global-style pkg")) === undefined, "--global-style passes");
  A.ok((await callBash("pnpm add --global-dir x")) === undefined, "--global-dir passes");
});

ms("use-mise: command-not-found failures get a mise hint appended", async () => {
  const pi = await hook("./pre/use-mise.ts");
  const result = pi.hs["tool_result"][0];
  const nf = await result({ toolName: "bash", isError: true, content: [{ type: "text", text: "zsh: command not found: foo" }] });
  A.strictEqual((nf.content as unknown[]).length, 2, "one hint chunk appended");
  A.match((nf.content as { type: string; text: string }[])[1].text, /mise/);
  A.ok((await result({ toolName: "bash", isError: false, content: [{ type: "text", text: "hello" }] })) === undefined, "success untouched");
  A.ok((await result({ toolName: "bash", isError: true, content: [{ type: "text", text: "exit 1" }] })) === undefined, "non-not-found error untouched");
});

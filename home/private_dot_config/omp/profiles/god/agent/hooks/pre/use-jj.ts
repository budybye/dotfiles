import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { helpReason } from "../lib/help.ts";

declare const Bun: { which(name: string): string | null };

// ponytail: blocks mutating git commands in jj-managed (colocated) workspaces;
// read-only git (log/diff/show/config) passes through. Name-based detection;
// exotic plumbing (worktree, am, apply) and `cd <other-repo> && git <mutator>`
// prefixes are not covered.
const MUTATORS =
  /(?:^|[\s;&|(])git\s+(?:-{1,2}[A-Za-z-]+(?:[ =]\S*)?\s+)*(?:add|commit|checkout|switch|restore|merge|rebase|cherry-pick|reset|revert|clean|push|pull|stash|bisect)\b/;

export default function (pi: ExtensionAPI): void {
  let jjPath: string | null | undefined;

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;
    const cmd = String(event.input.command ?? "");
    const cwd = event.input.cwd ? resolve(ctx.cwd, String(event.input.cwd)) : ctx.cwd; // input.cwd: absolute or relative to session cwd
    if (!MUTATORS.test(cmd)) return;
    if (/(?:^|[;&|(]|\n)\s*jj\b/.test(cmd)) return; // jj already used as a command; "jj" in messages/paths does not skip
    if (jjPath === undefined) jjPath = Bun.which("jj");
    if (!jjPath) return; // no jj -> git is the tool
    if (!existsSync(join(cwd, ".jj"))) return; // not a jj workspace

    return {
      block: true,
      reason: await helpReason(
        jjPath,
        "jj is the primary VCS here (colocated repo; git only for remotes/CI). jj has no index — the working copy IS the commit. git commit -> jj commit (or jj describe -m \"...\" then jj new); git push -> jj git push (--all or --change @); git pull -> jj git fetch; git checkout/switch <rev> -> jj new <rev> or jj edit <rev>; git restore <file> -> jj restore <file>; git stash -> unneeded: changes stay in @, jj new starts a fresh change. Read-only git (log/diff/status) is still allowed.",
      ),
    };
  });
}

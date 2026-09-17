import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { existsSync, statSync } from "node:fs";
import { join, resolve } from "node:path";
import { helpReason } from "../lib/help.ts";

declare const Bun: { which(name: string): string | null };

const MAX_NUDGES = 3;
const SHELL_GREP = /(?:^|[\s;&|(])(?:[./\w-]+\/)?(?:grep|rg|ripgrep)\b/;

export default function (pi: ExtensionAPI): void {
  let graphifyPath: string | null | undefined;
  let nudges = 0;

  pi.on("tool_call", async (event, ctx) => {
    if (nudges >= MAX_NUDGES) return;
    if (graphifyPath !== undefined && !graphifyPath) return;
    const cwd = event.input.cwd ? resolve(ctx.cwd, String(event.input.cwd)) : ctx.cwd; // input.cwd: absolute or relative to session cwd
    if (!existsSync(join(cwd, "graphify-out", "graph.json"))) return;

    if (event.toolName === "grep") {
      const raw = String(event.input.path ?? "").trim();
      const targets = raw === "" ? ["."] : raw.split(";").map((s) => s.trim()).filter(Boolean);
      const isDir = (p: string): boolean => {
        try {
          return statSync(p).isDirectory();
        } catch {
          return false;
        }
      };
      const broad = targets.some((t) => /[*?[{]/.test(t) || isDir(join(cwd, t)));
      if (!broad) return;
    } else if (event.toolName === "bash") {
      if (!SHELL_GREP.test(String(event.input.command ?? ""))) return;
    } else {
      return;
    }

    if (graphifyPath === undefined) graphifyPath = Bun.which("graphify");
    if (!graphifyPath) return; // no CLI to answer queries with -> let grep run

    nudges++;
    return {
      block: true,
      reason: await helpReason(
        graphifyPath,
        "A graphify index exists (./graphify-out/graph.json). For \"how does X work / what uses X / trace the flow\" questions use graphify query (add --dfs to trace), graphify path, graphify explain — not root-scope grep. After big refactors refresh with graphify update <path>. For exact-string symbol lookups re-run grep with a narrowed path (specific file or subdirectory).",
      ),
    };
  });
}

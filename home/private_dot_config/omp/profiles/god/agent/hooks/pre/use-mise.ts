import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { helpReason } from "../lib/help.ts";

declare const Bun: { which(name: string): string | null };

// ponytail: name-based installer detection; covers the common global installers.
const INSTALLERS =
  /\b(?:npm|pnpm|bun)\s+(?:install|add|i|a)\b[^|;&]*\s(?:-g|--global)(?=\s|$)|\byarn\s+global\s+add\b|\bbrew\s+(?:install|reinstall)\b|\bcargo\s+install\b|\bgem\s+install\b|\bpipx\s+install\b|\buv\s+tool\s+install\b|\bpip3?\s+install\b[^|;&]*\s--user\b/;
const NOT_FOUND_HINT =
  "[mise hint] run managed tools via `mise x <tool>@<version> -- <cmd>`, install via `mise use <tool>@<version>`, or use the mise MCP install_tool tool.";

export default function (pi: ExtensionAPI): void {
  let misePath: string | null | undefined;

  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return;
    const cmd = String(event.input.command ?? "");
    if (/\bmise\b/.test(cmd)) return; // already mise-managed
    if (misePath === undefined) misePath = Bun.which("mise");
    if (!misePath) return;
    // --cask is macOS-app territory; mise can't manage it -> let brew run.
    if (INSTALLERS.test(cmd) && !/\s--cask\b/.test(cmd)) {
      return {
        block: true,
        reason: await helpReason(
          misePath,
          "mise manages dev tools here: `mise use <tool>@<version>` installs/pins, `mise x <tool>@<version> -- <cmd>` runs ephemerally; the mise MCP tools (install_tool / run_task) are also available.",
        ),
      };
    }
  });

  pi.on("tool_result", async (event) => {
    if (event.toolName !== "bash" || !event.isError) return;
    if (misePath === undefined) misePath = Bun.which("mise");
    if (!misePath) return;
    const text = event.content.map((c) => (c.type === "text" ? c.text : "")).join("\n");
    if (!/command not found/i.test(text)) return;
    return { content: [...event.content, { type: "text", text: NOT_FOUND_HINT }] };
  });
}

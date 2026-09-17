import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { helpReason } from "../lib/help.ts";

declare const Bun: { which(name: string): string | null };

// Known limitation: in the god profile the context-mode omp plugin blocks
// curl/wget before hooks run; this hook is the fallback when that plugin is off.
const FETCHER = /(?:^|[\s;&|(])(?:[./\w-]+\/)?(?:curl|wget)(?=\s|$)/;

export default function (pi: ExtensionAPI): void {
  let axPath: string | null | undefined;

  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return;
    const cmd = String(event.input.command ?? "");
    if (!FETCHER.test(cmd)) return;
    if (/(?:^|\s)(?:--help|--version)\b|(?:^|\s)man\s/.test(cmd)) return; // diagnostics, not fetches

    if (axPath === undefined) axPath = Bun.which("ax");
    if (!axPath) return; // ax missing -> leave curl/wget alone

    return {
      block: true,
      reason: await helpReason(
        axPath,
        "ax replaces curl/wget for fetches. A bare `ax <url>` prints a {status,...,body} envelope (--text for the raw body, --md for docs as markdown); curl-style -H/-X/-d/-u/-o/-k/-m/-f work, -L/-i/-s are no-ops. Run ax alone, then consume the result deliberately — don't pipe its JSON envelope.",
      ),
    };
  });
}

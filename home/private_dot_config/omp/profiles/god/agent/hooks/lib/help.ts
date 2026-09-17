import { basename } from "node:path";

declare const Bun: { which(name: string): string | null };

// ponytail: block reasons show the CLI's real --help (ground truth, zero
// drift) with a short comment; capped so a man-page-style dump can't flood
// the model's context.
const CAP_LINES = 120;
const cache = new Map<string, string>();

async function capture(binPath: string): Promise<string> {
  try {
    const proc = Bun.spawn([binPath, "--help"], { stdout: "pipe", stderr: "pipe" });
    const kill = setTimeout(() => proc.kill(), 3000);
    const [out, err] = await Promise.all([
      new Response(proc.stdout).text(),
      new Response(proc.stderr).text(),
    ]);
    clearTimeout(kill);
    const lines = `${out}${err ? `\n${err}` : ""}`.trimEnd().split("\n");
    return lines.length > CAP_LINES
      ? `${lines.slice(0, CAP_LINES).join("\n")}\n... (${lines.length - CAP_LINES} more lines; full: ${basename(binPath)} --help)`
      : lines.join("\n");
  } catch {
    return `(could not capture ${basename(binPath)} --help)`;
  }
}

export async function helpReason(binPath: string, comment: string): Promise<string> {
  const label = basename(binPath);
  if (!cache.has(binPath)) cache.set(binPath, await capture(binPath));
  return `${comment}\n\n--- ${label} --help ---\n${cache.get(binPath)}`;
}

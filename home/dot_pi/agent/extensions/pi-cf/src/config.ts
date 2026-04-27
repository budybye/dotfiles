import { readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import type { Config } from "./types";

export const CONFIG_PATH = join(homedir(), ".pi", "cf-config.json");

export function loadConfig(): Partial<Config> {
  try {
    const raw = readFileSync(CONFIG_PATH, "utf8");
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

export function resolveConfigValue(
  jsonVal: string | undefined,
  fallbackEnv: string,
): string {
  const trimmed = jsonVal?.trim();
  if (trimmed) return process.env[trimmed] || trimmed;
  return process.env[fallbackEnv] || "";
}

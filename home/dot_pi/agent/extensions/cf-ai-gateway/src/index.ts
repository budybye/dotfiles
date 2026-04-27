/**
 * Cloudflare AI Gateway Extension for Pi
 *
 * Unified Billing + Zero Data Retention (ZDR) 対応
 * - モデルID形式: {provider}/{model-name}
 * - Provider名: "cf-ai-gateway"(Workers AIと区別)
 *
 * Workers AI (bneil/pi-cloudflare-workers-ai) との違い:
 * - Workers AI: @cf/meta/llama-3... などCloudflare固有モデル
 * - AI Gateway: OpenAI, Anthropic, Googleなどサードパーティモデル(Unified Billing)
 *
 * Docs:
 * - https://developers.cloudflare.com/ai-gateway/usage/chat-completion/
 * - https://developers.cloudflare.com/ai-gateway/features/unified-billing/
 * - https://developers.cloudflare.com/ai-gateway/features/zero-data-retention/
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const CONFIG_PATH = join(homedir(), ".pi", "cf-ai-gateway.json");

// ============================================
// Unified Billing対応モデル
// ============================================
// ZDR対応: OpenAI, Anthropic
// ZDR非対応: Google AI Studio

interface ModelDef {
  id: string;  // format: "openai/gpt-4o", "anthropic/claude-3-5-sonnet..."
  name: string;
  provider: "openai" | "anthropic" | "google";
  contextWindow: number;
  maxTokens: number;
  input: ("text" | "image")[];
  reasoning?: boolean;
  zdrSupported?: boolean;
  cost: {
    input: number;
    output: number;
    cacheRead?: number;
    cacheWrite?: number;
  };
  compat: {
    supportsDeveloperRole: boolean;
    maxTokensField: "max_tokens" | "max_completion_tokens";
    thinkingFormat?: "openai";
  };
}

const BUILT_IN_MODELS: ModelDef[] = [
  // OpenAI - ZDR対応 ✅
  // Docs: https://platform.openai.com/docs/models
  
  // 最上位: GPT-5.5 (2026-04-23)
  {
    id: "openai/gpt-5.5-2026-04-23",
    name: "GPT-5.5 (2026-04-23)",
    provider: "openai",
    contextWindow: 256000,
    maxTokens: 32768,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 100, output: 200, cacheRead: 50, cacheWrite: 100 },
    compat: { supportsDeveloperRole: true, maxTokensField: "max_tokens" },
  },
  // 上位: GPT-4.5 Preview
  {
    id: "openai/gpt-4.5-preview",
    name: "GPT-4.5 Preview",
    provider: "openai",
    contextWindow: 128000,
    maxTokens: 16384,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 75, output: 150, cacheRead: 37.5, cacheWrite: 75 },
    compat: { supportsDeveloperRole: true, maxTokensField: "max_tokens" },
  },
  // 中位: GPT-4o
  {
    id: "openai/gpt-4o",
    name: "GPT-4o",
    provider: "openai",
    contextWindow: 128000,
    maxTokens: 16384,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 2.5, output: 10, cacheRead: 1.25, cacheWrite: 5 },
    compat: { supportsDeveloperRole: true, maxTokensField: "max_tokens" },
  },
  // 軽量: GPT-5 Nano (2025-08-07)
  {
    id: "openai/gpt-5-nano-2025-08-07",
    name: "GPT-5 Nano (2025-08-07)",
    provider: "openai",
    contextWindow: 128000,
    maxTokens: 16384,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 1.0, output: 5.0, cacheRead: 0.5, cacheWrite: 1.0 },
    compat: { supportsDeveloperRole: true, maxTokensField: "max_tokens" },
  },

  // Anthropic - ZDR対応 ✅
  // Docs: https://docs.anthropic.com/en/docs/about-claude/models

  // 上位: Claude Opus 4-7
  {
    id: "anthropic/claude-opus-4-7",
    name: "Claude Opus 4-7",
    provider: "anthropic",
    contextWindow: 200000,
    maxTokens: 4096,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 15, output: 75 },
    compat: { supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  },

  // 中位: Claude Sonnet 4-6
  {
    id: "anthropic/claude-sonnet-4-6",
    name: "Claude Sonnet 4-6",
    provider: "anthropic",
    contextWindow: 200000,
    maxTokens: 8192,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 3, output: 15 },
    compat: { supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  },

  // 軽量: Claude 3.5 Haiku(2024-10-22)
  {
    id: "anthropic/claude-3-5-haiku-20241022",
    name: "Claude 3.5 Haiku (2024-10-22)",
    provider: "anthropic",
    contextWindow: 200000,
    maxTokens: 8192,
    input: ["text", "image"],
    zdrSupported: true,
    cost: { input: 0.8, output: 4 },
    compat: { supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  },

  // Google AI Studio - ZDR非対応 ⚠️
  // 上位: Gemini 2.5 Pro Preview(最新・最強)
  {
    id: "google/gemini-2.5-pro-preview-03-25",
    name: "Gemini 2.5 Pro",
    provider: "google",
    contextWindow: 1000000,
    maxTokens: 8192,
    input: ["text", "image"],
    zdrSupported: false,
    cost: { input: 1.25, output: 10 },
    compat: { supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  },
  // 中位: Gemini 2.0 Flash(高速・低コスト)
  {
    id: "google/gemini-2.0-flash",
    name: "Gemini 2.0 Flash",
    provider: "google",
    contextWindow: 1000000,
    maxTokens: 8192,
    input: ["text", "image"],
    zdrSupported: false,
    cost: { input: 0.1, output: 0.4 },
    compat: { supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  },
];

// ============================================
// 設定管理
// ============================================

interface Config {
  accountId: string;
  gatewayName: string;
  apiToken: string;
  zdrEnabled?: boolean;
  customModels?: ModelDef[];
  defaultHeaders?: Record<string, string>;
}

function loadConfig(): Partial<Config> {
  try {
    const raw = readFileSync(CONFIG_PATH, "utf8");
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

// pi 標準の resolve-config-value.ts と同じ規則:
//   - JSON 値が env 変数名と一致すればその値、なければリテラル扱い
//   - JSON が空なら fallback env 変数 (e.g. CF_API_TOKEN) を参照
function resolveConfigValue(jsonVal: string | undefined, fallbackEnv: string): string {
  const trimmed = jsonVal?.trim();
  if (trimmed) return process.env[trimmed] || trimmed;
  return process.env[fallbackEnv] || "";
}

// ============================================
// メインエクスポート
// ============================================

export default async function (pi: ExtensionAPI) {
  const cfg = loadConfig();
  const accountId = resolveConfigValue(cfg.accountId, "CF_ACCOUNT_ID");
  const gatewayName = resolveConfigValue(cfg.gatewayName, "CF_GATEWAY_NAME");
  const apiToken = resolveConfigValue(cfg.apiToken, "CF_API_TOKEN");

  // ============================================
  // セットアップコマンド
  // ============================================
  pi.registerCommand("cf-ai-setup", {
    description: "Configure Cloudflare AI Gateway (Unified Billing + ZDR)",
    handler: async (_args, ctx) => {
      const newAccountId = await ctx.ui.input("Cloudflare Account ID", accountId || "52b4505d...");
      if (newAccountId === undefined) return;

      const newGatewayName = await ctx.ui.input("AI Gateway name", gatewayName || "default");
      if (newGatewayName === undefined) return;

      const newApiToken = await ctx.ui.input("API token (AI Gateway:Read + AI Gateway:Edit)", apiToken || "cfut_...");
      if (newApiToken === undefined) return;

      const enableZdr = await ctx.ui.confirm(
        "Enable Zero Data Retention?",
        "ZDR routes traffic through provider endpoints that do not retain prompts or responses (OpenAI, Anthropic only)"
      );
      if (enableZdr === undefined) return;

      const config: Config = {
        accountId: newAccountId.trim(),
        gatewayName: newGatewayName.trim(),
        apiToken: newApiToken.trim(),
        zdrEnabled: enableZdr,
      };

      writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2) + "\n", "utf8");
      ctx.ui.notify(
        `✅ CF AI Gateway config saved\n` +
        `Provider: cf-ai-gateway\n` +
        `ZDR: ${enableZdr ? "enabled" : "disabled"}`,
        "info"
      );
      await ctx.reload();
    },
  });

  // ============================================
  // 設定不足チェック
  // ============================================
  if (!accountId || !gatewayName || !apiToken) {
    pi.on("session_start", (_event, ctx) => {
      ctx.ui.notify(
        "⚠️ CF AI Gateway: Run /cf-ai-setup to configure\n" +
        "Required: CF_API_TOKEN with AI Gateway permissions",
        "warning"
      );
    });
    return;
  }

  // ============================================
  // Unified Billingエンドポイント
  // ============================================
  const baseUrl = `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayName}`;
  const zdrEnabled = cfg.zdrEnabled ?? true;

  // モデルリスト構築
  const customModels = cfg.customModels ?? [];
  const modelMap = new Map(BUILT_IN_MODELS.map((m) => [m.id, m]));
  for (const custom of customModels) {
    modelMap.set(custom.id, custom);
  }
  const models = Array.from(modelMap.values());

  // ZDR対応モデルのみフィルタ(ZDR有効時)
  const zdrModels = zdrEnabled
    ? models.filter((m) => m.zdrSupported !== false)
    : models;

  // ============================================
  // Provider登録 - /compat エンドポイント
  // ============================================
  // Unified Chat API が403エラーになる場合は /compat を使用
  // モデルID: "openai/gpt-4o", "anthropic/claude-sonnet-4-5" (providerプレフィックス付き)
  pi.registerProvider("cf-ai-gateway", {
    baseUrl: `${baseUrl}/compat`,
    apiKey: apiToken,
    api: "openai-completions",
    headers: {
      ...(zdrEnabled && { "cf-aig-zdr": "true" }),
      ...(cfg.defaultHeaders?.["cf-aig-cache-ttl"] && {
        "cf-aig-cache-ttl": cfg.defaultHeaders["cf-aig-cache-ttl"],
      }),
      ...(cfg.defaultHeaders?.["cf-aig-skip-cache"] && {
        "cf-aig-skip-cache": cfg.defaultHeaders["cf-aig-skip-cache"],
      }),
    },
    models: zdrModels.map((m) => ({
      id: m.id,
      name: `${m.name} ${m.zdrSupported ? "🔒" : "⚠️"}`,
      reasoning: m.reasoning ?? false,
      input: m.input,
      cost: {
        input: m.cost.input,
        output: m.cost.output,
        cacheRead: m.cost.cacheRead ?? 0,
        cacheWrite: m.cost.cacheWrite ?? 0,
      },
      contextWindow: m.contextWindow,
      maxTokens: m.maxTokens,
      compat: m.compat,
    })),
  });

  // ============================================
  // 起動通知
  // ============================================
  pi.on("session_start", (_event, ctx) => {
    const zdrCount = zdrModels.filter((m) => m.zdrSupported).length;
    const nonZdrCount = zdrModels.filter((m) => !m.zdrSupported).length;

    ctx.ui.notify(
      `🚀 CF AI Gateway (${gatewayName})\n` +
      `Endpoint: /compat (Unified Billing + ${zdrEnabled ? "ZDR" : "no ZDR"})\n` +
      `${zdrModels.length} models (${zdrCount}🔒 ${nonZdrCount}⚠️)`,
      "info"
    );

    if (zdrEnabled && nonZdrCount > 0) {
      ctx.ui.notify(
        `⚠️ Non-ZDR: ${zdrModels
          .filter((m) => !m.zdrSupported)
          .map((m) => m.id)
          .join(", ")}`,
        "warning"
      );
    }
  });

  // ============================================
  // コマンド登録
  // ============================================

  // モデル一覧
  pi.registerCommand("cf-ai-models", {
    description: "List available AI Gateway models (ZDR status)",
    handler: async (_args, ctx) => {
      const byProvider = zdrModels.reduce((acc, m) => {
        acc[m.provider] = acc[m.provider] || [];
        acc[m.provider].push(`  ${m.zdrSupported ? "🔒" : "⚠️"} ${m.name}: ${m.id}`);
        return acc;
      }, {} as Record<string, string[]>);

      ctx.ui.notify(
        `AI Gateway Models (${zdrModels.length} total):\n\n` +
        Object.entries(byProvider)
          .map(([provider, ms]) => `[${provider}]\n${ms.join("\n")}`)
          .join("\n\n"),
        "info"
      );
    },
  });

  // ステータス確認
  pi.registerCommand("cf-ai-status", {
    description: "Check AI Gateway configuration",
    handler: async (_args, ctx) => {
      ctx.ui.notify(
        `CF AI Gateway Status\n` +
        `====================\n` +
        `Provider: cf-ai-gateway\n` +
        `Account: ${accountId.slice(0, 12)}...\n` +
        `Gateway: ${gatewayName}\n` +
        `ZDR: ${zdrEnabled ? "✅ enabled" : "❌ disabled"}\n` +
        `Models: ${zdrModels.length}`,
        "info"
      );
    },
  });

  // ZDR切り替え
  pi.registerCommand("cf-ai-zdr", {
    description: "Toggle Zero Data Retention",
    handler: async (_args, ctx) => {
      const newZdr = !zdrEnabled;
      const updatedConfig: Config = {
        ...cfg,
        accountId,
        gatewayName,
        apiToken,
        zdrEnabled: newZdr,
      };

      writeFileSync(CONFIG_PATH, JSON.stringify(updatedConfig, null, 2) + "\n", "utf8");

      ctx.ui.notify(
        `ZDR ${newZdr ? "enabled" : "disabled"}\nRestart Pi to apply`,
        newZdr ? "info" : "warning"
      );
    },
  });
}

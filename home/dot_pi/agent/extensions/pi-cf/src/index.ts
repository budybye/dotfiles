/**
 * Cloudflare AI Gateway & Workers AI Extension for Pi
 *
 * 2 つのプロバイダーを AI Gateway 経由で登録:
 *   - "cf-ai-gateway": Unified Billing + ZDR (OpenAI / Anthropic / Google)
 *     モデルID: {provider}/{model-name}
 *   - "cloudflare-ai":  Workers AI (@cf/...)
 *     モデルID: @cf/{org}/{model}  ※ZDR 非対応
 *
 * Docs:
 * - https://developers.cloudflare.com/ai-gateway/usage/chat-completion/
 * - https://developers.cloudflare.com/ai-gateway/providers/workers-ai/
 * - https://developers.cloudflare.com/ai-gateway/features/unified-billing/
 * - https://developers.cloudflare.com/ai-gateway/features/zero-data-retention/
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { writeFileSync } from "node:fs";
import { CONFIG_PATH, loadConfig, resolveConfigValue } from "./config";
import { BUILT_IN_MODELS, BUILT_IN_WORKERS_AI_MODELS } from "./models";
import type { Config, WorkersAiModelDef } from "./types";

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
      const newAccountId = await ctx.ui.input(
        "Cloudflare Account ID",
        accountId || "52b4505d...",
      );
      if (newAccountId === undefined) return;

      const newGatewayName = await ctx.ui.input(
        "AI Gateway name",
        gatewayName || "default",
      );
      if (newGatewayName === undefined) return;

      const newApiToken = await ctx.ui.input(
        "API token (AI Gateway:Read + AI Gateway:Edit)",
        apiToken || "cfut_...",
      );
      if (newApiToken === undefined) return;

      const enableZdr = await ctx.ui.confirm(
        "Enable Zero Data Retention?",
        "ZDR routes traffic through provider endpoints that do not retain prompts or responses (OpenAI, Anthropic only)",
      );
      if (enableZdr === undefined) return;

      const enableWorkersAi = await ctx.ui.confirm(
        "Enable Cloudflare Workers AI?",
        "Registers a second provider (cloudflare-ai) routing Workers AI models through the same AI Gateway.",
      );
      if (enableWorkersAi === undefined) return;

      const config: Config = {
        accountId: newAccountId.trim(),
        gatewayName: newGatewayName.trim(),
        apiToken: newApiToken.trim(),
        zdrEnabled: enableZdr,
        ...(cfg.customModels && { customModels: cfg.customModels }),
        ...(cfg.defaultHeaders && { defaultHeaders: cfg.defaultHeaders }),
        workersAi: {
          enabled: enableWorkersAi,
          ...(cfg.workersAi?.customModels && {
            customModels: cfg.workersAi.customModels,
          }),
        },
      };

      writeFileSync(
        CONFIG_PATH,
        JSON.stringify(config, null, 2) + "\n",
        "utf8",
      );
      ctx.ui.notify(
        `✅ CF AI Gateway config saved\n` +
          `Provider: cf-ai-gateway\n` +
          `ZDR: ${enableZdr ? "enabled" : "disabled"}\n` +
          `Workers AI: ${enableWorkersAi ? "enabled" : "disabled"}`,
        "info",
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
        "warning",
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

  // 両プロバイダー共通の AI Gateway キャッシュ系ヘッダー
  const cacheHeaders: Record<string, string> = {};
  for (const key of ["cf-aig-cache-ttl", "cf-aig-skip-cache"] as const) {
    const v = cfg.defaultHeaders?.[key];
    if (v) cacheHeaders[key] = v;
  }

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
      ...cacheHeaders,
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
  // Provider登録 - Workers AI (/workers-ai/v1)
  // ============================================
  // ZDR は Workers AI 非対応のため cf-aig-zdr ヘッダは送らない
  // モデルID: "@cf/moonshotai/kimi-k2.6" など
  const workersAiCfg = cfg.workersAi;
  const workersAiEnabled =
    workersAiCfg !== undefined && (workersAiCfg.enabled ?? true);
  let workersAiModels: WorkersAiModelDef[] = [];

  if (workersAiEnabled) {
    const waMap = new Map(BUILT_IN_WORKERS_AI_MODELS.map((m) => [m.id, m]));
    for (const c of workersAiCfg?.customModels ?? []) waMap.set(c.id, c);
    workersAiModels = Array.from(waMap.values());

    pi.registerProvider("cloudflare-ai", {
      baseUrl: `${baseUrl}/workers-ai/v1`,
      apiKey: apiToken,
      api: "openai-completions",
      headers: { ...cacheHeaders },
      models: workersAiModels.map((m) => ({
        id: m.id,
        name: m.name,
        reasoning: m.reasoning ?? false,
        input: m.input,
        cost: {
          input: m.cost.input,
          output: m.cost.output,
          cacheRead: 0,
          cacheWrite: 0,
        },
        contextWindow: m.contextWindow,
        maxTokens: m.maxTokens,
        compat: m.compat,
      })),
    });
  }

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
      "info",
    );

    if (zdrEnabled && nonZdrCount > 0) {
      ctx.ui.notify(
        `⚠️ Non-ZDR: ${zdrModels
          .filter((m) => !m.zdrSupported)
          .map((m) => m.id)
          .join(", ")}`,
        "warning",
      );
    }

    if (workersAiEnabled) {
      ctx.ui.notify(
        `🧠 Workers AI: ${workersAiModels.length} models via cloudflare-ai`,
        "info",
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
      const fmtCost = (i: number, o: number) => `In:$${i}/Out:$${o}`;
      const byProvider = zdrModels.reduce(
        (acc, m) => {
          acc[m.provider] = acc[m.provider] || [];
          acc[m.provider].push(
            `  ${m.zdrSupported ? "🔒" : "⚠️"} ${m.name}: ${m.id} (${fmtCost(m.cost.input, m.cost.output)})`,
          );
          return acc;
        },
        {} as Record<string, string[]>,
      );

      let body =
        `AI Gateway Models (${zdrModels.length} total):\n\n` +
        Object.entries(byProvider)
          .map(([provider, ms]) => `[${provider}]\n${ms.join("\n")}`)
          .join("\n\n");

      if (workersAiEnabled && workersAiModels.length > 0) {
        body +=
          `\n\nCloudflare Workers AI (${workersAiModels.length} total):\n` +
          workersAiModels
            .map(
              (m) =>
                `  🧠 ${m.name}: ${m.id} (${fmtCost(m.cost.input, m.cost.output)})`,
            )
            .join("\n");
      }

      ctx.ui.notify(body, "info");
    },
  });

  // ステータス確認
  pi.registerCommand("cf-ai-status", {
    description: "Check AI Gateway configuration",
    handler: async (_args, ctx) => {
      const lines = [
        `CF AI Gateway Status`,
        `====================`,
        `Account: ${accountId.slice(0, 12)}...`,
        `Gateway: ${gatewayName}`,
        ``,
        `[cf-ai-gateway] ${baseUrl}/compat`,
        `  ZDR: ${zdrEnabled ? "✅ enabled" : "❌ disabled"}`,
        `  Models: ${zdrModels.length}`,
        ``,
        workersAiEnabled
          ? `[cloudflare-ai] ${baseUrl}/workers-ai/v1\n  Models: ${workersAiModels.length}`
          : `[cloudflare-ai] ❌ disabled (set workersAi.enabled = true)`,
      ];
      ctx.ui.notify(lines.join("\n"), "info");
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

      writeFileSync(
        CONFIG_PATH,
        JSON.stringify(updatedConfig, null, 2) + "\n",
        "utf8",
      );

      ctx.ui.notify(
        `ZDR ${newZdr ? "enabled" : "disabled"}\nRestart Pi to apply`,
        newZdr ? "info" : "warning",
      );
    },
  });
}

# Cloudflare AI Gateway Extension (Unified Billing + ZDR)

AI Gateway経由で OpenAI、Anthropic、Google AI Studio のモデルを **Unified Billing** で使用する Pi 拡張。

**Workers AI (`cloudflare-ai`) との違い**: この拡張はサードパーティモデル（GPT-4o、Claude など）用。Workers AI は `@cf/meta/llama-3...` など Cloudflare ホストモデル専用。

## 特徴

- ✅ **Unified Billing対応** — Provider API Key 不要、Cloudflare Credits で支払い
- ✅ **Zero Data Retention (ZDR)** — OpenAI/Anthropic でデータ保持なし（オプション）
- ✅ ** Workers AI と区別** — `cf-ai-gateway/` プレフィックスで識別
- ✅ **各プロバイダー 2 モデル** — シンプルかつ実用的な選択肢

## インストール

```bash
cp -r cf-ai-gateway ~/.pi/agent/extensions/
```

## クイックスタート

### 1. 事前準備（Dashboard）

[dash.cloudflare.com](https://dash.cloudflare.com) で以下を実施：

1. **Credits 購入** — AI Gateway → Credits Available → Top-up
2. **Providers 有効化** — Settings → Providers → OpenAI/Anthropic/Google を Unified Billing モードに
3. **API Token 作成** — Profile → API Tokens → `AI Gateway:Read` + `AI Gateway:Edit` 権限

### 2. セットアップ

```
/cf-ai-setup
```

入力項目：
- **Account ID** — Dashboard 右サイドバー
- **Gateway name** — 作成したゲートウェイ名（default など）
- **API Token** — 上記で作成したトークン
- **ZDR enabled** — Zero Data Retention 有無

### 3. モデル選択

```
Ctrl+P
```

利用可能モデル（上位🔥 / 中位⚖️ / ZDR対応🔒 / 非対応⚠️）：

| Provider | ランク | モデルID | ZDR |
|----------|--------|---------|-----|
| OpenAI | 🚀最上位 | `cf-ai-gateway/openai/gpt-5.5-2026-04-23` | ✅🔒 |
| OpenAI | 🔥上位 | `cf-ai-gateway/openai/gpt-4.5-preview` | ✅🔒 |
| OpenAI | ⚖️中位 | `cf-ai-gateway/openai/gpt-4o` | ✅🔒 |
| OpenAI | ⚡軽量 | `cf-ai-gateway/openai/gpt-5-nano-2025-08-07` | ✅🔒 |
| Anthropic | 🔥上位 | `cf-ai-gateway/anthropic/claude-opus-4-7` | ✅🔒 |
| Anthropic | ⚖️中位 | `cf-ai-gateway/anthropic/claude-sonnet-4-6` | ✅🔒 |
| Anthropic | ⚡軽量 | `cf-ai-gateway/anthropic/claude-3-5-haiku-20241022` | ✅🔒 |
| Google | 🔥上位 | `cf-ai-gateway/google/gemini-2.5-pro-preview-03-25` | ❌⚠️ |
| Google | ⚖️中位 | `cf-ai-gateway/google/gemini-2.0-flash` | ❌⚠️ |

### 4. 利用開始

通常通りチャット開始。リクエストは AI Gateway → 各プロバイダーへルーティングされる。

## Zero Data Retention (ZDR)

### 概要

ZDR を有効にすると、リクエスト/レスポンスが **プロバイダーに保持されない** エンドポイント経由で送信される。

### ZDR 対応状況

| Provider | ZDR | 備考 |
|----------|-----|------|
| OpenAI | ✅ | 完全対応 |
| Anthropic | ✅ | 完全対応 |
| Google AI Studio | ❌ | **ZDR 非対応**（データ保持あり） |

### ZDR の有効/無効切り替え

```
/cf-ai-zdr
```

設定変更後は **Pi の再起動が必要**。

### 重要: ZDR の限界

ZDR は **プロバイダー側のデータ保持**を防ぐもの。Cloudflare AI Gateway 側のログは別途設定：

- Dashboard → AI Gateway → [gateway] → Settings → **Logging**
- ログを無効にしない限り、Cloudflare はリクエスト/レスポンスを保持

## 組み込みモデル詳細

| モデルID | ランク | コンテキスト | 最大トークン | 入力 | コスト/1M tokens | ZDR |
|---------|--------|-------------|-------------|------|-----------------|-----|
| **OpenAI** |
| `openai/gpt-5.5-2026-04-23` | 🚀最上位 | 256K | 32,768 | テキスト, 画像 | In: $100.00, Out: $200.00 | ✅ |
| `openai/gpt-4.5-preview` | 🔥上位 | 128K | 16,384 | テキスト, 画像 | In: $75.00, Out: $150.00 | ✅ |
| `openai/gpt-4o` | ⚖️中位 | 128K | 16,384 | テキスト, 画像 | In: $2.50, Out: $10.00 | ✅ |
| `openai/gpt-5-nano-2025-08-07` | ⚡軽量 | 128K | 16,384 | テキスト, 画像 | In: $1.00, Out: $5.00 | ✅ |
| **Anthropic** |
| `anthropic/claude-opus-4-7` | 🔥上位 | 200K | 4,096 | テキスト, 画像 | In: $15.00, Out: $75.00 | ✅ |
| `anthropic/claude-sonnet-4-6` | ⚖️中位 | 200K | 8,192 | テキスト, 画像 | In: $3.00, Out: $15.00 | ✅ |
| `anthropic/claude-3-5-haiku-20241022` | ⚡軽量 | 200K | 8,192 | テキスト, 画像 | In: $0.80, Out: $4.00 | ✅ |
| **Google** |
| `google/gemini-2.5-pro-preview-03-25` | 🔥上位 | 1M | 8,192 | テキスト, 画像 | In: $1.25, Out: $10.00 | ❌ |
| `google/gemini-2.0-flash` | ⚖️中位 | 1M | 8,192 | テキスト, 画像 | In: $0.10, Out: $0.40 | ❌ |

### モデル選択の指針

| 用途 | 推奨モデル | 理由 |
|------|-----------|------|
| **最高性能が必要** | `gpt-4.5-preview` または `claude-opus-4` | 複雑な推論・創作・コーディングで最強 |
| **コストパフォーマンス** | `gpt-4o` または `claude-sonnet-4-5` | 高品質を維持しながら比較的低コスト |
| **超長文処理** | `gemini-2.5-pro` | 1Mトークンコンテキストで最長 |
| **低コスト・高速** | `gemini-2.0-flash` | 価格性能比が最高 |
| **プライバシー重視** | OpenAI/Anthropicモデル（🔒マーク） | ZDRでプロバイダーにデータ保持されない |

## 設定ファイル

### `~/.pi/cf-ai-gateway.json`

拡張本体（`~/.pi/agent/extensions/cf-ai-gateway/`）には設定ファイルを置かず、`~/.pi/cf-ai-gateway.json` を読みにいく。これにより拡張ディレクトリは秘匿情報を含まずそのまま配布できる（`~/.pi/cloudflare-models.json` と同じ流儀）。

```json
{
  "accountId": "52b4505d...",
  "gatewayName": "default",
  "apiToken": "cfut_...",
  "zdrEnabled": true,
  "defaultHeaders": {
    "cf-aig-cache-ttl": "3600"
  }
}
```

| 項目 | 説明 |
|------|------|
| `accountId` | Cloudflare Account ID |
| `gatewayName` | AI Gateway 名（slug） |
| `apiToken` | Cloudflare API Token |
| `zdrEnabled` | Zero Data Retention デフォルト設定 |
| `defaultHeaders` | `cf-aig-*` ヘッダーでキャッシュ等制御 |

### デフォルト値と優先順位

設定値の解決規則は **pi 本体の [`resolveConfigValue`](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/src/core/resolve-config-value.ts) と揃えてある**：

1. JSON 値が **環境変数名と一致** → その env 値を採用（例: `"apiToken": "CF_API_TOKEN"`）
2. JSON 値が env に無ければ **リテラルとして採用**（例: `"apiToken": "cfut_xxx..."`）
3. JSON が空なら **fallback env 変数**（`CF_ACCOUNT_ID` 等）を参照
4. 全て空なら 起動時に警告

| 項目 | 環境変数 | 組み込みデフォルト | 必須 |
|------|---------|-------------------|------|
| `accountId` | `CF_ACCOUNT_ID` | — | ✅ |
| `gatewayName` | `CF_GATEWAY_NAME` | `default` | — |
| `apiToken` | `CF_API_TOKEN` | — | ✅ |
| `zdrEnabled` | — | `true` | — |
| `defaultHeaders` | — | `{}` | — |

**env 名で間接参照する config.json**（推奨：秘匿値を JSON に書かない）：
```json
{
  "accountId": "CF_ACCOUNT_ID",
  "gatewayName": "default",
  "apiToken": "CF_API_TOKEN",
  "zdrEnabled": true
}
```

**最小限の config.json**（fallback env のみで動かす）：
```json
{
  "zdrEnabled": true
}
```

**環境変数のみ**（一時的な利用など）：
```bash
export CF_ACCOUNT_ID="your-account-id"
export CF_API_TOKEN="your-token"
# gatewayName は default が使用される
```

### 環境変数

| 変数 | 用途 | config.json との関係 |
|------|------|---------------------|
| `CF_ACCOUNT_ID` | Cloudflare Account ID | config.json の `accountId` が空の場合に使用 |
| `CF_GATEWAY_NAME` | AI Gateway 名（slug） | config.json の `gatewayName` が空の場合に使用 |
| `CF_API_TOKEN` | API Token | config.json の `apiToken` が空の場合に使用 |

**推奨**: セキュリティのため、`CF_API_TOKEN` は環境変数に設定し、config.json には保存しない運用も可能。

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `/cf-ai-setup` | 対話的設定ウィザード |
| `/cf-ai-models` | 利用可能モデル一覧（ZDR ステータス付き） |
| `/cf-ai-status` | 現在の設定確認 |
| `/cf-ai-zdr` | ZDR 有効/無効切り替え |
| `/model` | Pi 標準のモデル切り替え |

## Workers AI との違い

Pi には 2 つの Cloudflare 関連プロバイダーがある：

| プロバイダー | 拡張 | 用途 | モデル例 |
|------------|------|------|---------|
| `cloudflare-ai` | `bneil/pi-cloudflare-workers-ai` | Workers AI モデル | `@cf/meta/llama-3.1-8b`, `@cf/mistral/mistral-7b` |
| `cf-ai-gateway` | この拡張 | サードパーティモデル（Unified Billing） | `openai/gpt-4o`, `anthropic/claude-sonnet-4-5` |

両方を同時に使用可能。

## トラブルシューティング

| エラー | 原因 | 対処 |
|-------|------|------|
| `401 Unauthorized` | API Token 無効または権限不足 | `AI Gateway:Read` + `AI Gateway:Edit` 権限を確認 |
| `403 Feature not enabled` | Unified Billing 未設定 / Credits 不足 | Dashboard で Credits 購入、Providers を Unified Billing に設定 |
| `404 Not Found` | Gateway 名が存在しない | 正しい gateway slug を確認 |
| `Invalid provider` | モデルID が不正 | `provider/model-name` 形式か確認 |
| モデルが表示されない | Extension 競合 | `cf-ai-gateway` が正しく読み込まれているか確認 |

### デバッグ

```bash
# API 直接テスト（Unified Billing）
curl -X POST "https://gateway.ai.cloudflare.com/v1/$CF_ACCOUNT_ID/$GATEWAY/compat/chat/completions" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "cf-aig-zdr: true" \
  -d '{"model":"anthropic/claude-sonnet-4-5","messages":[{"role":"user","content":"hi"}]}'
```

## 参考資料

- [Cloudflare AI Gateway Overview](https://developers.cloudflare.com/ai-gateway/)
- [Chat Completions API](https://developers.cloudflare.com/ai-gateway/usage/chat-completion/)
- [Unified Billing](https://developers.cloudflare.com/ai-gateway/features/unified-billing/)
- [Zero Data Retention](https://developers.cloudflare.com/ai-gateway/features/zero-data-retention/)
- [Provider-specific Endpoints](https://developers.cloudflare.com/ai-gateway/usage/providers/)
- [API Reference](https://developers.cloudflare.com/api/resources/ai_gateway/)

## 実装メモ

- エンドポイント: `{baseUrl}/compat`（Unified API `/chat/completions` は一部環境で 403）
- 認証: `Authorization: Bearer {CF_API_TOKEN}`（Provider API Key は不要）
- モデルID: `{provider}/{model-name}` 形式（例: `anthropic/claude-sonnet-4-5`）
- ZDR: `cf-aig-zdr: true` ヘッダーでリクエスト単位制御可能

## ライセンス

MIT

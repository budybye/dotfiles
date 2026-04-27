# Cloudflare AI Gateway Extension (Unified Billing + ZDR + Workers AI)

## 目次
- [概要](#概要)
- [インストール](#インストール)
- [セットアップ手順](#セットアップ手順)
- [モデル一覧 & 選択指針](#モデル一覧--選択指針)
- [設定ファイル詳細](#設定ファイル詳細)
- [環境変数対応表](#環境変数対応表)
- [コマンド一覧](#コマンド一覧)
- [Workers AI 追加情報](#workers-ai-追加情報)
- [移行ガイド](#移行ガイド)
- [トラブルシューティング](#トラブルシューティング)
- [参考資料](#参考資料)
- [実装メモ & ライセンス](#実装メモ---ライセンス)

---

## 概要

AI Gateway 経由で 2 つのプロバイダーを登録する Pi 拡張です。
- **`cf-ai-gateway`** – OpenAI / Anthropic / Google を **Unified Billing + ZDR** で使用
- **`cloudflare-ai`** – Cloudflare **Workers AI**（`@cf/...`）を AI Gateway 経由で使用

`bneil/pi-cloudflare-workers-ai` は本拡張に統合されたため不要です。

## 特徴

- ✅ **Unified Billing** – Provider API Key 不要、Cloudflare Credits で支払い
- ✅ **Zero Data Retention (ZDR)** – OpenAI/Anthropic でデータ保持なし（オプション）
- ✅ **Workers AI と区別** – `cf-ai-gateway/` プレフィックスで識別
- ✅ **主要モデルを厳選して同梱** – そのまま実用投入できる構成

## インストール

```bash
cp -r pi-cf ~/.pi/agent/extensions/
```

## セットアップ手順

### 1. 事前準備（Dashboard）

1. **Credits 購入** – AI Gateway → Credits Available → Top‑up
2. **Providers 有効化** – Settings → Providers → OpenAI/Anthropic/Google を Unified Billing に設定
3. **API Token 作成** – Profile → API Tokens → `AI Gateway:Read` + `AI Gateway:Edit` 権限付与

### 2. 設定ウィザード

```
/cf-ai-setup
```

入力項目:
- **Account ID** – Dashboard 右サイドバー
- **Gateway name** – 作成したゲートウェイ名（デフォルトは `default`）
- **API Token** – 前項で作成したトークン
- **ZDR enabled** – Zero Data Retention の有無

### 3. モデル選択

```
Ctrl+P
```

利用可能モデル（上位🔥 / 中位⚖️ / ZDR 対応🔒 / 非対応⚠️）を以下にまとめています。

### 4. 利用開始

通常通りチャット開始。リクエストは AI Gateway → 各プロバイダーへルーティングされます。

---

## Zero Data Retention (ZDR)

### 概要
ZDR を有効にすると、リクエスト/レスポンスが **プロバイダーに保持されない** エンドポイント経由で送信されます。

### 対応状況
| Provider | ZDR | 備考 |
|----------|-----|------|
| OpenAI | ✅ | 完全対応 |
| Anthropic | ✅ | 完全対応 |
| Google AI Studio | ❌ | **ZDR 非対応**（データ保持あり） |

### 切り替えコマンド
```
/cf-ai-zdr
```
設定変更後は **Pi の再起動** が必要です。

### 注意点
ZDR は **プロバイダー側のデータ保持** を防ぐだけです。Cloudflare 側のログは別途設定します:
- Dashboard → AI Gateway → `[gateway]` → Settings → **Logging**
- ログを無効にしない限り、Cloudflare はリクエスト/レスポンスを保持します。

---

## モデル一覧 & 選択指針

### モデル一覧
| Provider | ランク | モデルID | ZDR |
|----------|--------|---------|-----|
| OpenAI | 🚀最上位 | `cf-ai-gateway/openai/gpt-5.5-2026-04-23` | ✅ |
| OpenAI | 🔥上位 | `cf-ai-gateway/openai/gpt-4.5-preview` | ✅ |
| OpenAI | ⚖️中位 | `cf-ai-gateway/openai/gpt-4o` | ✅ |
| OpenAI | ⚡軽量 | `cf-ai-gateway/openai/gpt-5-nano-2025-08-07` | ✅ |
| Anthropic | 🔥上位 | `cf-ai-gateway/anthropic/claude-opus-4-7` | ✅ |
| Anthropic | ⚖️中位 | `cf-ai-gateway/anthropic/claude-sonnet-4-6` | ✅ |
| Anthropic | ⚡軽量 | `cf-ai-gateway/anthropic/claude-3-5-haiku-20241022` | ✅ |
| Google | 🔥上位 | `cf-ai-gateway/google/gemini-2.5-pro-preview-03-25` | ❌ |
| Google | ⚖️中位 | `cf-ai-gateway/google/gemini-2.0-flash` | ❌ |

### 選択指針
| 用途 | 推奨モデル | 理由 |
|------|-----------|------|
| 最高性能 | `gpt-5.5-2026-04-23` または `claude-opus-4-7` | 複雑な推論・創作・コーディングで最強 |
| コストパフォーマンス | `gpt-4o` または `claude-sonnet-4-6` | 高品質を維持しつつ低コスト |
| 超長文処理 | `gemini-2.5-pro-preview-03-25` | 1M トークンコンテキスト |
| 低コスト・高速 | `gemini-2.0-flash` | 価格性能比最高 |
| プライバシー重視 | OpenAI/Anthropic（🔒） | ZDR でデータ保持なし |

---

## 設定ファイル詳細

### `~/.pi/cf-config.json`
設定は拡張ディレクトリ外に置くことで、**秘匿情報が配布に混ざらない** 設計です。
```json
{
  "accountId": "52b4505d...",
  "gatewayName": "default",
  "apiToken": "cfut_...",
  "zdrEnabled": true,
  "defaultHeaders": { "cf-aig-cache-ttl": "3600" }
}
```
| 項目 | 説明 |
|------|------|
| `accountId` | Cloudflare Account ID |
| `gatewayName` | AI Gateway 名（slug） |
| `apiToken` | Cloudflare API Token |
| `zdrEnabled` | Zero Data Retention デフォルト |
| `defaultHeaders` | `cf-aig-*` ヘッダーでキャッシュ等制御 |

### デフォルト値と優先順位（`resolveConfigValue` 参照）
1. JSON の値が環境変数名と一致 → その env を使用（例: `"apiToken": "CF_API_TOKEN"`）
2. env が無ければリテラル採用
3. JSON が空なら fallback env（`CF_ACCOUNT_ID` 等）
4. すべて空なら起動時に警告

| 項目 | 環境変数 | デフォルト | 必須 |
|------|----------|-----------|------|
| `accountId` | `CF_ACCOUNT_ID` | — | ✅ |
| `gatewayName` | `CF_GATEWAY_NAME` | `default` | — |
| `apiToken` | `CF_API_TOKEN` | — | ✅ |
| `zdrEnabled` | — | `true` | — |
| `defaultHeaders` | — | `{}` | — |
| `workersAi.enabled` | — | `true`（ブロック存在時） | — |
| `workersAi.customModels` | — | `[]` | — |

**推奨**: 秘匿情報は環境変数経由で提供し、`config.json` にはプレースホルダーだけ残す。
```json
{
  "accountId": "CF_ACCOUNT_ID",
  "gatewayName": "default",
  "apiToken": "CF_API_TOKEN",
  "zdrEnabled": true
}
```

### 環境変数対応表
| 変数 | 用途 | config.json との関係 |
|------|------|---------------------|
| `CF_ACCOUNT_ID` | Cloudflare Account ID | `accountId` が空時に使用 |
| `CF_GATEWAY_NAME` | AI Gateway 名 | `gatewayName` が空時に使用 |
| `CF_API_TOKEN` | API Token | `apiToken` が空時に使用 |

> **推奨**: `CF_API_TOKEN` は環境変数にのみ保存し、`config.json` には書かない。

---

## コマンド一覧
| コマンド | 説明 |
|---------|------|
| `/cf-ai-setup` | 対話的設定ウィザード |
| `/cf-ai-models` | 利用可能モデル一覧（ZDR ステータス付き） |
| `/cf-ai-status` | 現在の設定確認 |
| `/cf-ai-zdr` | ZDR 有効/無効切り替え |
| `/model` | Pi 標準のモデル切替 |

---

## Workers AI 追加情報

本拡張は AI Gateway の `/workers-ai/v1` 経由で Cloudflare Workers AI の OpenAI 互換エンドポイントも提供します。`cf-ai-gateway` と同じ Account ID / API Token を共用し、観測・キャッシュも同一ゲートウェイで一元化されます。

### 組み込みモデル
| モデルID | コンテキスト | 最大トークン | コスト/1M tokens |
|---------|-------------|-------------|-----------------|
| `cloudflare-ai/@cf/moonshotai/kimi-k2.6` | 256K | 4,096 | In: $0.95, Out: $4.00 |
| `cloudflare-ai/@cf/moonshotai/kimi-k2.5` | 256K | 4,096 | In: $0.60, Out: $3.00 |
| `cloudflare-ai/@cf/zai-org/glm-4.7-flash` | 131K | 4,096 | In: $0.06, Out: $0.40 |

すべて `reasoning: true`、テキスト入力のみ。**ZDR は非対応** のため `cf-aig-zdr` ヘッダーは送信されません。

### カスタムモデル追加例
```json
{
  "workersAi": {
    "enabled": true,
    "customModels": [
      {
        "id": "@cf/meta/llama-3.3-70b-instruct-fp8-fast",
        "name": "Llama 3.3 70B Fast",
        "contextWindow": 128000,
        "maxTokens": 4096,
        "input": ["text"],
        "cost": { "input": 0.29, "output": 2.25 },
        "compat": { "supportsDeveloperRole": false, "maxTokensField": "max_tokens" }
      }
    ]
  }
}
```
`workersAi` を省略すると `cloudflare-ai` プロバイダーは登録されません（後方互換）。

---

## 移行ガイド
1. `~/.pi/cloudflare-models.json` のカスタムモデルを `~/.pi/cf-config.json` の `workersAi.customModels` に移行
2. `~/.pi/cloudflare-models.json` を削除
3. `~/.pi/agent/auth.json` から `cloudflare-ai` ブロック（`access` / `account_id`）を削除
4. `bneil` 拡張をアンインストール（`~/.pi/agent/extensions/` 配下削除または npm パッケージ削除）
> 先に **旧拡張の無効化** を行わないと `cloudflare-ai` プロバイダー名が衝突します。

---

## トラブルシューティング
| エラー | 原因 | 対処 |
|-------|------|------|
| `401 Unauthorized` | API Token 無効または権限不足 | `AI Gateway:Read` + `AI Gateway:Edit` 権限を確認 |
| `403 Feature not enabled` | Unified Billing 未設定 / Credits 不足 | Dashboard で Credits 購入、Providers を Unified Billing に設定 |
| `404 Not Found` | Gateway 名が存在しない | 正しい gateway slug を確認 |
| `Invalid provider` | モデルID が不正 | `provider/model-name` 形式か確認 |
| モデルが表示されない | Extension 競合 | `cf-ai-gateway` が正しく読み込まれているか確認 |

### デバッグ例（bash）
```bash
curl -X POST "https://gateway.ai.cloudflare.com/v1/$CF_ACCOUNT_ID/$GATEWAY/compat/chat/completions" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "cf-aig-zdr: true" \
  -d '{"model":"anthropic/claude-sonnet-4-5","messages":[{"role":"user","content":"hi"}]}'
```

---

## 参考資料
- [Cloudflare AI Gateway Overview](https://developers.cloudflare.com/ai-gateway/)
- [Chat Completions API](https://developers.cloudflare.com/ai-gateway/usage/chat-completion/)
- [Unified Billing](https://developers.cloudflare.com/ai-gateway/features/unified-billing/)
- [Zero Data Retention](https://developers.cloudflare.com/ai-gateway/features/zero-data-retention/)
- [Provider‑specific Endpoints](https://developers.cloudflare.com/ai-gateway/usage/providers/)
- [API Reference](https://developers.cloudflare.com/api/resources/ai_gateway/)

---

## 実装メモ & ライセンス
- エンドポイント: `{baseUrl}/compat`（Unified API `/chat/completions` は一部環境で 403）
- 認証: `Authorization: Bearer {CF_API_TOKEN}`（Provider API Key は不要）
- モデルID: `{provider}/{model-name}` 形式（例: `anthropic/claude-sonnet-4-5`）
- ZDR: `cf-aig-zdr: true` ヘッダーでリクエスト単位制御可能

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Doc Fields Reference

各ドキュメントファイルが何を含むべきかの一覧。更新時に「何が正しい情報源か」を判断する際に参照する。

---

## AGENTS.md

| フィールド | 情報源 |
|---|---|
| Tech Stack (言語・FW・ランタイム) | `package.json`, `wrangler.toml`, `Cargo.toml` |
| Environment Variables | `wrangler.toml` bindings, `.env.example` |
| Key Commands (`dev`, `deploy`, `test`) | `package.json` scripts, `Makefile` |
| Constraints & Gotchas | `docs/problems.md`, コードコメント |
| Directory Overview | `docs/directory.md` |

---

## docs/tech.md

| フィールド | 情報源 |
|---|---|
| ライブラリバージョン | `package.json`, lock ファイル |
| Node/Deno/Bun バージョン | `.node-version`, `.tool-versions`, `mise.toml` |
| ビルドツール | `package.json` devDependencies, `wrangler.toml` |
| テストフレームワーク | `package.json` + `vitest.config.*` |

---

## docs/design.md

| フィールド | 情報源 |
|---|---|
| ルーティング構造 | `src/` ディレクトリ, アプリ定義ファイル |
| バインディング名 | `wrangler.toml` → `[d1_databases]`, `[kv_namespaces]` 等 |
| 環境変数 | `wrangler.toml` `[vars]`, `.env.example` |
| アーキテクチャ図の説明 | コード構造との照合 |

---

## docs/directory.md

| フィールド | 情報源 |
|---|---|
| ファイルツリー | 実際のディレクトリ構造 (`ls`, `find`) |
| 各ファイル・ディレクトリの役割説明 | コード内容, `index.ts` の export |

---

## docs/tasks.md

| フィールド | 情報源 |
|---|---|
| TODO/In Progress タスク | コード中の TODO コメント, Issue トラッカー |
| 完了タスク | git log, PR マージ履歴 |

---

## docs/problems.md

| フィールド | 情報源 |
|---|---|
| 既知のバグ・制約 | コードコメント, Issue, エラーログ |
| 環境差・注意点 | テスト失敗ログ, CI 設定 |

---

## docs/requirements.md

| フィールド | 情報源 |
|---|---|
| 機能要件 | ユーザーインタビュー, 仕様書, Issue |
| 非機能要件 | インフラ設定, SLA, `wrangler.toml` |

---

## docs/test.md

| フィールド | 情報源 |
|---|---|
| テスト戦略 | `vitest.config.*`, テストファイル構造 |
| カバレッジ目標 | CI 設定, `.github/workflows/` |
| テスト実行コマンド | `package.json` scripts |

# pi agent README

このディレクトリは、`pi` 系エージェント実行基盤のローカル設定をまとめる場所。
現在の実体は `settings.json` と `models.json` を中心に、スキル/拡張/プロンプトを組み合わせる構成。

## 設定ファイル構成

- `settings.json`: 有効モデル、既定プロバイダー、スキル/パッケージ、セッション保存先
- `models.json`: プロバイダー定義（`sakura`/`openrouter`/`anthropic`）
- `auth.json`: API キー/トークン参照名（環境変数名）
- `SYSTEM.md`: 回答スタイル/出力ルールのシステムプロンプト
- `runline.json`: `pi-runline` 用の既定プロジェクト設定
- `prompts/`: テンプレート（`code-review.md`, `translate.md`）
- `extensions/`: 拡張設定（例: `plan-mode`, `todo`）
- `skills/`: ローカルスキル（`chezmoi-management`, `pi-skills`）
- `agents/`: 役割別エージェント定義

## プロバイダー

この環境で主に使い分けているプロバイダーは次の4つ。

- `cursor`
  - 既定値（`defaultProvider: "cursor"` / `defaultModel: "auto"`）
  - 迷ったらまずここ。日常の対話・編集を安定運用
- `openrouter`
  - 複数ベンダーを横断してモデル選択したいとき
  - `models.json` でルーティング互換設定を管理
- `cloudflare`（Cloudflare AI Gateway/Workers AI 系）
  - Cloudflare アカウント/トークン管理と相性が良い
- `sakura`
  - Sakura AI の OpenAI 互換エンドポイント
  - `gpt-oss-120b` / `Qwen3-Coder-480B...` を低レイテンシで使いたいとき

## モデルの使い分け

運用上のモデルカテゴリは次の5系統で整理する。

- `opus`
  - 高精度な設計/レビュー/難問対応（長文・高難度向け）
  - 例: `anthropic/claude-opus-4-7`, `openrouter/~anthropic/claude-opus-latest`
- `codex`
  - 実装スピード重視のコーディング作業
  - 例: `cursor/gpt-5.4-medium`（用途名として codex 系で扱う）
- `gemini`
  - Google 系モデル利用時の分類（キーは `GEMINI_API_KEY`）
  - スキル/補助系ワークフローの選択肢として保持
- `kimi`
  - コストと速度のバランス重視
  - 例: `cloudflare-ai/@cf/moonshotai/kimi-k2.5`, `openrouter/moonshotai/kimi-k2.6`
- `composer`
  - Cursor Composer 系（対話的な実装補助）
  - 例: `cursor/composer-2-fast`

## エージェント

- `pi`
  - このディレクトリの中核。`settings.json`/`models.json`/`skills`/`prompts` を読む
  - `pi-subagent` プラグインを追加
  - `~/.pi/agent/agents/*.md` で指定
    - analyst
    - assistant
    - attacker
    - cashier
    - coder
    - designer
    - lawer
    - manager
    - planner
    - security-engineer
    - tester
    - writer
- `opencode`
  - エディタ側（Zed など）で別レジストリとして併用するエージェント
  - 状況に応じて `pi` と切り替える前提

## セッション

- 保存先は `settings.json` の `sessionDir` で管理（既定: `.pi/sessions`）
- 履歴実体はファイル保存と SQLite 系メタ情報を併用する前提
- 運用時はプロジェクトごとの `.pi/` オーバーライドで分離可能

## エディタ

- `cursor`
  - 既定プロバイダーが `cursor`、`cursor/*` モデルを日常利用
- `zed`
  - `agent_servers` と `context_servers` を使って `pi-acp` / `opencode` / MCP を併用

## スキル

- 有効スキルルートは `settings.json` の `skills` で管理
  - `~/.claude/skills`
  - `~/.codex/skills`
  - `~/.gemini/skills`
  - `~/.agentskills`
  - `~/.aionui-config/skills`
- ローカル同梱スキルは `~/.pi/agent/skills/` 配下（例: `chezmoi-management`, `pi-skills`）

## プラグイン / 拡張機能

- `packages` で拡張パッケージを導入
  - `pi-skills`
  - `npm:pi-subagents`
  - `npm:pi-runline`
  - `npm:@netandreus/pi-cursor-provider`
  - `pi-cloudflare-ai-gateway` 系
- `extensions/` に個別設定を配置（例: `cloudflare-ai-gateway/config.json`）

## SYSTEM.md（システムプロンプト）

`SYSTEM.md` は、`pi` が最終回答を生成するときの「口調・禁止事項・出力フォーマット」を固定するための運用ファイル。

- 現在は「日本語のみ / タメ口 / 段落ごとに絵文字」などを定義
- 技術回答では演出より正確性を優先するルールを定義
- コード回答時の書式（コードフェンス形式や差分粒度）を制約

実務上の位置づけ:

- `settings.json` / `models.json` が「どのモデルで動かすか」を管理
- `SYSTEM.md` は「どう答えるか」を管理
- 使い分けることで、モデル切り替え時も回答品質を揃えやすい

## pi-runline

`pi-runline` は `settings.json` の `packages` で有効化している実行系プラグイン（`npm:pi-runline`）。
このリポジトリでは `runline.json` で既定プロジェクトを指定している。

- 現在の設定: `runline.json` の `project` は `~/Developer/4life`
- 用途: 反復実行する作業を runline 側でまとめて回すときの起点管理
- 位置づけ: モデル設定とは独立した「実行ワークフロー層」

運用メモ:

- 既定プロジェクトを変える場合は `runline.json` のみ変更
- 複数プロジェクト運用時は、プロジェクト側設定との衝突有無を先に確認
- プラグイン更新時は `settings.json` の `packages` と合わせて確認

## prompts（テンプレートプロンプト）

`prompts/` は定型タスクを再利用するためのテンプレート置き場。
現在は `code-review.md` と `translate.md` を同梱している。

- `code-review.md`
  - バグ/セキュリティ/性能/可読性にフォーカスしたレビュー雛形
  - `{{code}}` と `{{context}}` の差し込みを前提に設計
- `translate.md`
  - 英日翻訳（日本語入力時は英訳）向けテンプレート
  - frontmatter で説明と引数ヒントを定義

運用メモ:

- 同系統タスクはまず `prompts/` に追加し、毎回ゼロから書かない
- 汎用ロジックは `SYSTEM.md`、個別タスクは `prompts/` に分離
- テンプレート変更時は、実際の出力差を短いサンプルで確認

## MCP

- Cursor/Zed 側の MCP サーバー連携を前提
- Zed では `context_servers` により `context7` や `chrome-devtools` を有効化可能
- 必要に応じてローカル/リモートの有効・無効を切り替える

## ツール

主要コマンド（実行時）:

- `/model`: モデル切替
- `/settings`: 実行設定確認/変更
- `/tree`: セッション履歴表示
- `/compact`: コンテキスト圧縮
- `/reload`: 設定再読込

## モデル選択早見表

作業タイプごとに、まず試す候補を固定しておくと切り替え判断が速くなる。

| 作業タイプ             | まず使う provider/model                    | 切り替え先                        | 判断ポイント                       |
| ---------------------- | ------------------------------------------ | --------------------------------- | ---------------------------------- |
| 日常の実装・修正       | `cursor/auto`                              | `cursor/composer-2-fast`          | 迷ったら既定。安定性優先           |
| 重い設計・難問解析     | `openrouter/~anthropic/claude-opus-latest` | `anthropic/claude-opus-4-7`       | 推論品質優先。コストは高め         |
| 高速なコード生成ループ | `cursor/composer-2-fast`                   | `sakura/gpt-oss-120b`             | 反復速度優先。生成量が多いとき有効 |
| コスト重視の長時間作業 | `cloudflare-ai/@cf/moonshotai/kimi-k2.5`   | `openrouter/moonshotai/kimi-k2.6` | 品質を維持しつつ単価を抑える       |
| 翻訳・軽量整形         | `cursor/auto`                              | `gemini` 系モデル                 | 応答速度と価格のバランスで選ぶ     |

補足:

- `codex` は運用カテゴリ名として扱い、実体は `cursor/*` の高速コーディング系モデルを割り当てる
- `composer` は対話で実装を進めるときの既定候補
- 同じタスクで品質がぶれる場合は provider を変えず model だけ先に変える

## 認証情報

`auth.json` では実キーを直接持たず、環境変数名を参照する。

- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

## 運用メモ

- 既定は `cursor/auto` で開始し、必要時のみ `opus` や `kimi` に切替
- プロジェクト固有の上書きは `<project>/.pi/settings.json` を優先
- 機密値は必ず環境変数か secret 管理に置き、リポジトリへ直書きしない

## トラブルシュート

### 認証エラー（401/403）が出る

原因:

- `auth.json` の参照名と実環境変数名が一致していない
- シェル再起動前で環境変数が未反映

解決:

1. `auth.json` のキー名を確認（例: `OPENROUTER_API_KEY`）
2. シェルで `echo $OPENROUTER_API_KEY` などを確認
3. 必要ならシェル再起動後に `/reload`

再発防止:

- キー追加時は `auth.json` とシークレット管理を同時更新
- 端末プロファイル変更後は必ず `echo` で存在確認してから実行

### モデルが一覧に出ない

原因:

- `settings.json` の `providers.models` または `models.json` の定義漏れ
- provider 名の不一致（例: `cloudflare` と `cf_gateway` の混在）

解決:

1. `settings.json` で有効モデル一覧を確認
2. `models.json` に該当モデルが存在するか確認
3. provider 名を統一して `/reload`

再発防止:

- 新規モデル追加時は `settings.json` と `models.json` を同時に更新
- provider 名を README の表記に合わせて固定運用する

### MCP が接続されない

原因:

- Cursor/Zed 側の MCP サーバー定義が無効
- サーバー起動コマンドや実行権限の問題

解決:

1. エディタ設定で `context_servers` / MCP 有効状態を確認
2. サーバーコマンドを単体実行して起動可否を確認
3. エディタ再起動後に再接続

再発防止:

- MCP 更新時は「単体起動確認 -> エディタ接続確認」の順で検証
- 使わないサーバーは無効化し、接続先を最小化する

# AI ガイドライン

Chezmoi で管理する dotfiles（macOS / Ubuntu、XDG 準拠）。

指示に従い、指示範囲内で処理する。不明点は確認を取る。

---

## 手順

1. **分析** — タスクを要約し、[docs/tech.md](docs/tech.md) の技術スタックを確認（バージョンは変更しない）。既存の類似エイリアス・スクリプトの有無を確認。
2. **実行** — [docs/directory.md](docs/directory.md) の配置ルールに従い、ステップごとに進捗を簡潔に報告。
3. **検証** — 完了後に `chezmoi diff` または `make check` で確認。エラー時は原因を切り分け、修正後に再検証。

---

## リポジトリ固有ルール

### ファイル配置

| 種別               | 配置先                     | プレフィックス等                        |
| ------------------ | -------------------------- | --------------------------------------- |
| 設定               | `home/private_dot_config/` | `dot_`, `private_`                      |
| 実行スクリプト     | `home/dot_local/bin/`      | `executable_`（chmod +x 付与）          |
| chezmoi スクリプト | `home/.chezmoiscripts/`    | `run_*`, `run_once_*`, `run_onchange_*` |
| 暗号化             | 各所                       | `*.age`, `encrypted_*`                  |

### クロスプラットフォーム

- OS 分岐: `{{ .chezmoi.os }}`（`darwin` / `linux` / `windows`）。WSL2 は `linux`。区別は `env "WSL_DISTRO_NAME"`。
- 注意点: [docs/problems.md](docs/problems.md)

### 検証

- `chezmoi diff` — 適用前の差分
- `make check` — 構成チェック
- `chezmoi apply` — 変更適用

### シェルスクリプト

- shebang: `#!/usr/bin/env bash`。`set -eu`。ツール存在は `command -v <cmd> >/dev/null 2>&1`。長い関数は `~/.local/bin/` のスクリプトに分離を検討。

---

## 制約

- 明示されていない変更は行わない。必要なら提案し、承認を得る。
- [docs/tech.md](docs/tech.md) のバージョンは変更しない。変更時は理由を明示し、承認を得る。
- プロンプト・配色・ターミナル等の見た目変更は、理由を示し承認を得てから行う。
- 依存は最小限。長いコードは分割。フォーマット・リントは別コミット。命名・コメントは短く分かりやすく。

---

## 原則

- **YAGNI** — 将来の機能は実装しない
- **DRY** — 重複は関数化・モジュール化
- **KISS** — 単純な解決策を優先

---

## 参照

- [docs/requirements.md](docs/requirements.md) — 要件・対応 OS
- [docs/design.md](docs/design.md) — 設計・Makefile・XDG
- [docs/tech.md](docs/tech.md) — 技術スタック
- [docs/directory.md](docs/directory.md) — ディレクトリ構成
- [docs/problems.md](docs/problems.md) — 環境差・注意点
- [docs/plan.md](docs/plan.md) — 実装計画
- [docs/tasks.md](docs/tasks.md) — タスク管理

---

## 言語

応答は日本語。専門用語は日本語と併記可。コードのコメントは日本語、変数・関数名は英語可。

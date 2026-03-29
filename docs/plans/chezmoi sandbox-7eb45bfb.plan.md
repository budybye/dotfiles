---
name: "chezmoi: SANDBOX 環境変数プロファイル"
overview: ""
todos: []
isProject: false
---

---

todos:

- id: "edit-chezmoi-toml"
  content: "`home/.chezmoi.toml.tmpl` に SANDBOX 検出（先頭 or + else if 分岐）を追加"
  status: pending
- id: "doc-problems"
  content: "`docs/problems.md` の環境検出表に SANDBOX 行を追加"
  status: pending
- id: "verify"
  content: "承認後: `chezmoi doctor` / execute-template / `make check` で検証"
  status: pending
  isProject: false

---

# chezmoi: SANDBOX 環境変数プロファイル

## 現状

環境ごとの分岐は `[home/.chezmoi.toml.tmpl](home/.chezmoi.toml.tmpl)` に集約されている。

- 先頭の `if or (...)`（L20 付近）で CI/コンテナ/特定ユーザー時に `$bitwarden` / `$age` を `false` に固定している。
- 続く `else if` チェーンで `$name` / `$email` / `$github` / `$ssh` を設定している（例: Codespaces は `$github = true`, `$ssh = false`）。

## 変更内容

### 1. `.chezmoi.toml.tmpl`

**A. インタラクティブ無効・シークレットオフの条件に `SANDBOX` を追加**

- `if or` の列挙に `(ne (env "SANDBOX") "")` を追加する。
- 効果: sandbox 時も他の一時環境と同様、`$bitwarden` / `$age` が先頭ブロックで `false` のまま維持される（`run_once_before_bw` / `run_once_before_age` の前提と整合）。

**B. 環境分岐に `SANDBOX` 用 `else if` を追加**

- 条件: `ne (env "SANDBOX") ""`（空でなければ真。`SANDBOX=1` 等で有効）。
- 設定（合意どおり Codespaces 型）:
    - `$name = "sandbox"`（git/jj 用の固定表示名。必要なら後から `.chezmoi.username` に変更しやすい）
    - `$email = "null"`（個人メールを流さない。既存の「その他」フォールバックと同型）
    - `$github = true`
    - `$ssh = false`

**分岐の挿入位置**: 他の「環境変数で決まる」分岐（`GITHUB_ACTIONS` / `CODESPACES` 等）の直後付近に置き、ホストの `chezmoi.username` より先に評価されるようにする（ユーザー名が `hotmilk` でも `SANDBOX` を付けたシェルでは sandbox プロファイルが優先される）。

### 2. ドキュメント

`[docs/problems.md](docs/problems.md)` の「2. 環境検出（CI / コンテナ）」表に 1 行追加:

- 検出: `env "SANDBOX"` が空でない
- 用途: 使い捨て VM / サンドボックスシェル向けプロファイル（Bitwarden/age オフ、GitHub CLI 利用想定、SSH 鍵テンプレはオフ）

参照リンクを `[home/.chezmoi.toml.tmpl](home/.chezmoi.toml.tmpl)` に合わせる。

## 注意（暗号化）

`[home/.chezmoi.toml.tmpl](home/.chezmoi.toml.tmpl)` の `encryption = "age"` は現状 `GITHUB_ACTIONS` 以外では有効のまま。`SANDBOX` だけでは暗号化設定は変えない（Docker/Codespaces と同じ整理）。**age 用 identity が無い環境で `chezmoi apply` が暗号化ファイルで失敗する**場合は、別タスクで `encryption` ブロックに `SANDBOX` 条件を足すか、鍵配置フローを決める必要がある。本プランではスコープ外とする。

## 検証（承認後に実施）

- `chezmoi doctor`
- `SANDBOX=1 chezmoi execute-template '{{ .name }} {{ .github }} {{ .ssh }} {{ .bitwarden }} {{ .age }}'` のように data が期待どおりか確認
- `make check`（リポジトリルールに従う）

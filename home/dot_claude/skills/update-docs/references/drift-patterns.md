# Drift Patterns Reference

ドキュメントとコードの乖離がよく発生するパターン一覧。Phase 2 の検出時に参照する。

---

## バージョン乖離

**症状**: `docs/tech.md` や `AGENTS.md` のバージョンが `package.json` と合わない
**検出**: `package.json` の `dependencies`/`devDependencies` と `docs/tech.md` の記載を比較
**修正**: `package.json` の値を正として `docs/tech.md` を更新

```
# 例
docs/tech.md: Hono: 4.2.0
package.json: "hono": "^4.6.3"
→ docs/tech.md を 4.6.3 に更新
```

---

## 環境変数・バインディング名の不一致

**症状**: `AGENTS.md` や `docs/design.md` に書かれた env var / binding が `wrangler.toml` に存在しない（または逆）
**検出**: `wrangler.toml` の `[vars]`, `[d1_databases]`, `[kv_namespaces]` 等と docs を突き合わせる
**修正**: `wrangler.toml` を正として docs を更新。削除された binding は docs からも削除

---

## ファイルパス消滅

**症状**: `docs/directory.md` に記載されたファイルやディレクトリが存在しない
**検出**: `docs/directory.md` の各パスを Glob/Read で存在確認
**修正**: 削除されたパスを docs から除去。追加されたファイルで重要なものは docs に追記

---

## コマンド変更

**症状**: `AGENTS.md` の `dev`/`deploy`/`test` コマンドが `package.json` scripts と異なる
**検出**: `package.json` の `scripts` セクションと `AGENTS.md` の Key Commands を比較
**修正**: `package.json` を正として `AGENTS.md` を更新

---

## タスクステータス乖離

**症状**: `docs/tasks.md` の TODO/In Progress が実装済みになっている
**検出**: git log の最近のコミット・PR マージと tasks.md の項目を突き合わせる
**修正**: 実装済みのタスクを Done に移動。新規タスクがあれば追記

---

## アーキテクチャ記述の陳腐化

**症状**: `docs/design.md` のルーティング・ミドルウェア構成がコードと異なる
**検出**: `src/index.ts`（または相当するエントリポイント）と `docs/design.md` を比較
**修正**: 実際のルーティング構造に合わせて design.md を更新

---

## README の乖離

**症状**: README のインストール手順・env var 一覧・コマンドが `AGENTS.md` や `docs/` と矛盾する
**検出**: README の各セクションを `AGENTS.md` Key Commands・`docs/tech.md`・`.env.example` と照合
**修正**: README の factual な誤りのみ修正。説明文の tone・長さは保持する

---

## AGENTS.md の constraints 不足

**症状**: `docs/problems.md` に記載の制約が `AGENTS.md` の Constraints セクションに反映されていない
**検出**: `docs/problems.md` の各項目が `AGENTS.md` に言及されているか確認
**修正**: 重要な制約（エージェントが守るべきもの）を `AGENTS.md` に追記

---

## クロスファイル不整合

**症状**: 複数のファイルで同じ情報が矛盾している
**例**:
- `AGENTS.md` の Node バージョン ≠ `docs/tech.md` の Node バージョン
- `docs/design.md` のバインディング名 ≠ `AGENTS.md` の env vars セクション
- README のクイックスタート ≠ `AGENTS.md` の Key Commands

**修正方針**: [doc-fields.md](doc-fields.md) の「情報源」列を参照し、上流ファイルの値に統一する

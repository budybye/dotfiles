---
name: testcase
description: "Test planning: discover scope, classify (functional/integration/non-functional), prioritize P0–P3, emit testlist + roadmap. Framework-agnostic. [Triggers: /testcase, test design, test list, test strategy, enumerate tests]"
allowed-tools: Read, Grep, Glob
---

# /testcase — Test planning before code

実装より先に **何をもって合格か** を列挙する。TC-ID は二度と再利用しない。

## コンテキスト収集コマンド（必要なら）

```bash
find src/ app/ lib/ -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.py' -o -name '*.rs' \) 2>/dev/null | head -80
find tests/ test/ __tests__ spec/ -type f 2>/dev/null | head -50
find src/ \( -name '*.test.*' -o -name '*.spec.*' \) 2>/dev/null | head -30
cat jest.config.* vitest.config.* pytest.ini setup.cfg 2>/dev/null
cat docs/test.md test/testlist.md test/TDD.md 2>/dev/null
```

## 分類フレーム

**Functional**: Happy path、異常入力、境界値（空/最大/0/負）、状態遷移、競合。

**Integration**: モジュール連鎖、外部 API 契約、メッセージング、WS。

**Non-functional**: レイテンシ/同時実行、認可（401/403）、タイムアウト・再試行、ランタイム差。

## 優先度

| 優先   | 中身の目安                                     |
| ------ | ---------------------------------------------- |
| **P0** | 決済・認証・データ破損リスク・暗号・起動不能   |
| **P1** | メイン CRUD・コア計算・主要 API                |
| **P2** | レア境界・エラーメッセージ・ページネーション等 |
| **P3** | ベンチ・ドキュ検証・非クリティカル cosmetic    |

**サイズ見積り**: S≈0.5h, M≈1.5h, L≈6h。

## 出力（デフォルトパスはプロジェクト慣習で置換してよい）

### `test/testlist.md`

先頭にサマリ表（モジュール別件数・P 分布・実装済み比率）。各ケースに以下を必須で書く:

- `TC-XXX`（3 桁連番・全体で連続・削除済み ID の再利用禁止）
- Priority / Type(Unit|Integration|E2E) / Size(S|M|L) / Status
- Target（ファイル→関数）
- Preconditions / Input / Expected
- Test File パス（未定なら空でもよいが後で drift しないよう同期）

### `test/TDD.md`

Red→Green→Refactor のプロジェクトルール、テスト実行コマンド（実際の `npm test` 等）、スプリント別実装順テーブル、進捗ダッシュボード、直近アクティビティログ。

## ワークフロー

1. コード・既存テスト・`docs/requirements.md` からシグナル収集。
2. 上のフレームでケース洗い出し + P/S 付け。
3. testlist → TDD の順でファイル生成。
4. ユーザーとレビュー（漏れ・優先・依存順）。

## ルール

- TC-ID と実テストファイルは **1:1 対応を維持**（ズレたら drift）。
- P0/P1 をロードマップ前半に寄せる。
- ケース文は **自然語で仕様として読める** ように書く（コードスタブにしない）。
- 既に `test/cases.md` 等があるならそちらに合わせ、別命名で分裂させない。

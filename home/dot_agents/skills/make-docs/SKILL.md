---
name: make-docs
description: "Greenfield: create docs/* (9 files), AGENTS.md, README.md from interview or repo scan. If docs/ or AGENTS.md already exists, stop — use doc sync instead. [Triggers: /make-docs, create docs, init docs, generate AGENTS.md]"
disable-model-invocation: true
---

# /make-docs — Documentation bootstrap

**前提**: `docs/` も `AGENTS.md` も無いリポジトリだけ。既にあるなら **update-docs 系に切り替え**。このスキルは初回スキャフォールド用で、勝手に上書きしない。

## モード選択（最初に確定・途中で混ぜない）

```
リポジトリ無し / 仕様だけ → Interactive（2〜3 問ずつ）
リポジトリあり かつ docs と AGENTS が無い → Auto-scan（下の bash）→ 足りない所だけ短命インタビュー
docs または AGENTS が既にある → **STOP**（同期ワークフローへ）
```

## Auto-scan（プロジェクトルートで実行）

```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/build/*' -not -path '*/target/*' | head -100
cat README.md AGENTS.md 2>/dev/null
cat package.json 2>/dev/null || cat Cargo.toml 2>/dev/null || cat pyproject.toml 2>/dev/null
cat wrangler.toml wrangler.jsonc docker-compose.yml Dockerfile 2>/dev/null
ls docs/ 2>/dev/null; ls .env.example .dev.vars.example 2>/dev/null
```

結果からスタック・ディレクトリ・デプロイ手段を埋め、ビジネス文脈だけ質問で補う。

## 生成するファイル一覧

```
README.md, AGENTS.md,
docs/requirements.md, design.md, tech.md, test.md, tasks.md, directory.md, problems.md, references.md, security.md
```

## 各ファイルに最低限入れる中身（見出しレベルの義務）

| ファイル | 最低ライン |
|---|---|
| requirements.md | 概要 + 機能要件 1 つ以上 + 非機能 1 つ以上 |
| design.md | モジュール 1 つ説明 + ADR 1 つ（ trivial でよい） |
| tech.md | スタック表・**実バージョン**（`[Version]` 禁止） |
| test.md | フレーム名 + カバレッジ方針（none 明示でも可） |
| tasks.md | 現在フォーカスまたはマイルストーン 1 件 |
| directory.md | **実際の tree**（テンプレ丸写し禁止） |
| problems.md | 既知論点 1 つ or 「none known」明示 |
| references.md | tech の各行に対応する公式リンク |
| security.md | 秘密情報の扱い（env／vault／コミット禁止）+ 認可の境界（誰が何へ）+ 依存・サプライチェーン方針 1 行 + 「none / TBD」は理由付きで明示 |
| AGENTS.md | Prohibitions 非空、Key Commands が **実在する** scripts と一致 |
| README.md | コピペで動くインストール、env は `.env.example` へ誘導 |

## AGENTS.md / README の型

**AGENTS.md**: Overview → 開発ポリシー（lint/format）→ TDD 方針（テストリストの場所）→ Directory は `docs/directory.md` へ委譲 → Env / 重要設定は `docs/tech.md` へ委譲 → Prohibitions → Deploy → Troubleshooting。**詳細数値は docs に一本化**。

**README**: 一文概要 → Features → Quick Start（検証済みコマンド）→ `docs/` へのリンク。**docs と値の重複を作らない**。

## 原則

- Web 標準 API をデフォルト前提に書く（例: `fetch`, Web Crypto）。独自ランタイム依存は ADR で理由。**security と tech のスタック説明が矛盾しない**（例: SSRF になり得る出口はどこか、秘密はどこに置くか）。
- **1 ファイルずつ**生成して確認してから次（一気に 9 ファイルダンプ禁止）。
- `[placeholder]` / lorem を残さない。不明は `TBD — docs/tasks.md` と明示。
- 終わりに「生成したもの／推測したもの／人手確認してほしいもの」を必ず分けて書く。

## 完了のゲート（全部チェックできて初めて完了）

- [ ] 上記 11 パスが存在（README 省略はユーザー承認付きのみ）
- [ ] tech と AGENTS のスタック一致、env 名のクロスファイル一致
- [ ] directory が実ディレクトリと一致
- [ ] references が tech の各行をカバー
- [ ] security.md が公開面・認可・秘密の所在と矛盾してない（平文トークン・鍵なし）
- [ ] README のコマンドが実行可能
- [ ] どのファイルもギネス級に肥大化してない（例: 500 行超は情報の置き場所が間違ってる可能性）

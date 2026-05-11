---
name: update-docs
description: "Sync docs/ (9 core files incl. security.md) and AGENTS.md with the repo: detect drift vs package.json, wrangler, lockfiles, and filesystem; propose fixes; edit minimally. [Triggers: /update-docs, update docs, sync docs, docs drift, AGENTS.md outdated]"
disable-model-invocation: true
---

# /update-docs — Documentation sync

既存の `docs/`（9 ファイル）・ルート `AGENTS.md`・`README.md` を、コードと設定を真実として突き合わせて直す。緑野郎の想像で書き換えない。

## 対象ファイル

`docs/requirements.md`, `design.md`, `tech.md`, `test.md`, `tasks.md`, `directory.md`, `problems.md`, `references.md`, `security.md` に加え `AGENTS.md`, `README.md`。

## ソース・オブ・トゥルース（フィールド別）

| ドキュメント | フィールド | 真実の所在 |
|---|---|---|
| AGENTS.md | スタック・キーコマンド | `package.json` scripts, `Makefile`, `wrangler.*`, `Cargo.toml`, `go.mod`, `pyproject.toml` |
| AGENTS.md | 環境変数 | `wrangler.*` bindings / `[vars]`, `.env.example`, `.dev.vars.example` |
| AGENTS.md | ディレクトリ概要 | `docs/directory.md`（ただし実ファイルシステムが最優先） |
| docs/tech.md | ライブラリ・ランタイム版 | lockfile → `package.json` → `Cargo.lock` 等 |
| docs/tech.md | テストフレーム | `package.json`, `vitest.config.*`, `jest.config.*`, CI |
| docs/design.md | ルーティング・構成 | エントリ（例 `src/index.ts`）実コード |
| docs/design.md | binding 名 | `wrangler.*` の D1/KV/R2/DO セクション |
| docs/directory.md | ツリー・役割 | `find` / `ls` / Glob で実在確認 |
| docs/tasks.md | TODO/Done | `git log`, PR, issue |
| docs/problems.md | 既知の制約 | コードコメント・issue・CI ログ |
| docs/requirements.md | 要件の意味 | ユーザー／仕様（コードと矛盾したら一旦止めて確認） |
| docs/references.md | 外部リンク | `tech.md` のスタック各行に対応する公式ドキュメントが載っているか |
| docs/security.md | 秘密・認可・脅威の境界 | `.env.example` / wrangler `secrets`・binding 名・公開 API 面・TLS/Cookie 方針と **食い違いがないか** |
| README.md | クイックスタート | `package.json` scripts と AGENTS のコマンドと一致 |

## 不一致がよくあるパターン（検知→修正）

| 症状 | 検知 | 修正 |
|---|---|---|
| 版がズレ | `tech.md` / AGENTS と lock・package を diff | **lock / manifest 側を正**として docs を更新 |
| env / binding 名がズレ | `wrangler.*` と design / AGENTS を突き合わせ | **wrangler が正**、docs から幽霊を削除 |
| directory に死んだパス | `directory.md` のパスを Glob | 削除済みはドキュメントから除去 |
| コマンド改名 | `package.json` scripts と AGENTS Key Commands | **package.json が正** |
| tasks が古い | `tasks.md` の TODO と git | Done に寄せるか削除 |
| design の説明がコードと別物 | エントリファイルと design を読み比べ | design を現状に合わせる（ADR の経緯文は残してよい） |
| README だけ別情報 | README と AGENTS / `.env.example` | 事実だけ最小修正、トーンは変えない |
| references がスタックと不整合 | `tech.md` の各行と `references.md` | スタックに無いリンクは削る／足りない公式 URL を追加 |
| security が実装と矛盾 | ルートの fetch 先・認可ミドルウェア・`Authorization` ヘッダ扱いと `security.md` | **コードと設定が正**、曖昧な「secure by default」文だけは具体化 or 削除 |
| 秘密がドキュメントに露出 | `security.md` / README / AGENTS に平文の鍵・トークン | **即削除**し、`.env.example` のプレースホルダに寄せる |

## 複数ファイルで値が割れたとき（優先順）

上流を直してから下流へ伝播。**「最近更新された方」では決めない**。

| 事実 | 上流 | 下流（この順で合わせる） |
|---|---|---|
| ランタイム版 | `.tool-versions` / `mise.toml` / `.node-version`, `engines` | tech.md → AGENTS → README |
| ライブラリ版 | lock → package.json | tech.md → AGENTS |
| コマンド | scripts / Makefile | AGENTS → README |
| env 名 | `.env.example`, wrangler `[vars]` | tech → AGENTS → README |
| binding | wrangler | design → AGENTS |
| ディレクトリ | 実 FS | directory → AGENTS の概要 |

上流自体が怪しい（誰も使ってない古い pin 等）は **ユーザーに確認**してから docs に焼き付けない。

## ワークフロー

1. **スコープ**: 対話で「何が変わったか」／または自動で上記ファイル＋主要設定をスキャン。
2. **ドリフト検知**: 上のパターンテーブルで機械的に洗う。
3. **計画**: 変更予定を一覧 → **ユーザー確認**（明示的に waive されない限り）。
4. **適用**: **ファイル単位・セクション単位**で最小修正。フォーマットごちゃ替え禁止。
5. **整合**: tech と AGENTS、design と directory、references と tech、**security と wrangler／公開面のコード** を最終突き合わせ。

## エージェント向けルール

- 誤りが検知できたところだけ直す。読みやすくする改写はしない。
- 孤立コマンド（package に無いのに AGENTS にある）は **スクリプト追加か docs 削除**の二択、放置しない。
- `edit` / パッチは要点だけ。一括ダンプ書き換え禁止。

---
name: make-docs
description: "Greenfield: create docs/* (9 files), README.md from interview or repo scan. If docs/ or README.md already exists, stop — use doc sync instead. [Triggers: /make-docs, create docs, init docs, generate AGENTS.md]"
disable-model-invocation: true
---

# /make-docs — Documentation bootstrap

**前提**: `docs/` の無いリポジトリだけ。既にあるなら **update-docs 系に切り替え**。このスキルは初回スキャフォールド用で、勝手に上書きしない。

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
```

## 現在のプロジェクトのファイルを読み、内容に合わせて作成、またはインタラクティブに作成

- `./AGENTS.md` どうするか(Agent指示、progresive disclosure)
- `./docs/requirements.md` 何がしたいか(要件定義、ゴール設計)
- `./docs/architecture.md` どう動くか(詳細設計、スキーマ設計、レイヤー設計)
- `./docs/test.md` どう検証するか(テスト設計、テストガイド)
- `./docs/tech.md` 何を使うか(技術選定、依存ライブラリ、API連携)
- `./docs/directory.md` どこにあるか(ディレクトリ構成、命名規則)
- `./docs/security.md` どう守るか(セキュリティ設計、機密管理)
- `./docs/problems.md` 何に注意するか(注意点、落とし穴)
- `./docs/references.md` 調べる前に見る(参考文献、サンプルコード)

## Options

- ドキュメントの内容に合った 図(テーブル,ダイアグラム,テキストベース)を作成
- `./docs/*.md` 1のファイルが大きくなったら適切に分割するか判断
- 運用や保守がメインの場合などは `./docs/maintenance.md` を作成(保守、運用管理)
- プロジェクトの規模や複雑度に応じて `./docs/guidance.md` を作成(目次、まとめ)
- プロジェクトルートに `ROADMAP.md` 何を・いつ・どこまで(進捗管理、目標管理、バージョン管理)
- プロジェクトルートに UI/UX専用の `DESIGN.md` を作成(どう見える・操作するか)
	- ロゴ
	- レイアウト
	- 見出し
	- 配色
	- 文字
	- フォーム
	- コンポーネント
	- タブ/モーダル
	- アニメーション/3D
- `./openspec/config.yaml` がある場合は `./docs/*.md` を参照させる
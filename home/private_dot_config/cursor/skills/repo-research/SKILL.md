---
name: repo-research
description: GitHub リポジトリ調査とコーディングを効率化するスキル。ghq でリポジトリをローカル管理し、Context7 MCP で最新ドキュメントを参照する。外部ライブラリの実装調査、API ドキュメント参照、OSS コードリーディングの際に使用する。
---

# リポジトリ調査とコーディング効率化

## 基本方針

### ツールの役割

| ツール       | 用途                     | 取得するもの                    |
| ------------ | ------------------------ | ------------------------------- |
| **ghq**      | リポジトリのローカル管理 | ソースコード（Git クローン）    |
| **Context7** | ドキュメント参照         | 最新の API ドキュメント、使用例 |

### 使い分けの判断基準

```:
調査対象が...

├─ ライブラリの使い方、API 仕様
│  → Context7 を使用（最新ドキュメント）
│
├─ 内部実装、アルゴリズム、コード構造
│  → ghq でクローン後、ソースコード読解
│
└─ 両方必要（使い方 + 実装の理解）
   → ghq + Context7 を併用
```

## ghq: リポジトリのローカル管理

### 基本コマンド

```bash
# リポジトリを取得（クローン）
ghq get <repository-url>
ghq get github.com/user/repo

# ローカルのリポジトリ一覧
ghq list

# ghq のルートディレクトリ確認
ghq root
# 通常: ~/ghq
```

### リポジトリのパス構造

```:
~/ghq/
└── github.com/
    └── username/
        └── repository/
```

### エージェントの使用手順

1. **リポジトリ取得**

    ```bash
    ghq get <target-repo>
    ```

2. **ルートパス取得**

    ```bash
    ghq root
    # 出力例: /Users/username/ghq
    ```

3. **対象リポジトリのフルパス構築**

    ```:
    $(ghq root)/github.com/<owner>/<repo>
    ```

4. **ソースコード調査**
    - `Read`: 特定ファイルを読む
    - `Grep`: パターン検索
    - `SemanticSearch`: 意味的検索
    - `Glob`: ファイル名パターンマッチ

### 実行例

```bash
# Next.js のソースコードを調査
ghq get github.com/vercel/next.js

# 調査対象のパス
# $(ghq root)/github.com/vercel/next.js

# 例: middleware 実装を探す
# Grep pattern: "middleware" path: "$(ghq root)/github.com/vercel/next.js"
```

## Context7: 最新ドキュメント参照

Context7 は MCP (Model Context Protocol) 経由で最新のライブラリドキュメントを取得する。

### 主な MCP ツール

#### 1. `resolve-library-id`

ライブラリ名からライブラリ ID を解決する。

**パラメータ:**

- `query` (必須): ライブラリ名や説明

**使用例:**

```:
query: "Next.js middleware authentication"
→ ライブラリ ID を返す
```

#### 2. `query-docs`

ライブラリのドキュメントから特定のトピックを取得する。

**パラメータ:**

- `library_id` (必須): `resolve-library-id` で取得した ID
- `topic` (必須): 調査したい具体的なトピック
- `tokens` (オプション): 取得する最大トークン数（デフォルト: 4000）

**使用例:**

```:
library_id: "nextjs"
topic: "middleware redirect authentication"
tokens: 3000
```

### ワークフロー

```:
1. resolve-library-id でライブラリ ID 取得
   ↓
2. query-docs で具体的なトピックのドキュメント取得
   ↓
3. 取得した情報を基にコーディング
```

### トークン制限の考慮

- **デフォルト**: 4000 トークン
- **推奨**: 必要最小限に調整（2000-3000）
- **理由**: コンテキストウィンドウを節約し、他の情報にも余裕を持たせる

### 注意点

- Context7 は**ドキュメント専用**（ソースコードは含まれない）
- 実装の詳細を知りたい場合は ghq でソースコードを取得
- `topic` は具体的に指定する（"API reference" より "middleware authentication redirect" の方が良い）

## 統合ワークフロー

### パターン A: ライブラリの使い方を調べる（Context7 主体）

**シナリオ**: Prisma で多対多リレーションを実装したい

```:
1. resolve-library-id (query: "Prisma ORM")
2. query-docs (topic: "many-to-many relations")
3. 取得したドキュメントを基にコード実装
```

**コンテキスト最適化**:

- tokens: 2500 程度（サンプルコード含む）
- topic を具体的に指定してノイズを減らす

### パターン B: OSSの内部実装を調査（ghq 主体）

**シナリオ**: Zod のバリデーションロジックを理解したい

```:
1. ghq get github.com/colinhacks/zod
2. ghq root で基準パス取得
3. SemanticSearch または Grep で実装箇所を特定
   - 例: "validation logic schema"
4. Read でソースコード詳細を確認
```

**コンテキスト最適化**:

- 必要なファイルのみ読む（全体をスキャンしない）
- Grep で絞り込んでから Read

### パターン C: 使い方 + 実装確認（併用）

**シナリオ**: React Query のキャッシュ戦略を理解して実装したい

```:
1. Context7 でドキュメント取得
   - resolve-library-id (query: "React Query TanStack")
   - query-docs (topic: "cache strategy stale time")

2. ghq でソースコード取得
   - ghq get github.com/TanStack/query

3. ドキュメントで概念理解 → ソースコードで実装確認
   - Grep pattern: "staleTime" または "cacheTime"
   - 該当ファイルを Read

4. 両方の情報を統合してコード実装
```

**コンテキスト最適化**:

- Context7: tokens=2000（概要のみ）
- ghq: 特定ファイル 2-3 個に絞る

## エージェント向けガイドライン

### コンテキストウィンドウ最適化

**原則**: 必要最小限の情報のみ取得する

| 情報源           | 推奨取得量         | 理由                     |
| ---------------- | ------------------ | ------------------------ |
| Context7         | 2000-3000 トークン | コード例含む使い方の把握 |
| ghq ソースコード | 2-5 ファイル       | 実装の核心部分のみ       |

### ghq ルート配下のファイル探索パターン

```bash
# 1. ghq root を取得
ROOT=$(ghq root)

# 2. 対象リポジトリのパス構築
REPO_PATH="${ROOT}/github.com/<owner>/<repo>"

# 3. ファイル探索
# - Glob: "*.ts" など
# - Grep: pattern="function middleware"
# - SemanticSearch: query="authentication middleware implementation"
```

### Context7 の tokens パラメータ制御

**調査の深さに応じて調整**:

- **クイックリファレンス**: 1000-1500
  - API 仕様のみ、簡単な例

- **通常の調査**: 2000-3000
  - 詳細な説明とコード例

- **詳細な調査**: 4000-6000
  - 複数トピックの包括的なドキュメント

### 判断フロー

```:
ユーザーが "○○ を使いたい" と言った場合:
├─ "使い方" が明確 → Context7 のみ
├─ "仕組み" を知りたい → ghq + ソースコード読解
└─ 両方必要 → Context7 (概要) → ghq (詳細)

ユーザーが "○○ の実装を見たい" と言った場合:
└─ ghq get + ソースコード調査
```

### 実行順序の推奨

1. **Context7 優先** (高速)
    - ドキュメントで概要把握
    - 使い方が分かれば終了

2. **必要に応じて ghq** (時間がかかる)
    - Context7 で不足の場合
    - 実装詳細が必要な場合

3. **並行実行しない**
    - Context7 で十分か確認してから ghq を実行
    - コンテキストウィンドウを無駄にしない

## 具体的な使用例

### 例 1: Next.js の App Router を学ぶ

```:
目的: App Router の使い方を理解してプロジェクトに導入

手順:
1. Context7 でドキュメント取得
   - resolve-library-id (query: "Next.js")
   - query-docs (topic: "app router file conventions", tokens: 3000)

2. 実装開始
   - 取得したドキュメントを参考にファイル構造作成

※ この場合、ghq は不要（使い方のみで十分）
```

### 例 2: Vite のプラグインシステムを理解する

```:
目的: カスタムプラグインを作成したい

手順:
1. Context7 でプラグイン API を確認
   - resolve-library-id (query: "Vite")
   - query-docs (topic: "plugin api hooks", tokens: 2500)

2. ghq で既存プラグインの実装を参照
   - ghq get github.com/vitejs/vite
   - SemanticSearch (query: "plugin implementation hooks")
   - 該当ファイルを Read

3. 両方の情報を統合してプラグイン実装
```

### 例 3: React の内部実装を学習

```:
目的: React の reconciliation アルゴリズムを理解したい

手順:
1. ghq get github.com/facebook/react
2. Grep pattern: "reconcile" path: "$(ghq root)/github.com/facebook/react/packages/react-reconciler"
3. 見つかったファイルを Read して実装を確認

※ この場合、Context7 は不要（実装の理解が目的）
```

## トラブルシューティング

### ghq でクローンできない

```bash
# URL 形式を確認
ghq get https://github.com/owner/repo  # ✅
ghq get github.com/owner/repo          # ✅
ghq get owner/repo                     # ❌（不十分）
```

### Context7 で情報が取得できない

- ライブラリ名が間違っている可能性
  - `resolve-library-id` の query を具体的に
  - 例: "React" → "React JavaScript library"

- topic が広すぎる
  - "API" → "authentication API endpoints"

### コンテキストウィンドウが不足

1. Context7 の tokens を減らす（4000 → 2000）
2. ghq のファイル読み込みを絞る（Grep で先に絞り込み）
3. 段階的に情報取得（一度に全部取らない）

## 詳細リファレンス

より詳しいコマンド仕様と使用例は [reference.md](reference.md) を参照。

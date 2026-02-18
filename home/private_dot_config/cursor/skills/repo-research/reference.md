# リファレンス: ghq + Context7

## ghq コマンド詳細

### インストール

```bash
# mise 経由（推奨）
mise use -g ghq@latest

# Homebrew
brew install ghq

# Go
go install github.com/x-motemen/ghq@latest
```

### 基本コマンド

| コマンド         | 説明                   | 例                             |
| ---------------- | ---------------------- | ------------------------------ |
| `ghq get <repo>` | リポジトリをクローン   | `ghq get github.com/user/repo` |
| `ghq list`       | ローカルリポジトリ一覧 | `ghq list`                     |
| `ghq list -p`    | フルパスで表示         | `ghq list -p`                  |
| `ghq root`       | ルートディレクトリ表示 | `ghq root`                     |
| `ghq root --all` | 全ルートを表示         | `ghq root --all`               |

### ghq get の詳細オプション

```bash
# 基本形式
ghq get <repository-url>

# プロトコル指定
ghq get -p <repo>              # SSH でクローン
ghq get --update <repo>        # 既存なら更新
ghq get --shallow <repo>       # shallow clone
ghq get --branch <name> <repo> # 特定ブランチ
ghq get --bare <repo>          # bare リポジトリ
```

### URL 形式

```bash
# 以下の形式をサポート
ghq get https://github.com/owner/repo
ghq get github.com/owner/repo
ghq get git@github.com:owner/repo.git
```

### 設定（.gitconfig）

```ini
[ghq]
  # ルートディレクトリ
  root = ~/ghq
  root = ~/go/src  # 複数設定可能

  # VCS 指定
  [ghq "https://gitlab.com/"]
    vcs = git
```

### パス構造の詳細

```:tree
<ghq.root>/
└── <host>/
    └── <user>/
        └── <repo>/
            └── (リポジトリ内容)

例:
~/ghq/
├── github.com/
│   ├── facebook/
│   │   └── react/
│   └── vercel/
│       └── next.js/
└── gitlab.com/
    └── group/
        └── project/
```

## Context7 MCP ツール仕様

### ツール 1: resolve-library-id

**目的**: ライブラリ名から Context7 のライブラリ ID を解決

**パラメータ**:

```json
{
  "query": "string (required)"
}
```

**query の書き方**:

- ライブラリ名 + 説明: "Next.js React framework"
- 具体的な用途: "Prisma ORM for database"
- 公式名称推奨: "TanStack Query" (旧 "React Query")

**返り値**:

```json
{
  "library_id": "nextjs",
  "name": "Next.js",
  "confidence": 0.95
}
```

**ベストプラクティス**:

- 公式名称を使う（略称は避ける）
- バージョン指定は query に含めない（自動的に最新）
- あいまいな場合は説明を追加

### ツール 2: query-docs

**目的**: ライブラリの特定トピックのドキュメント取得

**パラメータ**:

```json
{
  "library_id": "string (required)",
  "topic": "string (required)",
  "tokens": "number (optional, default: 4000)"
}
```

**topic の書き方**:

- **良い例**: "middleware authentication redirect"
- **悪い例**: "how to use" (広すぎる)

**tokens の推奨値**:

| 用途 | tokens | 説明 |
| ---------- | -------- | ------ |
| クイックリファレンス | 1000-1500 | API 仕様のみ |
| 通常の調査 | 2000-3000 | 説明 + コード例 |
| 詳細な調査 | 4000-6000 | 包括的なドキュメント |

**返り値**:

```json
{
  "content": "マークダウン形式のドキュメント",
  "token_count": 2847,
  "sources": ["https://..."]
}
```

**注意点**:

- tokens は上限値（実際の取得量は topic により変動）
- コンテキストウィンドウを考慮して調整
- 複数トピックは別々に query-docs を実行

### ツール 3: search-for-libraries

**目的**: ライブラリを検索（resolve-library-id の前に使える）

**パラメータ**:

```json
{
  "query": "string (required)",
  "limit": "number (optional, default: 10)"
}
```

**使用例**:

```:
query: "React state management"
→ Redux, Zustand, Jotai などの候補を返す
```

## よくある調査シナリオ

### シナリオ 1: 新しいライブラリを導入

**状況**: プロジェクトに Zod を導入したい

```:
ステップ 1: Context7 でドキュメント取得
├─ resolve-library-id (query: "Zod TypeScript schema validation")
├─ query-docs (topic: "schema definition validation", tokens: 3000)
└─ 基本的な使い方を把握

ステップ 2: 実装開始
└─ 取得したコード例を参考に実装
```

**判断**: ドキュメントのみで十分 → ghq 不要

### シナリオ 2: バグの原因調査

**状況**: React Query のキャッシュ挙動が期待と異なる

```:
ステップ 1: Context7 でドキュメント確認
├─ resolve-library-id (query: "TanStack Query")
├─ query-docs (topic: "cache behavior staleTime cacheTime", tokens: 2500)
└─ 公式の挙動を理解

ステップ 2: 実装を確認する必要がある場合
├─ ghq get github.com/TanStack/query
├─ Grep pattern: "staleTime|cacheTime"
├─ 該当ファイルを Read
└─ 内部実装を理解して原因特定
```

**判断**: ドキュメント → 不十分 → ソースコード確認

### シナリオ 3: 既存コードのリファクタリング

**状況**: Next.js の Pages Router を App Router に移行

```:
ステップ 1: 移行ガイド取得
├─ resolve-library-id (query: "Next.js")
├─ query-docs (topic: "app router migration from pages", tokens: 4000)
└─ 移行手順を把握

ステップ 2: 実装パターン確認（必要に応じて）
├─ ghq get github.com/vercel/next.js
├─ Glob pattern: "examples/*/app/**"
└─ 公式の examples を参照
```

**判断**: ドキュメント + 公式例のソースコード

### シナリオ 4: カスタムプラグイン開発

**状況**: Vite のカスタムプラグインを作成

```:
ステップ 1: プラグイン API 理解
├─ resolve-library-id (query: "Vite")
├─ query-docs (topic: "plugin api hooks lifecycle", tokens: 3000)
└─ API 仕様を把握

ステップ 2: 既存プラグイン参照
├─ ghq get github.com/vitejs/vite
├─ ghq get github.com/vitejs/vite-plugin-react
├─ SemanticSearch (query: "plugin hooks implementation")
└─ 実装パターンを学ぶ

ステップ 3: 実装
└─ ドキュメント + 既存実装を参考に開発
```

**判断**: ドキュメント + 複数リポジトリのソースコード

### シナリオ 5: OSS へのコントリビューション

**状況**: React にバグ修正 PR を送りたい

```:
ステップ 1: リポジトリ取得
├─ ghq get github.com/facebook/react
└─ ローカルでビルド・テスト環境構築

ステップ 2: バグ箇所特定
├─ Grep でエラーメッセージ検索
├─ SemanticSearch で関連コード探索
└─ Read で詳細確認

ステップ 3: 修正実装
└─ ローカルで修正 & テスト

ステップ 4: コントリビューションガイド確認（必要に応じて）
├─ resolve-library-id (query: "React")
└─ query-docs (topic: "contributing guide", tokens: 2000)
```

**判断**: 主に ghq（ソースコード）、補助的に Context7

## エージェント実装パターン

### パターン A: Context7 → 実装

```python
# 擬似コード
def implement_with_docs(library_name, feature):
    # 1. ライブラリ ID 取得
    lib_id = resolve_library_id(query=library_name)

    # 2. ドキュメント取得
    docs = query_docs(
        library_id=lib_id,
        topic=feature,
        tokens=3000
    )

    # 3. 実装
    implement_code(docs)
```

### パターン B: ghq → 調査 → 実装

```python
# 擬似コード
def investigate_and_implement(repo_url, search_query):
    # 1. リポジトリ取得
    run_command(f"ghq get {repo_url}")

    # 2. パス構築
    root = run_command("ghq root").strip()
    repo_path = f"{root}/{parse_repo_path(repo_url)}"

    # 3. コード検索
    results = semantic_search(
        query=search_query,
        target_directories=[repo_path]
    )

    # 4. 詳細読み込み
    for file in results[:3]:  # 上位3件
        content = read_file(file.path)
        analyze(content)

    # 5. 実装
    implement_code()
```

### パターン C: Context7 + ghq（段階的）

```python
# 擬似コード
def research_and_implement(library_name, topic, repo_url):
    # 1. ドキュメントで概要把握
    lib_id = resolve_library_id(query=library_name)
    overview = query_docs(
        library_id=lib_id,
        topic=f"{topic} overview",
        tokens=2000  # 控えめ
    )

    # 2. 概要で不足があればソースコード確認
    if needs_more_detail(overview):
        run_command(f"ghq get {repo_url}")
        root = run_command("ghq root").strip()
        repo_path = f"{root}/{parse_repo_path(repo_url)}"

        # 特定ファイルのみ読む
        files = grep(pattern=topic, path=repo_path)
        for file in files[:2]:
            detail = read_file(file)
            analyze(detail)

    # 3. 実装
    implement_code()
```

## トラブルシューティング詳細

### ghq が見つからない

```bash
# mise でインストール確認
mise which ghq

# PATH 確認
echo $PATH | grep -o '[^:]*mise[^:]*'

# mise の shims 再生成
mise reshim
```

### ghq root が空

```bash
# デフォルト設定確認
git config --global ghq.root

# 設定されていない場合
git config --global ghq.root ~/ghq
```

### Context7 MCP が応答しない

```bash
# MCP 設定確認
cat ~/.config/cursor/mcp.json

# API キー確認（Bitwarden から）
# 設定ファイル: home/private_dot_config/cursor/mcp.json.tmpl
```

### Context7 で "library not found"

- **解決策 1**: query を具体的にする

    ```:
    ❌ "react query"
    ✅ "TanStack Query React data fetching"
    ```

- **解決策 2**: search-for-libraries で候補確認

    ```:
    search-for-libraries(query="react state")
    → 候補から正しい名称を選択
    ```

### コンテキストウィンドウオーバーフロー

**症状**: "context window exceeded" エラー

**解決策**:

1. Context7 の tokens を半減（4000 → 2000）
2. ghq のファイル読み込みを制限（全体 → 特定ファイルのみ）
3. 段階的に情報取得（一度に全部取らない）

```bash
# 悪い例
read_file(entire_repository)  # NG

# 良い例
grep(pattern="specific_function")  # 絞り込み
read_file(specific_files[0])        # 必要なファイルのみ
```

## 高度な使用例

### 例 1: マルチリポジトリ調査

**タスク**: React エコシステムのルーティングライブラリ比較

```bash
# リポジトリ取得
ghq get github.com/remix-run/react-router
ghq get github.com/TanStack/router
ghq get github.com/molefrog/wouter

# 各リポジトリで同じパターン検索
ROOT=$(ghq root)
for repo in react-router router wouter; do
  grep -r "route definition" "${ROOT}/github.com/*/${repo}"
done
```

### 例 2: バージョン間の差分調査

```bash
# 異なるバージョンを取得
ghq get -p github.com/facebook/react
cd $(ghq root)/github.com/facebook/react

# バージョンタグ確認
git tag | grep v18

# 特定バージョンに切り替え
git checkout v18.2.0

# 差分確認
git diff v18.0.0..v18.2.0 -- packages/react/
```

### 例 3: ドキュメント + ソースコード統合

```bash
# 1. Context7 でコンセプト理解
resolve-library-id(query="Remix")
query-docs(topic="loader action data flow", tokens=2500)

# 2. 実装例を ghq で確認
ghq get github.com/remix-run/remix
ghq get github.com/remix-run/examples

# 3. 両方を参照しながらコーディング
```

## チートシート

### ghq クイックリファレンス

```bash
# 取得
ghq get <repo>                    # クローン
ghq get -u <repo>                 # 更新
ghq get -p <repo>                 # SSH

# 一覧
ghq list                          # リポジトリ名
ghq list -p                       # フルパス
ghq list -e <query>               # 完全一致

# パス
ghq root                          # ルート
$(ghq root)/github.com/user/repo  # フルパス構築
```

### Context7 クイックリファレンス

```json
// ライブラリ ID 取得
{
  "tool": "resolve-library-id",
  "params": { "query": "Next.js" }
}

// ドキュメント取得
{
  "tool": "query-docs",
  "params": {
    "library_id": "nextjs",
    "topic": "middleware",
    "tokens": 3000
  }
}
```

### 推奨ワークフロー

```:
1. 質問を理解
   ├─ キーワード抽出
   └─ 目的判定（使い方 or 実装 or 両方）

2. Context7 でドキュメント（高速）
   ├─ resolve-library-id
   ├─ query-docs (tokens: 2000-3000)
   └─ 十分か判定

3. 不足時のみ ghq（低速）
   ├─ ghq get
   ├─ Grep / SemanticSearch
   └─ Read (最小限)

4. 実装
   └─ 取得した情報を統合
```

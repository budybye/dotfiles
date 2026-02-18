---
name: jj-vcs
description: Guide for using Jujutsu (jj) VCS instead of Git. Use when the user works with version control, commits, branches, bookmarks, push/pull, or mentions jj/jujutsu. Covers jj best practices, Git-to-jj command mapping, and colocated repo workflows.
---

# Jujutsu (jj) VCS ベストプラクティス

## 基本方針

- **jj を優先**: `git` コマンドの代わりに `jj` コマンドを使う
- **colocated モード**: `.jj` と `.git` を共存させ、既存の Git ツールとの互換性を維持
- **ブックマーク**: Git のブランチに相当する概念は jj では「ブックマーク (bookmark)」

## jj の核心概念

### Git との根本的な違い

| 概念             | Git                            | jj                                    |
| ---------------- | ------------------------------ | ------------------------------------- |
| ワーキングコピー | 手動で `add` / `commit`        | 自動的にコミットされる                |
| ステージング     | `git add` でインデックスに追加 | 不要（存在しない）                    |
| ブランチ         | `branch` が HEAD に追従        | `bookmark` を手動で移動               |
| コンフリクト     | 操作をブロック                 | コミット可能、後で解決                |
| 子孫コミット     | 手動リベース                   | 自動リベース                          |
| stash            | `git stash`                    | `jj new @-`（兄弟コミットとして残る） |
| Undo             | reflog から手動復元            | `jj undo` / `jj op revert`            |

### ワーキングコピーの自動コミット

jj では作業中の変更が自動的にワーキングコピーコミットに記録される。
`git add` は不要。新規ファイルも削除も自動追跡される。

```bash
# ファイルを編集するだけで変更が記録される
echo "hello" > file.txt
jj st           # 変更が表示される
jj diff         # 差分を確認
```

### 基本ワークフロー

```bash
# 1. main から新しい変更を開始
jj new main

# 2. ファイルを編集（自動追跡）
# 3. 変更にメッセージを付けて次の変更を開始
jj commit -m "feat: 新機能の追加"

# 4. ブックマークを作成してプッシュ
jj bookmark create my-feature -r @-
jj git push
```

## 頻出コマンド対応表

| 用途             | Git                                | jj                               |
| ---------------- | ---------------------------------- | -------------------------------- |
| 状態確認         | `git status`                       | `jj st`                          |
| 差分表示         | `git diff`                         | `jj diff`                        |
| ログ表示         | `git log --oneline --graph`        | `jj log`                         |
| コミット         | `git commit -am "msg"`             | `jj commit -m "msg"`             |
| 説明編集         | `git commit --amend --only`        | `jj describe`                    |
| 新しい変更を開始 | `git checkout -b topic main`       | `jj new main`                    |
| 変更を親に統合   | `git commit --amend -a`            | `jj squash`                      |
| 部分的に統合     | `git add -p && git commit --amend` | `jj squash -i`                   |
| 変更を分割       | `git commit -p`                    | `jj split`                       |
| リベース         | `git rebase B`                     | `jj rebase -d B`                 |
| 取り消し         | -                                  | `jj undo`                        |
| stash 相当       | `git stash`                        | `jj new @-`                      |
| stash pop 相当   | `git stash pop`                    | `jj edit <元のコミット>`         |
| リモート取得     | `git fetch`                        | `jj git fetch`                   |
| プッシュ         | `git push`                         | `jj git push`                    |
| クローン         | `git clone`                        | `jj git clone`                   |
| ブランチ一覧     | `git branch`                       | `jj bookmark list`               |
| ブランチ作成     | `git branch name`                  | `jj bookmark create name`        |
| ブランチ移動     | `git branch -f name rev`           | `jj bookmark move name --to rev` |
| ブランチ削除     | `git branch -d name`               | `jj bookmark delete name`        |
| リバート         | `git revert rev`                   | `jj revert -r rev -B @`          |

詳細な対応表は [reference.md](reference.md) を参照。

## GitHub/GitLab ワークフロー

### PR 用にプッシュする（自動ブックマーク名）

```bash
jj new main
# 作業して...
jj commit -m "feat: 新機能"
# 自動生成ブックマーク名でプッシュ（@- = 親コミット）
jj git push --change @-
```

### PR 用にプッシュする（名前付きブックマーク）

```bash
jj new main
# 作業して...
jj commit -m "feat: 新機能"
jj bookmark create my-feature -r @-
jj git push
```

### レビュー対応（コミット追加方式）

```bash
jj new my-feature
# 修正して...
jj commit -m "address pr comments"
jj bookmark move my-feature --to @-
jj git push
```

### レビュー対応（リライト方式 / クリーンコミット）

```bash
jj new my-feature-    # 末尾の - は parent を意味する
# 修正して...
jj squash             # 親コミットに統合
jj git push --bookmark my-feature
```

## Colocated リポジトリ

### 初期化

```bash
# 既存の Git リポジトリに jj を追加（推奨）
jj git init --colocate

# 新規リポジトリ作成
jj git init
```

colocated モードでは `.jj` と `.git` が共存し、`jj` コマンド実行時に Git の状態も自動同期される。

### GitHub CLI (gh) との連携

colocated リポジトリでは `gh` コマンドがそのまま使える。
非 colocated の場合は環境変数を設定する:

```bash
export GIT_DIR=$PWD/.jj/repo/store/git
```

## よくあるパターン

### 複数の変更をスタックする

```bash
jj new main
# 変更 1
jj commit -m "refactor: 準備"
# 変更 2
jj commit -m "feat: 本体"
# 変更 3（作業中）
jj describe -m "test: テスト追加"
```

### 過去のコミットを編集

```bash
# 特定のコミットを直接編集
jj edit <revision>
# 編集後、新しいワーキングコピーに戻る
jj new
```

### コンフリクトの解決

```bash
# コンフリクトがあってもコミット可能
jj rebase -d main    # コンフリクトが発生してもブロックしない
jj st                # コンフリクトファイルを確認
# ファイルを編集して解決
jj st                # 解決を確認
```

### 便利な revset

```bash
# ローカルのみのブックマーク
jj log -r 'bookmarks() && ~remote_bookmarks()'
# main からの差分
jj log -r 'remote_bookmarks()..@'
# 自分の変更
jj log -r 'mine()'
```

## エージェント向けガイドライン

### コマンド選択の優先順位

1. `jj` コマンドが利用可能な場合は `jj` を使う
2. `jj` がない場合のみ `git` にフォールバック
3. `gh` コマンドは colocated リポジトリでそのまま使える

### シェル関数例（ユーザーの既存パターン）

ユーザーは以下のような `jjj` 関数を使用している:

```bash
# jjj "メッセージ" "ブックマーク名" "リモート名"
# - メッセージ省略時はデフォルト絵文字
# - ブックマーク名省略時は自動検出（jj → git → main）
# - リモート名省略時は origin
```

この関数は `jj describe` + `jj bookmark set` + `jj git push` を一括実行する。
新しいエイリアスや関数を提案する際はこのパターンに合わせる。

### コミットメッセージ

jj では `jj describe` でメッセージを設定する。
`jj commit -m "msg"` は describe + new の一括実行。

### 注意点

- `jj` にはステージングがないため `git add` 相当の操作は不要
- ワーキングコピーは常に自動コミットされる
- ブックマークは手動で作成・移動する必要がある
- `jj git push` 前にブックマークが正しいコミットを指しているか確認
- `--colocate` で Git ツールとの互換性を確保

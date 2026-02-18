# Git → jj 詳細コマンド対応表

## リポジトリ操作

| 用途                       | Git                           | jj                               |
| -------------------------- | ----------------------------- | -------------------------------- |
| 新規リポジトリ             | `git init`                    | `jj git init [--no-colocate]`    |
| クローン                   | `git clone <src> <dst>`       | `jj git clone <src> <dst>`       |
| リモート追加               | `git remote add <name> <url>` | `jj git remote add <name> <url>` |
| フェッチ                   | `git fetch`                   | `jj git fetch`                   |
| プッシュ（全て）           | `git push --all`              | `jj git push --all`              |
| プッシュ（単一）           | `git push origin <branch>`    | `jj git push --bookmark <name>`  |
| 自動ブックマークでプッシュ | -                             | `jj git push --change <rev>`     |

## 状態確認

| 用途                    | Git                               | jj                        |
| ----------------------- | --------------------------------- | ------------------------- |
| 状態表示                | `git status`                      | `jj st`                   |
| 現在の変更の差分        | `git diff HEAD`                   | `jj diff`                 |
| 特定リビジョンの差分    | `git diff <rev>^ <rev>`           | `jj diff -r <rev>`        |
| 2つのリビジョン間の差分 | `git diff A B`                    | `jj diff --from A --to B` |
| コミット詳細表示        | `git show <rev>`                  | `jj show <rev>`           |
| ログ（祖先）            | `git log --oneline --graph`       | `jj log -r ::@`           |
| ログ（全て）            | `git log --oneline --graph --all` | `jj log -r 'all()'`       |
| ログ（main 以外）       | `git log --branches --not main`   | `jj log`                  |
| blame                   | `git blame <file>`                | `jj file annotate <path>` |
| ファイル一覧            | `git ls-files`                    | `jj file list`            |
| ルートディレクトリ      | `git rev-parse --show-toplevel`   | `jj workspace root`       |

## コミット操作

| 用途                 | Git                                               | jj                            |
| -------------------- | ------------------------------------------------- | ----------------------------- |
| コミット             | `git commit -am "msg"`                            | `jj commit -m "msg"`          |
| 説明編集（現在）     | -                                                 | `jj describe`                 |
| 説明編集（親）       | `git commit --amend --only`                       | `jj describe @-`              |
| 説明編集（任意）     | -                                                 | `jj describe <rev>`           |
| 新しい変更を開始     | `git checkout -b topic main`                      | `jj new main`                 |
| 親に統合             | `git commit --amend -a`                           | `jj squash`                   |
| 部分的に統合         | `git add -p && git commit --amend`                | `jj squash -i`                |
| 祖先に統合           | `git commit --fixup=X && git rebase --autosquash` | `jj squash --into X`          |
| 変更を分割           | `git commit -p`                                   | `jj split`                    |
| 任意のコミットを分割 | -                                                 | `jj split -r <rev>`           |
| 差分を対話編集       | -                                                 | `jj diffedit -r <rev>`        |
| チェリーピック       | `git cherry-pick <src>`                           | `jj duplicate <src> -o <dst>` |
| リバート             | `git revert <rev>`                                | `jj revert -r <rev> -B @`     |

## ブランチ / ブックマーク

| 用途         | Git                            | jj                                                     |
| ------------ | ------------------------------ | ------------------------------------------------------ |
| 一覧         | `git branch`                   | `jj bookmark list`                                     |
| 作成         | `git branch <name>`            | `jj bookmark create <name>`                            |
| 前方移動     | `git branch -f <name> <rev>`   | `jj bookmark move <name> --to <rev>`                   |
| 後方移動     | `git branch -f <name> <rev>`   | `jj bookmark move <name> --to <rev> --allow-backwards` |
| 削除         | `git branch -d <name>`         | `jj bookmark delete <name>`                            |
| リモート追跡 | `git branch --set-upstream-to` | `jj bookmark track <name>@<remote>`                    |

## リベース / 整理

| 用途                          | Git                      | jj                          |
| ----------------------------- | ------------------------ | --------------------------- |
| リベース（子孫ごと）          | `git rebase --onto B A^` | `jj rebase -s A -d B`       |
| リベース（ブックマークごと）  | `git rebase B A`         | `jj rebase -b A -d B`       |
| 順序変更（A-B-C-D → A-C-B-D） | `git rebase -i A`        | `jj rebase -r C --before B` |
| マージ                        | `git merge A`            | `jj new @ A`                |

## 復元 / 取り消し

| 用途                   | Git                      | jj                    |
| ---------------------- | ------------------------ | --------------------- |
| 変更を破棄             | `git reset --hard`       | `jj abandon`          |
| 変更を空にする         | `git reset --hard`       | `jj restore`          |
| 一部ファイルを復元     | `git restore <paths>`    | `jj restore <paths>`  |
| 親を破棄（差分は保持） | `git reset --soft HEAD~` | `jj squash --from @-` |
| 直前の操作を取り消し   | -                        | `jj undo`             |
| 操作ログ               | -                        | `jj op log`           |
| 操作を巻き戻し         | -                        | `jj op revert`        |

## stash 相当

| 用途       | Git             | jj                       |
| ---------- | --------------- | ------------------------ |
| 一時退避   | `git stash`     | `jj new @-`              |
| 退避を復元 | `git stash pop` | `jj edit <元のコミット>` |

## コンフリクト解決

| 用途             | Git                                       | jj                                         |
| ---------------- | ----------------------------------------- | ------------------------------------------ |
| コンフリクト解決 | `git add <file> && git rebase --continue` | ファイルを編集するだけ（操作は中断しない） |

## 便利な revset 式

```bash
# 全ローカルブックマーク（リモートにないもの）
jj log -r 'bookmarks() && ~remote_bookmarks()'

# 自分のブックマーク
jj log -r 'mine() && bookmarks() && ~remote_bookmarks()'

# リモートの自分のブックマーク
jj log -r 'remote_bookmarks() && mine()'

# main からの差分（プッシュ前確認用）
jj log -r 'remote_bookmarks()..@'

# 全リビジョン
jj log -r 'all()'
```

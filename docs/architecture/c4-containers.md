# C4 — Container (Level 2)

**Scope:** dotfiles リポジトリ内部と、それが接続するランタイム側の箱物。  
**前提:** ソースツリーの正は `chezmoi source-path`（通常は Git 作業ツリー）。

## 図

```mermaid
C4Container
  title Container Diagram — Dotfiles repo and apply path

  Person(owner, "Machine owner", "ローカルで編集・適用")

  System_Boundary(repo, "Dotfiles repository") {
    Container(srcTree, "Source tree", "Git / chezmoi layout", "home/（dot_*・テンプレ）, docs/, Makefile, .github/")
    Container(automation, "Repo automation", "Make / GitHub Actions", "check・テスト・リリース系ワークフロー")
    Container(devEnv, "Dev environment", "Docker devcontainer", "任意。クロスアーキ開発用（.devcontainer/）")
  }

  Container_Ext(chezmoiCli, "Chezmoi CLI", "chezmoi", "template 展開・差分・apply・data（.chezmoidata 等）")
  Container_Ext(homeLayout, "Home & XDG paths", "POSIX FS", "~/.config, ~/.local, ~/.ssh 等 実ファイル")
  Container_Ext(osPkg, "OS & tool runtimes", "brew / apt / mise 等", "設定が参照する CLI・サービスの土台")
  Container_Ext(gitRemote, "Git remote", "Git hosting", "clone / push / pull")

  Rel(owner, srcTree, "編集・commit")
  Rel(owner, chezmoiCli, "chezmoi コマンド実行")
  Rel(chezmoiCli, srcTree, "ソースからテンプレ読取")
  Rel(chezmoiCli, homeLayout, "apply / merge で反映")
  Rel(srcTree, gitRemote, "Git で同期")
  Rel(automation, srcTree, "CI 上で検証・ビルド")
  Rel(devEnv, srcTree, "コンテナ内で開発")
  Rel(homeLayout, osPkg, "アプリがツールと連携")
```

## コンテナの切り方メモ

- **Source tree**は「デプロイ可能な1アプリ」ではないが、このリポの **主要な成果物**（設定の正）なのでコンテナ相当として置く。
- **Chezmoi CLI**はリポに含めない外部ツールだが、**apply パスの中核**なので境界の外に明示した。

詳細ディレクトリは [directory.md](../directory.md)。

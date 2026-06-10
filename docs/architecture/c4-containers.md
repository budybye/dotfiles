# C4 — Container (Level 2)

**Scope:** dotfiles リポジトリ内部と、適用パス上のランタイム側コンテナ。  
**前提:** ソースツリーの正は `chezmoi source-path`（通常は Git 作業ツリー）。

## 図

```mermaid
C4Container
  title Container Diagram for Personal Dotfiles

  Person(owner, "Machine owner", "ローカルで編集・適用")

  System_Boundary(repo, "Dotfiles repository") {
    Container(srcTree, "Source tree", "Git / chezmoi layout", "home/（dot_*・*.tmpl・encrypted_*.age）, docs/, Makefile")
    Container(scripts, "Bootstrap scripts", "Bash / PowerShell", ".chezmoiscripts の run_*（OS 別パッケージ導入）")
    Container(automation, "Repo automation", "Make / GitHub Actions", "check・test→tag→GHCR・IPFS")
    Container(devEnv, "Dev environment", "Docker Compose", ".devcontainer（Ubuntu / Xfce / xrdp）")
    Container(cloudInit, "Cloud-init profiles", "YAML", "Multipass / LXD 初期化")
  }

  Container_Ext(chezmoiCli, "Chezmoi CLI", "chezmoi", "テンプレ評価・diff・apply・data 読込")
  Container_Ext(homeLayout, "Home & XDG paths", "POSIX FS", "~/.config, ~/.local, ~/.ssh 等")
  Container_Ext(osPkg, "OS & tool runtimes", "brew / apt / mise / aqua", "設定が参照する CLI・サービスの土台")
  Container_Ext(gitRemote, "Git remote", "GitHub", "clone / push / pull / Packages")
  Container_Ext(ageBw, "age / Bitwarden", "CLI", "復号 identity とテンプレ用シークレット")

  Rel(owner, srcTree, "編集・commit")
  Rel(owner, chezmoiCli, "chezmoi / make を実行")
  Rel(chezmoiCli, srcTree, "ソースと .chezmoidata を読取")
  Rel(chezmoiCli, scripts, "apply 時に run_* を実行")
  Rel(chezmoiCli, ageBw, "暗号化ファイル復号・BW 参照")
  Rel(chezmoiCli, homeLayout, "apply / merge で反映")
  Rel(scripts, osPkg, "パッケージをインストール")
  Rel(srcTree, gitRemote, "Git で同期")
  Rel(automation, srcTree, "CI 上で検証・ビルド")
  Rel(automation, gitRemote, "タグ・Release・GHCR push")
  Rel(devEnv, srcTree, "コンテナ内で開発・検証")
  Rel(cloudInit, homeLayout, "VM 上で初期ユーザー環境を用意")
  Rel(homeLayout, osPkg, "アプリがツールと連携")
```

## コンテナの切り方メモ

- **Source tree** は独立デプロイのアプリではないが、このリポの **主要な成果物**（設定の正）なのでコンテナ相当として置く。
- **Bootstrap scripts** は source tree 内だが、apply 時にホストへ副作用を与える実行単位として分離した。
- **Chezmoi CLI** はリポに含めない外部ツールだが、**apply パスの中核**なので境界の外に明示する。
- mise / brew / apt 等は「設定が前提とするランタイム層」として 1 コンテナにまとめ、要素数を抑える。

詳細ディレクトリは [directory.md](../directory.md)。内部構成は [c4-components-source.md](./c4-components-source.md)。

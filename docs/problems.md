---
name: problems
description: 環境差の吸収における注意点、プラットフォーム差、ライブラリの癖
---

# 環境差の吸収と注意点 - Chezmoi Dotfiles

このドキュメントは、環境（macOS / Linux / WSL2 / Windows / Docker / CI）による差異を chezmoi で吸収する際の注意点と、プラットフォーム・ライブラリの癖をまとめています。新規設定追加時やトラブルシューティング時の参照用です。

## 1. プラットフォーム差

### OS 検出

| 項目             | 内容                                                                                                         |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| テンプレート変数 | `{{ .chezmoi.os }}` は `darwin` / `linux` / `windows` のいずれか                                             |
| WSL2             | WSL2 上では `linux` として検出される。Ubuntu と区別する場合は `env "WSL_DISTRO_NAME"` や hostname で判定する |

参照: [home/.chezmoi.toml.tmpl](../home/.chezmoi.toml.tmpl), [docs/plans/2025-02-19-wsl2-support.md](plans/2025-02-19-wsl2-support.md)

### アーキテクチャ

| 項目             | 内容                                                                                                 |
| ---------------- | ---------------------------------------------------------------------------------------------------- |
| テンプレート変数 | `{{ .chezmoi.arch }}` は `amd64` / `arm64`                                                           |
| GitHub Releases  | リリースによって `x86_64` 表記を使う場合がある。必要に応じてマッピングする（例: `amd64` → `x86_64`） |

参照: [docs/tech.md](tech.md), [home/private_dot_config/zsh/dot_aliases](../home/private_dot_config/zsh/dot_aliases)

### アーキテクチャ取得（シェルスクリプト）

| 環境                  | コマンド                    |
| --------------------- | --------------------------- |
| Linux (Debian/Ubuntu) | `dpkg --print-architecture` |
| macOS / その他        | `uname -m`                  |

スクリプトで両方に対応する例: `ARCH=${ARCH:-$(dpkg --print-architecture 2>/dev/null || uname -m)}`

参照: [home/dot_profile](../home/dot_profile), [home/.chezmoiscripts/linux/run_onchange_after_gui.sh.tmpl](../home/.chezmoiscripts/linux/run_onchange_after_gui.sh.tmpl)

### パス

| 環境                     | パス例                                                   |
| ------------------------ | -------------------------------------------------------- |
| Homebrew (Apple Silicon) | `/opt/homebrew/bin`, `/opt/homebrew/sbin`                |
| Homebrew (Intel)         | `/usr/local/bin`, `/usr/local/sbin`                      |
| Linux                    | apt/snap 系。`~/.local/bin`, `~/.local/share/*/shims` 等 |

参照: [home/dot_zshenv](../home/dot_zshenv), [home/private_dot_config/zsh/dot_zprofile](../home/private_dot_config/zsh/dot_zprofile)

## 2. 環境検出（CI / コンテナ）

以下の環境変数で CI やコンテナ環境を検出する。

| 環境           | 検出方法                                | 用途                           |
| -------------- | --------------------------------------- | ------------------------------ |
| GitHub Actions | `env "GITHUB_ACTIONS"`                  | age 暗号化無効化、SSH キー除外 |
| Codespaces     | `env "CODESPACES"`                      | ユーザー名 vscode              |
| Dev Container  | `env "REMOTE_CONTAINERS"`               | ユーザー名 dev                 |
| Docker         | `env "DOCKER"`                          | ユーザー名 docker              |
| WSL2           | `env "WSL_DISTRO_NAME"` または hostname | Ubuntu ネイティブとの区別      |

参照: [home/.chezmoi.toml.tmpl](../home/.chezmoi.toml.tmpl)

## 3. ファイル配置の注意点

### .zshenv

- `$HOME/.zshenv` に必ず配置する
- ZDOTDIR の設定はここで行う。ZDOTDIR 配下のファイルでは zsh 起動時に読み込まれない
- chezmoi では `home/dot_zshenv` として管理し、適用先は `~/.zshenv`

参照: [home/dot_zshenv](../home/dot_zshenv)

### .chezmoiignore の順序

- 条件分岐の順序によって結果が変わる
- `{{ if eq .chezmoi.os "windows" }}` と `{{ else }}` の対応関係に注意する
- Windows 以外の else ブロックで linux 以外を除外する等、ネストした条件を慎重に書く

参照: [home/.chezmoiignore](../home/.chezmoiignore)

### スクリプトの OS 分岐

- `.chezmoiscripts/darwin/` は macOS 以外では .chezmoiignore で除外
- `.chezmoiscripts/linux/` は Linux 以外では .chezmoiscripts で除外
- `.chezmoiscripts/windows/` は Windows 以外では除外

参照: [home/.chezmoiignore](../home/.chezmoiignore)

## 4. テンプレート・スクリプトの癖

| ツール/設定                 | 癖                                                                                                                                                                  | 対処例                                                                                                                    |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| zsh .profile 読み込み       | zsh では `source` が bash 由来の構文。`emulate sh -c "source ..."` で bash 互換モードにして読み込む                                                                 | [home/private_dot_config/zsh/dot_zprofile](../home/private_dot_config/zsh/dot_zprofile)                                   |
| 対話シェル判定              | Bash の `[ -z "$PS1" ]` は Zsh で誤動作する（PS1 が未設定の場合がある）。`[[ -o interactive ]]` を使用する                                                          | [home/private_dot_config/zsh/dot_zshrc](../home/private_dot_config/zsh/dot_zshrc)                                         |
| zellij/tmux 自動起動        | Cursor/VS Code の統合ターミナルでは zellij が即終了してターミナルが閉じる。`TERM_PROGRAM` が vscode または Cursor のときはスキップする                              | [home/private_dot_config/zsh/dot_zprofile](../home/private_dot_config/zsh/dot_zprofile)                                   |
| gitHubLatestReleaseAssetURL | リリースによりアーキテクチャ名が異なる（amd64 vs x86_64）。パターンマッチで取得できない場合はマッピングを検討する                                                   | [home/.chezmoiexternal.toml.tmpl](../home/.chezmoiexternal.toml.tmpl)                                                     |
| dpkg                        | Linux (Debian/Ubuntu) 専用。macOS では存在しない。スクリプト内で `dpkg --print-architecture` を使う場合は、Linux 専用スクリプトに限定するかフォールバックを用意する | [home/.chezmoiscripts/linux/run_onchange_after_cli.sh.tmpl](../home/.chezmoiscripts/linux/run_onchange_after_cli.sh.tmpl) |

## 5. ライブラリ・ツール固有の癖

| ツール         | 癖                                                                                   | 備考                                                                                                  |
| -------------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| Starship       | OS ごとにアイコン定義が異なる（Windows, Linux 等）                                   | [home/private_dot_config/starship/starship.toml](../home/private_dot_config/starship/starship.toml)   |
| Neovim         | Windows の VSCode 統合ターミナル向けの色設定がある                                   | [home/private_dot_config/nvim/colors/monokai.vim](../home/private_dot_config/nvim/colors/monokai.vim) |
| Docker         | `ARCH` は `dpkg --print-architecture \|\| uname -m` で取得。WSL では dpkg が利用可能 | [home/private_dot_config/zsh/dot_aliases](../home/private_dot_config/zsh/dot_aliases)                 |
| Karabiner      | macOS 専用。`pbpaste` 等の macOS コマンドに依存する                                  | [home/.chezmoiignore](../home/.chezmoiignore)                                                         |
| fcitx5, Fusuma | Linux 専用。.chezmoiignore で darwin では適用しない                                  | [home/.chezmoiignore](../home/.chezmoiignore)                                                         |

## 6. チェックリスト（新規設定追加時）

以下の項目を確認してからコミットする。

- [ ] OS 条件は `{{ .chezmoi.os }}` で適切に分岐しているか
- [ ] アーキテクチャ依存のバイナリは `dpkg --print-architecture` と `uname -m` の両方に対応しているか
- [ ] .chezmoiignore に適切な条件を追加したか（条件の順序に注意）
- [ ] CI 環境（GITHUB_ACTIONS 等）ではスキップすべき処理か
- [ ] 統合ターミナル（Cursor/VS Code）で自動起動するスクリプトは `TERM_PROGRAM` チェックを入れているか

## 関連ドキュメント

- [要件定義](requirements.md) - 対応 OS・ツール要件
- [設計書](design.md) - クロスプラットフォーム設計
- [ディレクトリ構成](directory.md) - テンプレート変数・OS 分岐の例

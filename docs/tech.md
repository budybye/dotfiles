# 技術スタック - Chezmoi Dotfiles Management System

## コア技術

- **Chezmoi**: ^2.47.0 - ドットファイル管理システム
- **Go**: ^1.21.0 - Chezmoi の実行環境
- **Bash**: ^5.0.0 - シェルスクリプト実行環境
- **Zsh**: ^5.9.0 - ログインシェル環境
- **Make**: ^4.0.0 - ビルドツール

## 対応 OS・プラットフォーム

- **macOS**: Sequoia (14.0+) - プライマリ開発環境
- **Ubuntu**: 24.04 LTS (Noble Numbat) - Linux 開発環境
- **Docker**: ^24.0.0 - コンテナ化環境
- **Multipass**: ^1.13.0 - 軽量 VM 管理
- **WSL2**: Ubuntu 24.04 LTS - Windows Subsystem for Linux 2

## 開発ツール・エディタ

- **VSCode**: ^1.85.0 - メインエディタ
- **Cursor**: ^0.45.0 - AI 支援エディタ
- **Claude**: ^4 - Console AI Agents
- **Neovim**: ^0.9.0 - ターミナルエディタ
- **Alacritty**: ^0.13.0 - GPU 加速ターミナル
- **Ghostty**: ^0.3.0 - モダンターミナル
- **Byobu(tmux)** - ターミナルマルチプレクサ

## シェル・ターミナル

- **Zsh**: ^5.9.0 - メインシェル
- **Fish**: ^3.7.0 - 対話的シェル
- **Bash**: ^5.2.0 - 互換性シェル
- **Starship**: ^1.18.0 - シェルプロンプト
- **Sheldon**: ^0.7.0 - シェルプラグイン管理

## パッケージ管理

- **Homebrew**: ^4.1.0 - macOS パッケージ管理
- **Mise**: ^0.2.0 - ランタイムバージョン管理
- **Aqua**: ^2.20.0 - パッケージマネージャー
- **UV**: ^0.2.0 - Python パッケージ管理

## セキュリティ・暗号化

- **Age**: ^1.1.0 - モダン暗号化ツール
- **Bitwarden CLI**: ^1.0.0 - パスワード管理
- **SSH**: ^9.0.0 - セキュアシェル

## 開発環境・CI/CD

- **Git**: ^2.40.0 - バージョン管理
- **GitHub Actions**: ^3.0.0 - CI/CD
- **Dev Containers**: ^1.0.0 - 開発コンテナ
- **Docker Compose**: ^2.20.0 - コンテナオーケストレーション

## システム管理・モニタリング

- **Fastfetch**: ^10.0.0 - システム情報表示
- **Neofetch**: ^7.1.0 - システム情報表示
- **Sampler**: ^1.1.0 - システムモニタリング
- **Byobu**: ^5.133.0 - ターミナルマルチプレクサー
- **Tmux**: ^3.3.0 - ターミナルマルチプレクサー

## ファイル管理・検索

- **Ripgrep**: ^13.0.0 - 高速検索
- **Bat**: ^0.24.0 - シンタックスハイライト
- **LSD**: ^0.24.0 - モダン ls
- **Fusuma**: ^2.0.0 - タッチパッドジェスチャー

## ネットワーク・通信

- **Wireshark**: ^4.0.0 - ネットワーク解析
- **IPFS**: ^0.20.0 - 分散ファイルシステム
- **Element**: ^1.11.0 - Matrix クライアント

## メディア・エンターテイメント

- **MPD**: ^0.23.0 - 音楽プレーヤーデーモン
- **NCMPCPP**: ^0.9.0 - MPD クライアント
- **ffmpeg**: ^6.0.0 - メディアフォーマット管理
- **yt-dl** - youtube ダウンローダー (使えなくなった)

## 入力・アクセシビリティ

- **Fcitx5**: ^5.1.0 - 入力メソッド
- **Karabiner-Elements**: ^15.0.0 - キーボードカスタマイズ

## ブラウザ・Web

- **Chrome**: ^120.0.0 - Web ブラウザ
- **Brave**: ^1.60.0 - プライバシー重視ブラウザ

## 重要な制約事項

- **Chezmoi 設定**: `home/.chezmoi.toml.tmpl` でのみ管理
- **暗号化ファイル**: `age`暗号化で管理（`*.age`拡張子）
- **シークレット管理**: Bitwarden CLI 経由でのみアクセス
- **OS 別設定**: テンプレート変数による環境別分岐
- **XDG 準拠**: XDG Base Directory Specification に準拠

## 実装規則

- 命名規則は `chezmoi` の設計に従い `.` は `dot_` に置き換える
- `.tmpl` をつけることで Go Template 構文を使用できる
- 設定ファイルは `home/private_dot_config/` に配置
- シェルスクリプトは `home/.chezmoiscripts/` に配置
- 暗号化ファイルは `age` で暗号化
- OS 別設定は `.chezmoi.toml.tmpl` のテンプレート変数で制御
- パッケージ管理は `.chezmoidata/packages.yaml` `Brewfile` で管理
- ツール、ランタイムは `mise` `~/.config/mise/config.toml` で管理

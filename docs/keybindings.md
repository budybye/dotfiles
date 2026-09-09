---
name: keybindings
description: キーバインド設定の管理場所と区分
---

# キーバインド設定

キーバインドは、操作するレイヤーごとに各アプリの設定ファイルで管理します。共通設定へ無理に集約せず、アプリ固有の形式を維持します。

## 設定区分

| 区分 | アプリ | 管理場所 | 状態 |
|---|---|---|---|
| OS キーリマップ | Karabiner-Elements | [`home/private_dot_config/karabiner/karabiner.json`](../home/private_dot_config/karabiner/karabiner.json) | 管理中 |
| ウィンドウ管理 | AeroSpace | [`home/private_dot_config/aerospace/aerospace.toml`](../home/private_dot_config/aerospace/aerospace.toml) | 管理中 |
| 入力メソッド | Fcitx5 | [`home/private_dot_config/fcitx5/config`](../home/private_dot_config/fcitx5/config) | 管理中 |
| ターミナル | Ghostty | [`home/private_dot_config/ghostty/config`](../home/private_dot_config/ghostty/config) | 現在は未設定。競合回避時に追加検討 |
| ターミナル多重化 | Zellij | [`home/private_dot_config/zellij/config.kdl`](../home/private_dot_config/zellij/config.kdl) | 管理中 |
| ターミナル多重化 | herdr | [`home/private_dot_config/herdr/config.toml`](../home/private_dot_config/herdr/config.toml) | 管理中 |
| ターミナル多重化（互換） | tmux | [`home/private_dot_config/tmux/tmux.conf`](../home/private_dot_config/tmux/tmux.conf) | 管理中 |
| エディター | Neovim | [`home/private_dot_config/nvim/init.vim`](../home/private_dot_config/nvim/init.vim) | 管理中 |
| エディター | VS Code / Code 互換 | [`home/private_dot_config/Code/user-data/User/keybindings.json`](../home/private_dot_config/Code/user-data/User/keybindings.json) | 管理中 |
| エディター | Zed | [`home/private_dot_config/zed/settings.json`](../home/private_dot_config/zed/settings.json) | 設定のみ。専用 keymap なし |
| Git TUI | lazygit | [`home/private_dot_config/lazygit/config.yml`](../home/private_dot_config/lazygit/config.yml) | 管理中 |
| Agent TUI | Pi | [`home/private_dot_config/pi/agent/keybindings.json`](../home/private_dot_config/pi/agent/keybindings.json) | 管理中 |
| アプリランチャー | Raycast | — | キーバインド設定は未管理 |

## 区分の使い分け

### OS キーリマップ

Karabiner-Elements は macOS 全体のキー変換・ショートカットを担当します。アプリ内部の操作はここへ集約しません。

### 入力メソッド

Fcitx5 は入力メソッドの切り替えと候補操作を担当します。OS キーリマップやエディター操作とは分離します。

### ターミナル

Ghostty はターミナル本体の操作を担当します。現時点ではカスタム keybind を設定していませんが、Zellij・herdr・tmux とのショートカット競合を避ける必要が生じた場合に追加します。

### Git TUI

lazygit は Git 操作用の TUI キーバインドを管理します。Git の操作キーを tmux / Zellij の設定へ追加しません。

### ウィンドウ管理

AeroSpace はウィンドウ・ワークスペースの移動を担当します。ターミナルやエディター内部の操作はここに追加しません。

### ターミナル多重化

Zellij を主設定とし、tmux / Byobu は別形式の互換設定として分離します。ペイン、タブ、リサイズ、コピー、モード切り替えは各設定ファイル内で管理します。

### エディター

VS Code / Code 互換のキーバインドと Zed の設定を別管理します。Zed に VS Code 用 `keybindings.json` を流用する前提は置きません。

### Agent TUI

Pi のカーソル操作など、ターミナル内アプリ固有の操作を管理します。Zellij のモード操作とは混在させません。

### アプリランチャー

Raycast はインストール定義のみ存在し、現在はキーバインド設定をリポジトリで管理していません。設定を追加する場合は Raycast のエクスポート形式を確認してから、専用ファイルとして追加します。

## 運用ルール

- 新しいキーバインドは、最も内側の操作対象アプリへ追加する。
- 同じキーを複数レイヤーで使う場合は、修飾キーと有効範囲を明記する。
- 既存のショートカットを移動・統合する前に、対象アプリの設定形式を確認する。
- 設定を追加したら、この表の管理場所と状態を更新する。

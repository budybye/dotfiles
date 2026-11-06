---
version: alpha
title: ターミナルスタックのキーマップ設計
tags: [terminal, keymap, multiplexer, tui, design]
name: Kanagawa Dragon Terminal
description: ghostty→herdr→pi/omp スタックの視覚言語・キー所有権・衝突解消・逸脱記録
omitted:
  - section: rounded
    reason: 端末とペインに角丸なし(境界は枠線と gap のみ)
colors:
  primary: "{colors.on-surface}"
  surface: "#112233"
  on-surface: "#D4C69A"
  dragon-black1: "#12120f"
  dragon-black3: "#181616"
  dragon-gray: "#a6a69c"
  dragon-white: "#c5c9c5"
  dragon-blue2: "#8ba4b0"
  dragon-violet: "#8992a7"
  dragon-aqua: "#8ea4a2"
  dragon-green: "#87a987"
  dragon-orange: "#b6927b"
  dragon-red: "#c4746e"
typography:
  terminal:
    fontFamily: "HackGen35 Console NF"
    fontSize: 13px
  zed-ui:
    fontFamily: "HackGen35 Console NF"
    fontSize: 15px
  zed-buffer:
    fontFamily: "HackGen35 Console NF"
    fontSize: 16px
    fontWeight: 400
spacing:
  window-padding: 8px
components:
  ghostty:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.terminal}"
    padding: 8px
  starship-prompt:
    backgroundColor: "{colors.dragon-gray}"
    textColor: "{colors.dragon-black3}"
  zed:
    typography: "{typography.zed-buffer}"
---

# ターミナルスタックのキーマップ設計

## Overview

ghostty(ターミナル) → herdr 0.9.5(マルチプレクサ兼スーパーバイザ/ペイン管理) → pi 1.5.0 / omp 18.16.0(コーディングハーネス)。zellij 0.45.1 は不採用(binary/config は残置、herdr が無い環境のフォールバック起動のみ)。参照として zed(GUI エディタ、変更対象外)。更新: 2026-11-06。

**消費モデル**: キーは外側の層が「自分のバインドに一致するキー」を消費し、一致しないキーだけを内側に渡す。ghostty は macOS で `Alt+←/→` を `esc:b` / `esc:f` に変換して送るため、内側では `Alt+b` / `Alt+f` として観測される。

**視覚言語**: Kanagawa Dragon を全層の基調とし、ghostty のみ独自の背景 `#112233` / 前景 `#D4C69A`(紺+薄黄緑)を上乗せする。omp dark と zed light は Monokai 系がアクセント(omp light は titanium)。濃色・低彩度・低まぶしさを原則とし、奥行きは透明度で表現する。

**キー設計原則**: 1 キー = 1 所有者(所有権マップ参照)。新ツールはデフォルト優先で導入し、衝突キーだけを退避させる。全逸脱は逸脱リストに記録する。OS レイヤー(karabiner / Raycast / fcitx5 / fusuma)はスタック外だが、突合を入力環境セクションに記録する。

**状態**: 2026-09-22 移行を部分適用 — 起動経路を herdr に一本化(zlogin / bash_profile、zellij は不採用・binary/config は残置)、omp keybinding 上書きを削除して既定復帰(pi の `~/.pi/agent/keybindings.json` は残存するが、`PI_CODING_AGENT_DIR=~/.config/pi/agent` のため pi は読まない)。herdr config は git 復帰後に**現実効値 + 既定値コメントの統合版**へ整理(onboarding=false / kanagawa / default_shell=zsh / non_login / sidebar 28 / prompt_new_tab_name=false / toast off / CJK cursor)。既定の `/bin/zsh` は herdr pane で findcmd SIGABRT のため `default_shell = "zsh"` + `non_login` は意図的維持。herdr integration は pi v9 / omp v10 とも導入済み(chezmoi 追跡ファイルへのシンボリックリンク)。未実施: zellij uninstall・mise/tools.toml・tech.md / directory.md。`stty -ixon` は `setopt no_flow_control` が既存のため不要。

## Colors

パレットは Kanagawa Dragon 一族で統一し、Monokai 系は omp dark と zed light のアクセントに限定する。front matter の `colors` トークンは starship パレット(`[palettes.color]` の 10 色。値は dragon\* 系、キー名は `gray` / `navy` / `yellow` 等)と ghostty の独自背景/前景。それ以外の層はテーマ名指定で同じ血統を参照する。

| 層 | テーマ | 実値・備考 |
|---|---|---|
| ghostty | **Kanagawa Dragon** | 独自 bg `#112233`(surface) / fg `#D4C69A`(on-surface)。代替候補 Monokai Pro はコメントで保管 |
| zellij | (不採用) | `config.kdl` はコメントのみ(テーマ指定なし = 既定) |
| herdr | **kanagawa** | テーマ名指定のみ |
| starship | **Kanagawa Dragon パレット** | `[palettes.color]` に dragon\* 系の値 10 色を直接定義(キー名は dragon\* でなく `gray` / `navy` / `yellow` 等。`yellow` = dragonOrange、`blue` = dragonAqua) |
| pi | **dark**(内蔵) | settings.json に `theme` キーなし(既定値) |
| omp | **dark-monokai** / light: titanium | profiles/god の config.yml |
| zed | system 追従: dark **Kanagawa Dragon - No Italics** / light **Monokai Pro (CE)** | アイコン Material Icon Theme |

## Typography

フォントは **HackGen35 Console NF** に統一(ghostty / zed)。白源(HackGen)35 Console の **Nerd Fonts パッチ版**であり、"NF" は Nerd Fonts の略(Nord ではない)。等幅、日本語全角 1:2、Nerd Font グリフ内蔵。インストール済み: `HackGen35ConsoleNF-{Regular,Bold}.ttf` / `HackGenConsoleNF-{Regular,Bold}.ttf`。

- **ghostty**: 13.0pt + `font-thicken = true`(低解像度での視認性補正)。
- **zed**: UI 15pt / buffer 16pt、weight 400、行間 comfortable。
- **TUI(zellij / herdr / pi / omp)**: 端末フォントをそのまま継承(個別指定なし)。
- トークンの `fontSize` は spec の単位制約(px/em/rem)により px 表記。実運用値は pt(ghostty 13.0 / zed 15・16)。

## Layout

**層構造(現行)**: ghostty ウィンドウ(タイトルバー非表示。起動時の全画面化 `fullscreen` はコメントアウトで未設定)→ herdr ワークスペース「dev」(`executable_herdr-dev` が構築)→ agent ペイン。zellij は不採用で、`layouts/dev.kdl`(5 タブ)は残置のみ(`config.kdl` はコメントのみで `default_layout` 未設定のため、フォールバックの素の `zellij` 起動では読まれない)。

**幾何パラメータ**:

| 項目 | 値 | 出典 |
|---|---|---|
| ghostty ウィンドウ余白 | 8px(x/y)+ balance | ghostty config |
| herdr サイドバー幅 | 28 列(min 18 / max 36) | herdr config `[ui]` |
| herdr モバイル閾値 | 64 列 | 同上 |
| herdr タブバー | 上部配置、単一タブ時も表示 | 既定 |
| herdr agent パネル並び | `spaces` | 同上 |
| zed 端末 | dock right、12pt | zed settings.json |
| zellij レイアウト | dev.kdl(タブ 101/102/Dev/herdr/Docs。残置のみ) | zellij layouts |

## Elevation & Depth

奥行きは影ではなく**透明度**で表現する。ghostty `background-opacity = 0.78` により背景 `#112233` が全体透過し、壁紙が沈み込む。macOS ネイティブ全画面は使わず `macos-non-native-fullscreen = true`、タイトルバーは非表示。階層の区別は境界線と gap(Shapes 参照)で行い、浮き彫り表現は導入しない。

## Shapes

角丸は存在しない(omitted: rounded)。ペイン境界は枠線 + gap:

- herdr: `pane_borders` / `pane_gaps` は既定のまま(config.toml ではコメントアウト。それぞれ `auto` / `true`)
- zellij: `pane_frames` 既定(true)
- ghostty: `window-padding-balance = true` で端余白を均す
- ghostty カーソル: `cursor-style = block` + `cursor-style-blink = true`。サイズ系(`adjust-cursor-thickness` / `adjust-cursor-height`)と `cursor-opacity`(既定 1)は未設定(v1.4.0 で利用可能なノブ)。タイピング中は `mouse-hide-while-typing = true` でマウスカーソルを退ける。

## Components

| コンポーネント | 設定ファイル(dotfiles ソース) | テーマ | フォント | キー所有 |
|---|---|---|---|---|
| ghostty | `home/private_dot_config/ghostty/config` | Kanagawa Dragon + 独自 bg/fg | HackGen35 Console NF 13pt | plain `ctrl+文字` は消費しない |
| zellij | `home/private_dot_config/zellij/config.kdl` | 既定(テーマ指定なし) | 端末継承 | 既定のみ(config はコメントのみ。フォールバック起動時は `Ctrl+o/t/p/n/s/h/g/q` + Alt 群が有効) |
| herdr | `home/private_dot_config/herdr/config.toml` | kanagawa | 端末継承 | `Ctrl+b` prefix のみ(direct キーなし) |
| starship | `home/private_dot_config/starship/starship.toml` | Kanagawa Dragon パレット | 端末継承 | — |
| pi | `home/private_dot_config/pi/agent/`(`~/.config/pi/agent`) | dark | 端末継承 | 既定 + `~/.config/pi/agent/keybindings.json`(chezmoi 管理、エディタ移動 6 件を上書き) |
| omp | `home/private_dot_config/omp/profiles/god/` | dark-monokai | 端末継承 | 全既定(`keybindings.yml` なし) |
| zed | `home/private_dot_config/zed/settings.json` | KD - No Italics / Monokai Pro (CE) | HackGen35 Console NF | `cmd` ベース(GUI 層) |

## Do's and Don'ts

- **Do**: 1 キー = 1 所有者。所有者でない層は代替キーを使う。新 mux/ツールは**デフォルト優先**で導入し、衝突キーだけを所有権マップに従って退避させる。
- **Do**: 逸脱は必ず逸脱リストに全件・理由付きで記録する。テーマは kanagawa 系で統一し、monokai はアクセントのみに使う。奥行きは透明度と境界線で表現する。
- **Don't**: 複数層での同時主張を作らない。`Ctrl+q` = zellij Quit のような破壊的既定を「既定維持原則」の名目で放置して危険を先送りにしない(zellij は現在フォールバック起動時のみ該当。omp の `Ctrl+Q` 解除は `keybindings.yml` 削除で撤回済み。zellij を使う場合は Quit を別キーへ退避)。
- **Don't**: 層ごとに無関係なテーマを混在させない。記録なきキー変更をしない。

## 入力環境(OS レイヤー)

スタック(ghostty 以下)は macOS 前提だが、両 OS の入力系を併記する。macOS = karabiner / Raycast / システムホットキー、Ubuntu = fcitx5 / fusuma。いずれもスタック層との所有権衝突なし(各節の突合参照)。

### Ubuntu: fcitx5(`~/.config/fcitx5/config` の IME ホットキー)

| 機能 | キー |
|---|---|
| トリガー(IMS 切替トグル) | `Control+Shift+Control_L` / `Zenkaku_Hankaku` / `` ` ``(grave) |
| 代替トリガー | `Shift_L` |
| IM グループ前後切替 | `Super+space` / `Shift+Super+space` |
| 次候補 / 前候補 | `Tab` / `Shift+Tab` |
| 候補ページ送り | `Up` / `Down` |
| Preedit 表示トグル | `Ctrl+Alt+P` |
| 動作 | `ActiveByDefault = true`、`PreeditEnabledByDefault = true`、候補 1 ページ 5 件、入力状態はアプリ間非共有(`ShareInputState = No`) |

所有権マップとの突合: fcitx5 の `Tab`/`Shift+Tab`(候補移動)は herdr `prefix+tab` や pi/omp thinking の `Shift+Tab` と**字面が重なるが衝突ではない**: IME は変換中(プリエディット/候補ウィンドウ表示中)のみキーを捕捉し、通常入力時はスタックへそのまま通過する。`TriggerKeys`(`Control+Shift+Control_L` / `Zenkaku_Hankaku` / `` ` ``)・`Super+space` 群・`Ctrl+Alt+P` もスタック全層で未使用。herdr の実験機能 `switch_ascii_input_source_in_prefix` は macOS/Windows のみ対応で fcitx5 は対象外だが、トリガーが prefix(`Ctrl+b`)と重ならないため実害なし。

### Ubuntu: fusuma(`~/.config/fusuma/config.yml` のタッチパッドジェスチャ)

| ジェスチャ | 動作 |
|---|---|
| 3 本指スワイプ | ドラッグ(`xdotool` mousedown/mousemove/mouseup、accel 2、interval 0.01s) |
| 4 本指 swipe left / up | `ctrl+Super+Down`(次のワークスペース) |
| 4 本指 swipe right / down | `ctrl+Super+Up`(前のワークスペース) |
| pinch in / out | `ctrl` + scroll(ズームイン/アウト) |
| 閾値 | swipe 0.75(標準の 75%) / pinch 0.5 |
| interval | swipe・pinch とも 0.2s |

所有権マップとの突合: `ctrl+Super+Up/Down` はウィンドウマネージャ層(**スタック外**)で捕捉されるワークスペース切替。スタック全層で `ctrl+Super+*` は未使用。

### macOS: karabiner / Raycast / システムホットキー

**karabiner**(`home/private_dot_config/karabiner/karabiner.json`): JIS キーボード運用のリマップ群。扱うキー群は全て mandatory 修飾(`fn` / `right_option` / 左Cmd / 左Ctrl)をホールドした状態で発動し、素キーは原則不変(例外は下記)。現環境では Karabiner-Elements 自体が未導入(Brewfile は `cask "karabiner-elements"` をコメントアウト、設定ファイルのみ配備):

| ルール群 | 対象キー |
|---|---|
| カーソル移動系 | `→/←/↑/↓`、`Home`、`End`、`PageUp`、`PageDown` |
| 記号 | `_` `¥` `@` `[` `]` |
| F キー / 数値 | `F1`〜`F12`、`1`〜`9` |
| 制御キー | `Cmd+Q`、`Cmd+W`、アクティビティモニタ起動、強制終了ウィンドウ、`Esc`、`Tab`、`Shift+Tab` |
| 編集系 | `Enter`、`BackSpace`、`DELETE`、単語選択、スクリーンショット、undo/cut/copy/paste |
| その他 | `CapsLock` 切替、選択文字の Google 検索、メニューバー/Dock フォーカス、Finder 表示・リネーム系、Chrome リロード・アドレスバー・タブ系 |

Raycast 起動ルールは karabiner 側に**存在しない**(ホットキーは Raycast 自身が管理)。

実測(jq で全 manipulator を走査): 全ての `from` が **mandatory 修飾 prefix 方式**:`fn`(カーソル移動 / F1–F12 / 記号 / Google 検索)、`right_option`(数値キー / `Cmd+Q`・`W` 相当群 / `Enter`・`BackSpace`・`DELETE` / undo・cut・copy・paste / `right_option+space` = CapsLock)、Finder・Chrome 群は `left_command` / `left_control` + `frontmost_application_if` 条件付き(一部 Cmd 系は GLOBAL)。**complex_modifications に修飾なしの素キー(`Tab`・矢印・`Esc`)や `Alt+文字` を書き換える manipulator は 0 件。`Ctrl+文字` は Finder/Chrome 限定の `left_control` + 文字(t/w/n/f/l/j 等)のみ。例外として `simple_modifications` が素の `japanese_eisuu`(英数)→`right_option`、`japanese_kana`(かな)→`fn` に書き換える(IME 切替キーが全域で別キーになる)** → 端末アプリ内の所有権マップは macOS 上も成立する。

**Raycast**(`/Applications/Raycast.app`): ホットキーは `Option+Space`(ユーザー設定)。Spotlight は無効化済み(symbolic hotkeys 64/65 とも enabled=0 実測)。plist は移行初期値 `initialSpotlightHotkey = "Command-49"` のみを記録しており現ホットキーは plist 外管理のため、実値はユーザー設定を正とする。`Cmd+Space` は未割当(Spotlight 無効 + Raycast が Option 側へ移動)。`Option+Space` はスタック全層で未使用(zellij Alt 群は `[` `]` 等のみ / herdr direct キーなし / omp・pi・ghostty・karabiner も space なし)→ 非衝突。**注**: `右 Option+Space` は karabiner が CapsLock トグルとして所有(mandatory `right_option` + space、GLOBAL 実測)。Raycast の `Option+Space` は左 Option で運用すること(右側で押すと karabiner が先に取る)。

**macOS デフォルトでスタックに関わるキー(実測: `defaults read com.apple.symbolichotkeys`)**: 表は実測でキー割当(parameters)から機能名が確定できた symbolic ID のみ(60/61 = 入力ソース、32 = Mission Control、36 = Show Desktop)。機能名を確定できない ID(19/20/52/57/62/79〜82 等)は表から割愛した。**`Ctrl+←/→` の macOS 側割当は未検証**: ID 19 は enabled=0 だが割当は `Cmd+Option+-`(Spaces 移動ではない)、ID 20 は enabled=0 で値なし、ID 79〜82 は enabled=1 で値なし(既定割当のまま)。Spaces 切替が `Ctrl+←/→` を奪っているか、omp の `Ctrl+←/→` 語移動が届くかは確認していない。

| キー | 機能 | 状態 | スタックへの影響 |
|---|---|---|---|
| `Ctrl+Space` / `Ctrl+Option+Space` | 入力ソース切替(60/61) | 有効 | なし(スタック全層で未使用) |
| `Ctrl+↑` | Mission Control(32) | 有効 | なし |
| `F11` | Show Desktop(36) | 有効 | なし |
| `Option+Space` | **Raycast**(Spotlight 代替) | 有効 | なし(GUI 層・スタック全層で未使用) |
| `Cmd+Space` | 未割当(Spotlight 無効化) | 空き | なし |
| `Cmd+Tab` / `Cmd+Shift+Tab` | アプリ切替 | 有効 | なし(GUI 層) |
| ``Cmd+` `` | 同アプリのウィンドウ切替 | 有効 | なし(GUI 層) |
| `Cmd+Shift+3/4/5` | スクリーンショット | 有効 | なし(GUI 層) |

突合: karabiner のリマップは mandatory 修飾 prefix 方式で、Finder/Chrome 限定の `left_control` + 文字を除きスタック所有キー(`Ctrl+b` prefix・`Ctrl+o/t/p/n/s/h/g/q`・Alt 群)に干渉しない(上記実測)。GUI 層の `Cmd` 系は端末内 TUI へ届かない。→ スタックへの影響なし。

**トラックパッド**(`defaults read com.apple.AppleMultitouchTrackpad` 実測): 3 本指ドラッグ = ON(`TrackpadThreeFingerDrag = 1`、お気に入り設定)、3 本指スワイプ/タップ = OFF(`TrackpadThreeFinger{Horiz,Vert}SwipeGesture = 0` / `TapGesture = 0`)、4 本指横/縦スワイプ = ON(Mission Control / Spaces 切替、`TrackpadFourFinger{Horiz,Vert}SwipeGesture = 2`)、4 本指ピンチ = ON(= 2)。Ubuntu の fusuma(3 本指ドラッグ + 4 本指スワイプで workspace 切替)はこの好みの OS 間再現。

## 所有権マップ(現行: herdr 運用)

各キーの所有者は 1 層のみ。現行の起動経路は ghostty → herdr → pi/omp。zellij は herdr が無い環境のフォールバック起動のみ(下記「zellij フォールバック」)。herdr はユーザー設定の direct キーを持たず(`[keys]` は空)、ghostty は plain `ctrl+文字` を消費しないため、`Ctrl+b` 以外のキーは内側(shell / pi / omp)の既定にそのまま届く。

| キー | 所有者 | 内側・他層の代替 | 備考 |
|---|---|---|---|
| `Ctrl+b` | **herdr prefix** | shell・pi・omp では `Ctrl+b` は**文字左移動**(Emacs 系既定。pi の `tui.editor.cursorLeft` 既定は `left`, `ctrl+b` で、pi の docs/keybindings.md で確認。omp も同名のキー設定を持つが既定値は未確認)。代替は `←`。語左移動は `Alt+b`(omp 既定・pi は keybindings.json で維持) | tmux 既定と同じ prefix(`tmux.conf` は prefix を `Ctrl+q` に変更済み) |
| `Ctrl+q` | omp followUp(既定 `ctrl+q` / `ctrl+enter`) | tmux フォールバック内では tmux prefix(`C-q`)が消費する。`Ctrl+Enter` で代替できるかは未確認 | zsh は `setopt no_flow_control`(`dot_zshrc:40`)で `Ctrl+s`/`Ctrl+q` の flow control を ZLE 上で無効化済み |
| `Alt+b` / `Alt+f` | omp(語左/語右) | ghostty が `Alt+←/→` を `esc:b` / `esc:f` に変換した先 | pi は `~/.config/pi/agent/keybindings.json` が既定を置換し `alt+f` を外しているため、pi では `Alt+→` / `Alt+f` による語右移動は効かない |
| `Alt+h/j/k/l/w` | pi(エディタ移動の独自割当) | — | 同上 keybindings.json(下記 pi 節) |
| その他の `Ctrl+文字` / `Alt+文字` | 内側(shell / pi / omp)の既定 | — | herdr direct キーなし・ghostty 非消費 |

**zellij フォールバック**: `dot_zlogin` は `herdr-dev` → `zellij` → `tmux` の順、`dot_bash_profile` は `herdr-dev` → `zellij` の順に起動する。zellij は既定のまま(`config.kdl` はコメントのみ)なので、フォールバック起動時は zellij 既定の `Ctrl+o/t/p/n/s/h/g/q` と Alt 群が内側のキーを消費する。特に `Ctrl+q` = Quit は shell・pi・omp から押すとセッションごと終了する(既知の危険。通常経路は herdr のため該当しない)。過去に設けていた zellij 側の上書きと、それに合わせた omp `keybindings.yml` 5 件・pi `~/.pi/agent/keybindings.json` 2 件の退避は撤去済みで、現在は存在しない(必要なら git 履歴から復元)。

## ツール別キーマップ(現行)

### ghostty(`~/.config/ghostty/config` → dotfiles 経由)

- 現値 = 既定(keybind 記述なし)。テーマ/フォント等のみ設定。**最終 = 変更なし**。
- 既定キー(`ghostty +show-config --default` 実測): `super+*`(タブ/分割/検索/クリップボード/フォント), `ctrl+tab` / `ctrl+shift+tab`(タブ移動), `alt+←/→`→`esc:b/f`(内側では `Alt+b/f` として到達), `shift+矢印`(選択調整)。
- plain `ctrl+文字` は一切消費しない → スタック下位への影響なし。

### herdr(`~/.config/herdr/config.toml` → dotfiles 経由)

- 現値 = 既定(`herdr --default-config` と突合。`[keys]` は空で全バインドが既定値)。**prefix = `ctrl+b`**。**最終 = 変更なし**。
- 既定(prefix 後 2 キー目): `?` ヘルプ, `s` 設定, `q` デタッチ, `shift+r` リロード, `w` ワークスペース選択, `v` / `minus` 分割, `x` ペインを閉じる, `z` ズーム, `b` サイドバー, `h/j/k/l` フォーカス, `tab` 次ペイン, `e` スクロールバック編集, `c` 新規タブ, `shift+t` タブ改名, `p` / `n` 前後タブ, `1..9` タブ切替, `shift+x` タブを閉じる, `shift+n/w/d` ワークスペース新規/改名/閉じる, `r` リサイズモード。
- direct ターミナルキーはユーザー設定に存在しない(全て prefix 経由)。

### pi

**`~/.config/pi/agent/keybindings.json`(chezmoi 管理、ユーザー独自のエディタキー)**:

| Action | 現値 |
|---|---|
| `tui.editor.cursorUp/Down/Left/Right` | `up/down/left/right` + `alt+k/j/h/l` |
| `tui.editor.cursorWordLeft` | `alt+left` + `alt+b` |
| `tui.editor.cursorWordRight` | `alt+right` + `alt+w` |

- 設定値は既定を**置換**する。pi 既定(`docs/keybindings.md`)は `cursorWordLeft = alt+left, ctrl+left, alt+b` / `cursorWordRight = alt+right, ctrl+right, alt+f` なので、`ctrl+left/right` と `alt+f` による語移動は現在使えない。ghostty は `Alt+→` を `esc:f`(`Alt+f`)として送るため、`cursorWordRight` に `alt+f` を足さない限り pi では `Alt+→` でも語右移動しない。
- `~/.pi/agent/keybindings.json`(`app.editor.external = alt+e` / `app.message.dequeue = alt+q` の 2 件)は chezmoi 管理外の残存ファイル。`PI_CODING_AGENT_DIR=~/.config/pi/agent`(`dot_profile`)のため pi は読まず、実効なし(削除しても挙動は変わらない)。

### omp(`keybindings.yml` なし)

- 現値 = 全既定(実効 agent dir は `~/.config/omp/profiles/god/agent/`、`keybindings.yml` は存在しない)。followUp は既定どおり `Ctrl+Q` / `Ctrl+Enter`。
- エディタの Emacs 系既定(pi と共通: `Ctrl+b/f/a/e/d/k/u/w/y`、`ctrl+-` undo、`ctrl+j` 改行等)は変更せず、`Ctrl+b` のみ herdr prefix に所有権を譲る。`Ctrl+b` は omp では**文字左移動**(`cursorLeft` = `left`, `ctrl+b`)であり、`←` で代替できる。語左移動(`Alt+b` / `Alt+←` / `Ctrl+←`)は影響を受けない。

### zed(変更対象外)

- ユーザーオーバーライドなし(`keymap.json` 不在)。`base_keymap: VSCode`。
- 既定は macOS `cmd` ベース(GUI 層でありターミナルスタックと直接衝突しない)。主要既定: `cmd+P`(ファイル検索), `cmd+shift+P`(コマンドパレット)など。
- zed docs の取得は 404 で失敗したため、既定キーマップの完全な表は**未確認**。zed 内でコマンドパレットからキーマップ関連コマンドで確認可。

## 衝突一覧(現行)

| キー | 衝突する層 | 解消 | 状態 |
|---|---|---|---|
| `Ctrl+b` | herdr prefix ↔ shell / pi / omp の文字左移動 | herdr に所有権。内側は `←` を使う | **解決(意図的)** |
| `Ctrl+q` | tmux フォールバックの prefix(`tmux.conf` の `C-q`)↔ omp followUp(`ctrl+q`) | tmux 内では衝突する(`Ctrl+Enter` で代替できるかは未確認)。herdr 運用では衝突なし | **tmux フォールバック時のみ残存(受容)** |
| `Alt+→` / `Alt+f` | ghostty の `esc:f` 変換 ↔ pi の独自 keybindings(`alt+f` なし) | 未解消。pi では語右移動に `Alt+w` を使う | **受容** |
| zellij 既定キー全般 | zellij フォールバック起動時のみ内側と衝突 | 上書きなし(撤去済み)。herdr 運用では発生しない | **フォールバック時のみ残存(受容)** |
| `Ctrl+←/→`(OS) | macOS 側の割当 ↔ omp 語移動 | **未検証**(入力環境 セクション参照)。Ubuntu 側も未確認 | **未検証** |

## 逸脱リスト(現行)

1. **pi** `~/.config/pi/agent/keybindings.json`: エディタ移動 6 件(hjkl 系 + 語移動)を独自割当。pi 既定の `ctrl+left/right`・`alt+f` を置換して外す(上記)。
2. **herdr** `config.toml`: `default_shell = "zsh"` + `shell_mode = "non_login"`(既定 `/bin/zsh` は herdr pane で findcmd SIGABRT が出たため意図的維持)、`onboarding = false`、`theme = kanagawa`、`sidebar_width = 28`、`prompt_new_tab_name = false`、toast `delivery = "off"`、`pane_history = false`、`reveal_hidden_cursor_for_cjk_ime = true`。キーバインドの逸脱はなし。
3. **tmux**(フォールバックの更に後段): prefix を `C-q` に変更し `C-b` を unbind(`tmux.conf`)。
4. **ghostty**: 独自 bg `#112233` / fg `#D4C69A`(キー逸脱なし)。

逸脱なし(キー): ghostty・omp・zed。omp の `keybindings.yml` 上書き、zellij の上書きはともに撤去済み。

## 検証手順

- **herdr**: `herdr --version`(0.9.5)。設定変更後は `herdr server reload-config` または `prefix+shift+r`。`herdr --default-config` と突合。
- **omp**: セッション再起動後 `/hotkeys` で有効キーを確認(既定のはず)。
- **pi**: `/reload`。`Alt+h/j/k/l/w` が効くことを確認。
- **herdr integration**: `herdr integration status` は `PI_CODING_AGENT_DIR` を見て extension の場所を決めるため、実行する shell で結果が変わる。通常 shell(`PI_CODING_AGENT_DIR=~/.config/pi/agent`)では pi が `current (v9)`・omp が `not installed`(pi の dir を探すため)、omp セッション内(`PI_CODING_AGENT_DIR` が omp profile)では omp が `current (v10)`・pi が `not installed` と表示される。どちらも実体は両方とも導入済み(それぞれの dir に chezmoi 追跡ファイルへのシンボリックリンク)。
- **ghostty**: 自動再読み込みあり。`super+shift+,` でも再読み込み可。

**復元**: 編集対象は chezmoi 管理で、実体は `~/dotfiles/home/private_dot_config/` 配下。過去の設定は git 履歴から復元する(zellij の `config.kdl.bak-*` バックアップは存在しない)。pi の `~/.pi/agent/keybindings.json` は pi が読まない残存ファイル。

## mux 入替時の指針

- 原則: 新 mux は**デフォルト優先**で導入し、衝突キーだけを所有権マップに従って退避させる。内側(herdr → pi/omp)の最終キーマップは mux 非依存に設計済みで、可能な限り再編集しない。
- prefix を変える場合の選定基準: (1) 全層(ghostty / mux / herdr / pi・omp / shell)で未使用 (2) 片手・1 ストローク (3) tmux 互換性 (4) shell の Emacs キーを殺さない。
- 入替時チェックリスト: 新 mux の既定と衝突一覧を突合。優先確認キー: `Ctrl+b` `Ctrl+q`(tmux フォールバックの prefix と omp followUp) `Ctrl+r` `Ctrl+g` `Ctrl+o` `Ctrl+p` `Alt+b/f`。

## herdr 統合の現状(zellij からの移行)

zellij は 2026-09-22 に不採用化し、herdr を唯一の mux にした(ghostty → zellij → herdr の二重ネストを解消)。zellij は herdr が無い環境のフォールバックとしてのみ残す(binary / `config.kdl` / `layouts/dev.kdl`)。

**実施済み**:

- herdr 0.9.5 へ更新(`herdr --version` で確認)。
- herdr integration: pi は v9(`home/private_dot_config/pi/agent/extensions/herdr-agent-state.ts`)、omp は v10(`home/private_dot_config/omp/profiles/god/agent/extensions/herdr-omp-agent-state.ts`)。いずれも chezmoi 追跡済みで、各 extensions dir にシンボリックリンクとして配置済み。
- `home/dot_local/bin/executable_herdr-dev` による dev workspace の構築(下記)。
- 起動経路: `dot_zlogin`(zsh)/ `dot_bash_profile` が `herdr-dev` を自動起動(guard に `HERDR_ENV` を使用)。
- zellij `config.kdl` を既定化(コメントのみ)。omp `keybindings.yml` を削除。
- `stty -ixon` は不要(`setopt no_flow_control`、`dot_zshrc:40`)。

**未実施**:

- `home/private_dot_config/zellij/`(`config.kdl` + `layouts/dev.kdl`)の source 削除と `chezmoi apply`。
- mise `tools.toml:246` の `zellij = "latest"` 削除と `mise uninstall zellij`。
- `docs/tech.md` / `docs/directory.md` の zellij 記載の整理。

### dev プリセット(`executable_herdr-dev`)

herdr の永続 server 上に workspace「dev」(cwd 既定 `~/dotfiles`、`HERDR_DEV_CWD` で変更)と 4 タブ + 条件付き lazydocker を構築する。起動エントリは `home/dot_local/bin/executable_herdr-dev`。

| herdr tab | 中身 | 旧 zellij tab(`layouts/dev.kdl`) |
|---|---|---|
| 「101」 | btm @`~/dotfiles`(単一ペイン。`workspace create` の root tab を改名) | 「101」 |
| 「102」 | fastfetch @`~/Music` + `cat ~/cat.txt` @`~/`(上下。cat.txt があるときだけ下段を作る。`HERDR_DEV_DATA` で dir 変更) | 「102」 |
| 「Dev」 | zsh ×4 @`~/Developer`(2×2) | 「Dev」 |
| 「Docs」 | pi agent(`agent start pi --kind pi -- -c`)単一ペイン @`~/Developer/docs` | 「Docs」(+「Plan」) |
| 「lazydocker」(条件付き) | docker daemon 稼働 + lazydocker 導入時のみ作成 | (docker はコメント済) |

挙動:

1. server が未稼働なら `nohup herdr server` で起動し ready を待つ(稼働していれば skip)。
2. **自前で server を起動した場合(= snapshot 復元直後で pane が素 shell のみ)**は dev workspace を閉じ、btm・fastfetch・cat・pi・lazydocker をコマンド再実行込みで完全に作り直す。`herdr server stop` 後の `herdr-dev` もこの経路。
3. 既に稼働中の server に対しては、workspace と各プリセットタブの**存在保証のみ**(閉じたタブは次回起動時に個別復活。既存タブの pane 構成には触れない)。
4. `herdr-dev` を経由せず別経路で server が起動した場合(restore 後に pane が素 shell で復帰)は、btm・fastfetch・cat・lazydocker は再実行されないため手動で再実行する(`workspace close` してから `herdr-dev` でも再構築できる)。detach/reattach は process が継続するので無問題。
5. herdr 内の shell から手動実行した場合は構築のみで attach しない。`jq` が無い場合はプリセット保証をスキップする。

実装条件: `#!/usr/bin/env bash` + `set -eu`、`command -v herdr` / `jq` ガード。pane/tab/workspace ID は作成応答(`.result.{workspace.workspace_id, tab.tab_id, root_pane.pane_id, pane.pane_id}`)から読み、推測しない。

### zellij から受容した機能差

| zellij 機能 | herdr 代替 | 判定 |
|---|---|---|
| scroll/search モード | mouse wheel scroll + `copy_on_select`(既定 true)+ `prefix+e` edit_scrollback(エディタで検索) | 受容 |
| 汎用フローティングペイン | `[[keys.command]] type = "popup"`(コマンド単位のモーダル) | 受容。必要時に popup を追加 |
| pane move / swap キー | `herdr pane move` / `pane swap`(socket API) | 受容(低頻度) |
| swap layout / tab 全ペイン同期入力 | なし | 受容(未使用) |

## 将来対応(本タスク対象外・現状メモ)

- **aliases**: ユーザーメモの話題。シェルエイリアスは zsh が `zsh/dot_functions` と zsh-abbr、bash が `dot_aliases` に定義(未調査・未変更)。mux/キーマップ確定後に別タスクで整理する。
- **macOS システム**: `Ctrl+←/→` の macOS 側割当は未検証(入力環境 セクション参照)。Ubuntu 側の `Ctrl+←/→` 割当も未確認。
- **zed**: 既定キーマップの要点は docs 取得失敗のため未確認。zed 内ターミナルを常用するようになったら再確認する。
- **herdr plugin**: `herdr-dev` を経由せず server が再起動された場合の run-once コマンド(btm/fastfetch/cat/lazydocker)自動再実行が欲しくなったら、herdr plugin(event hooks)で「restore 後に pane run」を実装する。それまで手動再実行。

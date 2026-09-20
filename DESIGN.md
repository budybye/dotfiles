---
version: alpha
title: ターミナルスタックのキーマップ設計
tags: [terminal, keymap, multiplexer, tui, design]
name: Kanagawa Dragon Terminal
description: ghostty→zellij→herdr→pi/omp スタックの視覚言語・キー所有権・衝突解消・逸脱記録
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

ghostty(ターミナル) → zellij 0.45.1(マルチプレクサ) → herdr 0.9.1(スーパーバイザ/ペイン管理) → pi / omp 18.2.7(コーディングハーネス)。参照として zed(GUI エディタ、変更対象外)。更新: 2026-09-22。

**消費モデル**: キーは外側の層が「自分のバインドに一致するキー」を消費し、一致しないキーだけを内側に渡す。ghostty は macOS で `Alt+←/→` を `esc:b` / `esc:f` に変換して送るため、内側では `Alt+b` / `Alt+f` として観測される。

**視覚言語**: Kanagawa Dragon を全層の基調とし、ghostty のみ独自の背景 `#112233` / 前景 `#D4C69A`(紺+薄黄緑)を上乗せする。omp と zed の light モードは Monokai 系がアクセント。濃色・低彩度・低まぶしさを原則とし、奥行きは透明度で表現する。

**キー設計原則**: 1 キー = 1 所有者(所有権マップ参照)。新ツールはデフォルト優先で導入し、衝突キーだけを退避させる。全逸脱は逸脱リストに記録する。OS レイヤー(karabiner / Raycast / fcitx5 / fusuma)はスタック外だが、突合を入力環境セクションに記録する。

**状態**: 2026-09-22 移行を部分適用 — 起動経路を herdr に一本化(zprofile / bash_profile、zellij は不採用・binary/config は残置)、omp keybinding 上書きを削除して既定復帰(**pi はユーザー判断で現状維持**)。herdr config は git 復帰後に**現実効値 + 既定値コメントの統合版**へ整理(onboarding=false / kanagawa / default_shell=zsh / non_login / sidebar 28 / prompt_new_tab_name=false / toast off / CJK cursor)。既定の `/bin/zsh` は herdr pane で findcmd SIGABRT(zsh-*.ips 7 件)のため `default_shell = "zsh"` + `non_login` は意図的維持。未実施: zellij uninstall・mise/tools.toml・tech.md / directory.md・zshrc `stty -ixon`・herdr integrations。

## Colors

パレットは Kanagawa Dragon 一族で統一し、Monokai 系は omp dark と zed light のアクセントに限定する。front matter の `colors` トークンは starship パレット(dragon\* 10 色)と ghostty の独自背景/前景。それ以外の層はテーマ名指定で同じ血統を参照する。

| 層 | テーマ | 実値・備考 |
|---|---|---|
| ghostty | **Kanagawa Dragon** | 独自 bg `#112233`(surface) / fg `#D4C69A`(on-surface)。代替候補 Monokai Pro はコメントで保管 |
| zellij | **kanagawa** | 代替候補 molokai-dark はコメントで保管 |
| herdr | **kanagawa** | テーマ名指定のみ |
| starship | **Kanagawa Dragon パレット** | `[palettes.color]` に dragon\* 系 10 色を直接定義(トークン化済み) |
| pi | **dark**(内蔵) | settings.json `theme: "dark"` |
| omp | **dark-monokai** / light: titanium | profiles/god の config.yml |
| zed | system 追従: dark **Kanagawa Dragon - No Italics** / light **Monokai Pro (CE)** | アイコン Material Icon Theme |

## Typography

フォントは **HackGen35 Console NF** に統一(ghostty / zed)。白源(HackGen)35 Console の **Nerd Fonts パッチ版**であり、"NF" は Nerd Fonts の略(Nord ではない)。等幅、日本語全角 1:2、Nerd Font グリフ内蔵。インストール済み: `HackGen35ConsoleNF-{Regular,Bold}.ttf` / `HackGenConsoleNF-{Regular,Bold}.ttf`。

- **ghostty**: 13.0pt + `font-thicken = true`(低解像度での視認性補正)。
- **zed**: UI 15pt / buffer 16pt、weight 400、行間 comfortable。
- **TUI(zellij / herdr / pi / omp)**: 端末フォントをそのまま継承(個別指定なし)。
- トークンの `fontSize` は spec の単位制約(px/em/rem)により px 表記。実運用値は pt(ghostty 13.0 / zed 15・16)。

## Layout

**層構造(現行)**: ghostty 全画面ウィンドウ(タイトルバー非表示)→ zellij `layouts/dev.kdl`(8 タブ、`default_layout "dev"`)→ うち「herdr」タブで herdr ワークスペース → agent ペイン。移行後は herdr が唯一の mux となり層が一段なくなる(zellij 廃止計画参照)。

**幾何パラメータ**:

| 項目 | 値 | 出典 |
|---|---|---|
| ghostty ウィンドウ余白 | 8px(x/y)+ balance | ghostty config |
| herdr サイドバー幅 | 28 列(min 18 / max 36) | herdr config `[ui]` |
| herdr モバイル閾値 | 64 列 | 同上 |
| herdr タブバー | 上部配置、単一タブ時も表示 | 既定 |
| herdr agent パネル並び | `spaces` | 同上 |
| zed 端末 | dock right、12pt | zed settings.json |
| zellij レイアウト | dev.kdl(タブ 101/102/Dev/herdr/Docs/Plan) | zellij layouts |

## Elevation & Depth

奥行きは影ではなく**透明度**で表現する。ghostty `background-opacity = 0.78` により背景 `#112233` が全体透過し、壁紙が沈み込む。macOS ネイティブ全画面は使わず `macos-non-native-fullscreen = true`、タイトルバーは非表示。階層の区別は境界線と gap(Shapes 参照)で行い、浮き彫り表現は導入しない。

## Shapes

角丸は存在しない(omitted: rounded)。ペイン境界は枠線 + gap:

- herdr: `pane_borders = true` / `pane_gaps = true`
- zellij: `pane_frames` 既定(true)
- ghostty: `window-padding-balance = true` で端余白を均す
- ghostty カーソル: `cursor-style = block` + `cursor-style-blink = true`。サイズ系(`adjust-cursor-thickness` / `adjust-cursor-height`)と `cursor-opacity`(既定 1)は未設定(v1.3.1 で利用可能なノブ)。タイピング中は `mouse-hide-while-typing = true` でマウスカーソルを退ける。

## Components

| コンポーネント | 設定ファイル(dotfiles ソース) | テーマ | フォント | キー所有 |
|---|---|---|---|---|
| ghostty | `home/private_dot_config/ghostty/config` | Kanagawa Dragon + 独自 bg/fg | HackGen35 Console NF 13pt | plain `ctrl+文字` は消費しない |
| zellij | `home/private_dot_config/zellij/config.kdl` | kanagawa | 端末継承 | `Ctrl+o/t/p/n/s/h/g/q` + Alt 群(所有権マップ) |
| herdr | `home/private_dot_config/herdr/config.toml` | kanagawa | 端末継承 | `Ctrl+b` prefix のみ(direct キーなし) |
| starship | `home/private_dot_config/starship/starship.toml` | Kanagawa Dragon パレット | 端末継承 | — |
| pi | `~/.pi` + `home/private_dot_config/pi/agent/` | dark | 端末継承 | 既定 + `~/.pi/agent/keybindings.json`(2 件上書き) |
| omp | `~/.omp` + `home/private_dot_config/omp/profiles/god/` | dark-monokai | 端末継承 | 既定 + `~/.omp/agent/keybindings.yml`(5 件上書き) |
| zed | `home/private_dot_config/zed/settings.json` | KD - No Italics / Monokai Pro (CE) | HackGen35 Console NF | `cmd` ベース(GUI 層) |

## Do's and Don'ts

- **Do**: 1 キー = 1 所有者。所有者でない層は代替キーを使う。新 mux/ツールは**デフォルト優先**で導入し、衝突キーだけを所有権マップに従って退避させる。
- **Do**: 逸脱は必ず逸脱リストに全件・理由付きで記録する。テーマは kanagawa 系で統一し、monokai はアクセントのみに使う。奥行きは透明度と境界線で表現する。
- **Don't**: 複数層での同時主張を作らない。`Ctrl+q` = zellij Quit のような破壊的既定を「既定維持原則」の名目で放置して危険を先送りにしない(omp 側で `Ctrl+Q` は解除済み。誤爆が続くなら Quit を別キーへ退避)。
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

**karabiner**(`home/private_dot_config/karabiner/karabiner.json`): JIS キーボード運用のリマップ群。扱うキー群は全て mandatory 修飾(`fn` / `right_option` / 左Cmd / 左Ctrl)をホールドした状態で発動し、素キーは不変(実測は下記):

| ルール群 | 対象キー |
|---|---|
| カーソル移動系 | `→/←/↑/↓`、`Home`、`End`、`PageUp`、`PageDown` |
| 記号 | `_` `¥` `@` `[` `]` |
| F キー / 数値 | `F1`〜`F12`、`1`〜`9` |
| 制御キー | `Cmd+Q`、`Cmd+W`、アクティビティモニタ起動、強制終了ウィンドウ、`Esc`、`Tab`、`Shift+Tab` |
| 編集系 | `Enter`、`BackSpace`、`DELETE`、単語選択、スクリーンショット、undo/cut/copy/paste |
| その他 | `CapsLock` 切替、選択文字の Google 検索、メニューバー/Dock フォーカス、Finder 表示・リネーム系、Chrome リロード・アドレスバー・タブ系 |

Raycast 起動ルールは karabiner 側に**存在しない**(ホットキーは Raycast 自身が管理)。

実測(jq で全 manipulator を走査): 全ての `from` が **mandatory 修飾 prefix 方式**:`fn`(カーソル移動 / F1–F12 / 記号 / Google 検索)、`right_option`(数値キー / `Cmd+Q`・`W` 相当群 / `Enter`・`BackSpace`・`DELETE` / undo・cut・copy・paste / `right_option+space` = CapsLock)、Finder・Chrome 群は `left_command` / `left_control` + `frontmost_application_if` 条件付き(一部 Cmd 系は GLOBAL)。**修飾なしの素キー(`Tab`・矢印・`Esc`・`Ctrl+文字`・`Alt+文字`)を書き換える manipulator は 0 件** → 所有権マップは macOS 上も成立する。

**Raycast**(`/Applications/Raycast.app`): ホットキーは `Option+Space`(ユーザー設定)。Spotlight は無効化済み(symbolic hotkeys 64/65 とも enabled=0 実測)。plist は移行初期値 `initialSpotlightHotkey = "Command-49"` のみを記録しており現ホットキーは plist 外管理のため、実値はユーザー設定を正とする。`Cmd+Space` は未割当(Spotlight 無効 + Raycast が Option 側へ移動)。`Option+Space` はスタック全層で未使用(zellij Alt 群は `[` `]` 等のみ / herdr direct キーなし / omp・pi・ghostty・karabiner も space なし)→ 非衝突。**注**: `右 Option+Space` は karabiner が CapsLock トグルとして所有(mandatory `right_option` + space、GLOBAL 実測)。Raycast の `Option+Space` は左 Option で運用すること(右側で押すと karabiner が先に取る)。

**macOS デフォルトでスタックに関わるキー(実測: `defaults read com.apple.symbolichotkeys`)**: 表は実測で機能名が確定した symbolic ID のみ(19/20 = Space 移動、60/61 = 入力ソース、32 = Mission Control、36 = Show Desktop)。機能名が確定できない ID(52/57/62 等)は丸ごと割愛した(enabled の記録だけ残す形にはしない)。

| キー | 機能 | 状態 | スタックへの影響 |
|---|---|---|---|
| `Ctrl+←/→` | Spaces 切替(symbolic 19/20) | **無効化済み(enabled=0)** | なし → pi/omp の `Ctrl+←/→` 語移動が到達する |
| `Ctrl+Space` / `Ctrl+Option+Space` | 入力ソース切替(60/61) | 有効 | なし(スタック全層で未使用) |
| `Ctrl+Shift+↑` | Mission Control(32) | 有効 | なし |
| `F11` | Show Desktop(36) | 有効 | なし |
| `Option+Space` | **Raycast**(Spotlight 代替) | 有効 | なし(GUI 層・スタック全層で未使用) |
| `Cmd+Space` | 未割当(Spotlight 無効化) | 空き | なし |
| `Cmd+Tab` / `Cmd+Shift+Tab` | アプリ切替 | 有効 | なし(GUI 層) |
| ``Cmd+` `` | 同アプリのウィンドウ切替 | 有効 | なし(GUI 層) |
| `Cmd+Shift+3/4/5` | スクリーンショット | 有効 | なし(GUI 層) |

突合: karabiner のリマップは mandatory 修飾 prefix 方式でスタック所有キー(`Ctrl+b` prefix・`Ctrl+o/t/p/n/s/h/g/q`・Alt 群)に干渉しない(0 件実測、上記)。GUI 層の `Cmd` 系は端末内 TUI へ届かない。→ スタックへの影響なし。

**トラックパッド**(`defaults read com.apple.AppleMultitouchTrackpad` 実測): 3 本指ドラッグ = ON(`TrackpadThreeFingerDrag = 1`、お気に入り設定)、3 本指スワイプ/タップ = OFF(`TrackpadThreeFinger{Horiz,Vert}SwipeGesture = 0` / `TapGesture = 0`)、4 本指横/縦スワイプ = ON(Mission Control / Spaces 切替、`TrackpadFourFinger{Horiz,Vert}SwipeGesture = 2`)、4 本指ピンチ = ON(= 2)。Ubuntu の fusuma(3 本指ドラッグ + 4 本指スワイプで workspace 切替)はこの好みの OS 間再現。

## 所有権マップ(現行)

各キーの所有者は 1 層のみ。所有者でない層は表の代替キーを使う。

| キー | 所有者 | 内側・他層の代替 | 備考 |
|---|---|---|---|
| `Ctrl+b` | **herdr prefix** | zellij tmuxモード→`Alt+t` / pi・omp 語左移動→`Alt+b`・`←` / shell 語左移動→`Alt+b` | tmux 既定と同じ prefix。mux 入替後も維持 |
| `Ctrl+r` | **shell & omp(履歴検索)** | zellij 設定UI→`Alt+c` | 高頻度操作を優先 |
| `Ctrl+-` | **pi/omp undo・shell undo** | zellij 下分割→`Ctrl+p` → `d` | ユーザー追加キーを削除 |
| `Ctrl+o` | zellij(session モード) | omp ツール出力開閉→`Ctrl+Shift+O` / pi→代替なし(omp 使用) | zellij 既定を維持 |
| `Ctrl+t` | zellij(tab モード) | omp/pi thinking→`Shift+Tab` | zellij 既定を維持 |
| `Ctrl+p` | zellij(pane モード) | omp モデル→`Alt+P`・`Alt+M` / pi モデル→`Ctrl+L` / shell 履歴→`↑` | zellij 既定を維持 |
| `Ctrl+n` | zellij(resize モード) | shell 履歴→`↓` | zellij 既定を維持 |
| `Ctrl+s` | zellij(scroll モード) | shell XOFF は発生しない(zellij が消費して抑止) | **廃止後は `stty -ixon` が必要**(zellij 廃止計画) |
| `Ctrl+h` | zellij(move モード) | shell Backspace→Backspace キー | zellij 既定を維持 |
| `Ctrl+g` | zellij(lock 切替) | pi/omp 外部エディタ→`Alt+E` | zellij 既定を維持 |
| `Ctrl+q` | zellij(**Quit**) | omp followUp→`Ctrl+Enter` | 誤操作でセッション終了の危険あり(下記注意) |
| `Alt+f` | (解放 → pi/omp 語右移動) | zellij フロート切替→`Alt+w` | ghostty の `Alt+→` 変換先が `Alt+f` |
| `Alt+Up` | zellij(MoveFocus Up) | omp/pi dequeue→`Alt+Q` | |
| `Alt+L` | zellij(MoveFocusOrTab) | omp display reset→`Alt+U` | |
| `Alt+Shift+P` | zellij(グループマーキング) | omp plan モード→`Alt+G` | |
| `Alt+h/l/j/k`・`Alt+矢印`・`Alt+n/i/o/p/=[-[]/]` | zellij 既定 | omp の `Alt+M/A/R/Q/E/G/U`・`Alt+Shift+C/L/V` 等は非衝突 | |

**注意 (既知の危険)**: zellij 既定の `Ctrl+q` = Quit は、shell や pi で `Ctrl+q` を押すとセッションごと終了する。omp 側で `Ctrl+Q` を解除済みだが、zellij 既定自体は変更していない(既定維持原則)。誤爆が続くなら次回、zellij の Quit を別キーへ退避するかユーザー判断で。

## ツール別キーマップ(現行)

### ghostty(`~/.config/ghostty/config` → dotfiles 経由)

- 現値 = 既定(keybind 記述なし)。テーマ/フォント等のみ設定。**最終 = 変更なし**。
- 既定キー(`ghostty +show-config --default` 実測): `super+*`(タブ/分割/検索/クリップボード/フォント), `ctrl+tab` / `ctrl+shift+tab`(タブ移動), `alt+←/→`→`esc:b/f`(内側では `Alt+b/f` として到達), `shift+矢印`(選択調整)。
- plain `ctrl+文字` は一切消費しない → スタック下位への影響なし。

### zellij(`~/.config/zellij/config.kdl` → dotfiles 経由)

config は既定 + 追加のマージ(`clear-defaults=true` なし)。既定値は `zellij setup --dump-config`(0.45.1) と突合。インストール済み既定のうちユーザーファイルに無いバインド(pane の `Shift+f`、`;`、scroll の `[` `]` `m` `c` 等)も引き続き有効。

変更したキー(現値→最終):

| キー | 現値(適用前) | 既定 | 最終 | 
|---|---|---|---|
| `Ctrl+b` | tmux モード切替(=既定) | tmux モード切替 | `Write 2`(^B を下位へ透過) |
| `Alt+t` | — | — | tmux モード切替(新設) |
| `Ctrl+r` | 設定UI起動(ユーザー追加) | — | なし(`Alt+c` へ移設) |
| `Alt+c` | —(copy_on_select 用コメント) | — | 設定UI起動 |
| `Ctrl+\|` | 右分割(ユーザー追加) | — | なし(`Ctrl+p`→`r` で代替) |
| `Ctrl+-` | 下分割(ユーザー追加) | — | なし(`Ctrl+p`→`d` で代替) |
| `Alt+f` | フロート切替(=既定) | フロート切替 | なし(`Alt+w` へ移設) |
| `Alt+w` | — | — | フロート切替 |

その他(normal/shared の主要キー)は既定どおり: `Ctrl+p/n/s/o/t/h`(モード), `Ctrl+g`(lock), `Ctrl+q`(Quit), `Alt+h/l/j/k/矢印`(移動), `Alt+n/i/o/p` 等。

### herdr(`~/.config/herdr/config.toml` → dotfiles 経由)

- 現値 = 既定(`herdr --default-config` と突合、全バインドが既定値と同値)。**prefix = `ctrl+b`**。**最終 = 変更なし**。
- 既定(prefix 後 2 キー目): `?` ヘルプ, `q` デタッチ, `shift+r` リロード, `w` ワークスペース, `v`/`minus` 分割, `x` 閉じる, `z` ズーム, `b` サイドバー, `h/j/k/l` フォーカス, `tab` 次ペイン, `c` 新規タブ, `shift+t` 改名, `p`/`n` 前後タブ, `1..9` 切替, `shift+x` 閉じる, `shift+n/w/d` ワークスペース, `r` リサイズモード。
- direct ターミナルキーはユーザー設定に存在しない(全て prefix 経由)。

### pi(2 ファイル)

**`~/.pi/agent/keybindings.json`(chezmoi 管理外、適用済みの 2 件)**:

| Action | 既定 | 最終 | 理由 |
|---|---|---|---|
| `app.editor.external` | `ctrl+g` | `alt+e` | zellij `Ctrl+g` = lock |
| `app.message.dequeue` | `alt+up` | `alt+q` | zellij `Alt+up` = MoveFocus(Windows 既定と同じ `Alt+q` に統一) |

- 反映: pi 内で `/reload`。

**`~/.config/pi/agent/keybindings.json`(chezmoi 管理、ユーザー独自のエディタキー)**:

| Action | 現値 |
|---|---|
| `tui.editor.cursorUp/Down/Left/Right` | `up/down/left/right` + `alt+k/j/h/l` |
| `tui.editor.cursorWordLeft` | `alt+left` + `alt+b` |
| `tui.editor.cursorWordRight` | `alt+right` + `alt+w` |

- zellij 下では `Alt+h/j/k/l/w` と `Alt+←/→` が消費されるため語移動系は効かない(zellij 廃止で完全に有効化される)。ghostty は `Alt+→` を `esc:f` として送るため `Alt+→` 相当を欲しければ `alt+f` を追加。

### omp(`~/.omp/agent/keybindings.yml` を新規作成)

- 現値 = 全既定。**最終 = 5 件のみ**:

| Action | 既定 | 最終 | 理由 |
|---|---|---|---|
| `app.message.followUp` | `Ctrl+Q`, `Ctrl+Enter` | `Ctrl+Enter` | zellij `Ctrl+q` = Quit(セッション喪失の危険) |
| `app.message.dequeue` | `Alt+Up`, `Shift+Up` | `Alt+Q` | zellij `Alt+Up` = MoveFocus。`Shift+Up` は ghostty 選択操作と競合するため不採用 |
| `app.editor.external` | `Ctrl+G` | `Alt+E` | zellij `Ctrl+g` = lock |
| `app.plan.toggle` | `Alt+Shift+P` | `Alt+G` | zellij `Alt+Shift+P` = グループマーキング |
| `app.display.reset` | `Alt+L` | `Alt+U` | zellij `Alt+L` = MoveFocusOrTab |

- 反映: omp セッション再起動(keybindings.yml は起動時読み込み)。`/hotkeys` で有効キーを確認。
- エディタの Emacs 系既定(pi と共通: `Ctrl+b/f/a/e/d/k/u/w/y`、`ctrl+-` undo、`ctrl+j` 改行等)は変更せず、`Ctrl+b` のみ herdr prefix に所有権を譲る(語左移動は `Alt+b`・`←` が生きる)。

### zed(変更対象外)

- ユーザーオーバーライドなし(`keymap.json` 不在)。`base_keymap: VSCode`。
- 既定は macOS `cmd` ベース(GUI 層でありターミナルスタックと直接衝突しない)。主要既定: `cmd+P`(ファイル検索), `cmd+shift+P`(コマンドパレット)など。
- zed docs の取得は 404 で失敗したため、既定キーマップの完全な表は**未確認**。zed 内でコマンドパレットからキーマップ関連コマンドで確認可。

## 衝突一覧(現行)

| キー | 衝突する層 | 解消 | 状態 |
|---|---|---|---|
| `Ctrl+b` | zellij tmux切替 ↔ herdr prefix ↔ shell 語左 ↔ pi/omp 語左 | zellij を `Write 2` 透過へ、tmuxモードは `Alt+t` | **解決** |
| `Ctrl+r` | zellij 設定UI(追加) ↔ shell 履歴検索 ↔ omp 履歴検索 | zellij を `Alt+c` へ | **解決** |
| `Ctrl+-` | zellij 下分割(追加) ↔ pi/omp undo ↔ shell undo | zellij 追加を削除 | **解決** |
| `Ctrl+\|` | zellij 右分割(追加) ↔ (内側は未使用) | 削除(`Ctrl+p`→`r`) | **解決** |
| `Alt+f` | zellij フロート ↔ pi/omp 語右(ghostty `Alt+→` 変換含む) | zellij を `Alt+w` へ | **解決** |
| `Ctrl+q` | zellij Quit ↔ omp followUp | omp の `Ctrl+Q` 解除(`Ctrl+Enter` 使用) | **解決** |
| `Alt+Up` | zellij MoveFocus ↔ omp/pi dequeue | omp/pi を `Alt+q` へ | **解決** |
| `Ctrl+g` | zellij lock ↔ pi/omp 外部エディタ | pi/omp を `Alt+e` へ | **解決** |
| `Alt+Shift+P` | zellij グループマーキング ↔ omp plan | omp を `Alt+g` へ | **解決** |
| `Alt+L` | zellij MoveFocusOrTab ↔ omp display reset | omp を `Alt+u` へ | **解決** |
| `Ctrl+o/t/p/n/s/h` | zellij 既定 ↔ 内側の同名キー | zellij に所有権、内側は代替キー(所有権マップ) | **所有権移譲で解決** |
| `Ctrl+←/→`(OS) | macOS Spaces 切替 ↔ pi/omp 語移動 | macOS の Spaces 切替(symbolic 19/20)は無効化済みを確認(入力環境 セクション) | **解決(macOS 実測)/ Ubuntu 未確認** |

すべての 2 層同時主張は解消済み(所有権割当 + 代替キー明示)。残る制限: pi の `Ctrl+o`(ツール出力開閉)は pi に代替がなく omp の `Ctrl+Shift+O` を使用 / pi の picker 内 `Ctrl+r`(rename)等は zellij 所有のため使用不可(低頻度) / macOS `Ctrl+←/→` は解決済み(Spaces 無効化、入力環境 セクション)。Ubuntu 側の `Ctrl+←/→` 割当は未確認。

## 逸脱リスト(現行・適用済)

1. **zellij** `Ctrl+b` → `Write 2`(+新設 `Alt+t`): herdr prefix・shell・pi/omp に ^B を届ける。tmux モードは `Alt+t` から利用可能なため機能は喪失しない。
2. **zellij** `Ctrl+r` → `Alt+c`: shell/omp の履歴検索(Ctrl+r)を解放。設定UIはワンキーのまま。
3. **zellij** `Ctrl+|` 削除: 内側で未使用。pane モード `Ctrl+p`→`r` で代替。
4. **zellij** `Ctrl+-` 削除: pi/omp undo・shell undo を解放。pane モード `Ctrl+p`→`d` で代替。
5. **zellij** `Alt+f` → `Alt+w`: ghostty が `Alt+→` を `esc:f`(= `Alt+f`)に変換するため pi/omp の語右移動が zellij に食われる。pane モード `w` でも代替可。
6. **omp** followUp から `Ctrl+Q` 解除: zellij Quit との競合で、押すとセッション終了に繋がる危険キーのため。
7. **omp** dequeue `Alt+Up`→`Alt+Q`: zellij `Alt+Up` との競合。`Shift+Up` は ghostty 選択と競合のため不採用、Windows 既定の `Alt+Q` に寄せた。
8. **omp/pi** 外部エディタ `Ctrl+G`→`Alt+E`: zellij lock との競合。
9. **omp** plan.toggle `Alt+Shift+P`→`Alt+G`: zellij グループマーキングとの競合。
10. **omp** display.reset `Alt+L`→`Alt+U`: zellij MoveFocusOrTab との競合。
11. **pi** dequeue `Alt+Up`→`Alt+q`: omp と同じ。

逸脱なし: ghostty・herdr・zed(ghostty は既定のまま利用。herdr は prefix `ctrl+b` を意図的に維持 — tmux 互換で mux 入替に強い)。

## 検証・復元手順

**検証(実行中のセッションは停止しない。反映は次回起動/リロード時)**:

1. **zellij**: 設定はセッション開始時に読み込む。新規セッションまたは再起動後に確認: shell で `Ctrl+r` → 履歴検索 / `Ctrl+b` → zellij は何もしない(herdr ペインなら herdr prefix) / `Alt+t` → tmux モード / `Alt+w` → フロート切替 / `Alt+c` → 設定UI / `Ctrl+p` → `r`・`d` で分割
2. **herdr**: config 変更なし。稼働中の server はそのまま。
3. **omp**: セッション再起動後、`/hotkeys` で `Alt+Q/G/E/U`・followUp `Ctrl+Enter` を確認。
4. **pi**: `/reload` で即時反映。`Alt+E`(外部エディタ)・`Alt+Q`(dequeue)を確認。
5. **ghostty**: 変更なし(自動再読み込みあり)。`super+shift+,` でも再読み込み可。
6. 構文検証済み: zellij `setup --check` 合格、omp YAML・pi JSON パース合格。

**復元**:

- 編集対象は chezmoi(dotfiles)管理のシンボリックリンク。実体は `~/dotfiles/home/private_dot_config/` 配下。
- **zellij**: `cp ~/.config/zellij/config.kdl.bak-20260921 ~/.config/zellij/config.kdl`(リンク経由で実体へ書き戻る)。新規セッションで反映。dotfiles が jj/git 管理ならそちらでの差分確認/復帰も可。
- **omp**: `rm ~/.omp/agent/keybindings.yml` → 既定に戻る。
- **pi**: `rm ~/.pi/agent/keybindings.json` → 既定に戻る。
- **ghostty / herdr / zed**: 変更していないため復元不要。
- 備考: バックアップサフィックス `bak-20260921` はタスク指定どおり(適用実施日は 2026-09-22 だが指定名を遵守)。

## mux 入替時の指針

- 原則: 新 mux は**デフォルト優先**で導入し、衝突キーだけを所有権マップに従って mux 側を退避させる。内側(herdr → pi/omp)の最終キーマップは mux 非依存に設計済みで、可能な限り再編集しない。
- herdr prefix `Ctrl+b` は tmux 既定と同じ。新 mux が tmux 系で `Ctrl+b` を消費する場合は、本設計と同じパターン(該当キーを `Write` 透過か、モード切替を `Alt+T` 相当へ退避)で処理する。
- prefix を変える場合の選定基準: (1) 全層(ghostty / mux / herdr / pi・omp / shell)で未使用 (2) 片手・1 ストローク (3) tmux 互換性 (4) shell の Emacs キーを殺さない。
- 入替時チェックリスト: 新 mux の既定と衝突一覧を突合。優先確認キー: `Ctrl+b` `Ctrl+r` `Ctrl+q` `Ctrl+g` `Ctrl+o` `Ctrl+p` `Alt+f` `Alt+Up` `Alt+L` `Alt+Shift+P`。
- 本指針に基づく具体的な実行計画: 次節(zellij を廃止し herdr を唯一の mux に統合)。

## zellij 廃止計画(herdr へ統合)

状態: **部分適用(2026-09-22)** — 実施済み: 実施手順 3(preset `executable_herdr-dev` 新設・応答 ID は `.result.{workspace.workspace_id, tab.tab_id, root_pane.pane_id, pane.pane_id}` 準拠)/ 4(zprofile・bash_profile を `herdr` 自動起動へ、guard 追加)/ 6(zellij config.kdl を既定化・コメントのみ。layouts/dev.kdl は残置)/ 7(omp keybindings.yml 削除。pi はユーザー判断で現状維持)。herdr config は既定リセットを git 復帰で取り消した上で、**現実効値 + 既定値コメントの統合版**に整理 + reload-config 適用(`default_shell = "zsh"` + `non_login` は既定 `/bin/zsh` の findcmd SIGABRT 回避のため意図的維持)。dev workspace は crash 期に pane 子プロセス死亡(p7 欠番)で T 字化していたため `pane split --direction right` 1 回で 2×2 に修復済み。未実施: 1(uninstall はユーザー判断で保留)/ 2(herdr integrations)/ 5(zshrc `stty -ixon`)/ 8〜11。提案日: 2026-09-22。
目的: ghostty → zellij → herdr の二重ネストを解消し、**herdr を唯一の mux** にする。キー所有権は所有権マップの方針を踏襲し、mux 層の消滅により pi/omp の逸脱 11 件を全て既定へ戻す。

実測の前提(全て実機/公式ドキュメント v0.9.1 で確認):

- herdr 0.9.1 は workspace/tab/pane/agent の socket API(`herdr workspace|tab|pane|agent`)を持ち、`tab create --label --cwd`、`pane split --cwd`、`pane run`、`agent start --kind omp|pi` を備える。**宣言的 layout 機能は存在しない**(`--default-config` 全量で確認済み。起動時フックも `[[keys.command]]`(手動トリガー)のみ)。
- **永続化**(公式「Session state and restore」): detach/reattach は全 process が生きたまま復帰。**server 再起動後も workspace/tab/pane/cwd/layout/focus は snapshot 復元される**。ただし process は消滅するため、素 pane は「保存 cwd の新しい shell」として復帰する。
- **agent 対話の resume**(server 再起動後)は公式 integration が必須: Pi は integration v2 以上(`pi --session`)、OMP は v3 以上(`omp --resume=`)。**現状 `herdr integration status` で pi / omp とも not installed**。
- `herdr update` は **mise 管理では無効**(Homebrew/mise/Nix はパッケージマネージャ経由と公式明記)。

### スタック変更

| | 現行 | 移行後 |
|---|---|---|
| 起動 | ghostty → `zsh -l` → zprofile が `zellij -l dev` 自動起動 | ghostty → `zsh -l` → zprofile が `herdr`(attach or create) |
| レイアウト | zellij `layouts/dev.kdl`(8 タブ、うち「herdr」タブで herdr をネスト) | herdr 永続 server 上に workspace「dev」+ 5 タブ |
| detach/reattach | zellij `session_serialization false` / `on_force_close "quit"`(保持なし) | process 全部継続、そのまま復帰 |
| server 再起動(再起動・mac 再起動後) | 無し(セッション消滅) | layout/cwd/focus は snapshot 復元。**run-once コマンドは再実行されず素 shell で復帰**、omp 対話は integration で resume |
| 層構造 | ghostty → zellij → herdr → agent | ghostty → herdr → agent |

### レイアウト移行表(dev.kdl → herdr)

| zellij tab | herdr tab | 中身 |
|---|---|---|
| 「101」(縦 2) | tab「101」 | fastfetch @~/dotfiles + btm @ ~(横並び) |
| 「102」(横 2) | tab「102」 | ncmpcpp @~/Music + `cat ~/data/cat.txt`(上下) |
| 「Dev」(2×2) | tab「Dev」 | zsh ×4 @~/Developer |
| 「herdr」 | **廃止**(herdr 自身がホスト) | — |
| 「Docs」+「Plan」 | tab「Docs」(統合) | omp agent + spynel 横並び @~/Developer/docs |
| コメント済(xrp) | 作らない(元のままコメント) | — |
| (docker / lazydocker) | **条件付き tab「lazydocker」** | docker daemon 稼働 + lazydocker 導入時のみ作成(idempotent: 毎起動時にタブ有無を確認) |

再現手段: 起動エントリ **`home/dot_local/bin/executable_herdr-dev`**(zellij layouts/dev.kdl の置き換え物)。server 未稼働時は headless server を起動して ready 待ちし、**workspace と各プリセットタブ(102 / Dev / Docs / lazydocker)をタブ単位で冪等に保証**(閉じられたタブは次回起動時に個別復活。構築済みタブの pane 構成には触れない)した上で `herdr` attach する。autostart(zprofile / bash_profile)から直接呼ぶ。socket API を順に実行する:

1. server が未稼働なら `nohup herdr server` で起動し ready を待つ(既に稼働していれば skip)。**自前で起動した場合 = snapshot 復元直後で pane が素 shell のみ**のため、dev workspace を閉じてプリセットをコマンド再実行込みで完全再構築する(`herdr server stop` 後の `herdr-dev` でも全復元)
2. workspace「dev」存在確認 → 無ければ `workspace create --label dev`(再実行は no-op。作り直すときは `workspace close` してから)
3. `workspace create` の root tab を「101」に改名 → `pane run` で fastfetch → `pane split --direction right --cwd ~` → `pane run` で btm(「102」は split down、「Dev」は 2×2)
4. 「Docs」: `tab create --label Docs --cwd ~/Developer/docs` → `pane split --direction right` → `agent start omp --kind omp -- -c`(左)+ `pane run` で spynel(旧 Docs+Plan を 1 タブに統合)

実装条件: `#!/usr/bin/env bash` + `set -eu` + `command -v herdr` / `command -v jq` ガード(応答 JSON の parse 用)。pane/tab/workspace ID は作成応答から読み、推測しない。

server 再起動後の挙動: layout/cwd は復元されるため bootstrap の再実行は不要。fastfetch・btm・ncmpcpp・cat・spynel は素 shell として復帰するため**手動で再実行**(detach/reattach なら process 継続で無問題)。自動再実行が必要になったら herdr plugin(event hooks)で対応(将来対応セクション参照)。

### キー所有権マップ v2(廃止後)

| キー | 廃止後の所有者 | 内側・備考 |
|---|---|---|
| `Ctrl+b` | **herdr prefix**(既定値のまま) | shell・pi/omp 語左は `Alt+b`・`←`。zellij の `Write 2` 透過が不要になるだけ。所有者は現行どおり herdr |
| `Ctrl+o/t/p/n/h/g/q` | 解放 → 内側の既定 | pi `Ctrl+o`(ツール出力)・`Ctrl+g` 等が本来動作に復帰 |
| `Ctrl+s` | **tty flow control(XOFF)** ← zellij 消滅で初めて shell に届く | zsh 起動に `stty -ixon` を追加して無効化(実施手順)。TUI(btm/ncmpcpp/omp/pi/lazygit 等)は raw mode で IXON 自体が無効のため影響なし。shell pane が対象 |
| `Alt+f` | 解放 | pi/omp 語右(ghostty `Alt+→` の変換先) |
| `Alt+w/c/t`・`Alt+Up`・`Alt+L`・`Alt+Shift+P` | 解放 | omp/pi 既定に復帰 |
| `Alt+h/j/k/l`・`Alt+矢印` | 解放 | zellij 下では消費されていた pi エディタの hjkl 系キーが初めて全キー有効化される |

`stty -ixon` により `Ctrl+s`(XOFF)と `Ctrl+q`(XON)の flow control を無効化。`Ctrl+q` は shell に届いても無害化され、omp followUp の既定 `Ctrl+Q` が復活する。

反映手順:

- **pi**: `~/.pi/agent/keybindings.json`(`app.editor.external` / `app.message.dequeue` の 2 件上書き)を**削除** → 既定 `ctrl+g` / `alt+up` へ復帰。
- **pi**: `~/.config/pi/agent/keybindings.json`(chezmoi 管理・hjkl エディタキー)は**ユーザー独自設定として維持**。注: ghostty は `Alt+→` を `esc:f`(`Alt+f`)として送るため、`cursorWordRight: [alt+left, alt+w]` は `Alt+→` では発火しない(`Alt+→` 相当を欲しければ `alt+f` を追加)。
- **omp**: `~/.omp/agent/keybindings.yml`(5 件の上書き)を**削除** → followUp `Ctrl+Q`/`Ctrl+Enter`、dequeue `Alt+Up`/`Shift+Up`、external `Ctrl+G`、plan `Alt+Shift+P`、display reset `Alt+L` が既定へ復帰。
- **herdr**: keybind 変更**ゼロ**(prefix `ctrl+b` は既定値、direct キーなし)。
- **ghostty**: 変更なし。
- **zsh**: `stty -ixon` を追加(上記参照。これが新規の shell 側設定)。

→ 逸脱リスト 11 件(zellij 5 + omp 5 + pi 1)は**全件消滅**(zsh `stty -ixon` を新規逸脱として逸脱リストに記録)。

### 残る機能差(受容判断)

| zellij 機能 | herdr 代替 | 判定 |
|---|---|---|
| scroll/search モード(`Ctrl+s`, `v`/`y` コピー) | mouse wheel scroll + `copy_on_select`(既定 true)+ `prefix+e` edit_scrollback(エディタで検索) | 受容 |
| 汎用フローティングペイン(`Alt+w`) | `[[keys.command]] type = "popup"`(コマンド単位のモーダル) | 受容。必要時に popup を追加 |
| pane move / swap キー(`Ctrl+h` モード) | `herdr pane move` / `pane swap`(socket API) | 受容(低頻度) |
| swap layout(`Alt+[` / `Alt+]`) | なし | 受容 |
| tab 全ペイン同期入力(`Ctrl+t`→`s`) | なし | 受容(未使用) |
| tmux 互換モード(`Alt+t`) | 不要化(herdr 自体が prefix 型) | — |
| レイアウトの command 自動再実行(server 再起動後) | snapshot 復元は cwd のみ。plugin event hooks で自動化可 | 受容。必要時に plugin 化 |

### 実施手順

1. `mise upgrade herdr` → `herdr server stop` → `herdr`(client 0.9.1 / server 0.9.0 の版差を解消。`herdr update` は mise 管理では無効)
2. `herdr integration install omp pi` → omp セッション再起動 → `herdr integration status` で pi ≥ v2 / omp ≥ v3 を確認(server 再起動後の対話 resume 用。現状 both not installed)。**導入先は chezmoi 非管理の `~/.config/omp/profiles/god/agent/extensions/herdr-*.ts`**(実測の status 表示パス)。extensions/ 配下には既に非管理ファイル(`pi-rtk-optimizer/` 等)があるため、導入後に `chezmoi add` するか `.chezmoiignore` に明示して drift を潰す
3. `executable_herdr-dev` 新設 → herdr 内 shell で 1 回実行 → タブ/ペイン/agent 構成を確認
4. zprofile: `zellij -l dev` → `herdr` に変更。guard に `[ "${HERDR_ENV:-}" != 1 ]` を追加。tmux fallback は維持
5. zshrc: `stty -ixon` を追加(flow control 無効化。zellij 削除で `Ctrl+s` が shell に届くため)
6. `home/private_dot_config/zellij/`(config.kdl + layouts/dev.kdl)を source から削除し `chezmoi apply`(managed から外れた実ファイルも除去)
7. `~/.pi/agent/keybindings.json` と `~/.omp/agent/keybindings.yml` を削除(既定復帰)
8. 旧 zellij セッションを quit → ghostty 新規起動 → `herdr` 起動と workspace「dev」を確認
9. キー確認(検証手順 準拠): omp `/hotkeys` で既定復帰、pi `/reload`、shell `Ctrl+r` 履歴検索、`Ctrl+b` → herdr prefix、`Alt+b`/`Alt+f` 語移動、pi `Alt+h/j/k/l`、shell で `Ctrl+s` が画面凍結しないこと
10. 周辺清掃: mise `tools.toml` の `zellij = "latest"` 削除 + `mise uninstall zellij`、tech.md / directory.md の zellij 記載削除、`~/Developer/docs/DESIGN.md`(旧コピー・9/20 版)の更新
11. 本ドキュメントを廃止後スタックへ書き換え(廃止計画を本文へ昇格、別コミット)

### ロールバック

- jj revert(実施手順 4〜10)。zellij config / layouts は履歴から復元、pi/omp の上書きファイルは復元手順に従い再作成、zshrc の `stty -ixon` 行を削除。
- bootstrap script の残置は害なし。workspace「dev」のみ撤去する場合は `herdr workspace close`。

## 将来対応(本タスク対象外・現状メモ)

- **aliases**: ユーザーメモの話題。シェルエイリアス(想定: `~/.zshrc` 由来)は未調査・未変更。mux/キーマップ確定後に別タスクで整理する。
- **macOS システム**: `Ctrl+←/→`(Spaces)は無効化済みを確認(入力環境 セクション)。Ubuntu 側の `Ctrl+←/→` 割当は未確認。
- **zed**: 既定キーマップの要点は docs 取得失敗のため未確認。zed 内ターミナルを常用するようになったら再確認する。
- **herdr plugin**: server 再起動後の run-once コマンド(fastfetch/btm/ncmpcpp/cat/spynel)自動再実行が欲しくなったら、herdr plugin(event hooks)で「restore 後に pane run」を実装する。それまで手動再実行。

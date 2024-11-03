#!/usr/bin/env bash
set -ex

## コンピュータ名、ホスト名、ローカルホスト名、ユーザー名を設定
# sudo scutil --set ComputerName "iCom"
# sudo scutil --set HostName "101"
# sudo scutil --set LocalHostName "101"
# sudo scutil --set UserName "hotmilk"

# (on マシンがフリーズしたら自動的にリスタート)
systemsetup -setrestartfreeze on
# スリープしない
systemsetup -setcomputersleep Off > /dev/null 2>&1

# Show the ~/Library directory （ライブラリディレクトリを表示、デフォルトは非表示）
chflags nohidden ~/Library

## defaults による初期設定

# ログイン画面でシステム情報を表示する
# sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
# ダークモードをオンにする
sudo defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark
# 時計アイコンクリック時に OS やホスト名 IP を表示する
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
# メモリ過負荷時のアラートを表示する空きメモリを1000MBにする。無効にするには -int 1000を消して実行
# sudo defaults write /System/Library/LaunchDaemons/com.apple.jetsamproperties.Mac.plist JetsamCriticalHighWaterMark -int 1000

# 動きを高速化
defaults write -g com.apple.trackpad.scaling 3 && \
defaults write -g com.apple.mouse.scaling 1.5

## キーリピートを早くする
defaults write -g KeyRepeat -int 1 && \
defaults write -g InitialKeyRepeat -int 10

## ダイアログ表示やウィンドウリサイズ速度を高速化する
defaults write -g NSWindowResizeTime 0.1

## (保存ダイアログのデフォルト表示スタイル) -> true (常に詳細な情報を開いて表示)
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

## Enable `Tap to click` （タップでクリックを有効にする）
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
#defaults write -g com.apple.mouse.tapBehavior -int 1
#defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

## 三本指でドラッグ
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true && \
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# トラックパッドのナチュラルスクロールをオンにする
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# フルスクリーンアプリケーション感をするために4本指でスワイプを有効にする
defaults write com.apple.AppleMultitouchTrackpad.plist TrackpadFourFingerVertSwipeGesture -int 2 && \
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad.plist TrackpadFourFingerVertSwipeGesture -int 2

## スクロールバーを常時表示する
defaults write -g AppleShowScrollBars -string "Always"

## キー入力の連打を有効化させる
defaults write -g ApplePressAndHoldEnabled -bool false

## クラッシュレポートを無効化する
defaults write com.apple.CrashReporter DialogType -string "none"

## 未確認のアプリケーションを実行する際のダイアログを無効にする
defaults write com.apple.LaunchServices LSQuarantine -bool false

## ダウンロードしたファイルを開くときの警告ダイアログをなくしたい
defaults write com.apple.LaunchServices LSQuarantine -bool false

# ゴミ箱を空にする前の警告の無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool false

## ウィンドウを開閉するときのアニメーションを無効
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

## ウィンドウサイズを調整する際の加速再生
defaults write -g NSWindowResizeTime -float 0.001

## Finderで情報ウィンドウを開くときのアニメーションを無効
defaults write com.apple.finder DisableAllAnimations -bool true

## Quick Lookウィンドウのアニメーションをオフ
defaults write -g QLPanelAnimationDuration -float 0

## Dockからアプリを起動するときのアニメーションを無効
defaults write com.apple.dock launchanim -bool false

## Automatically hide or show the Dock （Dock を自動的に隠す）
defaults write com.apple.dock autohide -bool true

## Wipe all app icons from the Dock （Dock に標準で入っている全てのアプリを消す、Finder とごみ箱は消えない）
defaults write com.apple.dock persistent-apps -array

## Dock が表示されるまでの待ち時間を無効にする
defaults write com.apple.dock autohide-delay -float 0

## テキストエディットをプレーンテキストで使う
#defaults write com.apple.TextEdit RichText -int 0

## スペルの訂正を無効にする
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

## 他のMacで購入したアプリを自動的にダウンロードする
#defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

## terminalでUTF-8のみを使用する
defaults write com.apple.terminal StringEncodings -array 4

## 新しいウィンドウでデフォルトでホームフォルダを開く
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

## 隠しファイルを常にファインダーに表示する
defaults write com.apple.finder AppleShowAllFiles -bool YES && \
killall Finder

# アクセントカラーをマルチカラーに設定する
defaults write NSGlobalDomain AppleAccentColor -int -1

## スクリーンショットをjpgで保存
defaults write com.apple.screencapture type jpg

## 全ての拡張子のファイルを表示する
defaults write -g AppleShowAllExtensions -bool true

## Finder のタイトルバーにフルパスを表示する
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# タブバーを表示する
defaults write com.apple.finder ShowTabView -bool true

# パスバーを表示する
defaults write com.apple.finder ShowPathbar -bool true

# ステータスバーを表示する
defaults write com.apple.finder ShowStatusBar -bool true

## 名前で並べ替えを選択時にディレクトリを前に置くようにする
defaults write com.apple.finder _FXSortFoldersFirst -bool true

## Avoid creating `.DS_Store` files on network volumes （ネットワークディスクで、`.DS_Store` ファイルを作らない）
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

## Date options: Show the day of the week: on （日付表示設定、曜日を表示）
defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE H:mm'

## Bluetooth ヘッドフォン・ヘッドセットの音質を向上させる
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

## 未確認のアプリケーションを実行する際のダイアログを無効にする
defaults write com.apple.LaunchServices LSQuarantine -bool false

# F1、F2などのキーを標準的なファンクションキーとして使用
defaults write -g com.apple.keyboard.fnState -bool true

# 「新規フォルダ」のショートカットキー設定
defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "新規フォルダ" -string "^k"
# 「ここに項目を移動」のショートカットキー設定
defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "ここに項目を移動" -string "@^v"
# 「ゴミ箱に入れる」のショートカットキー設定
defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "ゴミ箱に入れる" -string "^d"
# 「情報を見る」のショートカットキー設定
defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "情報を見る" -string "^l"
# Finderの独自ショートカットキー設定の内容を確認
# echo Finderの独自キー設定：$(defaults read com.apple.Finder NSUserKeyEquivalents)

# Spotlight検索を表示を無効化
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
# Finderの検索ウインドウを表示を無効化
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1572864</integer></array><key>type</key><string>standard</string></dict></dict>"
# Spotlight検索を表示、Finderの検索ウインドウを表示が無効化になっているか確認する（64、65をチェックすること）
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys

# 再起動
for app in "Dock" \
    "Finder" \
    "SystemUIServer"; do
    killall "${app}" > /dev/null 2>&1
done

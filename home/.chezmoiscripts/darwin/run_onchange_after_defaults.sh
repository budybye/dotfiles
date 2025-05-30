#!/usr/bin/env bash

user_setup() {
    # コンピュータ名、ホスト名、ローカルホスト名、ユーザー名を設定
    scutil --set ComputerName "iCom"
    scutil --set LocalHostName "101"
    scutil --set HostName "101"
    scutil --set UserName "hotmilk"
    whoami
}

system_setup() {
    # (on マシンがフリーズしたら自動的にリスタート)
    sudo systemsetup -setrestartfreeze on
    # スリープしない
    sudo systemsetup -setcomputersleep Off
    # ネットワーク時刻サーバーを設定
    sudo systemsetup -setnetworktimeserver time.apple.com
    # タイムゾーンを設定
    sudo systemsetup -settimezone "Asia/Tokyo"
    # リモートログインを有効化
    sudo systemsetup -setremotelogin on
}

app_setup() {
    # 他のMacで購入したアプリを自動的にダウンロードする
    defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
    # ソフトウェアの自動更新を有効化
    defaults write com.apple.commerce AutoUpdate -bool true
    # WebKitデベロッパーツールを有効にする
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true
    # デバッグメニューを有効にする
    defaults write com.apple.appstore ShowDebugMenu -bool true
    # 自動更新チェックを有効にする
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    # 毎日アプリケーションのアップデートを確認する
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    # アプリケーションのアップデートをバックグラウンドでダウンロードする
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
    # システムデータファイルとセキュリティ更新プログラムをインストールする
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
    # 他のMacで購入したアプリを自動的にダウンロードする
    defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
    # アプリケーションの自動更新を有効化
    defaults write com.apple.commerce AutoUpdate -bool true
    # 再起動が必要なアプリケーションの場合自動で再起動を有効化する
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true
}

interface_setup() {
    # F1、F2などのキーを標準的なファンクションキーとして使用
    defaults write -g com.apple.keyboard.fnState -bool true
    # キーリピートを早くする
    defaults write -g KeyRepeat -int 1
    # キー入力の連打を有効化させる
    defaults write -g ApplePressAndHoldEnabled -bool false
    # トラックパッドのナチュラルスクロールをオンにする
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
    # マウスの動きを高速化
    defaults write "Apple Global Domain" com.apple.mouse.scaling 4.0
    # トラックパッドの動きを高速化
    defaults write "Apple Global Domain" com.apple.trackpad.scaling 4.0

    # Enable `Tap to click` （タップでクリックを有効にする）
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

    # 三本指でドラッグ
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true && \
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # フルスクリーンアプリケーション間を移動するために4本指でスワイプを有効にする
    defaults write com.apple.AppleMultitouchTrackpad.plist TrackpadFourFingerVertSwipeGesture -int 2 && \
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad.plist TrackpadFourFingerVertSwipeGesture -int 2
}

dock_setup() {
    # Dock を自動で隠す
    defaults write com.apple.dock autohide -bool true
    # dockの動作を素早くする
    defaults write com.apple.dock autohide-time-modifier -float 0.13
    # Dock が表示されるまでの待ち時間を無効にする
    defaults write com.apple.dock autohide-delay -float 0.01
    # Dockからアプリを起動するときのアニメーションを無効
    defaults write com.apple.dock launchanim -bool false
    # Automatically hide or show the Dock （Dock を自動的に隠す）
    defaults write com.apple.dock autohide -bool true
    # Wipe all app icons from the Dock （Dock に標準で入っている全てのアプリを消す、Finder とごみ箱は消えない）
    defaults write com.apple.dock persistent-apps -array
    # Dock Size
    defaults write com.apple.dock tilesize -int 50
    # Dock 拡大
    defaults write com.apple.dock magnification -bool true
    # Dock 拡大サイズ
    defaults write com.apple.dock largesize -int 78
    # ウィンドウをアプリケーションアイコンにしまう
    defaults write com.apple.dock minimize-to-application -bool true
    # 最近使ったアプリを Dock に表示しない
    defaults write com.apple.dock show-recents -bool false
}

window_setup() {
    # Show the ~/Library directory （ライブラリディレクトリを表示、デフォルトは非表示）
    chflags nohidden ~/Library
    # ログイン画面でシステム情報を表示する
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    # ダークモードをオンにする
    sudo defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark
    # 時計アイコンクリック時に OS やホスト名 IP を表示する
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    # クラッシュレポートを無効化する
    defaults write com.apple.CrashReporter DialogType -string "none"
    # 未確認のアプリケーションを実行する際のダイアログを無効にする
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    # ダウンロードしたファイルを開くときの警告ダイアログをなくしたい
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    # 未確認のアプリケーションを実行する際のダイアログを無効にする
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    # ダイアログ表示やウィンドウリサイズ速度を高速化する
    defaults write -g NSWindowResizeTime -float 0.001
    # (保存ダイアログのデフォルト表示スタイル) -> true (常に詳細な情報を開いて表示)
    defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
    # アクセントカラーをマルチカラーに設定する
    defaults write -g AppleAccentColor -int -1
    # ウィンドウを開閉するときのアニメーションを無効
    defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
    # スペルの訂正を無効にする
    defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
    # スクロールバーを常時表示する
    defaults write -g AppleShowScrollBars -string "Always"
    # ウィンドウサイズを調整する際の加速再生
    defaults write -g NSWindowResizeTime -float 0.001
    # Quick Lookウィンドウのアニメーションをオフ
    defaults write -g QLPanelAnimationDuration -float 0

    defaults write -g AccountInfoValidationCounter -int 4
    # テキストエディットをプレーンテキストで使う
    defaults write com.apple.TextEdit RichText -int 0
    # terminalでUTF-8のみを使用する
    defaults write com.apple.terminal StringEncodings -array 4
    # スクリーンショットをjpgで保存
    defaults write com.apple.screencapture type jpg
    # ネットワークディスクで、`.DS_Store` ファイルを作らない
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    # 日付表示設定、曜日を表示
    defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE H:mm'
    # Bluetooth ヘッドフォン・ヘッドセットの音質を向上させる
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # 通知センターを無効化
    launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
    # 通知センターを有効化する場合
    # launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
}

finder_setup() {
    # 全ての拡張子のファイルを表示
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # ディレクトリのスプリングロードを有効化
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true
    # スプリングロード遅延を除去
    defaults write NSGlobalDomain com.apple.springing.delay -float 0
    # 新しいウィンドウでデフォルトでホームフォルダを開く
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
    # 隠しファイルを常にファインダーに表示する
    defaults write com.apple.finder AppleShowAllFiles -bool true
    # Finder のタイトルバーにフルパスを表示する
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # 検索時にデフォルトでカレントディレクトリを検索
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # 拡張子変更時の警告を無効化
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # タブバーを表示する
    defaults write com.apple.finder ShowTabView -bool true
    # パスバーを表示する
    defaults write com.apple.finder ShowPathbar -bool true
    # ステータスバーを表示する
    defaults write com.apple.finder ShowStatusBar -bool true
    # Finderで情報ウィンドウを開くときのアニメーションを無効
    defaults write com.apple.finder DisableAllAnimations -bool true
    # ゴミ箱を空にする前の警告の無効化
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    # 「新規フォルダ」のショートカットキー設定
    defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "新規フォルダ" -string "^k"
    # 「ここに項目を移動」のショートカットキー設定
    defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "ここに項目を移動" -string "@^v"
    # 「ゴミ箱に入れる」のショートカットキー設定
    defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "ゴミ箱に入れる" -string "^d"
    # 「情報を見る」のショートカットキー設定
    defaults write com.apple.Finder NSUserKeyEquivalents -dict-add "情報を見る" -string "^l"
}

search_setup() {
    # Spotlight検索を表示を無効化
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
    # Finderの検索ウインドウを表示を無効化
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1572864</integer></array><key>type</key><string>standard</string></dict></dict>"
    # Spotlight検索を表示、Finderの検索ウインドウを表示が無効化になっているか確認する（64、65をチェックすること）
    # defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -E '64|65'
}

network_setup() {
    # sudo networksetup -SetAirportPower en0 on
    # sudo networksetup -SetAirportNetwork en0 <SSID> <PASSWORD>
    # sudo networksetup -SetV6Off Wi-Fi
    # sudo networksetup -SetDNSServers Wi-Fi 1.1.1.1 1.0.0.1
    # sudo networksetup -ListNetworkServiceOrder
    nslookup apple.com
}

restart() {
    echo 'Rebooting to reflect settings'
    # 再起動
    for app in \
        "Activity Monitor" \
        "Address Book" \
        "Calendar" \
        "Contacts" \
        "Dock" \
        "Finder" \
        "Mail" \
        "Messages" \
        "Photos" \
        "Safari" \
        "Terminal" \
        "SystemUIServer"; do
        killall "${app}" > /dev/null 2>&1
    done
}

echo "defaults.sh"
echo "--------------------------------"
# user_setup
# system_setup
# app_setup
interface_setup
window_setup
dock_setup
finder_setup
search_setup
# network_setup
restart

echo "--------------------------------"
echo "macOS setup complete."
echo "--------------------------------"

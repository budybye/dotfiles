#!/usr/bin/env bash
set -ex

# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}

# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

# デスクトップ環境のインストール
desktop_setup() {
    echo "desktop setup start..."
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y xfce4 xfce4-goodies xrdp xorgxrdp language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc plank || {
        echo "desktop setup failed."
        exit 1
    }
    # sudo apt-get remove -y light-locker xscreensaver &&
    sudo apt-get autoremove -y && sudo apt-get clean && sudo rm -rf /var/cache/apt /var/lib/apt/lists/*
    echo "desktop setup completed."
}

# Snap をインストールおよび管理する関数
install_snap() {
    echo "snapd install start..."
    command -v snap >/dev/null || sudo apt-get install -y snapd || {
        echo "snapd install failed."
        exit 1
    }
    echo "snapd installed."

    echo "codium install start..."
    command -v codium >/dev/null || sudo snap install codium --classic || {
        echo "codium install failed."
        exit 1
    }
    echo "codium installed."

    echo "speedtest install start..."
    command -v speedtest >/dev/null || sudo snap install speedtest || {
        echo "speedtest install failed."
        exit 1
    }
    echo "speedtest installed."

    echo "alacritty install start..."
    command -v alacritty >/dev/null || sudo snap install alacritty --classic || {
        echo "alacritty install failed."
        exit 1
    }
    echo "alacritty installed."

    if [ command -v firefox ]; then
        sudo snap remove firefox || sudo apt remove firefox || {
        echo "firefox uninstall failed."
    }
    fi
    echo "firefox uninstalled."

    # echo "### chromium のインストールを開始します..."
    # sudo snap install chromium || {
    #     echo "### chromium のインストールに失敗しました。"
    #     exit 1
    # }
    # echo "### chromium をインストールしました。"
    # which chromium

    echo "snap tools installed."
}

# Brave ブラウザをインストールする関数
install_brave_browser() {
    echo "brave browser install start..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
        https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt-get update -y
    sudo apt-get install -y brave-browser || {
        echo "brave browser install failed."
        exit 1
    }
    echo "brave browser installed."
}

# Tabby Terminal をインストールする関数
install_tabby_terminal() {
    echo "tabby terminal install start..."
    curl https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
    sudo apt-get update -y
    sudo apt-get install -y tabby-terminal || {
        echo "tabby terminal install failed."
        exit 1
    }
    echo "tabby terminal installed."
}

# Cloudflare Warp をインストールおよび設定する関数
install_cloudflare_warp() {
    echo "cloudflare warp install start..."
    sudo curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt-get update -y
    sudo apt-get install -y cloudflare-warp || {
        echo "cloudflare warp install failed."
        exit 1
    }
    echo "cloudflare warp installed."

    warp-cli --accept-tos registration new
    warp-cli --accept-tos mode warp
    warp-cli --accept-tos dns families malware
    warp-cli --accept-tos connect
    warp-cli --accept-tos disconnect

    echo "cloudflare warp configured."
}

# GitHub Desktop と Cursor をインストールする関数
install_github_desktop() {
    echo "github desktop install start..."
    sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.4.3-linux1/GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    sudo dpkg -i GitHubDesktop-linux-${arch}-3.4.3-linux1.deb || {
        echo "github desktop install failed."
        exit 1
    }
    sudo rm -f GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    echo "github desktop installed."
}

# Cursor をインストールする関数
install_cursor() {
    echo "cursor install start..."
    appimage="${HOME}/Applications/cursor"
    mkdir -p "${HOME}/Applications"

    if [ "${arch}" = "amd64" ]; then
        curl -L https://downloader.cursor.sh/inulx -o "${appimage}" || {
            echo "cursor download failed."
            exit 1
        }
    else
        curl -L https://github.com/coder/cursor-arm/releases/download/v0.42.2/cursor_0.42.2_linux_arm64.AppImage -o "${appimage}" || {
            echo "cursor download failed."
            exit 1
        }
    fi
    sudo chmod a+x "${appimage}"

    echo "libfuse2 install start..."
    command -v libfuse2 >/dev/null || sudo apt-get install -y libfuse2 || {
        echo "libfuse2 install failed."
        exit 1
    }
    echo "libfuse2 installed."
    echo "${appimage} installed."
}

# Wireshark をインストールおよび設定する関数
install_wireshark() {
    echo "wireshark install start..."
    sudo apt install -y wireshark || {
        echo "wireshark install failed."
        exit 1
    }
    echo "wireshark installed."
    sudo groupadd -f wireshark
    sudo usermod -aG wireshark "$USER_NAME"
}

# Ruby と Fusuma をインストールおよび設定する関数
install_ruby_fusuma() {
    echo "ruby and fusuma install start..."
    command -v gem >/dev/null || mise use ruby -y || sudo apt-get install -y ruby || {
        echo "ruby install failed."
        exit 1
    }
    echo "ruby installed."

    echo "fusuma install start..."
    sudo gem install fusuma || {
        echo "fusuma install failed."
        exit 1
    }
    sudo groupadd -f input
    sudo usermod -aG input "$USER_NAME"
    fusuma -d
    echo "fusuma configured."
}

# 日本語環境の設定
japan_setup() {
    echo "japan setup start..."
    # CRDA設定ファイル内のREGDOMAINをJPに変更（存在しない場合は無視）
    sudo sed -i 's/^\s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true
    setupcon -k --force || true
    LANG=C xdg-user-dirs-update --force
    # 入力メソッドとしてfcitx5を設定
    im-config -n fcitx5
    echo "#日本語環境の設定が完了しました"
}

# フォントをインストールする関数
install_fonts() {
    # フォントディレクトリ
    fonts="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    # フォントディレクトリを作成
    sudo mkdir -p "${fonts}"
    # HackGen フォントのダウンロード
    sudo curl -L https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_NF_v2.9.0.zip -o "${fonts}/HackGen_NF_v2.9.0.zip"
    # RobotoMonoJP フォントのダウンロード
    sudo curl -L https://github.com/mjun0812/RobotoMonoJP/releases/download/v5.9.0/RobotoMonoJP-Regular.ttf -o "${fonts}/RobotoMonoNF-Regular.ttf"

    # HackGen フォントの展開（ttfファイルのみをfontsディレクトリに配置）
    sudo unzip -j -o "${fonts}/HackGen_NF_v2.9.0.zip" '*.ttf' -d "${fonts}"
    # ダウンロードしたzipファイルの削除
    sudo rm -f "${fonts}/HackGen_NF_v2.9.0.zip"
    # フォントキャッシュの更新
    fc-cache -fv
    echo "fonts installed."
    tree "${fonts}"
}

# xrdpの設定
xrdp_setup() {
    echo "xrdp setup start..."
    sudo groupadd -f ssl-cert
    sudo groupadd -f xrdp
    # ubuntuユーザーを必要なグループに追加
    sudo usermod -aG ssl-cert,xrdp,input,audio,sudo "${USER_NAME}"
    # サービスの再起動
    sudo systemctl daemon-reload
    sudo systemctl restart rsyslog
    # ファイアウォールで3389番ポート（RDP）を許可
    sudo ufw allow 3389
    # xrdpサービスを有効化し、起動
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    # デフォルトのセッションマネージャーをxfce4-sessionに設定
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session
    echo "xrdp setup completed."

    echo "以下のコマンドを実行してパスワードを更新してください"
    echo "sudo passwd ${USER_NAME}"
}

main() {
    echo "desktop setup start..."
    desktop_setup
    install_snap
    install_brave_browser
    install_tabby_terminal
    install_cloudflare_warp
    install_github_desktop
    install_cursor
    install_ruby_fusuma
    install_wireshark
    install_fonts
    japan_setup
    xrdp_setup
    echo "desktop setup completed."
}

main

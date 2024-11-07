#!/usr/bin/env bash
set -ex

# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}

# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

echo "### Ubuntuのデスクトップ環境のインストールを開始します..."

# デスクトップ環境のインストール
desktop_setup() {
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y xfce4 xfce4-goodies xrdp xorgxrdp language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc wireshark plank || {
        echo "### デスクトップ環境のインストールに失敗しました。"
        exit 1
    }
    # sudo apt-get remove -y light-locker xscreensaver &&
        sudo apt-get autoremove -y &&
            sudo apt-get clean &&
                sudo rm -rf /var/cache/apt /var/lib/apt/lists/*

    echo "### デスクトップ環境のインストールが完了しました。"
}

# Snap をインストールおよび管理する関数
install_snap() {
    if ! command -v snap >/dev/null 2>&1; then
        sudo apt-get install -y snapd || {
            echo "### snapd のインストールに失敗しました。"
            exit 1
        }
        echo "### snapd をインストールしました。"
    else
        echo "### snapd は既にインストールされています。"
    fi

    # Codium のインストール確認
    if ! command -v codium >/dev/null 2>&1; then
        sudo snap install codium --classic || {
            echo "### codium のインストールに失敗しました。"
            exit 1
        }
        echo "### codium をインストールしました。"
    else
        echo "### codium は既にインストールされています。"
    fi
    which codium

    # Speedtest のインストール確認
    if ! command -v speedtest >/dev/null 2>&1; then
        sudo snap install speedtest || {
            echo "### speedtest のインストールに失敗しました。"
            exit 1
        }
        echo "### speedtest をインストールしました。"
    else
        echo "### speedtest は既にインストールされています。"
    fi
    which speedtest

    # Firefox の削除確認
    if command -v firefox >/dev/null 2>&1; then
        sudo snap remove firefox || {
            echo "### firefox のアンインストールに失敗しました。"
            exit 1
        }
        echo "### firefox を削除しました。"
    else
        echo "### firefox はインストールされていません。"
    fi
    # sudo snap install chromium || {
    #     echo "### chromium のインストールに失敗しました。"
    #     exit 1
    # }
    # echo "### chromium をインストールしました。"
    # which chromium

    echo "### Snap のインストールが完了しました。"
}

# Brave ブラウザをインストールする関数
install_brave_browser() {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
        https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt-get update -y
    sudo apt-get install -y brave-browser || {
        echo "### brave のインストールに失敗しました。"
        exit 1
    }
    echo "### brave-browser をインストールしました。"
    which brave-browser
}

# Tabby Terminal をインストールする関数
install_tabby_terminal() {
    curl https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
    sudo apt-get update -y
    sudo apt-get install -y tabby-terminal || {
        echo "### tabby のインストールに失敗しました。"
        exit 1
    }
    echo "### tabby-terminal をインストールしました。"
    which tabby
}

# Cloudflare Warp をインストールおよび設定する関数
install_cloudflare_warp() {
    if ! command -v warp-cli >/dev/null 2>&1; then
        sudo curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        sudo apt-get update -y
        sudo apt-get install -y cloudflare-warp || {
            echo "### warp のインストールに失敗しました。"
            exit 1
        }
        echo "### cloudflare-warp をインストールしました。"
    else
        echo "### cloudflare-warp はインストールされています。"
    fi
    which warp-cli

    warp-cli --accept-tos registration new
    warp-cli --accept-tos mode warp+doh
    warp-cli --accept-tos dns families malware
    warp-cli --accept-tos connect
    warp-cli --accept-tos disconnect

    echo "### cloudflare-warp を設定しました。"
}

# GitHub Desktop と Cursor をインストールする関数
install_github_desktop() {
    sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.4.3-linux1/GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    sudo dpkg -i GitHubDesktop-linux-${arch}-3.4.3-linux1.deb || {
        echo "### GithubDesktop のインストールに失敗しました。"
        exit 1
    }
    sudo rm -f GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    echo "### GithubDesktop をインストールしました。"
}

# Cursor をインストールする関数
install_cursor() {
    appimage="${HOME}/Applications/cursor"
    mkdir -p "${HOME}/Applications"
    if [ "${arch}" = "amd64" ]; then
        curl -L https://downloader.cursor.sh/inulx -o "${appimage}" || {
            echo "### cursor のダウンロードに失敗しました。"
            exit 1
        }
    else
        curl -L https://github.com/coder/cursor-arm/releases/download/v0.42.2/cursor_0.42.2_linux_arm64.AppImage -o "${appimage}" || {
            echo "### cursor のダウンロードに失敗しました。"
            exit 1
        }
    fi
    sudo chmod a+x "${appimage}"
    echo "### Cursor をインストールしました。"
    echo "${appimage}"
}

# Wireshark をインストールおよび設定する関数
install_wireshark() {
    if ! command -v wireshark >/dev/null 2>&1; then
        sudo apt install -y wireshark || {
            echo "### wireshark のインストールに失敗しました。"
            exit 1
        }
        echo "### wireshark をインストールしました。"
    else
        echo "### wireshark は既にインストールされています。"
    fi
    sudo groupadd -f wireshark
    sudo usermod -aG wireshark "$USER_NAME"
    which wireshark
}

# Ruby と Fusuma をインストールおよび設定する関数
install_ruby_fusuma() {
    if ! command -v gem >/dev/null 2>&1; then
        mise use ruby -y || sudo apt-get install -y ruby || {
            echo "### ruby のインストールに失敗しました。"
            exit 1
        }
        echo "### ruby をインストールしました。"
    else
        echo "### ruby は既にインストールされています。"
    fi
    which ruby

    sudo gem install fusuma || {
        echo "### fusuma のインストールに失敗しました。"
        exit 1
    }
    sudo groupadd -f input
    sudo usermod -aG input "$USER_NAME"
    fusuma -d
    echo "### fusuma の設定を完了しました。"
}

# 日本語環境の設定
japan_setup() {
    # CRDA設定ファイル内のREGDOMAINをJPに変更（存在しない場合は無視）
    sudo sed -i 's/^\s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true
    # ユーザーディレクトリを強制的に更新
    LANG=C xdg-user-dirs-update --force
    # 入力メソッドとしてfcitx5を設定
    im-config -n fcitx5
    setupcon -k --force || true
    echo "### 日本語環境の設定が完了しました"
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
    echo "### フォントをインストールしました。"
    tree "${fonts}"
}

# xrdpの設定
xrdp_setup() {
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
    echo "### xrdpの設定が完了しました"
    # デフォルトのセッションマネージャーをxfce4-sessionに設定
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

    echo "以下のコマンドを実行してパスワードを更新してください"
    echo "sudo passwd ${USER_NAME}"
    # ubuntuユーザーのパスワードを設定（対話形式で入力）
    # sudo passwd "${USER_NAME}"
    echo "### xfce4-sessionの設定が完了しました"
}

main() {
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
    echo "### デスクトップ環境のインストールが完了しました。"
}

main

#!/usr/bin/env bash
set -x

# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}

# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

# Zsh をデフォルトシェルに変更する関数
change_shell_to_zsh() {
    # Zsh がインストールされているか確認
    if ! command zsh >/dev/null 2>&1; then
        echo "### zsh がインストールされていません。インストールを行います。"
        sudo apt-get install -y zsh || {
            echo "### zsh のインストールに失敗しました。"
            exit 1
        }
    fi
    zsh_path=$(command -v zsh)
    # デフォルトシェルを Zsh に変更
    sudo chsh -s "${zsh_path}" "${USER_NAME}" || {
        echo "### デフォルトシェルの変更に失敗しました。"
        exit 1
    }
    echo "### デフォルトシェルを ${zsh_path} に変更しました。"
}

# 必要なパッケージをインストールする関数
install_packages() {
    sudo dpkg --configure -a
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y curl wget git build-essential cmake dbus-x11 gnupg g++ gh jq sudo \
        xrdp xfce4 xfce4-goodies language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc xorgxrdp \
        zsh vim tree xsel ncdu xdotool mkcert moreutils multitail neofetch plank lsd zoxide direnv \
        libfuse2 libssl-dev pkg-config apt-transport-https ca-certificates lsb-release libnss3-tools \
        libinput-tools libdb-dev libdb5.3-dev libgdbm-dev libgmp-dev libgmpxx4ldbl libgdbm-compat-dev rustc \
        libstd-rust-1.75 libstd-rust-dev libncurses5-dev libffi-dev libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
        ffmpeg mpd mpc ncmpcpp net-tools nmap wireshark snapd ufw rsyslog im-config byobu ruby cargo || {
        echo "### apt のインストールに失敗しました。"
        exit 1
    }
    sudo apt-get remove -y light-locker xscreensaver &&
        sudo apt-get autoremove -y &&
        sudo apt-get clean &&
        sudo rm -rf /var/cache/apt /var/lib/apt/lists/*

    echo "### 必要なパッケージがインストールされました。"
}

install_docker_compose() {
    # 最新バージョンを取得
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

    # ダウンロード URL の作成
    COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"

    # Docker Compose のバイナリをダウンロード
    sudo curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "### Docker Compose をインストールしました。バージョン: ${COMPOSE_VERSION}"

    # シンボリックリンクを作成（必要に応じて）
    if ! command -v docker-compose >/dev/null 2>&1; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi

    # インストール確認
    if command -v docker-compose >/dev/null 2>&1; then
        echo "### Docker Compose のインストールが確認されました。"
        which docker-compose
    else
        echo "### Docker Compose のインストールに失敗しました。"
        exit 1
    fi
}

install_docker() {
    # Docker の公式 GPG キーを追加
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "### Docker の GPG キーを追加しました。"

    # Docker のリポジトリを設定
    echo "deb [arch=${arch} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    echo "### Docker のリポジトリを追加しました。"

    # パッケージリストを更新
    sudo apt-get update -y

    # Docker Engine をインストール
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io || {
        echo "### docker のインストールに失敗しました。"
        exit 1
    }
    echo "### Docker Engine をインストールしました。"

    # 現在のユーザーを docker グループに追加
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER_NAME"
    echo "### ユーザーを docker グループに追加しました。"

    # Docker サービスを開始および有効化
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "### Docker サービスを開始および有効化しました。"
    which docker
    # Docker Compose のインストール
    install_docker_compose
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
        echo "### firefox は既に削除されています。"
    fi
    sudo snap install chromium || {
        echo "### chromium のインストールに失敗しました。"
        exit 1
    }
    echo "### chromium をインストールしました。"
    which chroimum
}

# mise でインストールする関数
install_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        curl https://mise.run | sh || {
            sudo install -dm 755 /etc/apt/keyrings
            wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
            echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=${arch}] \
                https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
            sudo apt-get update -y
            sudo apt-get install -y mise || {
                echo "### mise のインストールに失敗しました。"
                exit 1
            }
        }
        echo "### mise をインストールしました。"
    fi
    which mise

    mise activate zsh
    # mise activate --shims

    mise use chezmoi -y || {
        echo "### mise use に失敗しました。"
        exit 1
    }
    echo "### miseの設定を完了しました。"
}

# Cargo および Rust 関連ツールをインストールする関数
install_cargo_tools() {
    if ! command -v cargo >/dev/null 2>&1; then
        mise use rust -y || sudo apt-get install -y cargo
    else
        echo "### cargo は既にインストールされています。"
    fi
    cargo install starship sheldon fd-find xh bat
    echo "### cargo ツールがインストールされました。"
    which cargo
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
    sudo wget https://github.com/coder/cursor-arm/releases/download/v0.42.2/cursor_0.42.2_linux_arm64.AppImage || {
        echo "### cursor のダウンロードに失敗しました。"
        exit 1
    }
    sudo chmod a+x cursor_0.42.2_linux_arm64.AppImage
    mkdir -p ~/Applications
    mv cursor_0.42.2_linux_arm64.AppImage ~/Applications/cursor
    # mv cursor_0.42.2_linux_${arch}.AppImage ~/Applications/cursor_0.42.2_linux_${arch}.AppImage
    echo "### Cursor をインストールしました。"
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

# Go と Aqua をインストールする関数
install_go_aqua() {
    # Go がインストールされているか確認
    if ! command -v go >/dev/null 2>&1; then
        mise use go -y || sudo apt-get install -y golang || {
            echo "### go のインストールに失敗しました。"
            exit 1
        }
        echo "### go をインストールしました。"
    else
        echo "### go は既にインストールされています。"
    fi

    which go
    # Aqua をインストールおよび初期化
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest || {
        echo "### aqua のインストールに失敗しました。"
        exit 1
    }
    echo "### aqua をインストールしました。"
    # export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
    ls -la $GOROOT/bin
}

# mkcert をインストールおよび設定する関数
install_mkcert() {
    if ! command -v mkcert >/dev/null 2>&1; then
        mise use mkcert -y || sudo apt install -y mkcert || {
            echo "### mkcert のインストールに失敗しました。"
            exit 1
        }
        echo "### mkcert をインストールしました。"
        mkcert -install
    else
        echo "### mkcert は既にインストールされています。"
        mkcert -install
    fi
    which mkcert
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

# フォントをインストールする関数
install_fonts() {
    # フォントディレクトリ
    fonts="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    # フォントディレクトリを作成
    sudo mkdir -p "${fonts}"
    # HackGen フォントのダウンロード
    sudo curl -L https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_NF_v2.9.0.zip \
        -o "${fonts}/HackGen_NF_v2.9.0.zip"

    # HackGen フォントの展開（ttfファイルのみをfontsディレクトリに配置）
    sudo unzip -j "${fonts}/HackGen_NF_v2.9.0.zip" '*.ttf' -do "${fonts}"

    # ダウンロードしたzipファイルの削除
    sudo rm -f "${fonts}/HackGen_NF_v2.9.0.zip"

    # RobotoMonoJP フォントのダウンロード
    sudo curl -L https://github.com/mjun0812/RobotoMonoJP/releases/download/v5.9.0/RobotoMonoJP-Regular.ttf \
        -o "${fonts}/RobotoMonoNF-Regular.ttf"

    # フォントキャッシュの更新
    fc-cache -fv
    echo "### フォントをインストールしました。"
    tree "${fonts}"
}

# 背景画像を設定する関数
set_background_image() {
    sudo cp "${HOME}/data/bg.jpeg" /usr/share/backgrounds/bg.jpeg || {
        echo "### 壁紙の配置に失敗しました。"
        exti 1
    }
    echo "### /usr/share/backgrounds/bg.jpeg に壁紙を配置しました。"
}

# メイン関数
main() {
    install_packages
    install_snap
    change_shell_to_zsh
    install_mise
    install_docker
    install_tabby_terminal
    install_brave_browser
    install_github_desktop
    install_cursor
    install_cloudflare_warp
    install_cargo_tools
    install_go_aqua
    install_ruby_fusuma
    install_mkcert
    install_wireshark
    install_fonts
    set_background_image
    echo "### インストールが完了しました。再起動してください。"
    neofetch
}

# スクリプトを実行
main

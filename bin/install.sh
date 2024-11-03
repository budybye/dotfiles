#!/usr/bin/env bash

# pipefail
# set -euo pipefail
set -ex
# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}

# アーキテクチャを取得
arch="amd64"
# arch=$(uname -m)
# arch=${arch//x86_64/amd64}

# Dotfiles を初期化する関数
initialize_dotfiles() {
    if [ -n "${GIT_AUTHOR_NAME:-}" ]; then
        chezmoi init --apply "${GIT_AUTHOR_NAME}" || {
            echo "### dotfiles のクローンに失敗しました。"
            exit 1
        }
        echo "### dotfiles をクローンしました。"
    fi
}

# Zsh をデフォルトシェルに変更する関数
change_shell_to_zsh() {
    # Zsh がインストールされているか確認
    zsh_path=$(command -v zsh)
    if [ -z "$zsh_path" ]; then
        echo "### zsh がインストールされていません。インストールを行います。"
        sudo apt install -y zsh
        zsh_path=$(command -v zsh)
    fi

    # デフォルトシェルを Zsh に変更
    sudo chsh -s "$zsh_path" "$USER_NAME" || {
        echo "### デフォルトシェルの変更に失敗しました。"
        exit 1
    }
    echo "### デフォルトシェルを $zsh_path に変更しました。"
}

# 必要なパッケージをインストールする関数
install_packages() {
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y --no-install-recommends curl wget git build-essential cmake dbus-x11 \
        libfuse2 libssl-dev pkg-config apt-transport-https ca-certificates gnupg lsb-release \
        xrdp xfce4 xfce4-goodies language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc \
        g++ zsh vim gh jq tree xsel ncdu xdotool mkcert moreutils multitail neofetch plank lsd zoxide \
        ffmpeg mpd mpc ncmpcpp net-tools nmap wireshark snapd sudo ufw rsyslog im-config byobu ruby cargo
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
    if ! command -v docker-compose &>/dev/null; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi

    # インストール確認
    if command -v docker-compose &>/dev/null; then
        echo "### Docker Compose のインストールが確認されました。"
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
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    echo "### Docker のリポジトリを追加しました。"

    # パッケージリストを更新
    sudo apt update -y

    # Docker Engine をインストール
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    echo "### Docker Engine をインストールしました。"

    # 現在のユーザーを docker グループに追加
    sudo usermod -aG docker "$USER_NAME"
    echo "### ユーザーを docker グループに追加しました。"

    # Docker サービスを開始および有効化
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "### Docker サービスを開始および有効化しました。"

    # Docker Compose のインストール
    install_docker_compose
}
# Snap をインストールおよび管理する関数
install_snap() {
    if ! command -v snap &>/dev/null; then
        sudo apt install -y snapd
        echo "### snapd をインストールしました。"
    else
        echo "### snapd は既にインストールされています。"
    fi

    # Codium のインストール確認
    if ! command -v codium &>/dev/null; then
        sudo snap install codium --classic
        echo "### codium をインストールしました。"
    else
        echo "### codium は既にインストールされています。"
    fi

    # Speedtest のインストール確認
    if ! command -v speedtest &>/dev/null; then
        sudo snap install speedtest
        echo "### speedtest をインストールしました。"
    else
        echo "### speedtest は既にインストールされています。"
    fi

    # Firefox の削除確認
    if command -v firefox &>/dev/null; then
        sudo snap remove firefox
        echo "### firefox を削除しました。"
    else
        echo "### firefox は既に削除されています。"
    fi
}

# Brave ブラウザをインストールする関数
install_brave_browser() {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] " |
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update -y
    sudo apt install -y brave-browser
    echo "### brave-browser をインストールしました。"
}

# Tabby Terminal をインストールする関数
install_tabby_terminal() {
    curl https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
    sudo apt update -y
    sudo apt install -y tabby-terminal
    echo "### tabby-terminal をインストールしました。"
}

# Cloudflare Warp をインストールおよび設定する関数
install_cloudflare_warp() {
    if ! command -v warp-cli >/dev/null 2>&1; then
        sudo curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor \
            --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [arch=${arch} signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] " |
            sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        sudo apt update -y
        sudo apt install -y cloudflare-warp
        echo "### cloudflare-warp をインストールしました。"
    else
        echo "### cloudflare-warp はインストールされています。"
    fi
        warp-cli registration new
        warp-cli mode warp+doh
        warp-cli dns families malware
        warp-cli connect
        echo "### cloudflare-warp を設定しました。"
}

# Cargo および Rust 関連ツールをインストールする関数
install_cargo_tools() {
    if ! command -v cargo >/dev/null 2>&1; then
        sudo install -dm 755 /etc/apt/keyrings
        wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee \
            /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
        echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=${arch}] " |
            sudo tee /etc/apt/sources.list.d/mise.list
        sudo apt update -y
        sudo apt install -y mise
        echo "### mise をインストールしました。"

        mise use rust -y || sudo apt install -y cargo
    else
        echo "### cargo は既にインストールされています。"
        if ! command -v mise >/dev/null 2>&1; then
            cargo install mise || curl https://mise.run | sh
            echo "### mise をインストールしました。"
        fi
    fi
    cargo install starship sheldon fd-find xh bat
    echo "### cargo ツールがインストールされました。"
}

# mise でインストールする関数
install_mise() {
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >>"${HOME}/.zshrc"
    echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >>"${HOME}/.zshenv"

    mise use go chezmoi -y
    mise activate zsh
    # mise activate --shims
    echo "### miseの設定を完了しました。"
}

# フォントをインストールする関数
install_fonts() {
    sudo mkdir -p ${XDG_DATA_HOME}/fonts

    sudo curl -L https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_NF_v2.9.0.zip \
        -o ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip
    sudo unzip ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip -d ${XDG_DATA_HOME}/fonts/
    sudo rm -f ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip

    sudo curl -L https://github.com/mjun0812/RobotoMonoJP/releases/download/v5.9.0/RobotoMonoJP-Regular.ttf \
        -o ${XDG_DATA_HOME}/fonts/RobotoMonoNerd.ttf

    fc-cache -f -v
    echo "### フォントをインストールしました。"
}

# Wireshark をインストールおよび設定する関数
install_wireshark() {
    if ! command -v wireshark &>/dev/null; then
        sudo apt install -y wireshark
        echo "### wireshark をインストールしました。"
    else
        echo "### wireshark は既にインストールされています。"
    fi
    sudo usermod -a -G wireshark "$USER_NAME"
}

# GitHub Desktop と Cursor をインストールする関数
install_github_desktop() {
    sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.4.3-linux1/GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    sudo dpkg -i GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
    sudo rm -f GitHubDesktop-linux-${arch}-3.4.3-linux1.deb
}

# Cursor をインストールする関数
install_cursor() {
    sudo wget https://github.com/coder/cursor-${arch}/releases/download/v0.42.2/cursor_0.42.2_linux_${arch}.AppImage
    sudo chmod a+x cursor_0.42.2_linux_${arch}.AppImage
    mkdir -p ~/Applications
    mv cursor_0.42.2_linux_${arch}.AppImage ~/Applications/cursor_0.42.2_linux_${arch}.AppImage
}

# 背景画像を設定する関数
set_background_image() {
    sudo cp ${HOME}/data/bg.jpeg /usr/share/backgrounds/bg.jpeg
}

# Ruby と Fusuma をインストールおよび設定する関数
install_ruby_fusuma() {
    if ! command -v gem &>/dev/null; then
        mise use ruby -y || sudo apt install -y ruby
        echo "### ruby をインストールしました。"
    else
        echo "### ruby は既にインストールされています。"
    fi
    sudo gem install fusuma || {
        echo "### fusuma のインストールに失敗しました。"
        exit 1
    }
    sudo gpasswd -a "$USER_NAME" input
    fusuma -d
    echo "### fusuma の設定を完了しました。"
}

# Go と Aqua をインストールする関数
install_go_aqua() {
    # Go がインストールされているか確認
    if ! command -v go &>/dev/null; then
        mise use go -y || sudo apt install -y golang
        echo "### go をインストールしました。"
    else
        echo "### go は既にインストールされています。"
    fi

    # Aqua をインストールおよび初期化
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest || {
        echo "### aqua のインストールに失敗しました。"
        exit 1
    }
    aqua init || {
        echo "### aqua の初期化に失敗しました。"
        exit 1
    }
    echo "### aqua をインストールしました。"
}

# mkcert をインストールおよび設定する関数
install_mkcert() {
    if ! command -v mkcert &>/dev/null; then
        mise use mkcert -y || sudo apt install -y mkcert
        echo "### mkcert をインストールしました。"
        mkcert -install
    else
        echo "### mkcert は既にインストールされています。"
        mkcert -install
    fi
}

# メイン関数
main() {
    initialize_dotfiles
    install_packages
    change_shell_to_zsh
    install_snap
    install_docker
    install_cargo_tools
    install_mise
    install_brave_browser
    install_tabby_terminal
    install_cloudflare_warp
    install_wireshark
    install_github_desktop
    install_cursor
    install_mkcert
    install_go_aqua
    install_ruby_fusuma
    install_fonts
    set_background_image

    echo "### インストールが完了しました。再起動してください。"
}

# スクリプトを実行
main

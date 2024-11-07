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
        zsh vim tree xsel ncdu xdotool mkcert moreutils multitail neofetch lsd zoxide direnv \
        libfuse2 libssl-dev pkg-config apt-transport-https ca-certificates lsb-release libnss3-tools \
        libinput-tools libdb-dev libdb5.3-dev libgdbm-dev libgmp-dev libgmpxx4ldbl libgdbm-compat-dev rustc \
        libstd-rust-1.75 libstd-rust-dev libncurses5-dev libffi-dev libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
        ffmpeg mpd mpc ncmpcpp net-tools nmap snapd ufw rsyslog im-config byobu ruby cargo golang || {
        echo "### apt のインストールに失敗しました。"
        exit 1
    }
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
    sudo curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose || {
        echo "### Docker Compose のダウンロードに失敗しました。"
        exit 1
    }
    sudo chmod +x /usr/local/bin/docker-compose
    echo "### Docker Compose をインストールしました。バージョン: ${COMPOSE_VERSION}"

    # シンボリックリンクを作成（必要に応じて）
    if ! command -v docker-compose >/dev/null 2>&1; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || {
            echo "### Docker Compose のシンボリックリンクの作成に失敗しました。"
            exit 1
        }
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
    sudo chmod 666 /var/run/docker.sock
    # 現在のユーザーを docker グループに追加
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER_NAME"
    echo "### ユーザーを docker グループに追加しました。"

    # Docker サービスを開始および有効化
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "### Docker サービスを開始および有効化しました。"
    docker info
    which docker
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

    mise use chezmoi bun starship -y || {
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
    cargo install sheldon fd-find xh bat
    # cargo install starship sheldon fd-find xh bat
    echo "### cargo ツールがインストールされました。"
    which cargo
}

# Bitwarden をインストールする関数
install_bitwarden() {
    if ! command -v bitwarden >/dev/null 2>&1; then
        if [ "${arch}" = "amd64" ]; then
            sudo snap install bitwarden
        else
            bun install -g @bitwarden-cli/cli
            . ${HOME}/.zshenv
            echo "### bitwarden をインストールしました。"
        fi
    fi
    which bw
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
    # which aqua
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

# Gitの設定
git_setup() {
    echo "### gitの設定を開始します..."
    # Gitのグローバル設定（コメントアウトされているので必要に応じて有効化）
    # git config --global user.name "${GIT_AUTHOR_NAME}"
    # git config --global user.email "${GIT_AUTHOR_EMAIL}"
    # GitHub CLIの認証（コメントアウトされているので必要に応じて有効化）
    # gh auth login
    git status
}

# メイン関数
main() {
    echo "### cliのインストールを開始します..."
    install_packages
    change_shell_to_zsh
    install_mise
    install_bitwarden
    install_docker
    install_docker_compose
    install_cargo_tools
    install_go_aqua
    install_mkcert
    git_setup
    echo "### インストールが完了しました。再起動してください。"
    neofetch
}

# スクリプトを実行
main

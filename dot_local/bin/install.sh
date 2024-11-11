#!/usr/bin/env bash
set -x

# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}
# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

# Zsh をデフォルトシェルに変更する関数
change_shell_to_zsh() {
    echo "### zsh のインストールを開始します..."
    command -v zsh >/dev/null || sudo apt-get install -y zsh || {
        echo "### zsh のインストールに失敗しました。"
        exit 1
    }
    # デフォルトシェルを変更
    zsh_path=$(command -v zsh)
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
        ffmpeg mpd mpc ncmpcpp net-tools nmap snapd ufw rsyslog im-config byobu ruby cargo|| {
        echo "### apt のインストールに失敗しました。"
        exit 1
    }
    echo "### 必要なパッケージがインストールされました。"
    sudo apt-get autoremove -y && sudo apt-get clean && sudo rm -rf /var/cache/apt /var/lib/apt/lists/*
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
    echo "### Docker Compose のインストールが確認されました。"
    which docker-compose
}

install_docker() {
    echo "### Docker のインストールを開始します..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=${arch} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io || {
        echo "### docker のインストールに失敗しました。"
        exit 1
    }
    echo "### Docker Engine をインストールしました。"
    sudo chmod 666 /var/run/docker.sock
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER_NAME"
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "### Docker サービスを開始および有効化しました。"
    docker info
    which docker
}

# mise でインストールする関数
install_mise() {
    command -v mise >/dev/null || {
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
    }
    mise activate zsh
    # mise activate --shims
    mise set
    echo "### mise をインストールしました。"
    which mise

    mise use chezmoi bun starship node go -y --verbose || {
        echo "### mise use に失敗しました。"
        exit 1
    }
    echo "### miseの設定を完了しました。"
    echo "chezmoi bun starship node go" | xargs which
}

# Cargo および Rust 関連ツールをインストールする関数
install_cargo_tools() {
    echo "### cargo のインストールを開始します..."
    command -v cargo >/dev/null || mise use rust -y || sudo apt-get install -y cargo || {
        echo "### cargo のインストールに失敗しました。"
        exit 1
    }
    echo "### cargo をインストールしました。"
    which cargo

    echo "### cargo ツールのインストールを開始します..."
    cargo install sheldon fd-find xh bat || {
        echo "### cargo ツールのインストールに失敗しました。"
        exit 1
    }
    echo "### cargo ツールがインストールされました。"
    echo "sheldon fd-find xh bat" | xargs which
}

# Bitwarden をインストールする関数
install_bitwarden() {
    echo "### bitwarden のインストールを開始します..."
    command -v bitwarden >/dev/null || {
        if [ "${arch}" = "amd64" ]; then
            sudo snap install bitwarden
        else
            bun install -g @bitwarden-cli/cli
            . ${HOME}/.zshenv
        fi
    } || {
        echo "### bitwarden のインストールに失敗しました。"
        exit 1
    }
    echo "### bitwarden をインストールしました。"
    which bw
}

# Go と Aqua をインストールする関数
install_go_aqua() {
    echo "### go のインストールを開始します..."
    command -v go >/dev/null || mise use go -y || sudo apt-get install -y golang || {
        echo "### go のインストールに失敗しました。"
        exit 1
    }
    echo "### go をインストールしました。"
    which go

    echo "### aqua のインストールを開始します..."
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest || {
        echo "### aqua のインストールに失敗しました。"
        exit 1
    }
    echo "### aqua をインストールしました。"
    # which aqua
}

# mkcert をインストールおよび設定する関数
install_mkcert() {
    echo "### mkcert のインストールを開始します..."
    command -v mkcert >/dev/null || mise use mkcert -y || sudo apt install -y mkcert || {
        echo "### mkcert のインストールに失敗しました。"
        exit 1
    }
    mkcert -install
    echo "### mkcert のインストールが完了しました。"
    which mkcert
}

install_multipass() {
    echo "### multipass のインストールを開始します..."
    command -v multipass >/dev/null || sudo snap install multipass || {
        echo "### multipass のインストールに失敗しました。"
        exit 1
    }
    echo "### multipass のインストールが完了しました。"
    which multipass
}

# Gitの設定
git_setup() {
    echo "### gitの設定を開始します..."
    # Gitのグローバル設定（コメントアウトされているので必要に応じて有効化）
    # git config --global user.name "${GIT_AUTHOR_NAME}"
    # git config --global user.email "${GIT_AUTHOR_EMAIL}"
    # GitHub CLIの認証（コメントアウトされているので必要に応じて有効化）
    # gh auth login
    git config --global commit.template ${HOME}/.config/git/commit.template
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
    install_multipass
    git_setup
    echo "### インストールが完了しました。再起動してください。"
    neofetch
}

# スクリプトを実行
main

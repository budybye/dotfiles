#!/usr/bin/env bash
set -x

# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}
# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

# Zsh をデフォルトシェルに変更する関数
change_shell_to_zsh() {
    echo "zsh install start..."
    command -v zsh >/dev/null || sudo apt-get install -y zsh || {
        echo "zsh install failed."
        exit 1
    }
    # デフォルトシェルを変更
    zsh_path=$(command -v zsh)
    sudo chsh -s "${zsh_path}" "${USER_NAME}" || {
        echo "zsh default shell change failed."
        exit 1
    }
    echo "zsh default shell changed to ${zsh_path}."
}

# 必要なパッケージをインストールする関数
install_packages() {
    sudo dpkg --configure -a
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y curl wget git build-essential cmake dbus-x11 gnupg g++ gh jq sudo age \
        zsh vim tree xsel ncdu xdotool mkcert moreutils multitail neofetch lsd zoxide direnv \
        libssl-dev pkg-config apt-transport-https ca-certificates lsb-release libnss3-tools \
        libinput-tools libdb-dev libdb5.3-dev libgdbm-dev libgmp-dev libgmpxx4ldbl libgdbm-compat-dev rustc \
        libstd-rust-1.75 libstd-rust-dev libncurses5-dev libffi-dev libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
        ffmpeg mpd mpc ncmpcpp net-tools nmap snapd ufw rsyslog im-config byobu ruby cargo || {
        echo "apt install failed."
        exit 1
    }
    echo "apt install completed."
    sudo apt-get autoremove -y && sudo apt-get clean && sudo rm -rf /var/cache/apt /var/lib/apt/lists/*
}

install_docker_compose() {
    # 最新バージョンを取得
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    # ダウンロード URL の作成
    COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
    # Docker Compose のバイナリをダウンロード
    sudo curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose || {
        echo "docker-compose download failed."
        exit 1
    }
    sudo chmod +x /usr/local/bin/docker-compose
    echo "docker-compose install completed."
    # シンボリックリンクを作成（必要に応じて）
    if ! command -v docker-compose >/dev/null 2>&1; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || {
            echo "docker-compose link failed."
            exit 1
        }
    fi
    echo "docker-compose installed."
    which docker-compose
}

install_docker() {
    echo "docker install start..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=${arch} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io || {
        echo "docker install failed."
        exit 1
    }
    echo "docker install completed."
    sudo chmod 666 /var/run/docker.sock
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER_NAME"
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "docker service started and enabled."
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
                echo "mise install failed."
                exit 1
            }
        }
    }
    # .env ファイルを作成 (~/dotfiles を mise で設定してる関係)
    echo "exportGIT_AUTHOR_NAME=budybye" >>./.env
    mise activate zsh
    mise set
    echo "mise installed."
    which mise

    mise use -g chezmoi bun starship node go -y --verbose || {
        echo "mise use failed."
        exit 1
    }
    echo "mise setup completed."
    mise activate --shims
    echo "chezmoi bun starship node go" | xargs which
}

# Cargo および Rust 関連ツールをインストールする関数
install_cargo_tools() {
    echo "cargo install start..."
    command -v cargo >/dev/null || mise use rust -y || sudo apt-get install -y cargo || {
        echo "cargo install failed."
        exit 1
    }
    echo "cargo installed."
    which cargo

    echo "cargo tools install start..."
    cargo install sheldon fd-find xh bat || {
        echo "cargo tools install failed."
        exit 1
    }
    echo "cargo tools installed."
    echo "sheldon fd-find xh bat" | xargs which
}

# Bitwarden をインストールする関数
install_bitwarden() {
    echo "bitwarden install start..."
    command -v bitwarden >/dev/null || {
        if [ "${arch}" = "amd64" ]; then
            sudo snap install bitwarden
        else
            bun install -g @bitwarden-cli/cli
            . ${HOME}/.zshenv
        fi
    } || {
        echo "bitwarden install failed."
        exit 1
    }
    echo "bitwarden installed."
    which bw
}

# Go と Aqua をインストールする関数
install_go_aqua() {
    echo "go install start..."
    command -v go >/dev/null || mise use go -y || sudo apt-get install -y golang || {
        echo "go install failed."
        exit 1
    }
    echo "go installed."
    which go

    echo "aqua install start..."
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest || {
        echo "aqua install failed."
        exit 1
    }
    echo "aqua installed."
    # which aqua
}

# mkcert をインストールおよび設定する関数
install_mkcert() {
    echo "mkcert install start..."
    command -v mkcert >/dev/null || mise use mkcert -y || sudo apt install -y mkcert || {
        echo "mkcert install failed."
        exit 1
    }
    mkcert -install
    echo "mkcert installed."
    which mkcert
}

install_multipass() {
    echo "multipass install start..."
    command -v multipass >/dev/null || sudo snap install multipass || {
        echo "multipass install failed."
        exit 1
    }
    echo "multipass installed."
    which multipass
}

install_act() {
    echo "act install start..."
    command -v act >/dev/null || curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash || {
        echo "act install failed."
        exit 1
    }
    echo "act installed."
    which act
}

# Gitの設定
git_setup() {
    echo "git setup start..."
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
    echo "cli install start..."
    install_packages
    change_shell_to_zsh
    install_mise
    install_bitwarden
    install_docker
    install_docker_compose
    install_cargo_tools
    install_go_aqua
    install_mkcert
    install_act
    install_multipass
    git_setup
    echo "install completed. please reboot."
    neofetch
}

# スクリプトを実行
main

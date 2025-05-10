#!/usr/bin/env bash

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "docker already installed."
    else
        $sudo apt-get update
        $sudo apt-get install -y ca-certificates curl
        $sudo install -m 0755 -d /etc/apt/keyrings
        $sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        $sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        $sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        $sudo apt-get update

        $sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin || \
        echo "docker install failed."

        $sudo groupadd -f docker
        $sudo usermod -aG docker "$(whoami)"
        $sudo systemctl enable docker

        if [ -f /var/run/docker.sock ]; then
            $sudo chmod 666 /var/run/docker.sock
        fi

        # Dockerデーモンの起動（systemdを使用しない方法）
        if [ -f /var/run/docker.pid ]; then
            echo "Docker daemon is already running."
        else
            $sudo dockerd > /dev/null 2>&1 &
            sleep 5  # デーモンの起動を待機
        fi
    fi

    # docker-composeコマンドのシンボリックリンクを作成
    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose already exists."
    else
        $sudo ln -sf "$(which docker)" /usr/local/bin/docker-compose
    fi

    docker --version || echo "docker not found"
    docker compose version || echo "docker compose not found"
}

install_act() {
    if command -v act >/dev/null; then
        echo "act already installed."
    elif command -v curl >/dev/null; then
        curl https://raw.githubusercontent.com/nektos/act/master/install.sh | $sudo bash || echo "act install failed."
        ACT="${HOME}/bin/act"
        $sudo chmod +x ${ACT}
        $sudo mv -f ${ACT} ${HOME}/bin/act
        export PATH="${ACT}:${PATH}"
    elif command -v mise >/dev/null; then
        mise use -g -y act@latest || echo "act install failed."
    else
        echo "act install failed."
    fi
    act --version || echo "act not found"
}

echo "docker.sh"
echo "--------------------------------"
install_docker
install_act
echo "--------------------------------"
echo "Docker setup done!!"
echo "--------------------------------"

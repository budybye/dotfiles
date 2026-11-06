#!/usr/bin/env bash
set -eu

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
    # Docker の apt リポジトリは ubuntu / debian で URL が違う。派生ディストリビューションは ID_LIKE に従う
    docker_distro="$(. /etc/os-release && echo "${ID}")"
    case "${docker_distro}" in
      ubuntu|debian) ;;
      *) docker_distro="$(. /etc/os-release && echo "${ID_LIKE%% *}")" ;;
    esac
    $sudo install -m 0755 -d /etc/apt/keyrings
    $sudo curl -fsSL "https://download.docker.com/linux/${docker_distro}/gpg" -o /etc/apt/keyrings/docker.asc
    $sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${docker_distro} \
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

    # if [ -f /var/run/docker.sock ]; then
    #     $sudo chmod 666 /var/run/docker.sock
    # fi

    # systemctl enable に加え、systemd 非稼働環境(コンテナ等)用に dockerd を直接起動する
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

echo "docker.sh"
echo "--------------------------------"
install_docker
echo "--------------------------------"
echo "Docker setup done!!"
echo "--------------------------------"

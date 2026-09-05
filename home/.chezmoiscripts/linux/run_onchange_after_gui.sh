#!/usr/bin/env bash

set -eu

# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

install_gui() {
    $sudo apt-get update
    # $sudo apt-get install -y xfce4 xrdp xorgxrdp dbus-x11 lightdm gnome-keyring libinput-tools xdg-utils plank picard remmina xsel xclip oneko nyancat libfuse2t64
    $sudo apt-get install -y xfce4 xfce4-goodies xrdp xorgxrdp dbus-x11 lightdm gnome-keyring libinput-tools xdg-utils plank picard remmina xsel xclip oneko nyancat libfuse2t64
}

install_brave_browser() {
    if command -v brave-browser >/dev/null 2>&1; then
        echo "brave browser already installed."
    else
        $sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | $sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        $sudo apt-get update
        $sudo apt-get install -y brave-browser
        echo "brave browser installed."
    fi
}

install_cloudflare_warp() {
    if command -v warp-cli >/dev/null 2>&1; then
        echo "cloudflare warp already installed."
    else
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | $sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | $sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        $sudo apt-get update 
        $sudo apt-get install -y cloudflare-warp
        echo "cloudflare warp installed."
    fi

    warp-cli --accept-tos registration new
    warp-cli --accept-tos mode warp
    warp-cli --accept-tos dns families malware
    warp-cli --accept-tos connect
    warp-cli --accept-tos disconnect
}

# 代変えインストーラー https://github.com/watzon/cursor-linux-installer
install_cursor() {
    APP_DIR="${HOME}/Applications"
    mkdir -p "$APP_DIR"
    
    if command -v cursor >/dev/null 2>&1; then
        echo "cursor already installed."
    # elif command -v curl >/dev/null 2>&1; then
        # curl -L https://raw.githubusercontent.com/watzon/cursor-linux-installer/main/install.sh | bash -s -- latest || echo "cursor install failed."
      else
        # Cursor の GPG キーを追加
        curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | gpg --dearmor | $sudo tee /etc/apt/keyrings/cursor.gpg > /dev/null
        
        # Cursor リポジトリを追加
        echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/cursor.gpg] https://downloads.cursor.com/aptrepo stable main" | $sudo tee /etc/apt/sources.list.d/cursor.list > /dev/null
        
        # 更新してインストール
        sudo apt-get update
        sudo apt-get install cursor -y 
    fi

    # arm64 だと失敗する
    # cursor の実行方法を表示
    # if [ arch === "arm64" ]; then
    #     APP_IMAGE="${APP_DIR}/cursor"
    #     echo "'use command: ${APP_IMAGE} --no-sandbox'"
    # fi
    echo "cursor installed."
}

install_element_desktop() {
    if command -v element-desktop >/dev/null 2>&1; then
        echo "element desktop already installed."
    else
        $sudo apt-get install -y wget apt-transport-https
        $sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | $sudo tee /etc/apt/sources.list.d/element-io.list
        $sudo apt-get update
        $sudo apt-get install -y element-desktop
        echo "element desktop installed."
    fi
}

install_ferdium() {
    if command -v pacstall >/dev/null 2>&1; then
        # $sudo bash -c "$(wget -q https://pacstall.dev/q/install -O -)"
        $sudo apt install pacstall
    fi
    
    pacstall -I ferdium-deb || echo "ferdium install failed."  
    echo "ferdium installed."
}

install_github_desktop() {
    if command -v github-desktop >/dev/null 2>&1; then
        echo "github desktop already installed."
    else
        local version="3.4.13"
        local release="release-${version}-linux1"
        local url="https://github.com/shiftkey/desktop/releases/download/${release}/GitHubDesktop-linux-${arch}-${version}-linux1.deb"
        local tmpdir
        local deb

        tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/github-desktop.XXXXXX")"
        deb="${tmpdir}/GitHubDesktop.deb"
        cleanup_github_desktop() {
            rm -rf -- "${tmpdir}"
        }
        trap cleanup_github_desktop EXIT

        curl -fsSL "${url}" -o "${deb}"
        if ! $sudo dpkg -i "${deb}"; then
            $sudo apt-get install -f -y
            $sudo dpkg -i "${deb}"
        fi

        trap - EXIT
        cleanup_github_desktop
        echo "github desktop ${version} installed."
    fi
}

install_ruby_fusuma() {
    # ruby のインストール
    if command -v gem >/dev/null 2>&1; then
        echo "ruby already installed."
    elif command -v mise >/dev/null 2>&1; then
        mise use -g -y ruby
        echo "ruby installed."
    else
        $sudo apt-get install -y ruby
        echo "ruby installed."
    fi

    # fusuma のインストール
    if command -v fusuma >/dev/null 2>&1; then
        echo "fusuma already installed."
    elif command -v gem >/dev/null 2>&1; then
        $sudo gem install fusuma
        $sudo groupadd -f input
        $sudo usermod -aG input "$(whoami)"
        fusuma -d || true
        echo "fusuma installed."
    else
        echo "gem command not found."
        echo "fusuma install failed."
    fi
}

install_tabby_terminal() {
    if command -v tabby >/dev/null 2>&1; then
        echo "tabby terminal already installed."
    else
        curl https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | $sudo bash
        $sudo apt-get update
        $sudo apt-get install -y tabby-terminal
        echo "tabby terminal installed."
    fi
}

install_vscode() {
    if command -v code >/dev/null 2>&1; then
        echo "vscode already installed."
    else
        $sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | $sudo gpg --dearmor > packages.microsoft.gpg
        $sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | $sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        $sudo rm -f packages.microsoft.gpg
        $sudo apt-get update
        $sudo apt-get install -y code
        echo "vscode installed."
    fi
}

install_wireshark() {
    if command -v wireshark >/dev/null 2>&1; then
        echo "wireshark already installed."
    else
        $sudo apt install -y wireshark
        $sudo groupadd -f wireshark
        $sudo usermod -aG wireshark "$(whoami)"
        $sudo chmod +x /usr/bin/dumpcap
        echo "wireshark installed."
    fi
}

install_zen() {
    if command -v zen >/dev/null 2>&1; then
        echo "zen already installed."
        return
    else
        curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh 
        echo "zen latest installed."
    fi
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        echo "ghostty already installed."
    else
    # PPA は amd64 / arm64 両対応 (https://github.com/mkasberg/ghostty-ubuntu)
    # $sudo apt-get install -y software-properties-common || echo "software-properties-common install failed."
    # $sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
    # $sudo apt-get update -y
    # 26.04 以上なら apt install ghostty で入る
    $sudo apt-get install -y ghostty
    echo "ghostty installed."
    fi
}

install_zed() {
    if command -v zed >/dev/null 2>&1; then
        echo "zed already installed."
    else
        curl -f https://zed.dev/install.sh | sh || true # scriptエラー
        echo "zed installed."
    fi
}

install_vicinae() {
    if command -v vicinae >/dev/null 2>&1; then
        echo "vicinae already installed."
    else
        curl -fsSL https://vicinae.com/install | bash || echo "vicinae install failed."
        echo "vicinae installed."
    fi
}


install_obsidian() {
    # amd64: deb / arm64: AppImage
    # v1.13.8 is mobile-only; keep this on a desktop release.
    local version="1.13.7"
    local base_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}"

    if [ "${arch}" = "amd64" ]; then
        if command -v obsidian >/dev/null 2>&1; then
            echo "obsidian already installed."
            return
        fi
        local deb="/tmp/obsidian_amd64.deb"
        if ! curl -fsSL "${base_url}/obsidian_${version}_amd64.deb" -o "${deb}"; then
            echo "obsidian download failed." >&2
            rm -f "${deb}"
            return 1
        fi
        if ! $sudo dpkg -i "${deb}"; then
            echo "obsidian install failed." >&2
            rm -f "${deb}"
            return 1
        fi
        rm -f "${deb}"
        echo "obsidian installed."

    elif [ "${arch}" = "arm64" ]; then
        local app_dir="${HOME}/Applications"
        local app_image="${app_dir}/obsidian"
        local temp_app_image="${app_image}.download"
        mkdir -p "${app_dir}"
        if [ -f "${app_image}" ]; then
            echo "obsidian already installed."
            return
        fi
        if ! $sudo apt-get update; then
            echo "obsidian dependency index update failed." >&2
            return 1
        fi
        local fuse_package="libfuse2"
        if apt-cache show libfuse2t64 >/dev/null 2>&1; then
            fuse_package="libfuse2t64"
        fi
        if ! $sudo apt-get install -y "${fuse_package}"; then
            echo "obsidian FUSE dependency install failed." >&2
            return 1
        fi
        if ! curl -fsSL "${base_url}/Obsidian-${version}-arm64.AppImage" -o "${temp_app_image}"; then
            echo "obsidian download failed." >&2
            rm -f "${temp_app_image}"
            return 1
        fi
        chmod +x "${temp_app_image}"
        mv "${temp_app_image}" "${app_image}"
        echo "obsidian installed. run: ${app_image} --no-sandbox"
    else
        echo "obsidian: unsupported architecture: ${arch}"
    fi
}

install_opencode() {
    if command -v opencode >/dev/null 2>&1; then
        echo "opencode already installed."
        return
    fi
    
    # linux-x64-deb のみ提供 (2026-03-29 確認)
    # devcontainer では libwebkit2gtk 依存が解決できず apt を壊すためスキップ
    if [ "${arch}" = "amd64" ] && [ -n "${REMOTE_CONTAINERS:-}" ]; then
        echo "opencode: skipped in devcontainer."
        return
    fi
    
    local url="https://opencode.ai/download/stable/linux-x64-deb"
    local deb="/tmp/opencode-${arch}.deb"
    if ! curl -fsSL "${url}" -o "${deb}"; then
        echo "opencode download failed." >&2
        return 1
    fi
    if ! $sudo dpkg -i "${deb}"; then
        $sudo apt-get install -f -y
        $sudo dpkg -i "${deb}"
    fi
    rm -f "${deb}"
    echo "opencode installed."
}

echo "gui.sh"
echo "--------------------------------"
echo "gui tools setup"
echo "--------------------------------"
install_gui
install_brave_browser
install_cursor
# install_cloudflare_warp # systemd 必須？
install_ghostty
install_ferdium
install_github_desktop
install_obsidian
install_ruby_fusuma
install_vicinae
install_zed
install_zen
# install_element_desktop
# install_opencode
# install_tabby_terminal
# install_vscode
# install_wireshark

echo "--------------------------------"
echo "desktop setup complete"
echo "--------------------------------"

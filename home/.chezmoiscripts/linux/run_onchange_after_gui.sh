#!/usr/bin/env bash
# set -eu

# アーキテクチャを取得
arch="$(dpkg --print-architecture)"

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

install_brave_browser() {
    if command -v brave-browser >/dev/null 2>&1; then
        echo "brave browser already installed."
    else
        $sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | $sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        $sudo apt-get update -y
        $sudo apt-get install -y brave-browser || echo "brave browser install failed."
        echo "brave browser installed."
    fi
}

install_cloudflare_warp() {
    if command -v warp-cli >/dev/null 2>&1; then
        echo "cloudflare warp already installed."
    else
        $sudo curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | $sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | $sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        $sudo apt-get update -y
        $sudo apt-get install -y cloudflare-warp || echo "cloudflare warp install failed."
        echo "cloudflare warp installed."
    fi

    warp-cli --accept-tos registration new || echo "warp-cli registration failed."
    warp-cli --accept-tos mode warp || echo "warp-cli mode set failed."
    warp-cli --accept-tos dns families malware || echo "warp-cli dns set failed."
    warp-cli --accept-tos connect || echo "warp-cli connect failed."
    warp-cli --accept-tos disconnect || echo "warp-cli disconnect failed."
}

## 代変えインストーラー https://github.com/watzon/cursor-linux-installer
install_cursor() {
    APP_DIR="${HOME}/Applications"
    APP_IMAGE="${APP_DIR}/cursor"
    mkdir -p "$APP_DIR"
    
    if command -v cursor >/dev/null 2>&1; then
        echo "cursor already installed."
    elif command -v curl >/dev/null 2>&1; then
        curl -L https://raw.githubusercontent.com/watzon/cursor-linux-installer/main/install.sh | sh -s -- latest
    fi
    
    # cursor の実行方法を表示
    echo "'use command: ${APP_IMAGE} --no-sandbox'"
    echo "cursor installed."
}

install_element_desktop() {
    if command -v element-desktop >/dev/null 2>&1; then
        echo "element desktop already installed."
    else
        $sudo apt-get install -y wget apt-transport-https
        $sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | $sudo tee /etc/apt/sources.list.d/element-io.list
        $sudo apt-get update -y
        $sudo apt-get install -y element-desktop || echo "element desktop install failed."
        echo "element desktop installed."
    fi
}

install_github_desktop() {
    if command -v github-desktop >/dev/null 2>&1; then
        echo "github desktop already installed."
    else
        local version="3.4.13"
        local release="release-${version}-linux1"
        local deb="/tmp/GitHubDesktop-linux-${arch}-${version}-linux1.deb"
        local url="https://github.com/shiftkey/desktop/releases/download/${release}/GitHubDesktop-linux-${arch}-${version}-linux1.deb"

        $sudo curl -fsSL "${url}" -o "${deb}"
        $sudo dpkg -i "${deb}" || {
            $sudo apt-get install -f -y
            $sudo dpkg -i "${deb}"
        }
        $sudo rm -f "${deb}"
        echo "github desktop ${version} installed."
    fi
}

install_ruby_fusuma() {
    # ruby のインストール
    if command -v gem >/dev/null 2>&1; then
        echo "ruby already installed."
    elif command -v mise >/dev/null 2>&1; then
        activate_mise
        mise use -g -y ruby || echo "ruby install failed."
        echo "ruby installed."
    else
        $sudo apt-get install -y ruby || echo "ruby install failed."
        echo "ruby installed."
    fi

    # fusuma のインストール
    if command -v fusuma >/dev/null 2>&1; then
        echo "fusuma already installed."
    elif command -v gem >/dev/null 2>&1; then
        $sudo gem install fusuma || echo "fusuma install failed."
        $sudo groupadd -f input
        $sudo usermod -aG input "$(whoami)"
        fusuma -d
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
        $sudo apt-get update -y
        $sudo apt-get install -y tabby-terminal || echo "tabby terminal install failed."
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
        $sudo apt-get update -y
        $sudo apt-get install -y code || echo "vscode install failed."
        echo "vscode installed."
    fi
}

install_wireshark() {
    if command -v wireshark >/dev/null 2>&1; then
        echo "wireshark already installed."
    else
        $sudo apt install -y wireshark || echo "wireshark install failed."
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

install_emdash() {
    APP_DIR="${HOME}/Applications"
    APP_IMAGE="${APP_DIR}/emdash"
    mkdir -p "${APP_DIR}"

    if [ "${arch}" = "amd64" ]; then
      if [ ! -f "${APP_IMAGE}" ]; then
          curl -f https://github.com/generalaction/emdash/releases/latest/download/emdash-x86_64.AppImage -o "${APP_IMAGE}" || echo "emdash install failed."
          chmod +x "${APP_IMAGE}"
          echo "emdash installed."
      else
          echo "emdash already installed."
      fi
    else
        echo "emdash not installed for ${arch} architecture."
    fi
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        echo "ghostty already installed."
        return
    else
    # PPA は amd64 / arm64 両対応 (https://github.com/mkasberg/ghostty-ubuntu)
    $sudo apt-get install -y software-properties-common || echo "software-properties-common install failed."
    $sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
    $sudo apt-get update -y
    $sudo apt-get install -y ghostty || echo "ghostty install failed."
    echo "ghostty installed."
    fi
}

install_zed() {
    echo "checking latest zed..."
    if command -v zed >/dev/null 2>&1; then
        echo "zed already installed."
    else 
        curl -fsSL https://zed.dev/install.sh | sh || echo "zed install failed." 
        echo "zed latest installed."
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
        if ! $sudo apt-get update -y; then
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
    curl -fsSL "${url}" -o "${deb}" || { echo "opencode download failed."; return; }
    $sudo dpkg -i "${deb}" || true
    $sudo apt-get install -f -y || echo "opencode dependency fix failed."
    rm -f "${deb}"
    echo "opencode installed."
}

echo "gui.sh"
echo "--------------------------------"
echo "gui tools setup"
echo "--------------------------------"
# install_brave_browser
# install_element_desktop
# install_ghostty
# install_opencode
# install_tabby_terminal
# install_vscode
# install_wireshark
install_cloudflare_warp
install_cursor
install_github_desktop
install_obsidian
install_ruby_fusuma
install_zed
install_zen

echo "--------------------------------"
echo "desktop setup complete"
echo "--------------------------------"

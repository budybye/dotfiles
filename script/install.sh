#!/bin/sh -ex

sudo snap install codium --classic
echo "### codium installed"

sudo snap install speedtest
echo "### speedtest installed"

# sudo snap remove firefox
# sudo snap install chromium
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser
echo "### brave-browser installed"

curl https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
sudo apt update && sudo apt install -y tabby-terminal
echo "### tabby-terminal installed"

sudo curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt update && sudo apt install -y cloudflare-warp
warp-cli registration new &&
    warp-cli mode warp+doh &&
    warp-cli dns families malware &&
    warp-cli connect
echo "### cloudflare-warp done"

# rustup default stable
cargo install mise
# curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >>~/.zshrc
echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >>~/.zshenv

# sudo install -dm 755 /etc/apt/keyrings
# wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
# echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
# sudo apt update && sudo apt install -y mise

echo "### mise installed"

mise use rust go chezmoi -y
echo "### rust go chezmoi installed"

eval "$(~/.local/bin/mise activate bash)"
eval "$(~/.local/bin/mise activate --shims)"

cargo install starship sheldon fd-find xh bat
echo "### cargo tools installed"

# sudo apt install -y ruby
sudo gem i fusuma
sudo gpasswd -a ${USER} input
fusuma -d
echo "### fusuma done"

go install github.com/aquaproj/aqua/v2/cmd/aqua@latest
aqua init
echo "### aqua installed"

mkcert -install
echo "### mkcert installed"

sudo mkdir -p ${XDG_DATA_HOME}/fonts
sudo curl -L https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_NF_v2.9.0.zip -o ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip
sudo unzip ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip -d ${XDG_DATA_HOME}/fonts
sudo rm -f ${XDG_DATA_HOME}/fonts/HackGen_NF_v2.9.0.zip
sudo curl -L https://github.com/mjun0812/RobotoMonoJP/releases/download/v5.9.0/RobotoMonoJP-Regular.ttf -o ${XDG_DATA_HOME}/fonts/RobotoMonoNerd.ttf
fc-cache -f -v
echo "### Fonts installed"

sudo apt install -y wireshark
sudo usermod -a -G wireshark ubuntu
echo "### wireshark installed"

sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.4.3-linux1/GitHubDesktop-linux-arm64-3.4.3-linux1.deb
sudo dpkg -i GitHubDesktop-linux-arm64-3.4.3-linux1.deb

sudo wget https://github.com/coder/cursor-arm/releases/download/v0.42.2/cursor_0.42.2_linux_arm64.AppImage
sudo chomod a+x cursor_0.42.2_linux_arm64.AppImage
mkdir -p ~/Applications
mv cursor_0.42.2_linux_arm64.AppImage ~/Applications/cursor_0.42.2_linux_arm64.AppImage
# ~/Applications/cursor_0.42.2_linux_arm64.AppImage --no-sandbox

sudo cp ~/data/bg.jpeg /usr/share/backgrounds/bg.jpeg

chezmoi init --apply "${GIT_AUTHOR_NAME}"
echo " ### dotfiles cloned"

sudo chsh -s /bin/zsh ubuntu
echo "### login shell changed to ${SHELL}"

echo "### Finish!! Pleaes reboot"

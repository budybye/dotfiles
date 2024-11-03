#!/usr/bin/env bash
set -ex

echo "### setup ubuntu..."

sudo sed -i 's/^s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true
LANG=C xdg-user-dirs-update --force
im-config -n fcitx5
sudo systemctl restart rsyslog
sudo dpkg --configure -a

echo "### 日本語環境設定完了"

sudo usermod -a -G ssl-cert,xrdp,input,audio ubuntu
sudo ufw allow 3389
sudo systemctl enable xrdp
sudo systemctl start xrdp

echo "### xrdp done"

sudo passwd ubuntu
sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

echo "### xfce4-session done"

# git config --global user.name "${GIT_AUTHOR_NAME}"
# git config --global user.email "${GIT_AUTHOR_EMAIL}"
# gh auth login

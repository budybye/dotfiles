#!/usr/bin/env bash
# スクリプトのデバッグモードを有効にし、エラートレースを表示
set -ex
# ユーザー名を動的に取得
USER_NAME=${SUDO_USER:-$(whoami)}

echo "### Ubuntuのセットアップを開始します..."
# CRDA設定ファイル内のREGDOMAINをJPに変更（存在しない場合は無視）
sudo sed -i 's/^\s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true
# ユーザーディレクトリを強制的に更新
LANG=C xdg-user-dirs-update --force
# 入力メソッドとしてfcitx5を設定
im-config -n fcitx5
echo "### 日本語環境の設定が完了しました"

sudo groupadd -f ssl-cert
sudo groupadd -f xrdp
sudo groupadd -f input
sudo groupadd -f audio
sudo groupadd -f wireshark
sudo groupadd -f docker
# ubuntuユーザーを必要なグループに追加
sudo usermod -aG ssl-cert,xrdp,input,audio,wireshark,docker "${USER_NAME}"
# ファイアウォールで3389番ポート（RDP）を許可
sudo ufw allow 3389
sudo systemctl daemon-reload
# rsyslogサービスを再起動
sudo systemctl restart rsyslog
# xrdpサービスを有効化し、起動
sudo systemctl enable xrdp
sudo systemctl start xrdp
echo "### xrdpの設定が完了しました"
# デフォルトのセッションマネージャーをxfce4-sessionに設定
sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

echo "以下のコマンドを実行してパスワードを更新してください"
echo "sudo passwd ${USER_NAME}"
# ubuntuユーザーのパスワードを設定（対話形式で入力）
# sudo passwd "${USER_NAME}"
echo "### xfce4-sessionの設定が完了しました"

# Gitのグローバル設定（コメントアウトされているので必要に応じて有効化）
# git config --global user.name "${GIT_AUTHOR_NAME}"
# git config --global user.email "${GIT_AUTHOR_EMAIL}"
# GitHub CLIの認証（コメントアウトされているので必要に応じて有効化）
# gh auth login

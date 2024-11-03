#!/usr/bin/env bash
# スクリプトのデバッグモードを有効にし、エラートレースを表示
set -ex

# Ubuntuのセットアップ開始メッセージ
echo "### Ubuntuのセットアップを開始します..."

# CRDA設定ファイル内のREGDOMAINをJPに変更（存在しない場合は無視）
sudo sed -i 's/^\s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true

# ユーザーディレクトリを強制的に更新
LANG=C xdg-user-dirs-update --force

# 入力メソッドとしてfcitx5を設定
im-config -n fcitx5

# rsyslogサービスを再起動
sudo systemctl restart rsyslog

# 未設定のパッケージを設定
sudo dpkg --configure -a

# 日本語環境設定完了メッセージ
echo "### 日本語環境の設定が完了しました"

# ubuntuユーザーを必要なグループに追加
sudo usermod -a -G ssl-cert,xrdp,input,audio ubuntu

# ファイアウォールで3389番ポート（RDP）を許可
sudo ufw allow 3389

# xrdpサービスを有効化し、起動
sudo systemctl enable xrdp
sudo systemctl start xrdp

# xrdpの設定完了メッセージ
echo "### xrdpの設定が完了しました"

# ubuntuユーザーのパスワードを設定（対話形式で入力）
sudo passwd ubuntu

# デフォルトのセッションマネージャーをxfce4-sessionに設定
sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

# xfce4-sessionの設定完了メッセージ
echo "### xfce4-sessionの設定が完了しました"

# Gitのグローバル設定（コメントアウトされているので必要に応じて有効化）
# git config --global user.name "${GIT_AUTHOR_NAME}"
# git config --global user.email "${GIT_AUTHOR_EMAIL}"
# GitHub CLIの認証（コメントアウトされているので必要に応じて有効化）
# gh auth login

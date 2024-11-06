#!/usr/bin/env bash
set -ex

# このスクリプトを実行すると、SSH鍵を生成してGitHubに設定し、
# SSH鍵の管理を行うことができます。

# SSH鍵のファイル名
SSH="${HOME}/.ssh"
# keyの種類
KEY_TYPE="ed25519"
# KEY_TYPE=rsa
KEY_NAME="id_${KEY_TYPE}"
# KEY_NAME="id_rsa"
# SSH鍵のパス
KEY_PATH="${SSH}/${KEY_NAME}"
# GitHubのユーザーネーム
GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-budybye}"
# ユーザー名を動的に取得
USER_NAME=$(whoami)

# SSH用のディレクトリを作成
mkdir -p "${SSH}"
sudo chmod 700 "${SSH}"
# SSH用のディレクトリに移動
cd "${SSH}"
# authorized_keysとconfigファイルを作成
touch authorized_keys
touch config

# configファイルにGitHubのホスト情報を設定
cat <<EOF >"${SSH}/config"
Host github github.com
HostName github.com
IdentityFile "${KEY_PATH}"
User git
EOF

# SSH鍵を生成
if [ ! -f "${KEY_PATH}" ]; then
    ssh-keygen -t "${KEY_TYPE}" -f "${KEY_NAME}" -C "${USER_NAME}" -N ""
else
    echo "SSH key already exists"
fi

# 公開鍵をauthorized_keysファイルに追加
cat "${KEY_PATH}.pub" >>authorized_keys

# 公開鍵をmacのクリップボードにコピー
# ブラウザでgithubログイン画面を開く
case $OSTYPE in
darwin*)
    pbcopy <"${KEY_PATH}.pub"
    open "https://github.com/login?username=${GIT_AUTHOR_NAME}"
    ;;
*)
    echo "Please copy the following public key and add it to your GitHub account:"
    cat "${KEY_PATH}.pub"
    xdg-open "https://github.com/login?username=${GIT_AUTHOR_NAME}"
    ;;
esac

sudo chmod 600 "${SSH}"/*

# GitHubにSSH接続をテスト
# ssh -T git@github.com

# SSHエージェントを起動
eval "$(ssh-agent)"

# SSH鍵をエージェントに登録
ssh-add "${KEY_PATH}"

# 登録したSSH鍵の一覧を表示
ssh-add -l

# SSHエージェントを停止
eval "$(ssh-agent -k)"

# ホームディレクトリに移動
cd "${HOME}"
tree "${SSH}"

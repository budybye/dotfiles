#!/usr/bin/env bash
set -ex

SSH="${HOME}/.ssh"
KEY_TYPE="ed25519"
KEY_NAME="id_${KEY_TYPE}"
KEY_PATH="${SSH}/${KEY_NAME}"
# GitHubのユーザーネーム
GIT_USER="${GIT_USER:-budybye}"

# SSH用のディレクトリを作成
mkdir -p "${SSH}"
# authorized_keysとconfigとknown_hostsファイルを作成
sudo chmod 700 "${SSH}"
touch "${SSH}/authorized_keys"
touch "${SSH}/config"
touch "${SSH}/known_hosts"

# configファイルにGitHubのホスト情報を設定
cat <<EOF >"${SSH}/config"
Host github github.com
HostName github.com
IdentityFile "${KEY_PATH}"
User git
EOF

# SSH鍵を生成
if [ ! -f "${KEY_PATH}" ]; then
    ssh-keygen -t "${KEY_TYPE}" -f "${KEY_NAME}" -C "" -N ""
else
    echo "SSH key already exists"
fi

# 公開鍵をauthorized_keysファイルに追加
cat "${KEY_PATH}.pub" >>"${SSH}/authorized_keys"

ls -la "${SSH}"
cat "${SSH}/config"
cat "${SSH}/authorized_keys"
cat "${SSH}/known_hosts"

# 公開鍵をコピー
# ブラウザでgithubログイン画面を開く
case "${OSTYPE}" in
    darwin*)
        pbcopy <"${KEY_PATH}.pub"
        open "https://github.com/login?username=${GIT_USER}"
        ;;
    *)
        cat "${KEY_PATH}.pub"
        xdg-open "https://github.com/login?username=${GIT_USER}"
        ;;
esac

sudo chmod 600 "${SSH}"
sudo chmod 644 "${KEY_PATH}.pub"

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

echo "${KEY_PATH} done"

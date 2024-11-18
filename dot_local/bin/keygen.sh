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
# authorized_keysとconfigファイルを作成
sudo chmod 700 "${SSH}"
touch "${SSH}/authorized_keys"

# configファイルにGitHubのホスト情報を設定
cat <<EOF >"${SSH}/config"
Host github github.com
HostName github.com
IdentityFile "${KEY_PATH}"
User git
EOF

ls -la "${SSH}"

cd "${SSH}"

if [ ! -f "${KEY_PATH}.pub" ]; then
    echo "SSH public key already exists"
else
    sudo cp "${KEY_PATH}.pub" "${KEY_PATH}.pub.copy"
    rm -rf "${KEY_PATH}.pub"
fi

# SSH鍵を生成
if [ ! -f "${KEY_PATH}" ]; then
    ssh-keygen -t "${KEY_TYPE}" -f "${KEY_NAME}" -C "" -N ""
else
    echo "SSH key already exists"
    sudo cp "${KEY_PATH}" "${KEY_PATH}.copy"
    rm -rf "${KEY_PATH}.pub"
    ssh-keygen -t "${KEY_TYPE}" -f "${KEY_NAME}" -C "" -N ""
fi

# 公開鍵をauthorized_keysファイルに追加
cat "${KEY_PATH}.pub" >>"${SSH}/authorized_keys"

ls -la "${SSH}"
cat "${SSH}/config"
cat "${SSH}/authorized_keys"

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

chmod 600 "${KEY_PATH}"
chmod 600 "${SSH}/authorized_keys"
chmod 644 "${KEY_PATH}.pub"

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

cd "${HOME}"
ls -la "${SSH}"

echo "${KEY_PATH} done"

#!/bin/sh -ex

# このスクリプトを実行すると、SSH鍵を生成してGitHubに設定し、
# SSH鍵の管理を行うことができます。鍵のファイル名やパスは、
# シェル変数として定義されているため、必要に応じて変更できます。

# SSH鍵のファイル名
# KeyName="id_rsa"
KeyName="id_ed25519"
# SSH鍵のパス
KeyPath="${HOME}/.ssh/${KeyName}"
# GitHubのユーザーネーム
GitUser=budybye
# keyの種類
KeyType=ed25519

# SSH用のディレクトリを作成
mkdir -pm 700 "${HOME}/.ssh"

# SSH用のディレクトリに移動
cd "${HOME}/.ssh"

# authorized_keysとconfigファイルを作成
touch authorized_keys
touch config

# configファイルにGitHubのホスト情報を設定
cat <<EOF >${HOME}/.ssh/config
Host github github.com
HostName github.com
IdentityFile $KeyPath
User git
EOF

# SSH鍵を生成
if [ ! -f ${KeyPath} ]; then
    ssh-keygen -t ${KeyType} -f ${KeyName}
else
    echo "SSH key already exists"
fi

# 公開鍵をauthorized_keysファイルに追加
cat "${KeyPath}.pub" >> authorized_keys

# 公開鍵をmacのクリップボードにコピー
if [[ $OSTYPE == darwin* ]]; then
    pbcopy <"${KeyPath}.pub"
else
    echo "Please copy the following public key and add it to your GitHub account:"
    cat "${KeyPath}.pub"
fi

# ブラウザでgithubログイン画面を開く
if [[ $OSTYPE == darwin* ]]; then
    open https://github.com/login?username=$GitUser
else
    xdg-open https://github.com/login?username=$GitUser
fi

chmod 600 *

# GitHubにSSH接続をテスト
ssh -T git@github.com

# SSHエージェントを起動
eval "$(ssh-agent)"

# SSH鍵をエージェントに登録
ssh-add "${KeyPath}"

# 登録したSSH鍵の一覧を表示
ssh-add -l

# SSHエージェントを停止
eval "$(ssh-agent -k)"

# SSH秘密鍵を暗号化する
# sudo mkdir -p "/usr/bin/ksshaskpass"
# export SSH_ASKPASS="/usr/bin/ksshaskpass"

# ホームディレクトリに移動
cd "${HOME}"

#!/bin/bash

# xrdp サービスを開始
start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid

    # Use exec ... to forward SIGNAL to child processes
    xrdp-sesman && exec xrdp -n
}

# error が発生した場合に xrdp サービスを停止
stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

# エントリーポイントスクリプトが実行されたことを通知
echo Entryponit script is Running...
echo

# cmd の引数を3つ指定 ユーザー名 パスワード スーパーユーザーかどうか
# デフォルトは CMD["ubuntu", "ubuntu", "no"]

users=$(($#/3))
mod=$(($# % 3))

# echo "users is $users"
# echo "mod is $mod"

if [[ $# -eq 0 ]]; then
    echo "No input parameters. exiting..."
    echo "there should be 3 input parameters per user"
    exit
fi

if [[ $mod -ne 0 ]]; then
    echo "incorrect input. exiting..."
    echo "there should be 3 input parameters per user"
    exit
fi
echo "You entered $users users"

# 引数をループしてユーザーを作成
while [ $# -ne 0 ]; do

    # グループを作成 ユーザー名と同じグループ名
    addgroup $1
    # echo "username is $1"
    # useradd -m -s /bin/bash -g $1 $1
    if [ $(command -v zsh) ]; then
        useradd -m -s /usr/bin/zsh -g $1 $1
    else
        useradd -m -s /bin/bash -g $1 $1
    fi

    # パスワードを設定
    # getent passwd | grep $1
    echo $1:$2 | chpasswd
    wait

    # スーパーユーザーかどうか
    echo "sudo is $3"
    if [[ $3 == "yes" ]]; then
        usermod -aG sudo $1
    fi
    wait
    echo "user '$1' is added"

    # Shift all the parameters down by three
    shift 3
done

addgroup dev
wait
useradd -m -s /bin/bash -g dev dev
wait
echo dev:dev | chpasswd
wait
usermod -aG sudo dev

echo -e "starting xrdp services...\n"

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services

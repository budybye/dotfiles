#!/usr/bin/env bash

# ユーザーを作成して xrdp サービスを開始する
# 引数
# $1: ユーザー名
# $2: パスワード
# $3: スーパーユーザーかどうか yes or other

# root ユーザーで実行された場合は sudo をつけない
pwd
sudo="sudo"
if [ "$(whoami)" = "root" ]; then
    echo "running root user"
    sudo=""
fi

# xrdp サービスを開始
start_xrdp_services() {
    # Preventing xrdp startup failure
    $sudo rm -rf /var/run/xrdp-sesman.pid
    $sudo rm -rf /var/run/xrdp.pid
    $sudo rm -rf /var/run/xrdp/xrdp-sesman.pid
    $sudo rm -rf /var/run/xrdp/xrdp.pid

    # Use exec ... to forward SIGNAL to child processes
    $sudo xrdp-sesman && exec $sudo xrdp -n
}

# error が発生した場合に xrdp サービスを停止
stop_xrdp_services() {
    $sudo xrdp --kill
    $sudo xrdp-sesman --kill
    exit 0
}

# Docker では Chezmoi の Linux setup hook を除外するため、
# xrdp が使う XFCE X11 セッションをここで用意する。
configure_xsession() {
    local user_name="$1"
    local user_home="/home/${user_name}"

    $sudo tee "${user_home}/.xsession" >/dev/null <<'XSESSION'
#!/bin/sh
if command -v pipewire >/dev/null 2>&1; then
    pipewire &
    wireplumber &
    pipewire-pulse &
fi
exec dbus-run-session -- xfce4-session
XSESSION
    $sudo chown "${user_name}:${user_name}" "${user_home}/.xsession"
    $sudo chmod 700 "${user_home}/.xsession"
}

# エントリーポイントスクリプトが実行されたことを通知
echo Entryponit script is Running...
echo

# 引数の数を3で割った商をusersに格納
users=$(($#/3))
# 引数の数を3で割った余りをmodに格納
mod=$(($# % 3))
# echo "users is $users"
# echo "mod is $mod"

# 引数が0の場合は終了
if [[ $# -eq 0 ]]; then
    echo "No input parameters. exiting..."
    echo "there should be 3 input parameters per user"
    exit
fi

# 引数が3の倍数でない場合は終了
if [[ $mod -ne 0 ]]; then
    echo "incorrect input. exiting..."
    echo "there should be 3 input parameters per user"
    exit
fi
echo "You entered ${users} user(s)"

# 引数をループしてユーザーを作成
while [ $# -ne 0 ]; do

    # 既存の Ubuntu イメージでも安全に再実行できるようにする
    if ! $sudo getent group "$1" >/dev/null 2>&1; then
        $sudo addgroup "$1"
    fi
    
    if ! $sudo id "$1" >/dev/null 2>&1; then
        if [ "$(command -v zsh)" ]; then
            $sudo useradd -m -s "$(command -v zsh)" -g "$1" "$1"
        else
            $sudo useradd -m -s /bin/bash -g "$1" "$1"
        fi
    fi
    wait

    # パスワードを設定
    # getent passwd | grep $1
    echo "$1":"$2" | $sudo chpasswd
    wait

    # スーパーユーザーかどうか
    # echo "sudo is $3"
    if [[ $3 == "yes" ]]; then
        $sudo usermod -aG sudo "$1"
    fi
    configure_xsession "$1"
    wait
    # echo "user '$1' is added"

    # Shift all the parameters down by three
    shift 3
done

echo -e "starting xrdp services...\n"
echo "RDP_PORT is ${RDP_PORT:-3389}"

# SIGKILL/SIGSTOP は trap 不可
trap "stop_xrdp_services" SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services

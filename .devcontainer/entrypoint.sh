#!/usr/bin/env bash

echo "entrypoint.sh..."
ls -la
ls -la dotfiles

echo "chezmoi init..."
chezmoi init --help

echo "env..."
env

# # コンテナを実行し続けるためのプロセス
# exec tail -f /dev/null

# CMDで指定されたコマンドを実行 /bin/bash を指定しているので、コンテナが起動したままになる
exec "$@"

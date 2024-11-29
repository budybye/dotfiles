#!/usr/bin/env bash

# コンテナ起動時に /sbin/init を実行 systemd を使いたい
# /sbin/init &

# デバッグ情報の出力（必要に応じて）
echo "entrypoint.sh..."
uname -a
ls -la
ls -la dotfiles

echo "chezmoi init..."
chezmoi init --help

echo "env..."
env

# Dockerfileで指定されたCMDを実行
exec "$@"

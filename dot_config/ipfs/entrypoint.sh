#!/bin/sh
set -eu

# IPFS_PATHの設定ファイルのパス設定
# export IPFS_PATH=${HOME}.config/ipfs

# # IPFSの初期化 (既に初期化されている場合はスキップ)
if [ ! -f "$IPFS_PATH/config" ]; then
    ipfs init --profile server 2>/dev/null 1>dev/null
fi

# ipfs config show

# /exportをIPFSに追加 --offline
ipfs add "/export" -r --cid-version=1
# ipfs add /export --offline -r --quieter --cid-version=1
# CID=$(ipfs add "/export" -r --cid-version=1 | awk '{print $2}' | head -n 1)
# ipfs name publish ${CID} --allow-offline

ipfs daemon

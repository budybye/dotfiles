#!/bin/sh
set -eu

# IPFS_PATHの設定ファイルのパス設定
# export IPFS_PATH=${HOME}.config/.ipfs

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


# PrivateなPeerに設定する場合
# export PRIVATE_PEER_IP=
# export PRIVATE_PEER_IP_ADDR=

# 既存のbootstrapノードを全て削除
# ipfs bootstrap rm all

# 新しいbootstrapノードを追加
# この部分は環境変数PRIVATE_PEER_IP_ADDRとPRIVATE_PEER_IDが設定されていることを前提としています
# ipfs bootstrap add "/ip4/$PRIVATE_PEER_IP_ADDR/tcp/4001/ipfs/$PRIVATE_PEER_ID"

# IPFSデーモンの起動
ipfs daemon

#!/usr/bin/env bash

set -euo pipefail

# XRPL エンドポイント
# XRPL_ENDPOINT="https://s1.ripple.com:51234/"
XRPL_ENDPOINT="https://xrplcluster.com/"
ACCOUNT="rf1BiGeXwwQoi8Z2ueFYTEXSwuJYfV2Jpn"
# 通貨の発行者 bitstamp
ISSUER="rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"
LIMIT=1

# book_offers リクエストデータ
GET_USD_OFFERS='{
    "method": "book_offers",
    "params": [{
        "taker": "'$ACCOUNT'",
        "taker_gets": {"currency": "XRP"},
        "taker_pays": {
            "currency": "USD",
            "issuer": "'$ISSUER'"
        },
        "limit": '$LIMIT'
    }]
}'

# 手数料を取得
GET_FEE='{
    "method": "fee",
    "params": [{}]
}'

# USD/XRP の quality を取得して 1,000,000 倍にする
USD_XRP_QUALITY=$(curl -s -X POST "$XRPL_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "$GET_USD_OFFERS" | \
    jq -r '.result.offers[].quality | (tonumber * 1000000)')

# LedgerIndex を取得
LEDGER_INDEX=$(curl -s -X POST "$XRPL_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "$GET_FEE" | \
    jq -r '.result.ledger_current_index')

# fee リクエストを一度だけ実行し、必要な情報を取得
FEE_RESPONSE=$(curl -s -X POST "$XRPL_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "$GET_FEE")

# LedgerIndex を取得
LEDGER_INDEX=$(echo "$FEE_RESPONSE" | jq -r '.result.ledger_current_index')

# open_ledger_fee を取得
OPEN_LEDGER_FEE=$(echo "$FEE_RESPONSE" | jq -r '.result.drops.open_ledger_fee')

# 結果を表示
echo "XRP/USD: $USD_XRP_QUALITY"
echo "LedgerIndex: $LEDGER_INDEX"
echo "Fee: $OPEN_LEDGER_FEE"

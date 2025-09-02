#!/usr/bin/env bash

set -e

# XRP Ledger public server
XRPL_SERVER="${XRPL_SERVER:-https://xrpl.ws}"

# $1: account
# $2: currency
# $3: issuer
# $4: limit

# default account ripple
ACCOUNT="${1:-${ACCOUNT:-r3kmLJN5D28dHuH8vZNUZpMC43pEHpaocV}}"

# default bithomp usd
ISSUER="${2:-${ISSUER:-rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B}}"
# ISSUER="${2:-${rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De}}"
CURRENCY="${3:-${CURRENCY:-USD}}"
# CURRENCY="${3:-${RLUSD}}"

# book_offers xrp/currency grpc request json
GET_USD_OFFERS='{
    "method": "book_offers",
    "params": [{
        "taker": "'$ACCOUNT'",
        "taker_gets": {"currency": "XRP"},
        "taker_pays": {
            "currency": "'$CURRENCY'",
            "issuer": "'$ISSUER'"
        },
        "limit": 1
    }]
}'

# fee grpc request json
GET_FEE='{"method": "fee","params": [{}]}'
# account_info grpc request json
GET_ACCOUNT_INFO='{"method": "account_info","params": [{"account": "'$ACCOUNT'"}]}'

grpc_request() {
    if command -v curl > /dev/null 2>&1 ; then
        curl -s -X POST "$XRPL_SERVER" \
            -H "Content-Type: application/json" \
            -d "$1"
    else
        echo "curl is not installed"
        exit
    fi
}

# get offers
OFFER_RESPONSE=$(grpc_request "$GET_USD_OFFERS")
# get fee
FEE_RESPONSE=$(grpc_request "$GET_FEE")
# get account info
ACCOUNT_INFO_RESPONSE=$(grpc_request "$GET_ACCOUNT_INFO")

if command -v jq > /dev/null 2>&1 ; then
    # get quality and multiply by 1,000,000
    XRP_CURRENCY_QUALITY=$(echo "$OFFER_RESPONSE" | jq -r '.result.offers[].quality | (tonumber * 1000000)')
    # get ledger_current_index
    LEDGER_INDEX=$(echo "$FEE_RESPONSE" | jq -r '.result.ledger_current_index')
    # get open_ledger_fee
    OPEN_LEDGER_FEE=$(echo "$FEE_RESPONSE" | jq -r '.result.drops.open_ledger_fee')
    # get balance
    ACCOUNT_BALANCE=$(echo "$ACCOUNT_INFO_RESPONSE" | jq -r '.result.account_data.Balance | (tonumber / 1000000)')

    # json pretty print
    echo "$FEE_RESPONSE" | jq '.result'
    echo "$OFFER_RESPONSE" | jq '.result'
    echo "$ACCOUNT_INFO_RESPONSE" | jq '.result'
else
    echo "jq is not installed"
    exit
fi

echo "__  ______  ____    _             _"
echo "\ \/ /  _ \|  _ \  | |    ___  __| | __ _  ___ _ __"
echo " \  /| |_) | |_) | | |   / _ \/ _\` |/ _\` |/ _ \ '__|"
echo " /  \|  _ <|  __/  | |__|  __/ (_| | (_| |  __/ |"
echo "/_/\_\_| \_\_|     |_____\___|\__,_|\__, |\___|_|"
echo "                                    |___/"
echo "UTC: $(LC_ALL=C; date -u +%Y%m%dT%H%M%SZ)"
echo "Rippled Server: $XRPL_SERVER"
echo "LedgerIndex: $LEDGER_INDEX"
echo "OpenLedgerFee: $OPEN_LEDGER_FEE drops"
echo "Account: $ACCOUNT"
echo "XRP/$CURRENCY: \$$XRP_CURRENCY_QUALITY"
echo "Balance: $ACCOUNT_BALANCE XRP"
echo "Price($CURRENCY): $(echo "$ACCOUNT_BALANCE * $XRP_CURRENCY_QUALITY" | bc) $CURRENCY"
# echo "AccountInfo: $(echo "$ACCOUNT_INFO_RESPONSE" | jq '.result.account_data')"

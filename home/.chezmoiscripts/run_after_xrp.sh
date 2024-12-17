#!/usr/bin/env bash

# XRP Ledger public server
XRPL_SERVER="${XRPL_SERVER:-https://xrpl.ws/}"
# r3kmLJN5D28dHuH8vZNUZpMC43pEHpaocV
ACCOUNT="${1:-r9BUM9z14j7bLFzQHRfurWNdNKYSABdGtE}"
# default bithomp usd
ISSUER="${2:-rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B}"
# ISSUER="${2:-rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De}"
# default usd
CURRENCY="${3:-USD}"
# CURRENCY="${3:-RLUSD}"

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
    # LEDGER_INDEX=$(echo "$OFFER_RESPONSE" | jq -r '.result.ledger_current_index')
    # LEDGER_INDEX=$(echo "$ACCOUNT_INFO_RESPONSE" | jq -r '.result.ledger_current_index')

    # get open_ledger_fee
    OPEN_LEDGER_FEE=$(echo "$FEE_RESPONSE" | jq -r '.result.drops.open_ledger_fee')

    # get balance
    ACCOUNT_BALANCE=$(echo "$ACCOUNT_INFO_RESPONSE" | jq -r '.result.account_data.Balance | (tonumber / 1000000)')

else
    echo "jq is not installed"
    exit
fi

# show price, index, fee, account, balance
cat << 'EOF'
__  ______  ____    _             _
\ \/ /  _ \|  _ \  | |    ___  __| | __ _  ___ _ __
 \  /| |_) | |_) | | |   / _ \/ _` |/ _` |/ _ \ '__|
 /  \|  _ <|  __/  | |__|  __/ (_| | (_| |  __/ |
/_/\_\_| \_\_|     |_____\___|\__,_|\__, |\___|_|
                                    |___/
EOF

echo "Rippled: $XRPL_SERVER"
echo "XRP/$CURRENCY: \$$XRP_CURRENCY_QUALITY"
# echo "$OFFER_RESPONSE" | jq '.result'
echo "LedgerIndex: $LEDGER_INDEX"
echo "Fee: $OPEN_LEDGER_FEE"
echo "Account: $ACCOUNT"
echo "Balance: $ACCOUNT_BALANCE XRP"
# echo "$ACCOUNT_INFO_RESPONSE" | jq '.result'
echo "--------------------------------"

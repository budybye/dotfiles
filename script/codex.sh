#!/bin/sh -ex

# extensions.jsonのパス
CODEX="${XDG_CONFIG_HOME}/vscode/extensions.json"

# インストールされている拡張機能を"extension.json"の形式で出力する
echo '{"recommendations": [],"unwantedRecommendations":[]}' > $CODEX
code --list-extensions | xargs -I {} sh -c "cat $CODEX | jq '.recommendations |= .+[\"{}\"]' > temp && mv temp $CODEX"

echo 'done!'

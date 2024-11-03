#!/usr/bin/env/ bash -ex

# extensions.jsonのパス
CODEX="${XDG_CONFIG_HOME}/vscode/extensions.json"

# extensions.jsonディレクトリの作成
mkdir -p "${XDG_CONFIG_HOME}/vscode/User"
# mkdir -p "${XDG_CONFIG_HOME}/.vscode/User"
# mkdir -p "${XDG_CONFIG_HOME}/VSCodium/User"
# mkdir -p "${XDG_CONFIG_HOME}/Cursor/User"
# mkdir -p "${XDG_DATA_HOME}/vscode/user-data/User"

# extensions.jsonが存在する場合はバックアップを作成
if [ -f "${CODEX}" ]; then
    cp "${CODEX}" "${CODEX}.copy"
    echo "バックアップを作成しました: ${CODEX}.copy"
fi

# インストールされている拡張機能を"extensions.json"の形式で出力する
echo '{"recommendations": [],"unwantedRecommendations":[]}' > "${CODEX}"
code --list-extensions | xargs -I {} sh -c "jq '.recommendations += [\"{}\"]' ${CODEX} > temp && mv temp ${CODEX}"

echo '拡張機能の更新が完了しました!'

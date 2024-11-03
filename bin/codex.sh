#!/usr/bin/env bash
set -ex

# extensions.jsonディレクトリの作成
mkdir -p "${XDG_CONFIG_HOME}/vscode/User"

# extensions.jsonのパス
CODEX="${XDG_CONFIG_HOME}/vscode/extensions.json"

# settings.jsonのパス
SETTINGS_JSON="${XDG_CONFIG_HOME}/vscode/User/settings.json"

# extensions.jsonが存在する場合はバックアップを作成
if [ -f "${CODEX}" ]; then
    cp "${CODEX}" "${CODEX}.copy"
    echo "バックアップを作成しました: ${CODEX}.copy"
fi

# インストールされている拡張機能を"extensions.json"の形式で出力する
echo '{"recommendations": [],"unwantedRecommendations":[]}' >"${CODEX}"
code --list-extensions | xargs -I {} sh -c "jq '.recommendations += [\"{}\"]' ${CODEX} > temp && mv temp ${CODEX}"

echo '拡張機能の更新が完了しました!'

# settings.jsonのバックアップと更新

# settings.jsonが存在する場合はバックアップを作成
if [ -f "${SETTINGS_JSON}" ]; then
    cp "${SETTINGS_JSON}" "${SETTINGS_JSON}.copy"
    echo "バックアップを作成しました: ${SETTINGS_JSON}.copy"
else
    echo "settings.jsonが存在しません。"
    mkdir -p "$(dirname "${SETTINGS_JSON}")"
    cp "${HOME}/.config/vscode/User/settings.json" "${SETTINGS_JSON}"
    echo "新しいsettings.jsonを作成しました。"
fi

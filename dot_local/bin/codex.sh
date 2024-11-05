#!/usr/bin/env bash
set -ex

# 設定ファイルの場所
CODE_DIR="${XDG_CONFIG_HOME}/vscode"
# extensions.jsonディレクトリの作成
mkdir -p "${CODE_DIR}/User"
# extensions.jsonのパス
CODEX="${CODE_DIR}/extensions.json"
# settings.jsonのパス
SETTINGS_JSON="${CODE_DIR}/User/settings.json"

KEYBINDINGS_JSON="${CODE_DIR}/User/keybindings.json"

# extensions.jsonが存在する場合はバックアップを作成
if [ -f "${CODEX}" ]; then
    cp "${CODEX}" "${CODEX}.copy"
    echo "バックアップを作成しました: ${CODEX}.copy"
fi

if ! command -v code >/dev/null 1>&2; then
    echo "VScodeが存在しません。"
else
    # インストールされている拡張機能を"extensions.json"の形式で出力する
    echo '{"recommendations": [],"unwantedRecommendations":[]}' >"${CODEX}"
    code --list-extensions | xargs -I {} sh -c "jq '.recommendations += [\"{}\"]' ${CODEX} > temp && mv temp ${CODEX}"
    echo '拡張機能の更新が完了しました!'
fi

# settings.jsonが存在する場合はバックアップを作成
if [ -f "${SETTINGS_JSON}" ]; then
    cp "${SETTINGS_JSON}" "${SETTINGS_JSON}.copy"
    echo "バックアップを作成しました: ${SETTINGS_JSON}.copy"
else
    echo "${SETTING_JSON}が存在しません。"
    mkdir -p "$(dirname "${SETTINGS_JSON}")"
    cp "${XGD_DATA_HOME}/vscode/user-data/User/settings.json" "${SETTINGS_JSON}"
    echo "新しい${SETTING_JSON}を作成しました。"
fi

# keybindings.jsonが存在する場合はバックアップを作成
if [ -f "${KEYBINDINGS_JSON}" ]; then
    cp "${KEYBINDINGS_JSON}" "${KEYBINDINGS_JSON}.copy"
    echo "バックアップを作成しました: ${KEYBINDINGS_JSON}.copy"
else
    echo "${SEKEYBINDINGS_JSONTTING_JSON}が存在しません。"
    mkdir -p "$(dirname "${KEYBINDINGS_JSON}")"
    cp "${XGD_DATA_HOME}/vscode/user-data/User/keybindings.json" "${KEYBINDINGS_JSON}"
    echo "新しい${KEYBINDINGS_JSON}を作成しました。"
fi

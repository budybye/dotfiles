#!/usr/bin/env bash
set -ex

# 管理下の設定ファイルの場所
FROM="${HOME}/.local/share/vscode"

# 環境によって変わる 設定ファイルの場所
if command -v cursor >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.local/share/Cursor"
    CODE_CMD="cursor"
elif [ -f "${HOME}/Applications/cursor" ]; then
    CODE_DIR="${HOME}/.local/share/Cursor"
    CODE_CMD="${HOME}/Applications/cursor --no-sandbox"
elif command -v codium >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.config/VSCodium"
    CODE_CMD="codium"
else
    CODE_DIR="${HOME}/.config/vscode"
    CODE_CMD="code"
fi

# VSCodeのUserディレクトリの作成
sudo mkdir -p "${CODE_DIR}/User"

extensions_json() {
    # extensions.jsonのパス
    CODEX="${CODE_DIR}/extensions.json"
    # extensions.jsonが存在する場合はバックアップを作成
    if [ -f "${CODEX}" ]; then
        cp "${CODEX}" "${CODEX}.copy"
        echo "バックアップを作成しました: ${CODEX}.copy"
    fi

    if ! command -v "${CODE_CMD}" >/dev/null 1>&2; then
        echo "${CODE_CMD}が存在しません。"
        sudo cp "${FROM}/extensions.json" "${CODEX}"
        echo "新しい ${CODEX} を作成しました。"
    else
        # インストールされている拡張機能を"extensions.json"の形式で出力する
        echo '{"recommendations": [],"unwantedRecommendations":[]}' >"${CODEX}"
        sudo "${CODE_CMD}" --list-extensions | xargs -I {} sh -c "jq '.recommendations += [\"{}\"]' ${CODEX} > temp && mv temp ${CODEX}"
        echo '拡張機能の更新が完了しました!'
    fi
    cat "${CODEX}"
}

settings_json() {
    # settings.jsonのパス
    SETTINGS_JSON="${CODE_DIR}/User/settings.json"
    # settings.jsonが存在する場合はバックアップを作成
    if [ -f "${SETTINGS_JSON}" ]; then
        sudo cp "${SETTINGS_JSON}" "${SETTINGS_JSON}.copy"
        echo "バックアップを作成しました: ${SETTINGS_JSON}.copy"
    else
        echo "${SETTINGS_JSON}が存在しません。"
        sudo mkdir -p "$(dirname "${SETTINGS_JSON}")"
    fi
    sudo cp "${FROM}/user-data/User/settings.json" "${SETTINGS_JSON}"
    echo "新しい ${SETTINGS_JSON} を作成しました。"
    cat "${SETTINGS_JSON}"
}

keybindings_json() {
    # keybindings.jsonのパス
    KEYBINDINGS_JSON="${CODE_DIR}/User/keybindings.json"
    # keybindings.jsonが存在する場合はバックアップを作成
    if [ -f "${KEYBINDINGS_JSON}" ]; then
        sudo cp "${KEYBINDINGS_JSON}" "${KEYBINDINGS_JSON}.copy"
        echo "バックアップを作成しました: ${KEYBINDINGS_JSON}.copy"
    else
        echo "${KEYBINDINGS_JSON}が存在しません。"
        sudo mkdir -p "$(dirname "${KEYBINDINGS_JSON}")"
    fi
    sudo cp "${FROM}/user-data/User/keybindings.json" "${KEYBINDINGS_JSON}"
    echo "新しい ${KEYBINDINGS_JSON} を作成しました。"
    cat "${KEYBINDINGS_JSON}"
}

main() {
    echo "VSCodeの設定を開始します。"
    extensions_json
    settings_json
    keybindings_json
    ls -l "${CODE_DIR}"
    echo "VSCodeの設定が完了しました。"
}

main

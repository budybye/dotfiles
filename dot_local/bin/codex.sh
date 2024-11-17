#!/usr/bin/env bash
set -ex

# 管理下の設定ファイルの場所
FROM="${HOME}/.config/vscode"

# 環境によって変わる 設定ファイルの場所
if command -v cursor >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.local/share/Cursor"
elif [ -f "${HOME}/Applications/cursor" ]; then
    CODE_DIR="${HOME}/.local/share/Cursor"
elif command -v codium >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.config/VSCodium"
elif command -v code >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.local/share/vscode"
fi

# VSCodeのUserディレクトリの作成
sudo mkdir -p "${CODE_DIR}/User"

# 設定ファイルをバックアップし、新しいファイルを作成する汎用関数
copy_json_file() {
    local json_type="$1"  # 'settings' または 'keybindings'
    local from_file="${FROM}/user-data/User/${json_type}.json"
    local target_file="${CODE_DIR}/User/${json_type}.json"

    # json_fileが存在する場合はバックアップを作成
    if [ -f "${target_file}" ]; then
        sudo cp "${target_file}" "${target_file}.copy"
        echo "バックアップを作成しました: ${target_file}.copy"
    else
        echo "${target_file}が存在しません。"
    fi

    sudo ln -sf "${from_file}" "${target_file}"
    echo "新しい ${target_file} を作成しました。"
    cat "${target_file}"
}

extensions_json() {
    # extensions.jsonのパス
    CODEX="${CODE_DIR}/extensions.json"
    # extensions.jsonが存在する場合はバックアップを作成
    if [ -f "${CODEX}" ]; then
        sudo cp "${CODEX}" "${CODEX}.copy"
        echo "バックアップを作成しました: ${CODEX}.copy"
    fi

    if ! command -v "code" >/dev/null 1>&2; then
        echo "VSCodeが存在しません。"
        sudo ln -sf "${FROM}/extensions.json" "${CODEX}"
        echo "新しい ${CODEX} を作成しました。"
    else
        # インストールされている拡張機能を"extensions.json"の形式で出力する
        echo '{"recommendations": [],"unwantedRecommendations":[]}' | sudo tee "${CODEX}" > /dev/null
        sudo "code" --list-extensions | xargs -I {} sh -c "jq '.recommendations += [\"{}\"]' ${CODEX} | sudo tee temp > /dev/null && sudo mv temp ${CODEX}"
        echo '拡張機能の更新が完了しました!'
    fi
    cat "${CODEX}"
}

main() {
    echo "VSCodeの設定を開始します..."
    copy_json_file "settings"
    copy_json_file "keybindings"
    extensions_json
    tree "${CODE_DIR}"
    echo "VSCodeの設定が完了しました。"
}

main

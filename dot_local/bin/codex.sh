#!/usr/bin/env bash
set -ex

# 管理下の設定ファイルの場所
FROM="${HOME}/.local/share/vscode"

# 環境によって変わる 設定ファイルの場所
if command -v cursor >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.local/share/Cursor"
elif [ -f "${HOME}/Applications/cursor" ]; then
    CODE_DIR="${HOME}/.local/share/Cursor"
elif command -v codium >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.config/VSCodium"
elif command -v code >/dev/null 2>&1; then
    CODE_DIR="${HOME}/.config/vscode"
fi

# VSCodeのUserディレクトリの作成
sudo mkdir -p "${CODE_DIR}/User"

# 設定ファイルをバックアップし、新しいファイルを作成する汎用関数
copy_json_file() {
    local json_type="$1"  # 'settings' または 'keybindings'
    local json_file="${CODE_DIR}/User/${json_type}.json"
    local from_file="${FROM}/user-data/User/${json_type}.json"

    # json_fileが存在する場合はバックアップを作成
    if [ -f "${json_file}" ]; then
        sudo cp "${json_file}" "${json_file}.copy"
        echo "バックアップを作成しました: ${json_file}.copy"
    else
        echo "${json_file}が存在しません。"
        sudo mkdir -p "$(dirname "${json_file}")"
    fi

    sudo cp "${from_file}" "${json_file}"
    echo "新しい ${json_file} を作成しました。"
    cat "${json_file}"
}

extensions_json() {
    # extensions.jsonのパス
    CODEX="${CODE_DIR}/extensions.json"
    # extensions.jsonが存在する場合はバックアップを作成
    if [ -f "${CODEX}" ]; then
        cp "${CODEX}" "${CODEX}.copy"
        echo "バックアップを作成しました: ${CODEX}.copy"
    fi

    if ! command -v "code" >/dev/null 1>&2; then
        echo "VSCodeが存在しません。"
        sudo cp "${FROM}/extensions.json" "${CODEX}"
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
    extensions_json
    copy_json_file "settings"
    copy_json_file "keybindings"
    tree "${CODE_DIR}"
    echo "VSCodeの設定が完了しました。"
}

main
